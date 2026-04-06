import { Test } from '@nestjs/testing';
import { ConfigService } from '@nestjs/config';
import { DeviceIntegrityService } from './device-integrity.service';

describe('DeviceIntegrityService', () => {
  let service: DeviceIntegrityService;

  beforeEach(async () => {
    const moduleRef = await Test.createTestingModule({
      providers: [
        DeviceIntegrityService,
        {
          provide: ConfigService,
          useValue: {
            get: jest.fn((key: string, defaultValue?: string) => {
              const values: Record<string, string> = {
                NODE_ENV: 'development',
                MOBILE_SECURITY_ENFORCEMENT: 'false',
                PLAY_INTEGRITY_PACKAGE_NAME: 'com.example.tras_phone',
                DEVICE_INTEGRITY_SECRET: 'secret',
              };

              return values[key] ?? defaultValue;
            }),
          },
        },
      ],
    }).compile();

    service = moduleRef.get(DeviceIntegrityService);
  });

  it('creates a nonce challenge with expiration', () => {
    const challenge = service.createChallenge('auth.login');

    expect(challenge.nonce).toContain('.');
    expect(challenge.expiresAt).toBeTruthy();
  });

  it('blocks rooted local signals immediately', async () => {
    const verdict = await service.evaluate({
      platform: 'android',
      requestType: 'auth.login',
      requestHash: 'ignored',
      nonce: 'ignored',
      signals: {
        platform: 'android',
        isDebuggable: false,
        isDebuggerAttached: false,
        isEmulator: false,
        hasTestKeys: false,
        hasRootFiles: true,
        hasMagiskFiles: false,
        hasHookFramework: false,
        hasFridaServer: false,
        issues: [],
      },
    });

    expect(verdict.status).toBe('blocked');
    expect(verdict.reasons).toContain('root_artifacts_detected');
  });

  it('marks an Android payload as blocked when the request hash is invalid', async () => {
    const challenge = service.createChallenge('auth.login');

    const verdict = await service.evaluate({
      platform: 'android',
      requestType: 'auth.login',
      requestHash: 'invalid',
      nonce: challenge.nonce,
      packageName: 'com.example.tras_phone',
      appVersion: '1.0.0',
      signals: {
        platform: 'android',
        isDebuggable: false,
        isDebuggerAttached: false,
        isEmulator: false,
        hasTestKeys: false,
        hasRootFiles: false,
        hasMagiskFiles: false,
        hasHookFramework: false,
        hasFridaServer: false,
        issues: [],
      },
    });

    expect(verdict.status).toBe('blocked');
    expect(verdict.reasons).toContain('request_hash_mismatch');
  });
});
