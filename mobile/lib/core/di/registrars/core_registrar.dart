library;

import 'package:get_it/get_it.dart';

import '../../cache/hive_cache_service.dart';
import '../../config/app_config.dart';
import '../../network/api_client.dart';
import '../../network/network_info.dart';
import '../../network/token_manager.dart';
import '../../security/app_security_service.dart';
import '../../storage/local_storage.dart';
import '../../storage/secure_storage.dart';
import '../../../features/favorite/data/services/favorite_cache_service.dart';
import '../../../features/home/data/services/home_cache_service.dart';
import '../../../features/catalog/data/services/product_cache_service.dart';

Future<void> registerCoreDependencies(
  GetIt getIt, {
  required Future<void> Function() onForcedLogout,
}) async {
  final localStorage = LocalStorage();
  await localStorage.init();
  getIt.registerSingleton<LocalStorage>(localStorage);

  final secureStorage = SecureStorage();
  getIt.registerSingleton<SecureStorage>(secureStorage);

  final tokenManager = TokenManager(secureStorage: secureStorage);
  getIt.registerSingleton<TokenManager>(tokenManager);

  getIt.registerSingleton<NetworkInfo>(NetworkInfoImpl());

  final apiClient = ApiClient(localStorage: localStorage);
  apiClient.initialize(
    tokenManager: tokenManager,
    onLogout: onForcedLogout,
    enableLogging: AppConfig.enableNetworkLogging,
  );
  getIt.registerSingleton<ApiClient>(apiClient);
  getIt.registerLazySingleton<AppSecurityService>(
    () => AppSecurityService(apiClient: getIt<ApiClient>()),
  );

  final hiveCacheService = HiveCacheService();
  await hiveCacheService.init();
  getIt.registerSingleton<HiveCacheService>(hiveCacheService);

  getIt.registerSingleton<HomeCacheService>(HomeCacheService(hiveCacheService));
  getIt.registerSingleton<ProductCacheService>(
    ProductCacheService(hiveCacheService),
  );
  getIt.registerSingleton<FavoriteCacheService>(
    FavoriteCacheService(hiveCacheService),
  );
}
