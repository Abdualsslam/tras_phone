/// App Widget - Root application widget
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'core/config/theme/app_theme.dart';
import 'core/cubit/locale_cubit.dart';
import 'core/cubit/theme_cubit.dart';
import 'core/di/injection.dart';
import 'core/storage/local_storage.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/cart/presentation/cubit/cart_cubit.dart';
import 'features/home/presentation/cubit/home_cubit.dart';
import 'features/home/data/services/home_cache_service.dart';
import 'features/catalog/data/datasources/catalog_remote_datasource.dart';
import 'features/orders/presentation/cubit/orders_cubit.dart';
import 'features/orders/presentation/cubit/payment_methods_cubit.dart';
import 'features/orders/data/datasources/orders_remote_datasource.dart';
import 'features/promotions/presentation/cubit/promotions_cubit.dart';
import 'features/promotions/data/datasources/promotions_remote_datasource.dart';
import 'features/address/presentation/cubit/locations_cubit.dart';
import 'features/address/domain/repositories/locations_repository.dart';
import 'features/wallet/presentation/cubit/wallet_cubit.dart';
import 'features/notifications/presentation/cubit/notifications_cubit.dart';
import 'features/banners/presentation/cubit/banners_cubit.dart';
import 'features/profile/presentation/cubit/profile_cubit.dart';
import 'features/support/presentation/cubit/live_chat_cubit.dart';
import 'features/support/presentation/cubit/support_cubit.dart';
import 'l10n/app_localizations.dart';
import 'routes/app_router.dart';

class TrasPhoneApp extends StatelessWidget {
  const TrasPhoneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812), // iPhone X design size
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (_) =>
                  LocaleCubit(localStorage: getIt<LocalStorage>())
                    ..loadSavedLocale(),
            ),
            BlocProvider.value(value: getIt<ThemeCubit>()),
            BlocProvider(create: (_) => getIt<AuthCubit>()),
            BlocProvider(
              create: (_) => HomeCubit(
                dataSource: getIt<CatalogRemoteDataSource>(),
                cacheService: getIt<HomeCacheService>(),
              ),
            ),
            BlocProvider.value(value: getIt<CartCubit>()),
            BlocProvider(
              create: (_) =>
                  OrdersCubit(dataSource: getIt<OrdersRemoteDataSource>()),
            ),
            BlocProvider(
              create: (_) =>
                  PromotionsCubit(getIt<PromotionsRemoteDataSource>()),
            ),
            BlocProvider(
              create: (_) => LocationsCubit(
                repository: getIt<LocationsRepository>(),
              ),
            ),
            BlocProvider(create: (_) => getIt<WalletCubit>()),
            BlocProvider(
              create: (_) {
                try {
                  return getIt<NotificationsCubit>();
                } catch (e) {
                  debugPrint('Error creating NotificationsCubit: $e');
                  rethrow;
                }
              },
            ),
            BlocProvider(create: (_) => getIt<BannersCubit>()),
            BlocProvider(create: (_) => getIt<ProfileCubit>()),
            BlocProvider(create: (_) => getIt<AddressesCubit>()),
            BlocProvider(create: (_) => getIt<PaymentMethodsCubit>()),
            BlocProvider(create: (_) => getIt<SupportCubit>()),
            BlocProvider(create: (_) => getIt<LiveChatCubit>()),
          ],
          child: BlocBuilder<LocaleCubit, LocaleState>(
            builder: (context, localeState) {
              return BlocBuilder<ThemeCubit, ThemeState>(
                builder: (context, themeState) {
                  return MaterialApp.router(
                    title: 'تراس فون',
                    debugShowCheckedModeBanner: false,

                    // Theme
                    theme: AppTheme.lightTheme,
                    darkTheme: AppTheme.darkTheme,
                    themeMode: themeState.themeMode,

                    // Localization
                    locale: localeState.locale,
                    supportedLocales: AppLocalizations.supportedLocales,
                    localizationsDelegates:
                        AppLocalizations.localizationsDelegates,

                    // Router
                    routerConfig: appRouter,

                    // Builder for global modifications
                    builder: (context, child) {
                      // Dynamically set text direction based on locale
                      final isRtl = localeState.locale.languageCode == 'ar';
                      return Directionality(
                        textDirection: isRtl
                            ? TextDirection.rtl
                            : TextDirection.ltr,
                        child: child ?? const SizedBox.shrink(),
                      );
                    },
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
