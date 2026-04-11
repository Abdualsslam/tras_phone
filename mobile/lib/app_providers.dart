library;

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/di/injection.dart';
import 'core/network/api_client.dart';
import 'core/services/biometric_credential_service.dart';
import 'core/services/biometric_service.dart';
import 'core/services/share_service.dart';
import 'core/storage/local_storage.dart';
import 'core/security/app_security_service.dart';
import 'features/address/domain/repositories/locations_repository.dart';
import 'features/address/presentation/cubit/locations_cubit.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/banners/data/datasources/banners_remote_datasource.dart';
import 'features/banners/domain/repositories/banners_repository.dart';
import 'features/banners/presentation/cubit/banners_cubit.dart';
import 'features/cart/data/datasources/cart_remote_datasource.dart';
import 'features/cart/presentation/cubit/cart_cubit.dart';
import 'features/catalog/data/datasources/catalog_remote_datasource.dart';
import 'features/catalog/data/services/product_cache_service.dart';
import 'features/catalog/domain/repositories/catalog_repository.dart';
import 'features/core_services/biometric_availability_service.dart';
import 'features/education/data/services/favorites_service.dart';
import 'features/education/domain/repositories/education_repository.dart';
import 'features/favorite/domain/repositories/favorite_repository.dart';
import 'features/home/data/services/home_cache_service.dart';
import 'features/home/presentation/cubit/home_cubit.dart';
import 'features/notifications/domain/repositories/notifications_repository.dart';
import 'features/notifications/presentation/cubit/notifications_cubit.dart';
import 'features/notifications/services/push_notification_manager.dart';
import 'features/orders/data/datasources/orders_remote_datasource.dart';
import 'features/orders/presentation/cubit/payment_methods_cubit.dart';
import 'features/orders/presentation/cubit/orders_cubit.dart';
import 'features/profile/domain/repositories/profile_repository.dart';
import 'features/profile/presentation/cubit/profile_cubit.dart';
import 'features/promotions/data/datasources/promotions_remote_datasource.dart';
import 'features/promotions/presentation/cubit/promotions_cubit.dart';
import 'features/support/presentation/cubit/live_chat_cubit.dart';
import 'features/support/presentation/cubit/support_cubit.dart';
import 'features/wallet/domain/repositories/wallet_repository.dart';
import 'features/wallet/presentation/cubit/wallet_cubit.dart';
import 'core/cubit/locale_cubit.dart';
import 'core/cubit/theme_cubit.dart';

class AppProviders extends StatelessWidget {
  final Widget child;

  const AppProviders({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: getIt<LocalStorage>()),
        RepositoryProvider.value(value: getIt<ApiClient>()),
        RepositoryProvider.value(value: getIt<AppSecurityService>()),
        RepositoryProvider.value(value: getIt<BiometricService>()),
        RepositoryProvider.value(value: getIt<BiometricCredentialService>()),
        RepositoryProvider.value(value: getIt<BiometricAvailabilityService>()),
        RepositoryProvider.value(value: getIt<ShareService>()),
        RepositoryProvider.value(value: getIt<CatalogRemoteDataSource>()),
        RepositoryProvider.value(value: getIt<CatalogRepository>()),
        RepositoryProvider.value(value: getIt<ProductCacheService>()),
        RepositoryProvider.value(value: getIt<HomeCacheService>()),
        RepositoryProvider.value(value: getIt<FavoriteRepository>()),
        RepositoryProvider.value(value: getIt<OrdersRemoteDataSource>()),
        RepositoryProvider.value(value: getIt<CartRemoteDataSource>()),
        RepositoryProvider.value(value: getIt<LocationsRepository>()),
        RepositoryProvider.value(value: getIt<ProfileRepository>()),
        RepositoryProvider.value(value: getIt<PromotionsRemoteDataSource>()),
        RepositoryProvider.value(value: getIt<NotificationsRepository>()),
        RepositoryProvider.value(value: getIt<PushNotificationManager>()),
        RepositoryProvider.value(value: getIt<EducationRepository>()),
        RepositoryProvider.value(value: getIt<FavoritesService>()),
        RepositoryProvider.value(value: getIt<WalletRepository>()),
        RepositoryProvider.value(value: getIt<BannersRepository>()),
        RepositoryProvider.value(value: getIt<BannersRemoteDataSource>()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) =>
                LocaleCubit(localStorage: getIt<LocalStorage>())
                  ..loadSavedLocale(),
          ),
          BlocProvider.value(value: getIt<ThemeCubit>()),
          BlocProvider(create: (_) => getIt<AuthCubit>()),
          BlocProvider(
            create: (context) => HomeCubit(
              dataSource: context.read<CatalogRemoteDataSource>(),
              cacheService: context.read<HomeCacheService>(),
            ),
          ),
          BlocProvider.value(value: getIt<CartCubit>()),
          BlocProvider(
            create: (context) => OrdersCubit(
              dataSource: context.read<OrdersRemoteDataSource>(),
            ),
          ),
          BlocProvider(
            create: (context) => PromotionsCubit(
              context.read<PromotionsRemoteDataSource>(),
            ),
          ),
          BlocProvider(
            create: (context) => LocationsCubit(
              repository: context.read<LocationsRepository>(),
            ),
          ),
          BlocProvider(create: (context) => WalletCubit(context.read<WalletRepository>())),
          BlocProvider(
            create: (context) => NotificationsCubit(
              repository: context.read<NotificationsRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) =>
                BannersCubit(repository: context.read<BannersRepository>()),
          ),
          BlocProvider(
            create: (context) =>
                ProfileCubit(repository: context.read<ProfileRepository>()),
          ),
          BlocProvider(
            create: (context) =>
                AddressesCubit(repository: context.read<ProfileRepository>()),
          ),
          BlocProvider(
            create: (context) => PaymentMethodsCubit(
              dataSource: context.read<OrdersRemoteDataSource>(),
            ),
          ),
          BlocProvider(
            create: (_) => getIt<SupportCubit>(),
          ),
          BlocProvider(
            create: (_) => getIt<LiveChatCubit>(),
          ),
        ],
        child: child,
      ),
    );
  }
}
