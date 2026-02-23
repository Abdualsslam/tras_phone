/// App Router - GoRouter configuration
library;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../core/di/injection.dart';
import '../features/cart/presentation/cubit/checkout_session_cubit.dart';
import '../features/auth/presentation/screens/forgot_password_screen.dart';
import '../features/auth/presentation/screens/biometric_login_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/onboarding_screen.dart';
import '../features/auth/presentation/screens/otp_verification_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/auth/presentation/screens/reset_password_screen.dart';
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
import '../features/wallet/presentation/screens/loyalty_tiers_screen.dart';
import '../features/wallet/presentation/screens/loyalty_transactions_screen.dart';
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
import '../features/favorite/presentation/screens/favorite_screen.dart';
import '../features/favorite/presentation/screens/stock_alerts_screen.dart';
import '../features/reviews/presentation/screens/product_reviews_screen.dart';
import '../features/reviews/presentation/screens/write_review_screen.dart';
import '../features/reviews/presentation/screens/my_reviews_screen.dart';
import '../features/returns/presentation/screens/returns_list_screen.dart';
import '../features/returns/presentation/screens/create_return_screen.dart';
import '../features/returns/presentation/screens/return_details_screen.dart';
import '../features/returns/presentation/screens/select_items_for_return_screen.dart';
import '../features/returns/data/models/return_model.dart';
import '../features/support/presentation/screens/support_tickets_screen.dart';
import '../features/support/presentation/screens/ticket_chat_screen.dart';
import '../features/support/presentation/screens/create_ticket_screen.dart';
import '../features/education/presentation/screens/faq_screen.dart';
import '../features/education/presentation/screens/static_page_screen.dart';
import '../features/address/presentation/screens/map_location_picker_screen.dart';
import '../features/education/presentation/screens/education_categories_screen.dart';
import '../features/education/presentation/screens/education_list_screen.dart';
import '../features/education/presentation/screens/education_details_screen.dart';
import '../features/education/presentation/screens/product_education_list_screen.dart';
import '../features/orders/presentation/screens/order_details_screen.dart';
import '../features/profile/domain/entities/address_entity.dart';
import '../features/orders/presentation/screens/order_tracking_screen.dart';
import '../features/orders/presentation/screens/upload_receipt_screen.dart';
import '../features/orders/presentation/screens/invoice_view_screen.dart';
import '../features/profile/presentation/screens/addresses_list_screen.dart';
import '../features/profile/presentation/screens/edit_profile_screen.dart';
import '../features/profile/presentation/screens/change_password_screen.dart';
import '../features/profile/presentation/screens/add_edit_address_screen.dart';
import '../features/catalog/presentation/screens/advanced_search_screen.dart';
import '../features/catalog/presentation/screens/product_search_results_screen.dart';
import '../features/reviews/presentation/screens/pending_reviews_screen.dart';
import '../features/support/presentation/screens/ticket_details_screen.dart';
import '../features/support/presentation/screens/live_chat_screen.dart';
import '../features/favorite/presentation/screens/favorite_empty_screen.dart';

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
    GoRoute(
      path: '/biometric-login',
      builder: (context, state) => const BiometricLoginScreen(),
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
    GoRoute(
      path: '/reset-password',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return ResetPasswordScreen(
          phone: extra?['phone'] ?? '',
          resetToken: extra?['resetToken'] ?? '',
        );
      },
    ),

    // ═══════════════════════════════════════════════════════════════════════
    // MAIN APP ROUTES
    // ═══════════════════════════════════════════════════════════════════════
    GoRoute(
      path: '/home',
      builder: (context, state) {
        final tabIndex =
            int.tryParse(state.uri.queryParameters['tab'] ?? '0') ?? 0;
        return MainNavigationShell(initialIndex: tabIndex.clamp(0, 4));
      },
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
      path: '/product/:id/education',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        final extra = state.extra;
        final productName = extra is Map<String, dynamic>
            ? extra['productName'] as String?
            : state.uri.queryParameters['productName'];

        return ProductEducationListScreen(
          productId: id,
          productName: productName,
        );
      },
    ),
    GoRoute(
      path: '/categories',
      builder: (context, state) => const CategoriesListScreen(),
    ),
    GoRoute(
      path: '/brands',
      builder: (context, state) {
        final flowParam = state.uri.queryParameters['flow'];
        final flow =
            flowParam == null || flowParam == '1' || flowParam == 'true';
        final categoryId = state.uri.queryParameters['categoryId'];
        final categoryName = state.uri.queryParameters['categoryName'];

        return BrandsListScreen(
          flowMode: flow,
          categoryId: categoryId,
          categoryName: categoryName,
        );
      },
    ),
    GoRoute(path: '/search', builder: (context, state) => const SearchScreen()),
    GoRoute(
      path: '/products',
      builder: (context, state) {
        final isFeatured =
            state.uri.queryParameters['isFeatured'] ??
            state.uri.queryParameters['featured'];
        final sort = state.uri.queryParameters['sort'];
        final categoryId = state.uri.queryParameters['categoryId'];
        final categoryName = state.uri.queryParameters['categoryName'];
        final brandId = state.uri.queryParameters['brandId'];
        final brandName = state.uri.queryParameters['brandName'];
        final deviceId = state.uri.queryParameters['deviceId'];
        final deviceName = state.uri.queryParameters['deviceName'];
        return ProductsListScreen(
          isFeatured: isFeatured == 'true' ? true : null,
          sortBy: sort,
          categoryId: categoryId,
          categoryName: categoryName,
          brandId: brandId,
          brandName: brandName,
          deviceId: deviceId,
          deviceName: deviceName,
        );
      },
    ),

    // ═══════════════════════════════════════════════════════════════════════
    // CART & CHECKOUT ROUTES
    // ═══════════════════════════════════════════════════════════════════════
    GoRoute(
      path: '/checkout',
      builder: (context, state) => BlocProvider(
        create: (_) => getIt<CheckoutSessionCubit>(),
        child: const CheckoutScreen(),
      ),
    ),
    GoRoute(
      path: '/order-confirmation',
      builder: (context, state) => const OrderConfirmationScreen(),
    ),

    // ═══════════════════════════════════════════════════════════════════════
    // ORDER ROUTES
    // ═══════════════════════════════════════════════════════════════════════
    GoRoute(path: '/orders', redirect: (context, state) => '/home?tab=1'),
    GoRoute(
      path: '/order/:id',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return OrderDetailsScreen(orderId: id);
      },
    ),
    // Alias for checkout screen navigation
    GoRoute(
      path: '/order-details/:id',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return OrderDetailsScreen(orderId: id);
      },
    ),
    GoRoute(
      path: '/order/:id/tracking',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        final extra = state.extra;
        final orderNumber = extra is String ? extra : 'ORD-$id';
        return OrderTrackingScreen(orderId: id, orderNumber: orderNumber);
      },
    ),

    // ═══════════════════════════════════════════════════════════════════════
    // FAVORITES & REVIEWS ROUTES
    // ═══════════════════════════════════════════════════════════════════════
    GoRoute(
      path: '/favorites',
      builder: (context, state) => const FavoriteScreen(),
    ),
    GoRoute(
      path: '/product/:id/reviews',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        final extra = state.extra;
        return ProductReviewsScreen(
          productId: id,
          productName: extra is Map ? extra['productName'] as String? : null,
          averageRating: extra is Map
              ? extra['averageRating'] as double?
              : null,
          reviewsCount: extra is Map ? extra['reviewsCount'] as int? : null,
        );
      },
    ),
    GoRoute(
      path: '/product/:id/write-review',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        final extra = state.extra;
        final productName = extra is Map
            ? extra['productName'] as String?
            : null;
        return WriteReviewScreen(
          productId: id,
          productName: productName ?? 'المنتج',
        );
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
      path: '/returns/select-items',
      builder: (context, state) => const SelectItemsForReturnScreen(),
    ),
    GoRoute(
      path: '/returns/create',
      builder: (context, state) {
        final preSelectedItems = state.extra as List<CreateReturnItemRequest>?;
        return CreateReturnScreen(preSelectedItems: preSelectedItems);
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
    GoRoute(
      path: '/loyalty-tiers',
      builder: (context, state) => const LoyaltyTiersScreen(),
    ),
    GoRoute(
      path: '/loyalty/transactions',
      builder: (context, state) => const LoyaltyTransactionsScreen(),
    ),

    // ═══════════════════════════════════════════════════════════════════════
    // PROFILE ROUTES
    // ═══════════════════════════════════════════════════════════════════════
    GoRoute(
      path: '/addresses',
      builder: (context, state) => const AddressesListScreen(),
    ),
    GoRoute(
      path: '/map/location-picker',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return MapLocationPickerScreen(
          initialLatitude: extra?['initialLatitude'] as double?,
          initialLongitude: extra?['initialLongitude'] as double?,
        );
      },
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
        final id = state.pathParameters['id'] ?? '';
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
      path: '/brand/:slug',
      builder: (context, state) {
        final slug = state.pathParameters['slug'] ?? '';
        return BrandDetailsScreen(brandSlug: slug);
      },
    ),
    GoRoute(
      path: '/devices',
      builder: (context, state) {
        final flow =
            state.uri.queryParameters['flow'] == '1' ||
            state.uri.queryParameters['flow'] == 'true';
        final categoryId = state.uri.queryParameters['categoryId'];
        final categoryName = state.uri.queryParameters['categoryName'];
        final brandId = state.uri.queryParameters['brandId'];
        final brandName = state.uri.queryParameters['brandName'];

        return DevicesListScreen(
          flowMode: flow,
          categoryId: categoryId,
          categoryName: categoryName,
          initialBrandId: brandId,
          initialBrandName: brandName,
        );
      },
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
        final extra = state.extra as Map<String, dynamic>?;
        final amount = (extra?['amount'] as num?)?.toDouble() ?? 0.0;
        return UploadReceiptScreen(orderId: id, amount: amount);
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
      path: '/address/edit',
      builder: (context, state) {
        final address = state.extra as AddressEntity?;
        return AddEditAddressScreen(address: address);
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
    // NEW FAVORITES ROUTES
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

    // ═══════════════════════════════════════════════════════════════════════
    // NEW SEARCH ROUTES
    // ═══════════════════════════════════════════════════════════════════════
    GoRoute(
      path: '/advanced-search',
      builder: (context, state) => const AdvancedSearchScreen(),
    ),
    GoRoute(
      path: '/search-results',
      builder: (context, state) {
        final filters = state.extra as Map<String, dynamic>?;
        return ProductSearchResultsScreen(filters: filters);
      },
    ),

    // ═══════════════════════════════════════════════════════════════════════
    // NEW REVIEWS ROUTES
    // ═══════════════════════════════════════════════════════════════════════
    GoRoute(
      path: '/pending-reviews',
      builder: (context, state) => const PendingReviewsScreen(),
    ),

    // ═══════════════════════════════════════════════════════════════════════
    // NEW SUPPORT ROUTES
    // ═══════════════════════════════════════════════════════════════════════
    GoRoute(
      path: '/ticket/:id',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return TicketDetailsScreen(ticketId: id);
      },
    ),
    GoRoute(
      path: '/live-chat',
      builder: (context, state) => const LiveChatScreen(),
    ),

    // ═══════════════════════════════════════════════════════════════════════
    // NEW WISHLIST ROUTES
    // ═══════════════════════════════════════════════════════════════════════
    GoRoute(
      path: '/favorites-empty',
      builder: (context, state) => const FavoriteEmptyScreen(),
    ),
  ],
);
