library;

import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../config/app_config.dart';
import '../constants/api_endpoints.dart';
import '../errors/exceptions.dart';
import '../network/api_client.dart';
import 'app_security_models.dart';

class AppSecurityService {
  AppSecurityService({required ApiClient apiClient}) : _apiClient = apiClient;

  static const MethodChannel _channel = MethodChannel('com.trasphone/security');

  final ApiClient _apiClient;
  Future<void>? _warmUpFuture;

  Future<AppSecurityAssessment> evaluateStartupRisk() async {
    final signals = await _collectLocalSignals();
    return _buildAssessment(signals);
  }

  Future<void> warmUpIntegrityProvider() async {
    if (!Platform.isAndroid || AppConfig.playIntegrityCloudProjectNumber.isEmpty) {
      return;
    }

    _warmUpFuture ??= _prepareIntegrityProvider();
    await _warmUpFuture;
  }

  Future<DeviceIntegrityPayload> buildAuthIntegrityPayload({
    required String requestType,
  }) async {
    final signals = await _collectLocalSignals();
    final assessment = _buildAssessment(signals);

    if (assessment.shouldBlock) {
      throw const ForbiddenException(
        message: 'تم رفض تشغيل التطبيق على هذا الجهاز لوجود مؤشرات عبث عالية الخطورة',
      );
    }

    String? nonce;
    String? integrityToken;

    final challenge = await _requestChallenge(requestType: requestType);
    nonce = challenge.nonce;
    final requestHash = _buildRequestHash(
      requestType: requestType,
      nonce: nonce,
      packageName: signals.packageName,
      appVersion: signals.appVersion,
    );

    if (Platform.isAndroid && AppConfig.playIntegrityCloudProjectNumber.isNotEmpty) {
      try {
        await warmUpIntegrityProvider();
        integrityToken = await _channel.invokeMethod<String>(
          'requestIntegrityToken',
          {'requestHash': requestHash},
        );
      } catch (error, stackTrace) {
        developer.log(
          'Play Integrity request failed',
          name: 'AppSecurityService',
          error: error,
          stackTrace: stackTrace,
        );

        if (AppConfig.securityEnforcementEnabled) {
          throw const ForbiddenException(
            message: 'تعذر التحقق من موثوقية التطبيق على هذا الجهاز',
          );
        }
      }
    }

    return DeviceIntegrityPayload(
      platform: signals.platform,
      requestType: requestType,
      requestHash: requestHash,
      nonce: nonce,
      integrityToken: integrityToken,
      packageName: signals.packageName,
      appVersion: signals.appVersion,
      localSignals: signals,
    );
  }

  Future<LocalSecuritySignals> _collectLocalSignals() async {
    try {
      if (!Platform.isAndroid) {
        final packageInfo = await PackageInfo.fromPlatform();
        return LocalSecuritySignals(
          platform: Platform.operatingSystem,
          isDebuggable: false,
          isDebuggerAttached: false,
          isEmulator: false,
          hasTestKeys: false,
          hasRootFiles: false,
          hasMagiskFiles: false,
          hasHookFramework: false,
          hasFridaServer: false,
          packageName: packageInfo.packageName,
          appVersion: packageInfo.version,
          issues: const <String>[],
        );
      }

      final raw = await _channel.invokeMapMethod<Object?, Object?>(
        'getSecuritySignals',
      );

      if (raw == null) {
        throw PlatformException(code: 'security/signals-null');
      }

      return LocalSecuritySignals.fromJson(raw);
    } catch (error, stackTrace) {
      developer.log(
        'Falling back to restricted security state',
        name: 'AppSecurityService',
        error: error,
        stackTrace: stackTrace,
      );

      final packageInfo = await PackageInfo.fromPlatform();
      return LocalSecuritySignals(
        platform: Platform.operatingSystem,
        isDebuggable: false,
        isDebuggerAttached: false,
        isEmulator: false,
        hasTestKeys: false,
        hasRootFiles: false,
        hasMagiskFiles: false,
        hasHookFramework: false,
        hasFridaServer: false,
        packageName: packageInfo.packageName,
        appVersion: packageInfo.version,
        issues: const <String>['security_signals_unavailable'],
      );
    }
  }

  AppSecurityAssessment _buildAssessment(LocalSecuritySignals signals) {
    final reasons = <String>[
      ...signals.issues,
    ];

    final isBlocked =
        signals.isDebuggable ||
        signals.isDebuggerAttached ||
        signals.hasRootFiles ||
        signals.hasMagiskFiles ||
        signals.hasHookFramework ||
        signals.hasFridaServer;

    final isRestricted = isBlocked || signals.isEmulator || signals.hasTestKeys;

    return AppSecurityAssessment(
      status: isBlocked
          ? AppSecurityStatus.blocked
          : isRestricted
          ? AppSecurityStatus.restricted
          : AppSecurityStatus.trusted,
      signals: signals,
      reasons: reasons,
      enforcementEnabled: AppConfig.securityEnforcementEnabled,
    );
  }

  Future<void> _prepareIntegrityProvider() async {
    try {
      await _channel.invokeMethod<void>('prepareIntegrityTokenProvider', {
        'cloudProjectNumber': AppConfig.playIntegrityCloudProjectNumber,
      });
    } finally {
      _warmUpFuture = null;
    }
  }

  Future<DeviceIntegrityChallenge> _requestChallenge({
    required String requestType,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.deviceIntegrityChallenge,
      data: {'requestType': requestType},
    );

    return DeviceIntegrityChallenge.fromJson(
      Map<String, dynamic>.from(response.data as Map),
    );
  }

  String _buildRequestHash({
    required String requestType,
    required String nonce,
    required String? packageName,
    required String? appVersion,
  }) {
    final source =
        '$requestType|$nonce|${packageName ?? 'unknown'}|${appVersion ?? 'unknown'}';
    final digest = sha256.convert(utf8.encode(source));
    return base64UrlEncode(digest.bytes).replaceAll('=', '');
  }
}
