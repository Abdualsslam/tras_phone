/// Dependency Injection setup using get_it
library;

import 'package:get_it/get_it.dart';
import '../network/api_client.dart';
import '../network/network_info.dart';
import '../storage/local_storage.dart';
import '../storage/secure_storage.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  // ═══════════════════════════════════════════════════════════════════════════
  // CORE DEPENDENCIES
  // ═══════════════════════════════════════════════════════════════════════════

  // Storage
  final localStorage = LocalStorage();
  await localStorage.init();
  getIt.registerSingleton<LocalStorage>(localStorage);
  getIt.registerSingleton<SecureStorage>(SecureStorage());

  // Network
  getIt.registerSingleton<NetworkInfo>(NetworkInfoImpl());
  getIt.registerSingleton<ApiClient>(ApiClient());

  // ═══════════════════════════════════════════════════════════════════════════
  // FEATURE DEPENDENCIES
  // Will be registered when each feature is implemented
  // ═══════════════════════════════════════════════════════════════════════════

  // Auth
  // getIt.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(...));
  // getIt.registerFactory(() => AuthCubit(getIt()));

  // Catalog
  // getIt.registerLazySingleton<CatalogRepository>(() => CatalogRepositoryImpl(...));
  // getIt.registerFactory(() => CatalogCubit(getIt()));

  // Cart
  // getIt.registerLazySingleton<CartRepository>(() => CartRepositoryImpl(...));
  // getIt.registerFactory(() => CartCubit(getIt()));

  // Orders
  // getIt.registerLazySingleton<OrdersRepository>(() => OrdersRepositoryImpl(...));
  // getIt.registerFactory(() => OrdersCubit(getIt()));
}
