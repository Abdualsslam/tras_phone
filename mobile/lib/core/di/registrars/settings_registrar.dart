library;

import 'package:get_it/get_it.dart';
import 'package:local_auth/local_auth.dart';

import '../../cubit/theme_cubit.dart';
import '../../services/biometric_credential_service.dart';
import '../../services/biometric_service.dart';
import '../../services/share_service.dart';
import '../../storage/local_storage.dart';
import '../../storage/secure_storage.dart';
import '../../../features/core_services/biometric_availability_service.dart';

void registerSettingsDependencies(GetIt getIt) {
  getIt.registerLazySingleton<ThemeCubit>(
    () => ThemeCubit(localStorage: getIt<LocalStorage>())..loadSavedTheme(),
  );
  getIt.registerLazySingleton<BiometricService>(
    () => BiometricService(
      localAuth: LocalAuthentication(),
      localStorage: getIt<LocalStorage>(),
    ),
  );
  getIt.registerLazySingleton<BiometricCredentialService>(
    () => BiometricCredentialService(secureStorage: getIt<SecureStorage>()),
  );
  getIt.registerLazySingleton<BiometricAvailabilityService>(
    () => BiometricAvailabilityService(
      biometricService: getIt<BiometricService>(),
      credentialService: getIt<BiometricCredentialService>(),
    ),
  );
  getIt.registerLazySingleton<ShareService>(ShareService.new);
}
