/// Dependency Injection setup using get_it
library;

import 'package:get_it/get_it.dart';
import '../network/api_client.dart';
import '../network/network_info.dart';
import '../network/token_manager.dart';
import '../storage/local_storage.dart';
import '../storage/secure_storage.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/catalog/data/datasources/catalog_remote_datasource.dart';
import '../../features/catalog/data/repositories/catalog_repository_impl.dart';
import '../../features/catalog/domain/repositories/catalog_repository.dart';
import '../../features/catalog/presentation/cubit/brands_cubit.dart';
import '../../features/catalog/presentation/cubit/categories_cubit.dart';
import '../../features/catalog/presentation/cubit/devices_cubit.dart';
import '../../features/catalog/presentation/cubit/quality_types_cubit.dart';
import '../../features/cart/data/datasources/cart_remote_datasource.dart';
import '../../features/orders/data/datasources/orders_remote_datasource.dart';
import '../../features/profile/data/datasources/profile_remote_datasource.dart';
import '../../features/wishlist/data/datasources/wishlist_remote_datasource.dart';
import '../../features/notifications/data/datasources/notifications_remote_datasource.dart';
import '../../features/returns/data/datasources/returns_remote_datasource.dart';
import '../../features/support/data/datasources/support_remote_datasource.dart';
import '../../features/reviews/data/datasources/reviews_remote_datasource.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  // ═══════════════════════════════════════════════════════════════════════════
  // CORE DEPENDENCIES
  // ═══════════════════════════════════════════════════════════════════════════

  // Storage
  final localStorage = LocalStorage();
  await localStorage.init();
  getIt.registerSingleton<LocalStorage>(localStorage);

  final secureStorage = SecureStorage();
  getIt.registerSingleton<SecureStorage>(secureStorage);

  // Token Manager
  final tokenManager = TokenManager(secureStorage: secureStorage);
  getIt.registerSingleton<TokenManager>(tokenManager);

  // Network
  getIt.registerSingleton<NetworkInfo>(NetworkInfoImpl());

  // API Client with interceptors
  final apiClient = ApiClient();
  apiClient.initialize(
    tokenManager: tokenManager,
    onLogout: _handleForcedLogout,
    enableLogging: true, // Set to false in production
  );
  getIt.registerSingleton<ApiClient>(apiClient);

  // ═══════════════════════════════════════════════════════════════════════════
  // AUTH FEATURE
  // ═══════════════════════════════════════════════════════════════════════════

  // DataSources
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(apiClient: getIt<ApiClient>()),
  );

  // Repository
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      dataSource: getIt<AuthRemoteDataSource>(),
      localStorage: getIt<LocalStorage>(),
      secureStorage: getIt<SecureStorage>(),
    ),
  );

  // Cubit
  getIt.registerFactory<AuthCubit>(
    () => AuthCubit(repository: getIt<AuthRepository>()),
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // CATALOG FEATURE
  // ═══════════════════════════════════════════════════════════════════════════

  // DataSources
  getIt.registerLazySingleton<CatalogRemoteDataSource>(
    () => CatalogRemoteDataSourceImpl(apiClient: getIt<ApiClient>()),
  );

  // Repository
  getIt.registerLazySingleton<CatalogRepository>(
    () => CatalogRepositoryImpl(
      remoteDataSource: getIt<CatalogRemoteDataSource>(),
    ),
  );

  // Cubits
  getIt.registerFactory<BrandsCubit>(
    () => BrandsCubit(repository: getIt<CatalogRepository>()),
  );

  getIt.registerFactory<BrandDetailsCubit>(
    () => BrandDetailsCubit(repository: getIt<CatalogRepository>()),
  );

  getIt.registerFactory<CategoriesCubit>(
    () => CategoriesCubit(repository: getIt<CatalogRepository>()),
  );

  getIt.registerFactory<CategoryTreeCubit>(
    () => CategoryTreeCubit(repository: getIt<CatalogRepository>()),
  );

  getIt.registerFactory<CategoryDetailsCubit>(
    () => CategoryDetailsCubit(repository: getIt<CatalogRepository>()),
  );

  getIt.registerFactory<CategoryChildrenCubit>(
    () => CategoryChildrenCubit(repository: getIt<CatalogRepository>()),
  );

  getIt.registerFactory<DevicesCubit>(
    () => DevicesCubit(repository: getIt<CatalogRepository>()),
  );

  getIt.registerFactory<DeviceDetailsCubit>(
    () => DeviceDetailsCubit(repository: getIt<CatalogRepository>()),
  );

  getIt.registerFactory<QualityTypesCubit>(
    () => QualityTypesCubit(repository: getIt<CatalogRepository>()),
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // CART FEATURE
  // ═══════════════════════════════════════════════════════════════════════════

  // DataSources
  getIt.registerLazySingleton<CartRemoteDataSource>(
    () => CartRemoteDataSourceImpl(apiClient: getIt<ApiClient>()),
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // ORDERS FEATURE
  // ═══════════════════════════════════════════════════════════════════════════

  // DataSources
  getIt.registerLazySingleton<OrdersRemoteDataSource>(
    () => OrdersRemoteDataSourceImpl(apiClient: getIt<ApiClient>()),
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // PROFILE FEATURE
  // ═══════════════════════════════════════════════════════════════════════════

  // DataSources
  getIt.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(apiClient: getIt<ApiClient>()),
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // WISHLIST FEATURE
  // ═══════════════════════════════════════════════════════════════════════════

  // DataSources
  getIt.registerLazySingleton<WishlistRemoteDataSource>(
    () => WishlistRemoteDataSourceImpl(apiClient: getIt<ApiClient>()),
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // NOTIFICATIONS FEATURE
  // ═══════════════════════════════════════════════════════════════════════════

  // DataSources
  getIt.registerLazySingleton<NotificationsRemoteDataSource>(
    () => NotificationsRemoteDataSourceImpl(apiClient: getIt<ApiClient>()),
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // RETURNS FEATURE
  // ═══════════════════════════════════════════════════════════════════════════

  // DataSources
  getIt.registerLazySingleton<ReturnsRemoteDataSource>(
    () => ReturnsRemoteDataSourceImpl(apiClient: getIt<ApiClient>()),
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // SUPPORT FEATURE
  // ═══════════════════════════════════════════════════════════════════════════

  // DataSources
  getIt.registerLazySingleton<SupportRemoteDataSource>(
    () => SupportRemoteDataSourceImpl(apiClient: getIt<ApiClient>()),
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // REVIEWS FEATURE
  // ═══════════════════════════════════════════════════════════════════════════

  // DataSources
  getIt.registerLazySingleton<ReviewsRemoteDataSource>(
    () => ReviewsRemoteDataSourceImpl(apiClient: getIt<ApiClient>()),
  );
}

/// Handle forced logout when token refresh fails
Future<void> _handleForcedLogout() async {
  // Clear all auth-related data
  await getIt<TokenManager>().clearTokens();
  await getIt<SecureStorage>().deleteAll();

  // Navigate to login screen (this would be handled by the app's navigation)
  // The AuthCubit will handle the state change
}
