/// OTP Verification Screen
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../../../../core/config/theme/app_theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String phone;
  final String purpose;

  const OtpVerificationScreen({
    super.key,
    required this.phone,
    required this.purpose,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final _otpController = TextEditingController();
  bool _isLoading = false;
  int _resendTimer = 60;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  void _startResendTimer() {
    setState(() {
      _resendTimer = 60;
      _canResend = false;
    });

    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() => _resendTimer--);
      if (_resendTimer <= 0) {
        setState(() => _canResend = true);
        return false;
      }
      return true;
    });
  }

  void _handleVerify() {
    if (_otpController.text.length == 6) {
      if (widget.purpose == 'password_reset') {
        // For password reset, use verifyResetOtp to get resetToken
        context.read<AuthCubit>().verifyResetOtp(
          phone: widget.phone,
          otp: _otpController.text,
        );
      } else {
        // For registration/login, use regular verifyOtp
        context.read<AuthCubit>().verifyOtp(
          phone: widget.phone,
          otp: _otpController.text,
          purpose: widget.purpose,
        );
      }
    }
  }

  void _handleResend() {
    if (_canResend) {
      context.read<AuthCubit>().sendOtp(
        phone: widget.phone,
        purpose: widget.purpose,
      );
      _startResendTimer();
    }
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthLoading) {
          setState(() => _isLoading = true);
        } else {
          setState(() => _isLoading = false);
        }

        if (state is AuthOtpVerified) {
          if (widget.purpose == 'password_reset') {
            context.push('/reset-password', extra: {
              'phone': widget.phone,
              'resetToken': state.resetToken ?? '',
            });
          } else {
            context.go('/home');
          }
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: const Text('رمز التحقق')),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 40.h),

                  // Icon
                  Container(
                    width: 80.w,
                    height: 80.w,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Iconsax.sms,
                      size: 40.sp,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(height: 32.h),

                  // Title
                  Text(
                    'أدخل رمز التحقق',
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'تم إرسال رمز التحقق إلى',
                    style: TextStyle(
                      fontSize: 15.sp,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '+966 ${widget.phone}',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                    textDirection: TextDirection.ltr,
                  ),
                  SizedBox(height: 8.h),

                  // Test OTP hint
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.info.withValues(alpha: 0.1),
                      borderRadius: AppTheme.radiusSm,
                    ),
                    child: Text(
                      'للتجربة: الرمز هو 123456',
                      style: TextStyle(fontSize: 13.sp, color: AppColors.info),
                    ),
                  ),
                  SizedBox(height: 40.h),

                  // OTP Fields
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: PinCodeTextField(
                      appContext: context,
                      length: 6,
                      controller: _otpController,
                      keyboardType: TextInputType.number,
                      animationType: AnimationType.fade,
                      pinTheme: PinTheme(
                        shape: PinCodeFieldShape.box,
                        borderRadius: BorderRadius.circular(12.r),
                        fieldHeight: 56.h,
                        fieldWidth: 48.w,
                        activeColor: AppColors.primary,
                        selectedColor: AppColors.primary,
                        inactiveColor: isDark
                            ? AppColors.dividerDark
                            : AppColors.dividerLight,
                        activeFillColor: isDark
                            ? AppColors.surfaceDark
                            : AppColors.backgroundLight,
                        selectedFillColor: isDark
                            ? AppColors.surfaceDark
                            : AppColors.backgroundLight,
                        inactiveFillColor: isDark
                            ? AppColors.surfaceDark
                            : AppColors.backgroundLight,
                      ),
                      enableActiveFill: true,
                      textStyle: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                      onCompleted: (_) => _handleVerify(),
                      onChanged: (_) {},
                    ),
                  ),
                  SizedBox(height: 32.h),

                  // Verify Button
                  AppButton(
                    text: 'تحقق',
                    onPressed: _handleVerify,
                    isLoading: _isLoading,
                  ),
                  SizedBox(height: 24.h),

                  // Resend
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'لم تستلم الرمز؟',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                      TextButton(
                        onPressed: _canResend ? _handleResend : null,
                        child: Text(
                          _canResend
                              ? 'إعادة الإرسال'
                              : 'إعادة الإرسال ($_resendTimer)',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: _canResend
                                ? AppColors.primary
                                : (isDark
                                      ? AppColors.textTertiaryDark
                                      : AppColors.textTertiaryLight),
                          ),
                        ),
                      ),
                    ],
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
