/// Main entry point for TRAS Phone application
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'app.dart';
import 'core/di/injection.dart';
import 'features/notifications/services/push_notification_manager.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    debugPrint('Warning: Could not load .env file: $e');
    debugPrint('Please create .env file from .env.example');
  }

  // Initialize Hive for caching
  await Hive.initFlutter();

  // Initialize Firebase
  // Note: Make sure to add google-services.json (Android) and GoogleService-Info.plist (iOS)
  // from Firebase Console to the respective platform directories
  try {
    await Firebase.initializeApp();

    // Register background message handler
    // This must be a top-level function (defined in push_notification_manager.dart)
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  } catch (e) {
    // Firebase initialization failed - log error but continue app startup
    // This allows the app to work without Firebase if configuration files are missing
    debugPrint('Firebase initialization failed: $e');
    debugPrint(
      'Note: Add Firebase configuration files to enable push notifications',
    );
  }

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

  // Setup dependency injection
  await setupDependencies();

  // Run the app
  runApp(const TrasPhoneApp());
}
