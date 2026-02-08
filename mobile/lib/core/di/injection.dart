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
import '../../features/cart/data/datasources/cart_local_datasource.dart';
import '../../features/cart/presentation/cubit/cart_cubit.dart';
import '../../features/cart/presentation/cubit/checkout_session_cubit.dart';
import '../../features/orders/data/datasources/orders_remote_datasource.dart';
import '../../features/orders/presentation/cubit/orders_cubit.dart';
import '../../features/orders/presentation/cubit/payment_methods_cubit.dart';
import '../../features/profile/data/datasources/profile_remote_datasource.dart';
import '../../features/wishlist/data/datasources/wishlist_remote_datasource.dart';
import '../../features/notifications/data/datasources/notifications_remote_datasource.dart';
import '../../features/notifications/data/repositories/notifications_repository.dart';
import '../../features/notifications/presentation/cubit/notifications_cubit.dart';
import '../../features/notifications/services/push_notification_manager.dart';
import '../../features/returns/data/datasources/returns_remote_datasource.dart';
import '../../features/returns/data/repositories/returns_repository_impl.dart';
import '../../features/returns/domain/repositories/returns_repository.dart';
import '../../features/returns/presentation/cubit/returns_cubit.dart';
import '../../features/returns/presentation/cubit/create_return_cubit.dart';
import '../../features/returns/presentation/cubit/return_details_cubit.dart';
import '../../features/support/data/datasources/support_remote_datasource.dart';
import '../../features/support/presentation/cubit/support_cubit.dart';
import '../../features/support/presentation/cubit/live_chat_cubit.dart';
import '../../features/reviews/data/datasources/reviews_remote_datasource.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/presentation/cubit/profile_cubit.dart';
import '../../features/address/data/datasources/locations_remote_datasource.dart';
import '../../features/address/presentation/cubit/locations_cubit.dart';
import '../../features/promotions/data/datasources/promotions_remote_datasource.dart';
import '../../features/promotions/presentation/cubit/promotions_cubit.dart';
import '../../features/education/data/datasources/education_remote_datasource.dart';
import '../../features/education/data/repositories/education_repository_impl.dart';
import '../../features/education/data/services/favorites_service.dart';
import '../../features/education/domain/repositories/education_repository.dart';
import '../../features/education/presentation/cubit/education_categories_cubit.dart';
import '../../features/education/presentation/cubit/education_content_cubit.dart';
import '../../features/education/presentation/cubit/education_details_cubit.dart';
import '../../features/wallet/data/datasources/wallet_remote_datasource.dart';
import '../../features/wallet/data/repositories/wallet_repository.dart';
import '../../features/wallet/presentation/cubit/wallet_cubit.dart';
import '../../features/banners/data/datasources/banners_remote_datasource.dart';
import '../../features/banners/data/repositories/banners_repository.dart';
import '../../features/banners/data/services/banners_service.dart';
import '../../features/banners/presentation/cubit/banners_cubit.dart';
import '../cache/hive_cache_service.dart';
import '../../features/home/data/services/home_cache_service.dart';
import '../../features/catalog/data/services/product_cache_service.dart';
import '../cubit/theme_cubit.dart';
import '../services/biometric_credential_service.dart';
import '../services/biometric_service.dart';
import '../services/share_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';

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
  final apiClient = ApiClient(localStorage: localStorage);
  apiClient.initialize(
    tokenManager: tokenManager,
    onLogout: _handleForcedLogout,
    enableLogging: true, // Set to false in production
  );
  getIt.registerSingleton<ApiClient>(apiClient);

  // Cache Services
  final hiveCacheService = HiveCacheService();
  await hiveCacheService.init();
  getIt.registerSingleton<HiveCacheService>(hiveCacheService);

  final homeCacheService = HomeCacheService(hiveCacheService);
  getIt.registerSingleton<HomeCacheService>(homeCacheService);

  final productCacheService = ProductCacheService(hiveCacheService);
  getIt.registerSingleton<ProductCacheService>(productCacheService);

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
      cacheService: getIt<ProductCacheService>(),
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

  getIt.registerLazySingleton<CartLocalDataSource>(
    () => CartLocalDataSourceImpl(storage: getIt<LocalStorage>()),
  );

  // Cubit - Singleton so it can be accessed from AuthCubit
  getIt.registerLazySingleton<CartCubit>(
    () => CartCubit(
      remoteDataSource: getIt<CartRemoteDataSource>(),
      localDataSource: getIt<CartLocalDataSource>(),
    ),
  );

  // CheckoutSessionCubit - Factory for fresh instance each checkout
  getIt.registerFactory<CheckoutSessionCubit>(
    () => CheckoutSessionCubit(
      remoteDataSource: getIt<CartRemoteDataSource>(),
    ),
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // ORDERS FEATURE
  // ═══════════════════════════════════════════════════════════════════════════

  // DataSources
  getIt.registerLazySingleton<OrdersRemoteDataSource>(
    () => OrdersRemoteDataSourceImpl(apiClient: getIt<ApiClient>()),
  );

  // Cubits
  getIt.registerFactory<OrdersCubit>(
    () => OrdersCubit(dataSource: getIt<OrdersRemoteDataSource>()),
  );

  getIt.registerFactory<PaymentMethodsCubit>(
    () => PaymentMethodsCubit(dataSource: getIt<OrdersRemoteDataSource>()),
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // PROFILE FEATURE
  // ═══════════════════════════════════════════════════════════════════════════

  // DataSources
  getIt.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(apiClient: getIt<ApiClient>()),
  );

  // Repository
  getIt.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(dataSource: getIt<ProfileRemoteDataSource>()),
  );

  // Cubits
  getIt.registerFactory<ProfileCubit>(
    () => ProfileCubit(repository: getIt<ProfileRepository>()),
  );

  getIt.registerLazySingleton<AddressesCubit>(
    () => AddressesCubit(repository: getIt<ProfileRepository>()),
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

  // Repository
  getIt.registerLazySingleton<NotificationsRepository>(
    () => NotificationsRepositoryImpl(
      remoteDataSource: getIt<NotificationsRemoteDataSource>(),
    ),
  );

  // Cubit
  getIt.registerFactory<NotificationsCubit>(
    () => NotificationsCubit(repository: getIt<NotificationsRepository>()),
  );

  // Push Notification Manager
  getIt.registerLazySingleton<PushNotificationManager>(
    () => PushNotificationManager(repository: getIt<NotificationsRepository>()),
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // RETURNS FEATURE
  // ═══════════════════════════════════════════════════════════════════════════

  // DataSources
  getIt.registerLazySingleton<ReturnsRemoteDataSource>(
    () => ReturnsRemoteDataSourceImpl(apiClient: getIt<ApiClient>()),
  );

  // Repository
  getIt.registerLazySingleton<ReturnsRepository>(
    () => ReturnsRepositoryImpl(
      remoteDataSource: getIt<ReturnsRemoteDataSource>(),
    ),
  );

  // Cubits
  getIt.registerFactory<ReturnsCubit>(
    () => ReturnsCubit(repository: getIt<ReturnsRepository>()),
  );

  getIt.registerFactory<CreateReturnCubit>(
    () => CreateReturnCubit(repository: getIt<ReturnsRepository>()),
  );

  getIt.registerFactory<ReturnDetailsCubit>(
    () => ReturnDetailsCubit(repository: getIt<ReturnsRepository>()),
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // SUPPORT FEATURE
  // ═══════════════════════════════════════════════════════════════════════════

  // DataSources
  getIt.registerLazySingleton<SupportRemoteDataSource>(
    () => SupportRemoteDataSourceImpl(apiClient: getIt<ApiClient>()),
  );

  // Cubits
  getIt.registerFactory<SupportCubit>(
    () => SupportCubit(getIt<SupportRemoteDataSource>()),
  );

  getIt.registerFactory<LiveChatCubit>(
    () => LiveChatCubit(getIt<SupportRemoteDataSource>()),
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // REVIEWS FEATURE
  // ═══════════════════════════════════════════════════════════════════════════

  // DataSources
  getIt.registerLazySingleton<ReviewsRemoteDataSource>(
    () => ReviewsRemoteDataSourceImpl(apiClient: getIt<ApiClient>()),
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // LOCATIONS FEATURE
  // ═══════════════════════════════════════════════════════════════════════════

  // DataSources
  getIt.registerLazySingleton<LocationsRemoteDataSource>(
    () => LocationsRemoteDataSourceImpl(apiClient: getIt<ApiClient>()),
  );

  // Cubits
  getIt.registerFactory<LocationsCubit>(
    () => LocationsCubit(dataSource: getIt<LocationsRemoteDataSource>()),
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // PROMOTIONS FEATURE
  // ═══════════════════════════════════════════════════════════════════════════

  // DataSources
  getIt.registerLazySingleton<PromotionsRemoteDataSource>(
    () => PromotionsRemoteDataSourceImpl(getIt<ApiClient>()),
  );

  // Cubits
  getIt.registerFactory<PromotionsCubit>(
    () => PromotionsCubit(getIt<PromotionsRemoteDataSource>()),
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // EDUCATION FEATURE
  // ═══════════════════════════════════════════════════════════════════════════

  // DataSources
  getIt.registerLazySingleton<EducationRemoteDataSource>(
    () => EducationRemoteDataSourceImpl(apiClient: getIt<ApiClient>()),
  );

  // Repository
  getIt.registerLazySingleton<EducationRepository>(
    () => EducationRepositoryImpl(
      remoteDataSource: getIt<EducationRemoteDataSource>(),
    ),
  );

  // Services
  final prefs = await SharedPreferences.getInstance();
  getIt.registerLazySingleton<FavoritesService>(
    () => FavoritesService(prefs: prefs),
  );

  // Cubits
  getIt.registerFactory<EducationCategoriesCubit>(
    () => EducationCategoriesCubit(repository: getIt<EducationRepository>()),
  );

  getIt.registerFactory<EducationContentCubit>(
    () => EducationContentCubit(repository: getIt<EducationRepository>()),
  );

  getIt.registerFactory<EducationDetailsCubit>(
    () => EducationDetailsCubit(repository: getIt<EducationRepository>()),
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // WALLET FEATURE
  // ═══════════════════════════════════════════════════════════════════════════

  // DataSources
  getIt.registerLazySingleton<WalletRemoteDataSource>(
    () => WalletRemoteDataSourceImpl(getIt<ApiClient>()),
  );

  // Repository
  getIt.registerLazySingleton<WalletRepository>(
    () => WalletRepositoryImpl(getIt<WalletRemoteDataSource>()),
  );

  // Cubit
  getIt.registerFactory<WalletCubit>(
    () => WalletCubit(getIt<WalletRepository>()),
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // BANNERS FEATURE
  // ═══════════════════════════════════════════════════════════════════════════

  // DataSources
  getIt.registerLazySingleton<BannersRemoteDataSource>(
    () => BannersRemoteDataSourceImpl(apiClient: getIt<ApiClient>()),
  );

  // Repository
  getIt.registerLazySingleton<BannersRepository>(
    () => BannersRepositoryImpl(
      remoteDataSource: getIt<BannersRemoteDataSource>(),
    ),
  );

  // Service
  getIt.registerLazySingleton<BannersService>(
    () => BannersService(repository: getIt<BannersRepository>()),
  );

  // Cubit
  getIt.registerFactory<BannersCubit>(
    () => BannersCubit(service: getIt<BannersService>()),
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // SETTINGS FEATURE
  // ═══════════════════════════════════════════════════════════════════════════

  // Theme Cubit
  getIt.registerLazySingleton<ThemeCubit>(
    () => ThemeCubit(localStorage: getIt<LocalStorage>())..loadSavedTheme(),
  );

  // Biometric Service
  getIt.registerLazySingleton<BiometricService>(
    () => BiometricService(
      localAuth: LocalAuthentication(),
      localStorage: getIt<LocalStorage>(),
    ),
  );

  // Biometric Credential Service
  getIt.registerLazySingleton<BiometricCredentialService>(
    () => BiometricCredentialService(secureStorage: getIt<SecureStorage>()),
  );

  // Share Service
  getIt.registerLazySingleton<ShareService>(() => ShareService());
}

/// Handle forced logout when token refresh fails
Future<void> _handleForcedLogout() async {
  // Clear all auth-related data
  await getIt<TokenManager>().clearTokens();
  await getIt<SecureStorage>().deleteAll();

  // Clear product/home cache - prices differ by customer tier
  try {
    await getIt<ProductCacheService>().clearAll();
    await getIt<HomeCacheService>().clearHomeData();
  } catch (_) {
    // Fail silently
  }

  // Navigate to login screen (this would be handled by the app's navigation)
  // The AuthCubit will handle the state change
}
