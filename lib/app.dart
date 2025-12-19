/// App Widget - Root application widget
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'core/config/theme/app_theme.dart';
import 'core/di/injection.dart';
import 'core/storage/local_storage.dart';
import 'core/storage/secure_storage.dart';
import 'features/auth/data/datasources/auth_mock_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/home/presentation/cubit/home_cubit.dart';
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
              create: (_) => AuthCubit(
                repository: AuthRepositoryImpl(
                  dataSource: AuthMockDataSource(),
                  localStorage: getIt<LocalStorage>(),
                  secureStorage: getIt<SecureStorage>(),
                ),
              ),
            ),
            BlocProvider(create: (_) => HomeCubit()),
          ],
          child: MaterialApp.router(
            title: 'تراس فون',
            debugShowCheckedModeBanner: false,

            // Theme
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.system,

            // Localization
            locale: const Locale('ar'),
            supportedLocales: const [Locale('ar'), Locale('en')],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],

            // Router
            routerConfig: appRouter,

            // Builder for global modifications
            builder: (context, child) {
              return Directionality(
                textDirection: TextDirection.rtl,
                child: child ?? const SizedBox.shrink(),
              );
            },
          ),
        );
      },
    );
  }
}
