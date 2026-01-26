/// App Configuration - Environment and global settings
library;

import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  AppConfig._();

  // App Info
  static const String appName = 'TRAS Phone';
  static const String appNameAr = 'تراس فون';
  static const String appVersion = '1.0.0';
  static const int appBuildNumber = 1;

  // API Configuration (for future use)
  static const String baseUrl = 'https://api-trasphone.smartagency-ye.com/api/v1';
  static const String apiVersion = 'v1';
  static const Duration apiTimeout = Duration(seconds: 30);

  // Google Maps API Key (loaded from .env)
  static String get googleMapsApiKey {
    final key = dotenv.env['GOOGLE_MAPS_API_KEY'];
    if (key == null || key.isEmpty) {
      throw Exception(
        'GOOGLE_MAPS_API_KEY is not set in .env file. '
        'Please create .env file from .env.example and add your API key.',
      );
    }
    return key;
  }

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 50;

  // Cache Duration
  static const Duration cacheDuration = Duration(hours: 1);
  static const Duration searchCacheDuration = Duration(minutes: 15);

  // Animation Duration
  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);

  // Image Sizes
  static const int thumbnailSize = 150;
  static const int productImageSize = 400;
  static const int bannerImageSize = 800;

  // Locale
  static const String defaultLocale = 'ar';
  static const List<String> supportedLocales = ['ar', 'en'];

  // Currency
  static const String defaultCurrency = 'SAR';
  static const String currencySymbol = 'ر.س';
}
