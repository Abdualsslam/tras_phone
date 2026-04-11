library;

class AppRoutePaths {
  const AppRoutePaths._();

  // Auth
  static const splash = '/splash';
  static const securityBlocked = '/security-blocked';
  static const onboarding = '/onboarding';
  static const biometricLogin = '/biometric-login';
  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';
  static const otpVerification = '/otp-verification';
  static const resetPassword = '/reset-password';

  // Main
  static const home = '/home';

  // Catalog
  static const product = '/product/:id';
  static const productAlias = '/products/:id';
  static const productEducation = '/product/:id/education';
  static const categories = '/categories';
  static const category = '/category/:id';
  static const brands = '/brands';
  static const brand = '/brand/:slug';
  static const search = '/search';
  static const products = '/products';
  static const devices = '/devices';
  static const device = '/device/:id';
  static const searchHistory = '/search-history';
  static const advancedSearch = '/advanced-search';
  static const searchResults = '/search-results';

  // Cart and checkout
  static const checkout = '/checkout';
  static const checkoutPayment = '/checkout/payment';
  static const checkoutAddress = '/checkout/address';
  static const orderConfirmation = '/order-confirmation';

  // Orders
  static const orders = '/orders';
  static const order = '/order/:id';
  static const orderAlias = '/orders/:id';
  static const orderDetails = '/order-details/:id';
  static const orderTracking = '/order/:id/tracking';
  static const orderUploadReceipt = '/order/:id/upload-receipt';
  static const orderInvoice = '/order/:id/invoice';

  // Favorites and reviews
  static const favorites = '/favorites';
  static const favoriteEmpty = '/favorites-empty';
  static const stockAlerts = '/stock-alerts';
  static const productReviews = '/product/:id/reviews';
  static const writeReview = '/product/:id/write-review';
  static const writeReviewAlias = '/write-review/:id';
  static const myReviews = '/my-reviews';
  static const pendingReviews = '/pending-reviews';

  // Returns
  static const returns = '/returns';
  static const returnsSelectItems = '/returns/select-items';
  static const returnsCreate = '/returns/create';
  static const returnDetails = '/return/:id';

  // Wallet
  static const wallet = '/wallet';
  static const loyaltyPoints = '/loyalty-points';
  static const loyaltyTiers = '/loyalty-tiers';
  static const loyaltyTransactions = '/loyalty/transactions';
  static const walletTransactions = '/wallet/transactions';
  static const referral = '/referral';

  // Profile
  static const addresses = '/addresses';
  static const mapLocationPicker = '/map/location-picker';
  static const editProfile = '/edit-profile';
  static const changePassword = '/change-password';
  static const addressAdd = '/address/add';
  static const addressEdit = '/address/edit';
  static const addressEditAlias = '/address/edit/:id';

  // Support
  static const support = '/support';
  static const supportCreate = '/support/create';
  static const supportCreateAlias = '/support/create-ticket';
  static const supportChat = '/support/:id/chat';
  static const ticket = '/ticket/:id';
  static const liveChat = '/live-chat';

  // Education and static
  static const faq = '/faq';
  static const terms = '/terms';
  static const privacy = '/privacy';
  static const about = '/about';
  static const education = '/education';
  static const educationList = '/education/list/:id';
  static const educationDetails = '/education/details/:id';

  // Settings and notifications
  static const notifications = '/notifications';
  static const notification = '/notification/:id';
  static const settings = '/settings';
  static const settingsNotifications = '/settings/notifications';
  static const settingsLanguage = '/settings/language';

  // Compatibility aliases
  static const promotionAlias = '/promotions/:id';
}
