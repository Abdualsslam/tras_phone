/// Biometric Service - Handles biometric authentication
library;

import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';
import '../storage/local_storage.dart';
import '../constants/storage_keys.dart';

class BiometricService {
  final LocalAuthentication _localAuth;
  final LocalStorage _localStorage;

  BiometricService({
    required LocalAuthentication localAuth,
    required LocalStorage localStorage,
  })  : _localAuth = localAuth,
        _localStorage = localStorage;

  /// Check if biometric authentication is available on the device
  Future<bool> isAvailable() async {
    try {
      final isAvailable = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      return isAvailable && isDeviceSupported;
    } catch (e) {
      return false;
    }
  }

  /// Get available biometric types
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }

  /// Check if biometric is enabled by user
  Future<bool> isEnabled() async {
    return _localStorage.getBool(StorageKeys.biometricEnabled) ?? false;
  }

  /// Enable/disable biometric authentication
  Future<void> setEnabled(bool enabled) async {
    await _localStorage.setBool(StorageKeys.biometricEnabled, enabled);
  }

  /// Verify identity for setup (e.g. when enabling biometric) - does not check isEnabled
  Future<bool> verifyIdentityForSetup({
    String localizedReason = 'يرجى التحقق من هويتك لتفعيل البصمة',
    bool useErrorDialogs = true,
  }) async {
    try {
      final isAvailable = await this.isAvailable();
      if (!isAvailable) {
        return false;
      }

      final didAuthenticate = await _localAuth.authenticate(
        localizedReason: localizedReason,
        options: AuthenticationOptions(
          useErrorDialogs: useErrorDialogs,
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      return didAuthenticate;
    } on PlatformException {
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Authenticate using biometric
  Future<bool> authenticate({
    String localizedReason = 'يرجى التحقق من هويتك للمتابعة',
    bool useErrorDialogs = true,
    bool stickyAuth = true,
  }) async {
    try {
      final isAvailable = await this.isAvailable();
      if (!isAvailable) {
        return false;
      }

      final isEnabled = await this.isEnabled();
      if (!isEnabled) {
        return false;
      }

      final didAuthenticate = await _localAuth.authenticate(
        localizedReason: localizedReason,
        options: AuthenticationOptions(
          useErrorDialogs: useErrorDialogs,
          stickyAuth: stickyAuth,
          biometricOnly: true,
        ),
      );

      return didAuthenticate;
    } on PlatformException {
      // Handle platform-specific errors
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Stop authentication (if in progress)
  Future<void> stopAuthentication() async {
    try {
      await _localAuth.stopAuthentication();
    } catch (e) {
      // Ignore errors
    }
  }
}
