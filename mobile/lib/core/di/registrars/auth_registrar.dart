library;

import 'package:get_it/get_it.dart';

import '../../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../../features/auth/domain/repositories/auth_repository.dart';
import '../../../features/auth/domain/services/auth_device_info_service.dart';
import '../../../features/auth/domain/services/auth_lifecycle_coordinator.dart';
import '../../../features/auth/domain/services/auth_notification_navigation_service.dart';
import '../../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../network/api_client.dart';
import '../../network/token_manager.dart';
import '../../security/app_security_service.dart';
import '../../services/biometric_service.dart';
import '../../storage/local_storage.dart';
import '../../storage/secure_storage.dart';
import '../../../features/cart/presentation/cubit/cart_cubit.dart';
import '../../../features/catalog/data/services/product_cache_service.dart';
import '../../../features/favorite/data/services/favorite_cache_service.dart';
import '../../../features/home/data/services/home_cache_service.dart';
import '../../../features/notifications/services/push_notification_manager.dart';
import '../../../features/profile/presentation/cubit/profile_cubit.dart';

void registerAuthDependencies(GetIt getIt) {
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      apiClient: getIt<ApiClient>(),
      appSecurityService: getIt<AppSecurityService>(),
    ),
  );

  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      dataSource: getIt<AuthRemoteDataSource>(),
      localStorage: getIt<LocalStorage>(),
      secureStorage: getIt<SecureStorage>(),
    ),
  );

  getIt.registerLazySingleton<AuthDeviceInfoService>(
    AuthDeviceInfoService.new,
  );
  getIt.registerLazySingleton<AuthNotificationNavigationService>(
    AuthNotificationNavigationService.new,
  );
  getIt.registerLazySingleton<AuthLifecycleCoordinator>(
    () => AuthLifecycleCoordinator(
      productCacheService: getIt<ProductCacheService>(),
      homeCacheService: getIt<HomeCacheService>(),
      favoriteCacheService: getIt<FavoriteCacheService>(),
      profileCubit: getIt<ProfileCubit>(),
      addressesCubit: getIt<AddressesCubit>(),
      pushNotificationManager: getIt<PushNotificationManager>(),
      cartCubit: getIt<CartCubit>(),
      tokenManager: getIt<TokenManager>(),
      deviceInfoService: getIt<AuthDeviceInfoService>(),
    ),
  );

  getIt.registerFactory<AuthCubit>(
    () => AuthCubit(
      repository: getIt<AuthRepository>(),
      biometricService: getIt<BiometricService>(),
      lifecycleCoordinator: getIt<AuthLifecycleCoordinator>(),
      notificationNavigationService:
          getIt<AuthNotificationNavigationService>(),
    ),
  );
}
