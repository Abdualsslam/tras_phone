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
  static const String forgotPassword =
      '/auth/forgot-password'; // Legacy - kept for backward compatibility
  static const String requestPasswordReset = '/auth/request-password-reset';
  static const String verifyResetOtp = '/auth/verify-reset-otp';
  static const String resetPassword = '/auth/reset-password';
  static const String changePassword = '/auth/change-password';
  static const String me = '/auth/me';
  static const String fcmToken = '/auth/fcm-token';
  static const String sessions = '/auth/sessions';
  static String deleteSession(String sessionId) => '/auth/sessions/$sessionId';

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
  static String brandProducts(String brandId) =>
      '/catalog/brands/$brandId/products';
  static const String categories = '/catalog/categories';
  static const String categoriesTree = '/catalog/categories/tree';
  static String categoryProducts(String identifier) =>
      '/catalog/categories/$identifier/products';
  static const String devices = '/catalog/devices';
  static String deviceProducts(String identifier) =>
      '/catalog/devices/$identifier/products';
  static const String qualityTypes = '/catalog/quality-types';
  static const String products = '/products';
  static const String productsSearch = '/products/search';
  static const String productsFeatured = '/products/featured';
  static const String productsNewArrivals = '/products/new-arrivals';
  static const String productsBestSellers = '/products/best-sellers';
  static const String productsOnOffer = '/products/on-offer';

  // ═══════════════════════════════════════════════════════════════════════════
  // FAVORITES & REVIEWS
  // ═══════════════════════════════════════════════════════════════════════════
  static const String favoritesMy = '/products/favorite/my';
  static String productFavorite(String id) => '/products/$id/favorite';
  static String productFavoriteCheck(String id) => '/products/$id/favorite/check';
  static String productReviews(String id) => '/products/$id/reviews';
  static String productReviewsMine(String id) => '/products/$id/reviews/mine';
  static String productReviewUpdate(String productId, String reviewId) =>
      '/products/$productId/reviews/$reviewId';
  static const String reviews = '/reviews';
  static const String myReviews = '/customer/reviews';
  static const String pendingReviews = '/customer/pending-reviews';
  static const String recentlyViewed = '/analytics/recently-viewed';
  static const String stockAlerts = '/products/stock-alerts';

  // ═══════════════════════════════════════════════════════════════════════════
  // CART & CHECKOUT
  // ═══════════════════════════════════════════════════════════════════════════
  static const String cart = '/cart';
  static const String cartItems = '/cart/items';
  static const String cartCoupon = '/cart/coupon';
  // Legacy endpoints (kept for backward compatibility)
  static const String cartAdd = '/cart/items';
  static const String cartUpdate = '/cart/items';
  static const String cartRemove = '/cart/items';
  static const String cartClear = '/cart';
  static const String cartCount = '/cart/count';
  static const String cartSync = '/cart/sync';
  static const String cartApplyCoupon = '/cart/coupon';
  static const String cartRemoveCoupon = '/cart/coupon';
  static const String applyCoupon = '/cart/coupon';
  static const String removeCoupon = '/cart/coupon';
  static const String checkoutSession = '/checkout/session';
  static const String checkoutSummary = '/checkout/summary';
  static const String placeOrder = '/checkout/place-order';
  static const String paymentMethods = '/settings/payment-methods';
  static const String bankAccounts = '/bank-accounts';
  static const String calculateShipping = '/checkout/calculate-shipping';
  static const String validateCoupon = '/coupons/validate';
  static const String availableCoupons = '/coupons/available';
  static const String activePromotions = '/promotions/active';

  // ═══════════════════════════════════════════════════════════════════════════
  // ORDERS
  // ═══════════════════════════════════════════════════════════════════════════
  static const String orders = '/orders';
  static const String ordersMy = '/orders/my';
  static const String ordersCreate = '/orders';
  static const String ordersStats = '/orders/stats';
  static const String ordersRecent = '/orders/recent';
  static const String ordersPendingPayment = '/orders/pending-payment';
  static String orderUploadReceipt(String orderId) =>
      '/orders/$orderId/upload-receipt';
  static String adminOrderInvoice(String orderId) =>
      '/admin/orders/$orderId/invoice';

  // ═══════════════════════════════════════════════════════════════════════════
  // RETURNS
  // ═══════════════════════════════════════════════════════════════════════════
  static const String returns = '/returns';
  static const String returnReasons = '/returns/reasons';

  // ═══════════════════════════════════════════════════════════════════════════
  // SUPPORT (backend controller: support/tickets)
  // ═══════════════════════════════════════════════════════════════════════════
  static const String ticketCategories = '/support/tickets/categories';
  static const String myTickets = '/support/tickets/my';
  static const String tickets = '/support/tickets';
  static const String supportCategories = '/support/categories';
  static const String ticketUpload = '/support/tickets/upload';

  // Ticket endpoints (customer: my tickets)
  static String ticketDetails(String id) => '/support/tickets/my/$id';
  static String ticketMessages(String id) => '/support/tickets/my/$id/messages';
  static String ticketRate(String id) => '/support/tickets/my/$id/rate';

  // Live Chat
  static const String chatStart = '/chat/start';
  static const String chatMySession = '/chat/my-session';
  static const String chatConversations = '/chat/conversations';
  static const String chatMessages = '/chat/my-session/messages';
  static const String chatEnd = '/chat/my-session/end';

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
  static const String educationCategories = '/educational/categories';
  static const String educationContent = '/educational/content';
  static const String pages = '/pages';
  static const String faqs = '/faqs';
  static const String banners = '/banners';
  static String bannersImpression(String id) =>
      '/content/banners/$id/impression';
  static String bannersClick(String id) => '/content/banners/$id/click';

  // ═══════════════════════════════════════════════════════════════════════════
  // LOCATIONS
  // ═══════════════════════════════════════════════════════════════════════════
  static const String locationsCountries = '/locations/countries';
  static const String locationsCities = '/locations/cities';
  static const String locationsMarkets = '/locations/markets';
  static const String locationsShippingCalculate =
      '/locations/shipping/calculate';
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
