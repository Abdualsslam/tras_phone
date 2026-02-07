/// Biometric Login Screen - Login using fingerprint or Face ID
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../../../../core/config/theme/app_theme.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

class BiometricLoginScreen extends StatefulWidget {
  const BiometricLoginScreen({super.key});

  @override
  State<BiometricLoginScreen> createState() => _BiometricLoginScreenState();
}

class _BiometricLoginScreenState extends State<BiometricLoginScreen> {
  bool _hasTriggeredBiometric = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _triggerBiometricAuth();
    });
  }

  Future<void> _triggerBiometricAuth() async {
    if (_hasTriggeredBiometric || !mounted) return;
    _hasTriggeredBiometric = true;

    await context.read<AuthCubit>().loginWithBiometric();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          context.go('/home');
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
          // Reset so user can try again
          if (mounted) {
            setState(() => _hasTriggeredBiometric = false);
          }
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 60.h),

                  // Logo
                  Center(
                    child: Container(
                      width: 100.w,
                      height: 100.w,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.cardDark : Colors.white,
                        borderRadius: BorderRadius.circular(24.r),
                        boxShadow: AppTheme.shadowMd,
                      ),
                      padding: EdgeInsets.all(12.w),
                      child: Image.asset(
                        isDark
                            ? 'assets/images/logo_dark.png'
                            : 'assets/images/logo.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  SizedBox(height: 32.h),

                  // Title
                  Center(
                    child: Text(
                      'سجل دخولك بالبصمة',
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Center(
                    child: Text(
                      'استخدم بصمتك أو Face ID للدخول',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                  ),
                  SizedBox(height: 48.h),

                  // Biometric icon button
                  Center(
                    child: GestureDetector(
                      onTap: isLoading ? null : _triggerBiometricAuth,
                      child: Container(
                        width: 120.w,
                        height: 120.w,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.2),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: isLoading
                            ? Padding(
                                padding: EdgeInsets.all(40.w),
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  valueColor: const AlwaysStoppedAnimation<Color>(
                                    AppColors.primary,
                                  ),
                                ),
                              )
                            : Icon(
                                Iconsax.finger_scan,
                                size: 56.sp,
                                color: AppColors.primary,
                              ),
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),

                  if (!isLoading)
                    Center(
                      child: Text(
                        'اضغط للمصادقة',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                    ),
                  SizedBox(height: 48.h),

                  // Manual login button
                  TextButton(
                    onPressed: isLoading
                        ? null
                        : () => context.go('/login'),
                    child: Text(
                      'تسجيل الدخول يدوياً',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
