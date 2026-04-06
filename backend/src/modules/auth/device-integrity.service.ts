import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { createHash, createHmac, createSign, timingSafeEqual } from 'crypto';
import {
  AUTH_ERROR_CODES,
  buildAuthUnauthorizedException,
} from './auth-errors';
import { DeviceIntegrityDto, DeviceSecuritySignalsDto } from './dto/device-integrity.dto';

export type SessionTrustStatus = 'trusted' | 'restricted' | 'blocked';

export interface DeviceTrustVerdict {
  status: SessionTrustStatus;
  reasons: string[];
  platform: string;
  requestType?: string;
  packageName?: string;
  appVersion?: string;
  appRecognitionVerdict?: string;
  deviceRecognitionVerdicts?: string[];
  licensingVerdict?: string;
  verifiedAt?: Date;
}

type GoogleAccessTokenCache = {
  accessToken: string;
  expiresAt: number;
};

@Injectable()
export class DeviceIntegrityService {
  private googleAccessTokenCache?: GoogleAccessTokenCache;

  constructor(private readonly configService: ConfigService) {}

  createChallenge(requestType: string) {
    const now = Date.now();
    const payload = {
      requestType,
      issuedAt: now,
      expiresAt: now + 5 * 60 * 1000,
    };
    const encodedPayload = this.toBase64Url(JSON.stringify(payload));
    const signature = this.signChallenge(encodedPayload);

    return {
      nonce: `${encodedPayload}.${signature}`,
      expiresAt: new Date(payload.expiresAt).toISOString(),
    };
  }

  async evaluate(payload?: DeviceIntegrityDto): Promise<DeviceTrustVerdict> {
    if (!payload) {
      return {
        status: this.isEnforced() ? 'blocked' : 'restricted',
        reasons: ['device_integrity_missing'],
        platform: 'unknown',
      };
    }

    const localVerdict = this.evaluateSignals(payload.signals);
    if (localVerdict.status === 'blocked') {
      return {
        ...localVerdict,
        requestType: payload.requestType,
        packageName: payload.packageName ?? payload.signals.packageName,
        appVersion: payload.appVersion ?? payload.signals.appVersion,
      };
    }

    if (
      payload.platform.toLowerCase() !== 'android' ||
      !this.expectedPackageName()
    ) {
      return {
        ...localVerdict,
        requestType: payload.requestType,
        packageName: payload.packageName ?? payload.signals.packageName,
        appVersion: payload.appVersion ?? payload.signals.appVersion,
      };
    }

    const noncePayload = this.verifyChallengeNonce(
      payload.nonce,
      payload.requestType,
    );
    const expectedPackageName = this.expectedPackageName();
    const effectivePackageName =
      payload.packageName ?? payload.signals.packageName ?? '';
    const effectiveAppVersion =
      payload.appVersion ?? payload.signals.appVersion ?? '';

    if (effectivePackageName && effectivePackageName !== expectedPackageName) {
      return {
        status: 'blocked',
        reasons: ['package_name_mismatch'],
        platform: payload.platform,
        requestType: payload.requestType,
        packageName: effectivePackageName,
        appVersion: effectiveAppVersion,
      };
    }

    const expectedRequestHash = this.buildRequestHash({
      requestType: payload.requestType,
      nonce: payload.nonce ?? noncePayload.originalNonce,
      packageName: expectedPackageName,
      appVersion: effectiveAppVersion,
    });

    if (payload.requestHash !== expectedRequestHash) {
      return {
        status: 'blocked',
        reasons: ['request_hash_mismatch'],
        platform: payload.platform,
        requestType: payload.requestType,
        packageName: effectivePackageName,
        appVersion: effectiveAppVersion,
      };
    }

    if (!payload.integrityToken) {
      return {
        status: this.isEnforced() ? 'blocked' : 'restricted',
        reasons: ['integrity_token_missing'],
        platform: payload.platform,
        requestType: payload.requestType,
        packageName: effectivePackageName,
        appVersion: effectiveAppVersion,
      };
    }

    if (!this.isGoogleVerificationConfigured()) {
      return {
        status: this.isEnforced() ? 'blocked' : 'restricted',
        reasons: ['play_integrity_not_configured'],
        platform: payload.platform,
        requestType: payload.requestType,
        packageName: effectivePackageName,
        appVersion: effectiveAppVersion,
      };
    }

    const decodedVerdict = await this.decodeIntegrityToken(
      payload.integrityToken,
    );
    const tokenPayload = decodedVerdict?.tokenPayloadExternal ?? {};
    const requestDetails = tokenPayload.requestDetails ?? {};
    const appIntegrity = tokenPayload.appIntegrity ?? {};
    const deviceIntegrity = tokenPayload.deviceIntegrity ?? {};
    const accountDetails = tokenPayload.accountDetails ?? {};
    const verdictReasons = [...localVerdict.reasons];
    const recognitionVerdict = appIntegrity.appRecognitionVerdict as
      | string
      | undefined;
    const deviceRecognitionVerdicts = Array.isArray(
      deviceIntegrity.deviceRecognitionVerdict,
    )
      ? deviceIntegrity.deviceRecognitionVerdict.map(String)
      : [];

    if (requestDetails.requestPackageName !== expectedPackageName) {
      verdictReasons.push('request_package_name_mismatch');
    }

    if (requestDetails.requestHash !== expectedRequestHash) {
      verdictReasons.push('play_request_hash_mismatch');
    }

    const timestampMillis = Number(requestDetails.timestampMillis ?? 0);
    if (
      Number.isFinite(timestampMillis) &&
      timestampMillis > 0 &&
      Date.now() - timestampMillis > 10 * 60 * 1000
    ) {
      verdictReasons.push('integrity_token_expired');
    }

    if (recognitionVerdict !== 'PLAY_RECOGNIZED') {
      verdictReasons.push('app_not_play_recognized');
    }

    if (
      !deviceRecognitionVerdicts.includes('MEETS_DEVICE_INTEGRITY') &&
      !deviceRecognitionVerdicts.includes('MEETS_STRONG_INTEGRITY')
    ) {
      if (deviceRecognitionVerdicts.includes('MEETS_BASIC_INTEGRITY')) {
        verdictReasons.push('device_integrity_basic_only');
      } else {
        verdictReasons.push('device_integrity_failed');
      }
    }

    const status: SessionTrustStatus = verdictReasons.some((reason) =>
      [
        'request_package_name_mismatch',
        'play_request_hash_mismatch',
        'integrity_token_expired',
        'app_not_play_recognized',
        'device_integrity_failed',
      ].includes(reason),
    )
      ? 'blocked'
      : verdictReasons.includes('device_integrity_basic_only')
      ? 'restricted'
      : 'trusted';

    return {
      status,
      reasons: verdictReasons,
      platform: payload.platform,
      requestType: payload.requestType,
      packageName: effectivePackageName || expectedPackageName,
      appVersion: effectiveAppVersion,
      appRecognitionVerdict: recognitionVerdict,
      deviceRecognitionVerdicts,
      licensingVerdict: accountDetails.appLicensingVerdict,
      verifiedAt: new Date(),
    };
  }

  assertTrusted(verdict: DeviceTrustVerdict) {
    if (verdict.status === 'trusted') {
      return;
    }

    if (this.isEnforced()) {
      throw buildAuthUnauthorizedException({
        code: AUTH_ERROR_CODES.DEVICE_NOT_TRUSTED,
      });
    }
  }

  private evaluateSignals(signals: DeviceSecuritySignalsDto): DeviceTrustVerdict {
    const reasons = [...signals.issues];
    const blocked =
      signals.isDebuggable ||
      signals.isDebuggerAttached ||
      signals.hasRootFiles ||
      signals.hasMagiskFiles ||
      signals.hasHookFramework ||
      signals.hasFridaServer;

    if (signals.isDebuggable) reasons.push('debuggable_build');
    if (signals.isDebuggerAttached) reasons.push('debugger_attached');
    if (signals.hasRootFiles) reasons.push('root_artifacts_detected');
    if (signals.hasMagiskFiles) reasons.push('magisk_artifacts_detected');
    if (signals.hasHookFramework) reasons.push('hook_framework_detected');
    if (signals.hasFridaServer) reasons.push('frida_server_detected');
    if (signals.isEmulator) reasons.push('emulator_detected');
    if (signals.hasTestKeys) reasons.push('test_keys_detected');

    return {
      status: blocked
        ? 'blocked'
        : signals.isEmulator || signals.hasTestKeys || reasons.length > 0
        ? 'restricted'
        : 'trusted',
      reasons: [...new Set(reasons)],
      platform: signals.platform,
      packageName: signals.packageName,
      appVersion: signals.appVersion,
    };
  }

  private verifyChallengeNonce(nonce: string | undefined, requestType: string) {
    if (!nonce) {
      throw buildAuthUnauthorizedException({
        code: AUTH_ERROR_CODES.DEVICE_NOT_TRUSTED,
      });
    }

    const [encodedPayload, receivedSignature] = nonce.split('.');
    if (!encodedPayload || !receivedSignature) {
      throw buildAuthUnauthorizedException({
        code: AUTH_ERROR_CODES.DEVICE_NOT_TRUSTED,
      });
    }

    const expectedSignature = this.signChallenge(encodedPayload);
    if (!this.compareSafe(expectedSignature, receivedSignature)) {
      throw buildAuthUnauthorizedException({
        code: AUTH_ERROR_CODES.DEVICE_NOT_TRUSTED,
      });
    }

    const payload = JSON.parse(
      Buffer.from(encodedPayload, 'base64url').toString('utf8'),
    ) as {
      requestType: string;
      issuedAt: number;
      expiresAt: number;
    };

    if (payload.requestType !== requestType || payload.expiresAt < Date.now()) {
      throw buildAuthUnauthorizedException({
        code: AUTH_ERROR_CODES.DEVICE_NOT_TRUSTED,
      });
    }

    return {
      ...payload,
      originalNonce: nonce,
    };
  }

  private buildRequestHash(params: {
    requestType: string;
    nonce: string;
    packageName: string;
    appVersion: string;
  }) {
    return createHash('sha256')
      .update(
        `${params.requestType}|${params.nonce}|${params.packageName}|${params.appVersion}`,
      )
      .digest('base64url');
  }

  private signChallenge(payload: string) {
    return createHmac('sha256', this.challengeSecret())
      .update(payload)
      .digest('base64url');
  }

  private challengeSecret() {
    return this.configService.get<string>(
      'DEVICE_INTEGRITY_SECRET',
      this.configService.get<string>('JWT_SECRET', 'trasphone-device-integrity'),
    );
  }

  private compareSafe(a: string, b: string) {
    const left = Buffer.from(a);
    const right = Buffer.from(b);

    if (left.length !== right.length) {
      return false;
    }

    return timingSafeEqual(left, right);
  }

  private async decodeIntegrityToken(integrityToken: string) {
    const accessToken = await this.getGoogleAccessToken();
    const response = await fetch(
      `https://playintegrity.googleapis.com/v1/${this.expectedPackageName()}:decodeIntegrityToken`,
      {
        method: 'POST',
        headers: {
          Authorization: `Bearer ${accessToken}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ integrity_token: integrityToken }),
      },
    );

    if (!response.ok) {
      const responseText = await response.text();
      throw new Error(`Play Integrity decode failed: ${response.status} ${responseText}`);
    }

    return response.json();
  }

  private async getGoogleAccessToken() {
    if (
      this.googleAccessTokenCache &&
      this.googleAccessTokenCache.expiresAt > Date.now() + 60_000
    ) {
      return this.googleAccessTokenCache.accessToken;
    }

    const clientEmail = this.googleServiceAccountEmail();
    const privateKey = this.googleServiceAccountPrivateKey();
    if (!clientEmail || !privateKey) {
      throw new Error('Google service account is not configured for Play Integrity');
    }

    const now = Math.floor(Date.now() / 1000);
    const header = this.toBase64Url(JSON.stringify({ alg: 'RS256', typ: 'JWT' }));
    const claim = this.toBase64Url(
      JSON.stringify({
        iss: clientEmail,
        scope: 'https://www.googleapis.com/auth/playintegrity',
        aud: 'https://oauth2.googleapis.com/token',
        exp: now + 3600,
        iat: now,
      }),
    );

    const signer = createSign('RSA-SHA256');
    signer.update(`${header}.${claim}`);
    signer.end();

    const signature = signer.sign(privateKey).toString('base64url');
    const assertion = `${header}.${claim}.${signature}`;

    const response = await fetch('https://oauth2.googleapis.com/token', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: new URLSearchParams({
        grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer',
        assertion,
      }),
    });

    if (!response.ok) {
      const responseText = await response.text();
      throw new Error(`Google OAuth token fetch failed: ${response.status} ${responseText}`);
    }

    const data = (await response.json()) as {
      access_token: string;
      expires_in: number;
    };

    this.googleAccessTokenCache = {
      accessToken: data.access_token,
      expiresAt: Date.now() + data.expires_in * 1000,
    };

    return data.access_token;
  }

  private googleServiceAccountEmail() {
    return this.configService.get<string>(
      'GOOGLE_SERVICE_ACCOUNT_CLIENT_EMAIL',
      this.configService.get<string>('FCM_CLIENT_EMAIL', ''),
    );
  }

  private googleServiceAccountPrivateKey() {
    return this.configService
      .get<string>(
        'GOOGLE_SERVICE_ACCOUNT_PRIVATE_KEY',
        this.configService.get<string>('FCM_PRIVATE_KEY', ''),
      )
      ?.replace(/\\n/g, '\n');
  }

  private expectedPackageName() {
    return this.configService.get<string>(
      'PLAY_INTEGRITY_PACKAGE_NAME',
      'com.example.tras_phone',
    );
  }

  private isGoogleVerificationConfigured() {
    return Boolean(
      this.expectedPackageName() &&
        this.googleServiceAccountEmail() &&
        this.googleServiceAccountPrivateKey(),
    );
  }

  private isEnforced() {
    const raw = this.configService.get<string>(
      'MOBILE_SECURITY_ENFORCEMENT',
      this.configService.get<string>('NODE_ENV') === 'production'
        ? 'true'
        : 'false',
    );
    return raw === 'true';
  }

  private toBase64Url(value: string) {
    return Buffer.from(value).toString('base64url');
  }
}
