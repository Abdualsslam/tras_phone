/// Reset Password Screen - Set new password after OTP verification
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/widgets.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String phone;
  final String resetToken;

  const ResetPasswordScreen({
    super.key,
    required this.phone,
    required this.resetToken,
  });

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _showPassword = false;
  bool _showConfirmPassword = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleResetPassword() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('كلمات المرور غير متطابقة'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      context.read<AuthCubit>().resetPassword(
        resetToken: widget.resetToken,
        newPassword: _passwordController.text,
      );
    }
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

        if (state is AuthPasswordResetSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('تم إعادة تعيين كلمة المرور بنجاح'),
              backgroundColor: AppColors.success,
            ),
          );
          context.go('/login');
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
          appBar: AppBar(title: const Text('إعادة تعيين كلمة المرور')),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24.w),
              child: Form(
                key: _formKey,
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
                        Iconsax.lock_1,
                        size: 40.sp,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(height: 32.h),

                    // Title
                    Text(
                      'أدخل كلمة المرور الجديدة',
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      'يجب أن تكون كلمة المرور قوية وآمنة',
                      style: TextStyle(
                        fontSize: 15.sp,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8.h),

                    // Phone display
                    Text(
                      '+966 ${widget.phone}',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                      textDirection: TextDirection.ltr,
                    ),
                    SizedBox(height: 48.h),

                    // New Password Field
                    AppTextField(
                      label: 'كلمة المرور الجديدة',
                      hint: 'أدخل كلمة مرور قوية',
                      controller: _passwordController,
                      obscureText: !_showPassword,
                      prefixIcon: Iconsax.lock,
                      suffix: IconButton(
                        icon: Icon(
                          _showPassword ? Iconsax.eye : Iconsax.eye_slash,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                        onPressed: () => setState(() => _showPassword = !_showPassword),
                      ),
                      validator: Validators.password,
                      textInputAction: TextInputAction.next,
                    ),
                    SizedBox(height: 16.h),

                    // Confirm Password Field
                    AppTextField(
                      label: 'تأكيد كلمة المرور',
                      hint: 'أعد إدخال كلمة المرور',
                      controller: _confirmPasswordController,
                      obscureText: !_showConfirmPassword,
                      prefixIcon: Iconsax.lock,
                      suffix: IconButton(
                        icon: Icon(
                          _showConfirmPassword ? Iconsax.eye : Iconsax.eye_slash,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                        onPressed: () => setState(() => _showConfirmPassword = !_showConfirmPassword),
                      ),
                      validator: (value) => Validators.confirmPassword(
                        value,
                        _passwordController.text,
                      ),
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _handleResetPassword(),
                    ),
                    SizedBox(height: 24.h),

                    // Password Requirements
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: AppColors.info.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: AppColors.info.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Iconsax.info_circle,
                                size: 18.sp,
                                color: AppColors.info,
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                'متطلبات كلمة المرور',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.info,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12.h),
                          _buildRequirement('8 أحرف على الأقل'),
                          _buildRequirement('حرف كبير واحد على الأقل'),
                          _buildRequirement('حرف صغير واحد على الأقل'),
                          _buildRequirement('رقم واحد على الأقل'),
                          _buildRequirement(r'رمز خاص واحد على الأقل (@$!%*?&)'),
                        ],
                      ),
                    ),
                    SizedBox(height: 32.h),

                    // Reset Password Button
                    AppButton(
                      text: 'إعادة تعيين كلمة المرور',
                      onPressed: _handleResetPassword,
                      isLoading: _isLoading,
                    ),
                    SizedBox(height: 24.h),

                    // Back to Login
                    TextButton(
                      onPressed: () => context.go('/login'),
                      child: Text(
                        'العودة لتسجيل الدخول',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRequirement(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4.h),
      child: Row(
        children: [
          Icon(
            Iconsax.tick_circle,
            size: 14.sp,
            color: AppColors.success,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13.sp,
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}