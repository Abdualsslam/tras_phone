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
import '../features/catalog/domain/entities/product_entity.dart';
import '../features/navigation/presentation/screens/main_navigation_shell.dart';
import '../features/wallet/presentation/screens/wallet_screen.dart';
import '../features/wallet/presentation/screens/loyalty_points_screen.dart';
import '../features/notifications/presentation/screens/notifications_screen.dart';
import '../features/settings/presentation/screens/settings_screen.dart';

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

    // Product routes
    GoRoute(
      path: '/product/:id',
      builder: (context, state) {
        final product = state.extra as ProductEntity?;
        if (product != null) {
          return ProductDetailsScreen(product: product);
        }
        return Scaffold(
          appBar: AppBar(title: const Text('المنتج')),
          body: const Center(child: Text('المنتج غير موجود')),
        );
      },
    ),

    // Category routes
    GoRoute(
      path: '/categories',
      builder: (context, state) => const CategoriesListScreen(),
    ),
    GoRoute(
      path: '/category/:id/products',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return Scaffold(
          appBar: AppBar(title: Text('القسم #$id')),
          body: Center(child: Text('Category Products: $id')),
        );
      },
    ),

    // Brand routes
    GoRoute(
      path: '/brands',
      builder: (context, state) => const BrandsListScreen(),
    ),
    GoRoute(
      path: '/brand/:id/products',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return Scaffold(
          appBar: AppBar(title: Text('الماركة #$id')),
          body: Center(child: Text('Brand Products: $id')),
        );
      },
    ),

    // Search
    GoRoute(path: '/search', builder: (context, state) => const SearchScreen()),

    // ═══════════════════════════════════════════════════════════════════════
    // WALLET & LOYALTY ROUTES
    // ═══════════════════════════════════════════════════════════════════════
    GoRoute(path: '/wallet', builder: (context, state) => const WalletScreen()),
    GoRoute(
      path: '/loyalty-points',
      builder: (context, state) => const LoyaltyPointsScreen(),
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
  ],
);
