/// Splash Screen - App startup screen
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/services/biometric_credential_service.dart';
import '../../../../core/services/biometric_service.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      context.read<AuthCubit>().checkAuthStatus();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) async {
        if (state is AuthAuthenticated) {
          context.go('/home');
        } else if (state is AuthUnauthenticated) {
          if (state.isFirstLaunch) {
            context.go('/onboarding');
          } else {
            // Check if biometric login is available
            final biometricService = getIt<BiometricService>();
            final credentialService = getIt<BiometricCredentialService>();
            final biometricAvailable = await biometricService.isAvailable();
            final biometricEnabled = await biometricService.isEnabled();
            final hasCredentials = await credentialService.hasCredentials();

            if (mounted &&
                biometricAvailable &&
                biometricEnabled &&
                hasCredentials) {
              context.go('/biometric-login');
            } else if (mounted) {
              context.go('/login');
            }
          }
        }
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.primary, AppColors.primaryDark],
            ),
          ),
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Center(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo Icon
                        Builder(
                          builder: (context) {
                            final isDark =
                                Theme.of(context).brightness == Brightness.dark;
                            return Container(
                              width: 120.w,
                              height: 120.w,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.cardDark
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(28.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.2),
                                    blurRadius: 30,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              padding: EdgeInsets.all(16.w),
                              child: Image.asset(
                                isDark
                                    ? 'assets/images/logo_dark.png'
                                    : 'assets/images/logo.png',
                                fit: BoxFit.contain,
                              ),
                            );
                          },
                        ),
                        SizedBox(height: 24.h),
                        // App Name
                        Text(
                          AppConfig.appNameAr,
                          style: TextStyle(
                            fontSize: 32.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 1,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        // Tagline
                        Text(
                          'قطع غيار الجوالات بين يديك',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w400,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                        SizedBox(height: 60.h),
                        // Loading indicator
                        SizedBox(
                          width: 24.w,
                          height: 24.w,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
