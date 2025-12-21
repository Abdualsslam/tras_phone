/// App Router - GoRouter configuration
library;

import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../features/auth/presentation/screens/forgot_password_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/onboarding_screen.dart';
import '../features/auth/presentation/screens/otp_verification_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/auth/presentation/screens/splash_screen.dart';
import '../features/catalog/presentation/screens/screens.dart';
import '../features/catalog/presentation/screens/category_products_screen.dart';
import '../features/catalog/presentation/screens/brand_details_screen.dart';
import '../features/catalog/presentation/screens/devices_list_screen.dart';
import '../features/catalog/presentation/screens/device_products_screen.dart';
import '../features/catalog/presentation/screens/search_history_screen.dart';
import '../features/catalog/domain/entities/product_entity.dart';
import '../features/navigation/presentation/screens/main_navigation_shell.dart';
import '../features/wallet/presentation/screens/wallet_screen.dart';
import '../features/wallet/presentation/screens/loyalty_points_screen.dart';
import '../features/wallet/presentation/screens/wallet_transactions_screen.dart';
import '../features/wallet/presentation/screens/referral_screen.dart';
import '../features/notifications/presentation/screens/notifications_screen.dart';
import '../features/notifications/presentation/screens/notification_details_screen.dart';
import '../features/settings/presentation/screens/settings_screen.dart';
import '../features/settings/presentation/screens/notification_settings_screen.dart';
import '../features/settings/presentation/screens/language_settings_screen.dart';
import '../features/cart/presentation/screens/checkout_screen.dart';
import '../features/cart/presentation/screens/order_confirmation_screen.dart';
import '../features/cart/presentation/screens/payment_method_screen.dart';
import '../features/cart/presentation/screens/address_selection_screen.dart';
import '../features/wishlist/presentation/screens/wishlist_screen.dart';
import '../features/wishlist/presentation/screens/stock_alerts_screen.dart';
import '../features/reviews/presentation/screens/product_reviews_screen.dart';
import '../features/reviews/presentation/screens/write_review_screen.dart';
import '../features/reviews/presentation/screens/my_reviews_screen.dart';
import '../features/returns/presentation/screens/returns_list_screen.dart';
import '../features/returns/presentation/screens/create_return_screen.dart';
import '../features/returns/presentation/screens/return_details_screen.dart';
import '../features/support/presentation/screens/support_tickets_screen.dart';
import '../features/support/presentation/screens/ticket_chat_screen.dart';
import '../features/support/presentation/screens/create_ticket_screen.dart';
import '../features/education/presentation/screens/faq_screen.dart';
import '../features/education/presentation/screens/static_page_screen.dart';
import '../features/education/presentation/screens/education_categories_screen.dart';
import '../features/education/presentation/screens/education_list_screen.dart';
import '../features/education/presentation/screens/education_details_screen.dart';
import '../features/orders/presentation/screens/order_details_screen.dart';
import '../features/orders/presentation/screens/order_tracking_screen.dart';
import '../features/orders/presentation/screens/upload_receipt_screen.dart';
import '../features/orders/presentation/screens/invoice_view_screen.dart';
import '../features/profile/presentation/screens/addresses_list_screen.dart';
import '../features/profile/presentation/screens/edit_profile_screen.dart';
import '../features/profile/presentation/screens/change_password_screen.dart';
import '../features/profile/presentation/screens/add_edit_address_screen.dart';
import '../features/admin/presentation/screens/admin_dashboard_screen.dart';
import '../features/admin/presentation/screens/admin_orders_screen.dart';
import '../features/admin/presentation/screens/admin_customers_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/splash',
  routes: [
    // ═══════════════════════════════════════════════════════════════════════
    // AUTH ROUTES
    // ═══════════════════════════════════════════════════════════════════════
    GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: '/otp-verification',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return OtpVerificationScreen(
          phone: extra?['phone'] ?? '',
          purpose: extra?['purpose'] ?? 'verification',
        );
      },
    ),

    // ═══════════════════════════════════════════════════════════════════════
    // MAIN APP ROUTES
    // ═══════════════════════════════════════════════════════════════════════
    GoRoute(
      path: '/home',
      builder: (context, state) => const MainNavigationShell(),
    ),

    // ═══════════════════════════════════════════════════════════════════════
    // CATALOG ROUTES
    // ═══════════════════════════════════════════════════════════════════════
    GoRoute(
      path: '/product/:id',
      builder: (context, state) {
        final product = state.extra as ProductEntity?;
        if (product != null) return ProductDetailsScreen(product: product);
        return Scaffold(
          appBar: AppBar(title: const Text('المنتج')),
          body: const Center(child: Text('المنتج غير موجود')),
        );
      },
    ),
    GoRoute(
      path: '/categories',
      builder: (context, state) => const CategoriesListScreen(),
    ),
    GoRoute(
      path: '/brands',
      builder: (context, state) => const BrandsListScreen(),
    ),
    GoRoute(path: '/search', builder: (context, state) => const SearchScreen()),

    // ═══════════════════════════════════════════════════════════════════════
    // CART & CHECKOUT ROUTES
    // ═══════════════════════════════════════════════════════════════════════
    GoRoute(
      path: '/checkout',
      builder: (context, state) => const CheckoutScreen(),
    ),
    GoRoute(
      path: '/order-confirmation',
      builder: (context, state) => const OrderConfirmationScreen(),
    ),

    // ═══════════════════════════════════════════════════════════════════════
    // ORDER ROUTES
    // ═══════════════════════════════════════════════════════════════════════
    GoRoute(
      path: '/order/:id',
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
        return OrderDetailsScreen(orderId: id);
      },
    ),
    GoRoute(
      path: '/order/:id/tracking',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return OrderTrackingScreen(orderNumber: 'ORD-2024-$id');
      },
    ),

    // ═══════════════════════════════════════════════════════════════════════
    // WISHLIST & REVIEWS ROUTES
    // ═══════════════════════════════════════════════════════════════════════
    GoRoute(
      path: '/wishlist',
      builder: (context, state) => const WishlistScreen(),
    ),
    GoRoute(
      path: '/product/:id/reviews',
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
        return ProductReviewsScreen(productId: id);
      },
    ),
    GoRoute(
      path: '/product/:id/write-review',
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
        return WriteReviewScreen(productId: id, productName: 'منتج');
      },
    ),

    // ═══════════════════════════════════════════════════════════════════════
    // RETURNS ROUTES
    // ═══════════════════════════════════════════════════════════════════════
    GoRoute(
      path: '/returns',
      builder: (context, state) => const ReturnsListScreen(),
    ),
    GoRoute(
      path: '/returns/create/:orderId',
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['orderId'] ?? '') ?? 0;
        return CreateReturnScreen(orderId: id);
      },
    ),

    // ═══════════════════════════════════════════════════════════════════════
    // WALLET & LOYALTY ROUTES
    // ═══════════════════════════════════════════════════════════════════════
    GoRoute(path: '/wallet', builder: (context, state) => const WalletScreen()),
    GoRoute(
      path: '/loyalty-points',
      builder: (context, state) => const LoyaltyPointsScreen(),
    ),

    // ═══════════════════════════════════════════════════════════════════════
    // PROFILE ROUTES
    // ═══════════════════════════════════════════════════════════════════════
    GoRoute(
      path: '/addresses',
      builder: (context, state) => const AddressesListScreen(),
    ),
    GoRoute(
      path: '/edit-profile',
      builder: (context, state) => const EditProfileScreen(),
    ),
    GoRoute(
      path: '/change-password',
      builder: (context, state) => const ChangePasswordScreen(),
    ),

    // ═══════════════════════════════════════════════════════════════════════
    // SUPPORT ROUTES
    // ═══════════════════════════════════════════════════════════════════════
    GoRoute(
      path: '/support',
      builder: (context, state) => const SupportTicketsScreen(),
    ),
    GoRoute(
      path: '/support/create',
      builder: (context, state) => const CreateTicketScreen(),
    ),
    GoRoute(
      path: '/support/:id/chat',
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
        return TicketChatScreen(ticketId: id, subject: 'تذكرة دعم');
      },
    ),

    // ═══════════════════════════════════════════════════════════════════════
    // EDUCATION ROUTES
    // ═══════════════════════════════════════════════════════════════════════
    GoRoute(path: '/faq', builder: (context, state) => const FaqScreen()),
    GoRoute(
      path: '/terms',
      builder: (context, state) =>
          const StaticPageScreen(title: 'الشروط والأحكام', slug: 'terms'),
    ),
    GoRoute(
      path: '/privacy',
      builder: (context, state) =>
          const StaticPageScreen(title: 'سياسة الخصوصية', slug: 'privacy'),
    ),
    GoRoute(
      path: '/about',
      builder: (context, state) =>
          const StaticPageScreen(title: 'عن التطبيق', slug: 'about'),
    ),

    // ═══════════════════════════════════════════════════════════════════════
    // OTHER ROUTES
    // ═══════════════════════════════════════════════════════════════════════
    GoRoute(
      path: '/notifications',
      builder: (context, state) => const NotificationsScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),

    // ═══════════════════════════════════════════════════════════════════════
    // ADMIN ROUTES
    // ═══════════════════════════════════════════════════════════════════════
    GoRoute(
      path: '/admin',
      builder: (context, state) => const AdminDashboardScreen(),
    ),
    GoRoute(
      path: '/admin/orders',
      builder: (context, state) => const AdminOrdersScreen(),
    ),
    GoRoute(
      path: '/admin/customers',
      builder: (context, state) => const AdminCustomersScreen(),
    ),

    // ═══════════════════════════════════════════════════════════════════════
    // NEW CATALOG ROUTES
    // ═══════════════════════════════════════════════════════════════════════
    GoRoute(
      path: '/category/:id',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        final name = state.uri.queryParameters['name'];
        return CategoryProductsScreen(categoryId: id, categoryName: name);
      },
    ),
    GoRoute(
      path: '/brand/:id',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return BrandDetailsScreen(brandId: id);
      },
    ),
    GoRoute(
      path: '/devices',
      builder: (context, state) => const DevicesListScreen(),
    ),
    GoRoute(
      path: '/device/:id',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        final name = state.uri.queryParameters['name'];
        return DeviceProductsScreen(deviceId: id, deviceName: name);
      },
    ),
    GoRoute(
      path: '/search-history',
      builder: (context, state) => const SearchHistoryScreen(),
    ),

    // ═══════════════════════════════════════════════════════════════════════
    // NEW CART ROUTES
    // ═══════════════════════════════════════════════════════════════════════
    GoRoute(
      path: '/checkout/payment',
      builder: (context, state) => const PaymentMethodScreen(),
    ),
    GoRoute(
      path: '/checkout/address',
      builder: (context, state) => const AddressSelectionScreen(),
    ),

    // ═══════════════════════════════════════════════════════════════════════
    // NEW WALLET ROUTES
    // ═══════════════════════════════════════════════════════════════════════
    GoRoute(
      path: '/wallet/transactions',
      builder: (context, state) => const WalletTransactionsScreen(),
    ),
    GoRoute(
      path: '/referral',
      builder: (context, state) => const ReferralScreen(),
    ),

    // ═══════════════════════════════════════════════════════════════════════
    // NEW ORDER ROUTES
    // ═══════════════════════════════════════════════════════════════════════
    GoRoute(
      path: '/order/:id/upload-receipt',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return UploadReceiptScreen(orderId: id);
      },
    ),
    GoRoute(
      path: '/order/:id/invoice',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return InvoiceViewScreen(orderId: id);
      },
    ),

    // ═══════════════════════════════════════════════════════════════════════
    // NEW PROFILE ROUTES
    // ═══════════════════════════════════════════════════════════════════════
    GoRoute(
      path: '/address/add',
      builder: (context, state) => const AddEditAddressScreen(),
    ),
    GoRoute(
      path: '/address/edit/:id',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return AddEditAddressScreen(addressId: id);
      },
    ),

    // ═══════════════════════════════════════════════════════════════════════
    // NEW SETTINGS ROUTES
    // ═══════════════════════════════════════════════════════════════════════
    GoRoute(
      path: '/settings/notifications',
      builder: (context, state) => const NotificationSettingsScreen(),
    ),
    GoRoute(
      path: '/settings/language',
      builder: (context, state) => const LanguageSettingsScreen(),
    ),

    // ═══════════════════════════════════════════════════════════════════════
    // NEW NOTIFICATION ROUTES
    // ═══════════════════════════════════════════════════════════════════════
    GoRoute(
      path: '/notification/:id',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return NotificationDetailsScreen(notificationId: id);
      },
    ),

    // ═══════════════════════════════════════════════════════════════════════
    // NEW EDUCATION ROUTES
    // ═══════════════════════════════════════════════════════════════════════
    GoRoute(
      path: '/education',
      builder: (context, state) => const EducationCategoriesScreen(),
    ),
    GoRoute(
      path: '/education/list/:id',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return EducationListScreen(categoryId: id);
      },
    ),
    GoRoute(
      path: '/education/details/:id',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return EducationDetailsScreen(contentId: id);
      },
    ),

    // ═══════════════════════════════════════════════════════════════════════
    // NEW WISHLIST ROUTES
    // ═══════════════════════════════════════════════════════════════════════
    GoRoute(
      path: '/stock-alerts',
      builder: (context, state) => const StockAlertsScreen(),
    ),

    // ═══════════════════════════════════════════════════════════════════════
    // NEW REVIEWS ROUTES
    // ═══════════════════════════════════════════════════════════════════════
    GoRoute(
      path: '/my-reviews',
      builder: (context, state) => const MyReviewsScreen(),
    ),

    // ═══════════════════════════════════════════════════════════════════════
    // NEW RETURNS ROUTES
    // ═══════════════════════════════════════════════════════════════════════
    GoRoute(
      path: '/return/:id',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return ReturnDetailsScreen(returnId: id);
      },
    ),
  ],
);
