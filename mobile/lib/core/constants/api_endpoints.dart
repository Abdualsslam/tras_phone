/// API Endpoints - All API paths for the application
library;

class ApiEndpoints {
  ApiEndpoints._();

  // ═══════════════════════════════════════════════════════════════════════════
  // AUTH ENDPOINTS
  // ═══════════════════════════════════════════════════════════════════════════
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';
  static const String sendOtp = '/auth/send-otp';
  static const String verifyOtp = '/auth/verify-otp';
  static const String forgotPassword = '/auth/forgot-password';
  static const String verifyResetOtp = '/auth/verify-reset-otp';
  static const String resetPassword = '/auth/reset-password';
  static const String changePassword = '/auth/change-password';
  static const String me = '/auth/me';
  static const String fcmToken = '/auth/fcm-token';

  // ═══════════════════════════════════════════════════════════════════════════
  // CUSTOMER ENDPOINTS
  // ═══════════════════════════════════════════════════════════════════════════
  static const String profile = '/customer/profile';
  static const String addresses = '/customer/addresses';
  static const String wallet = '/customer/wallet';
  static const String walletTransactions = '/customer/wallet/transactions';
  static const String loyalty = '/customer/loyalty';
  static const String referral = '/customer/referral';

  // ═══════════════════════════════════════════════════════════════════════════
  // CATALOG ENDPOINTS
  // ═══════════════════════════════════════════════════════════════════════════
  static const String brands = '/catalog/brands';
  static const String categories = '/catalog/categories';
  static const String categoriesTree = '/catalog/categories/tree';
  static const String devices = '/catalog/devices';
  static const String qualityTypes = '/catalog/quality-types';
  static const String products = '/products';
  static const String productsSearch = '/products/search';
  static const String productsFeatured = '/products/featured';
  static const String productsNewArrivals = '/products/new-arrivals';
  static const String productsBestSellers = '/products/best-sellers';

  // ═══════════════════════════════════════════════════════════════════════════
  // WISHLIST & REVIEWS
  // ═══════════════════════════════════════════════════════════════════════════
  static const String wishlist = '/wishlist';
  static const String reviews = '/reviews';
  static const String myReviews = '/customer/reviews';
  static const String pendingReviews = '/customer/pending-reviews';
  static const String recentlyViewed = '/recently-viewed';
  static const String stockAlerts = '/stock-alerts';

  // ═══════════════════════════════════════════════════════════════════════════
  // CART & CHECKOUT
  // ═══════════════════════════════════════════════════════════════════════════
  static const String cart = '/cart';
  static const String cartItems = '/cart/items';
  static const String cartAdd = '/cart/add';
  static const String cartUpdate = '/cart/update';
  static const String cartRemove = '/cart/remove';
  static const String cartClear = '/cart/clear';
  static const String cartCount = '/cart/count';
  static const String cartSync = '/cart/sync';
  static const String cartApplyCoupon = '/cart/apply-coupon';
  static const String cartRemoveCoupon = '/cart/remove-coupon';
  static const String applyCoupon = '/cart/apply-coupon';
  static const String removeCoupon = '/cart/remove-coupon';
  static const String checkoutSummary = '/checkout/summary';
  static const String placeOrder = '/checkout/place-order';
  static const String paymentMethods = '/checkout/payment-methods';
  static const String bankAccounts = '/checkout/bank-accounts';
  static const String calculateShipping = '/checkout/calculate-shipping';
  static const String validateCoupon = '/coupons/validate';
  static const String availableCoupons = '/coupons/available';
  static const String activePromotions = '/promotions/active';

  // ═══════════════════════════════════════════════════════════════════════════
  // ORDERS
  // ═══════════════════════════════════════════════════════════════════════════
  static const String orders = '/orders';
  static const String ordersCreate = '/orders/create';
  static const String ordersStats = '/orders/stats';
  static const String ordersRecent = '/orders/recent';
  static const String ordersPendingPayment = '/orders/pending-payment';

  // ═══════════════════════════════════════════════════════════════════════════
  // RETURNS
  // ═══════════════════════════════════════════════════════════════════════════
  static const String returns = '/returns';
  static const String returnReasons = '/returns/reasons';

  // ═══════════════════════════════════════════════════════════════════════════
  // SUPPORT
  // ═══════════════════════════════════════════════════════════════════════════
  static const String tickets = '/support/tickets';
  static const String supportCategories = '/support/categories';
  static const String chatConversations = '/chat/conversations';

  // ═══════════════════════════════════════════════════════════════════════════
  // NOTIFICATIONS
  // ═══════════════════════════════════════════════════════════════════════════
  static const String notifications = '/notifications';
  static const String notificationsMy = '/notifications/my';
  static const String notificationsReadAll = '/notifications/read-all';
  static const String notificationsToken = '/notifications/token';
  static const String notificationsUnreadCount = '/notifications/unread-count';

  // ═══════════════════════════════════════════════════════════════════════════
  // CONTENT
  // ═══════════════════════════════════════════════════════════════════════════
  static const String educationCategories = '/education/categories';
  static const String educationContent = '/education/content';
  static const String pages = '/pages';
  static const String faqs = '/faqs';
  static const String banners = '/banners';

  // ═══════════════════════════════════════════════════════════════════════════
  // LOCATIONS
  // ═══════════════════════════════════════════════════════════════════════════
  static const String locationsCountries = '/locations/countries';
  static const String locationsCities = '/locations/cities';
  static const String locationsMarkets = '/locations/markets';
  static const String locationsShippingCalculate = '/locations/shipping/calculate';
  static const String locationsShippingZones = '/locations/shipping-zones';

  // ═══════════════════════════════════════════════════════════════════════════
  // GENERAL
  // ═══════════════════════════════════════════════════════════════════════════
  static const String countries = '/countries';
  static const String cities = '/cities';
  static const String settings = '/settings/public';
  static const String appVersion = '/app/version';
  static const String appConfig = '/app/config';
  static const String searchSuggestions = '/search/suggestions';
  static const String searchPopular = '/search/popular';
  static const String searchHistory = '/search/history';
}
