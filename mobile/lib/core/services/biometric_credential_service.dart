/// Biometric Credential Service - Secure storage for biometric login credentials
library;

import '../constants/storage_keys.dart';
import '../storage/secure_storage.dart';

class BiometricCredentialService {
  final SecureStorage _secureStorage;

  BiometricCredentialService({required SecureStorage secureStorage})
      : _secureStorage = secureStorage;

  /// Save credentials for biometric login
  Future<void> saveCredentials({
    required String phone,
    required String password,
  }) async {
    await _secureStorage.write(StorageKeys.biometricPhone, phone);
    await _secureStorage.write(StorageKeys.biometricPassword, password);
  }

  /// Get stored credentials for biometric login
  Future<({String phone, String password})?> getCredentials() async {
    final phone = await _secureStorage.read(StorageKeys.biometricPhone);
    final password = await _secureStorage.read(StorageKeys.biometricPassword);

    if (phone != null &&
        phone.isNotEmpty &&
        password != null &&
        password.isNotEmpty) {
      return (phone: phone, password: password);
    }
    return null;
  }

  /// Check if credentials are stored
  Future<bool> hasCredentials() async {
    final credentials = await getCredentials();
    return credentials != null;
  }

  /// Clear stored credentials (on logout or when disabling biometric)
  Future<void> clearCredentials() async {
    await _secureStorage.delete(StorageKeys.biometricPhone);
    await _secureStorage.delete(StorageKeys.biometricPassword);
  }
}
