/// Main entry point for TRAS Phone application
library;

import 'dart:async';
import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'app.dart';
import 'core/cubit/app_bloc_observer.dart';
import 'core/di/injection.dart';
import 'core/errors/app_error_reporter.dart';
import 'core/security/app_security_service.dart';
import 'features/notifications/services/push_notification_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await runZonedGuarded(() async {
    await Hive.initFlutter();

    try {
      await Firebase.initializeApp();
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    } catch (error) {
      debugPrint('Firebase initialization failed: $error');
      debugPrint(
        'Note: Add Firebase configuration files to enable push notifications',
      );
    }

    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );

    await setupDependencies();

    final errorReporter = getIt<AppErrorReporter>();
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      errorReporter.recordError(
        details.exception,
        details.stack ?? StackTrace.current,
        source: 'FlutterError',
        fatal: true,
      );
    };

    PlatformDispatcher.instance.onError = (error, stackTrace) {
      errorReporter.recordError(
        error,
        stackTrace,
        source: 'PlatformDispatcher',
        fatal: true,
      );
      return true;
    };

    unawaited(getIt<AppSecurityService>().warmUpIntegrityProvider());
    Bloc.observer = getIt<AppBlocObserver>();
    runApp(const TrasPhoneApp());
  }, (error, stackTrace) {
    if (getIt.isRegistered<AppErrorReporter>()) {
      getIt<AppErrorReporter>().recordError(
        error,
        stackTrace,
        source: 'runZonedGuarded',
        fatal: true,
      );
      return;
    }

    debugPrint('Unhandled startup error: $error');
  });
}
