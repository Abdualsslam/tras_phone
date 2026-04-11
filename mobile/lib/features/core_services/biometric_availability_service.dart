library;

import '../../core/services/biometric_credential_service.dart';
import '../../core/services/biometric_service.dart';

class BiometricAvailabilityService {
  final BiometricService _biometricService;
  final BiometricCredentialService _credentialService;

  BiometricAvailabilityService({
    required BiometricService biometricService,
    required BiometricCredentialService credentialService,
  }) : _biometricService = biometricService,
       _credentialService = credentialService;

  Future<bool> canUseBiometricLogin() async {
    final biometricAvailable = await _biometricService.isAvailable();
    final biometricEnabled = await _biometricService.isEnabled();
    final hasCredentials = await _credentialService.hasCredentials();

    return biometricAvailable && biometricEnabled && hasCredentials;
  }
}
