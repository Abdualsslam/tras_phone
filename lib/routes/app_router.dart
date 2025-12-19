/// App Router - GoRouter configuration
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/presentation/screens/forgot_password_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/onboarding_screen.dart';
import '../features/auth/presentation/screens/otp_verification_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/auth/presentation/screens/splash_screen.dart';
import '../features/navigation/presentation/screens/main_navigation_shell.dart';

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

    // Product routes
    GoRoute(
      path: '/product/:id',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return Scaffold(
          appBar: AppBar(title: Text('المنتج #$id')),
          body: Center(child: Text('Product Details: $id')),
        );
      },
    ),
    GoRoute(
      path: '/products',
      builder: (context, state) => Scaffold(
        appBar: AppBar(title: const Text('المنتجات')),
        body: const Center(child: Text('Products List')),
      ),
    ),

    // Category routes
    GoRoute(
      path: '/categories',
      builder: (context, state) => Scaffold(
        appBar: AppBar(title: const Text('الأقسام')),
        body: const Center(child: Text('Categories')),
      ),
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
      builder: (context, state) => Scaffold(
        appBar: AppBar(title: const Text('الماركات')),
        body: const Center(child: Text('Brands')),
      ),
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
    GoRoute(
      path: '/search',
      builder: (context, state) => Scaffold(
        appBar: AppBar(title: const Text('البحث')),
        body: const Center(child: Text('Search')),
      ),
    ),

    // Notifications
    GoRoute(
      path: '/notifications',
      builder: (context, state) => Scaffold(
        appBar: AppBar(title: const Text('الإشعارات')),
        body: const Center(child: Text('Notifications')),
      ),
    ),
  ],
);
