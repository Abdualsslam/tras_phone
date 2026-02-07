/// Storage Keys - Keys for local storage
library;

class StorageKeys {
  StorageKeys._();

  // Auth
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String userId = 'user_id';
  static const String isLoggedIn = 'is_logged_in';
  static const String isFirstLaunch = 'is_first_launch';

  // User
  static const String userData = 'user_data';
  static const String customerData = 'customer_data';

  // Settings
  static const String locale = 'locale';
  static const String themeMode = 'theme_mode';
  static const String notificationsEnabled = 'notifications_enabled';
  static const String biometricEnabled = 'biometric_enabled';
  static const String biometricPhone = 'biometric_phone';
  static const String biometricPassword = 'biometric_password';
  static const String notificationSettings = 'notification_settings';

  // Cart
  static const String cartItems = 'cart_items';
  static const String cartCount = 'cart_count';

  // Cache
  static const String categoriesCache = 'categories_cache';
  static const String brandsCache = 'brands_cache';
  static const String productsCache = 'products_cache';
  static const String bannersCache = 'banners_cache';

  // Search
  static const String searchHistory = 'search_history';
  static const String recentlyViewed = 'recently_viewed';
}
