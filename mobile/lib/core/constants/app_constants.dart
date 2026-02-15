/// App Constants - General application constants
library;

class AppConstants {
  AppConstants._();

  // ═══════════════════════════════════════════════════════════════════════════
  // PAGINATION
  // ═══════════════════════════════════════════════════════════════════════════
  static const int pageSize = 20;
  static const int maxPageSize = 50;

  // ═══════════════════════════════════════════════════════════════════════════
  // VALIDATION
  // ═══════════════════════════════════════════════════════════════════════════
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 50;
  static const int otpLength = 6;
  static const int phoneLength = 9; // Without country code
  static const int searchMinLength = 2;

  // ═══════════════════════════════════════════════════════════════════════════
  // TIMEOUTS
  // ═══════════════════════════════════════════════════════════════════════════
  static const Duration otpTimeout = Duration(minutes: 2);
  static const Duration sessionTimeout = Duration(days: 14);
  static const Duration cacheTimeout = Duration(hours: 1);

  // ═══════════════════════════════════════════════════════════════════════════
  // LIMITS
  // ═══════════════════════════════════════════════════════════════════════════
  static const int maxCartQuantity = 99;
  static const int maxSearchHistory = 10;
  static const int maxRecentlyViewed = 20;
  static const int maxWishlistItems = 100;
  static const int maxImageUpload = 5;
  static const int maxImageSizeMB = 5;

  // ═══════════════════════════════════════════════════════════════════════════
  // PATTERNS
  // ═══════════════════════════════════════════════════════════════════════════
  static final RegExp phonePattern = RegExp(r'^[0-9]{9}$');
  static final RegExp emailPattern = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );
  static final RegExp passwordPattern = RegExp(
    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d@$!%*?&]{8,}$',
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // CURRENCY
  // ═══════════════════════════════════════════════════════════════════════════
  static const String currencyCode = 'SAR';
  static const String currencySymbol = 'ر.س';
  static const String currencyNameAr = 'ريال سعودي';
  static const String currencyNameEn = 'Saudi Riyal';

  // ═══════════════════════════════════════════════════════════════════════════
  // COUNTRY CODE
  // ═══════════════════════════════════════════════════════════════════════════
  static const String defaultCountryCode = '+966';
  static const String defaultCountryIso = 'SA';

  // ═══════════════════════════════════════════════════════════════════════════
  // ORDER STATUS
  // ═══════════════════════════════════════════════════════════════════════════
  static const List<String> orderStatuses = [
    'pending',
    'confirmed',
    'processing',
    'shipped',
    'out_for_delivery',
    'delivered',
    'cancelled',
    'returned',
  ];

  // ═══════════════════════════════════════════════════════════════════════════
  // PAYMENT METHODS
  // ═══════════════════════════════════════════════════════════════════════════
  static const List<String> paymentMethods = [
    'cash_on_delivery',
    'credit_card',
    'mada',
    'apple_pay',
    'stc_pay',
    'bank_transfer',
    'wallet',
    'credit',
  ];
}
