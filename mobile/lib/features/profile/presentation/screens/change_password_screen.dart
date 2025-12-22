/// Change Password Screen - Update account password
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _showCurrentPassword = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.changePassword),
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_right_3),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Security Icon
              Center(
                child: Container(
                  width: 80.w,
                  height: 80.w,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Iconsax.lock,
                    size: 40.sp,
                    color: AppColors.primary,
                  ),
                ),
              ),
              SizedBox(height: 32.h),

              // Current Password
              _buildPasswordField(
                theme,
                isDark,
                controller: _currentPasswordController,
                label: 'كلمة المرور الحالية',
                showPassword: _showCurrentPassword,
                onToggle: () => setState(
                  () => _showCurrentPassword = !_showCurrentPassword,
                ),
              ),
              SizedBox(height: 16.h),

              // New Password
              _buildPasswordField(
                theme,
                isDark,
                controller: _newPasswordController,
                label: 'كلمة المرور الجديدة',
                showPassword: _showNewPassword,
                onToggle: () =>
                    setState(() => _showNewPassword = !_showNewPassword),
              ),
              SizedBox(height: 16.h),

              // Confirm Password
              _buildPasswordField(
                theme,
                isDark,
                controller: _confirmPasswordController,
                label: 'تأكيد كلمة المرور الجديدة',
                showPassword: _showConfirmPassword,
                onToggle: () => setState(
                  () => _showConfirmPassword = !_showConfirmPassword,
                ),
              ),
              SizedBox(height: 16.h),

              // Password Requirements
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'متطلبات كلمة المرور:',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    _buildRequirement('8 أحرف على الأقل'),
                    _buildRequirement('حرف كبير واحد على الأقل'),
                    _buildRequirement('رقم واحد على الأقل'),
                  ],
                ),
              ),
              SizedBox(height: 32.h),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _changePassword,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                  ),
                  child: const Text('تغيير كلمة المرور'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField(
    ThemeData theme,
    bool isDark, {
    required TextEditingController controller,
    required String label,
    required bool showPassword,
    required VoidCallback onToggle,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: !showPassword,
      validator: (value) {
        if (value == null || value.isEmpty) return 'هذا الحقل مطلوب';
        if (value.length < 8) return 'كلمة المرور قصيرة جداً';
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(
          Iconsax.lock,
          color: AppColors.textSecondaryLight,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            showPassword ? Iconsax.eye : Iconsax.eye_slash,
            color: AppColors.textSecondaryLight,
          ),
          onPressed: onToggle,
        ),
        filled: true,
        fillColor: isDark ? AppColors.cardDark : AppColors.cardLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
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
            color: AppColors.textTertiaryLight,
          ),
          SizedBox(width: 8.w),
          Text(
            text,
            style: TextStyle(
              fontSize: 12.sp,
              color: AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  void _changePassword() {
    if (_formKey.currentState!.validate()) {
      if (_newPasswordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('كلمات المرور غير متطابقة'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('تم تغيير كلمة المرور بنجاح'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
      );
      context.pop();
    }
  }
}
