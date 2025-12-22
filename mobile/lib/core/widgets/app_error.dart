/// AppError - Error display widgets
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import '../config/theme/app_colors.dart';
import 'app_button.dart';

/// Full page error state
class AppError extends StatelessWidget {
  final String? title;
  final String message;
  final String? buttonText;
  final VoidCallback? onRetry;
  final IconData? icon;

  const AppError({
    super.key,
    this.title,
    required this.message,
    this.buttonText,
    this.onRetry,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80.w,
              height: 80.w,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon ?? Iconsax.warning_2,
                size: 40.sp,
                color: AppColors.error,
              ),
            ),
            SizedBox(height: 24.h),
            if (title != null) ...[
              Text(
                title!,
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.h),
            ],
            Text(
              message,
              style: TextStyle(
                fontSize: 15.sp,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              SizedBox(height: 32.h),
              AppButton(
                text: buttonText ?? 'إعادة المحاولة',
                onPressed: onRetry,
                isFullWidth: false,
                size: AppButtonSize.medium,
                icon: Iconsax.refresh,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Network error state
class NetworkError extends StatelessWidget {
  final VoidCallback? onRetry;

  const NetworkError({super.key, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return AppError(
      icon: Iconsax.wifi_square,
      title: 'لا يوجد اتصال',
      message: 'تحقق من اتصالك بالإنترنت وحاول مرة أخرى',
      onRetry: onRetry,
    );
  }
}

/// Empty state widget
class EmptyState extends StatelessWidget {
  final String? title;
  final String message;
  final IconData? icon;
  final String? buttonText;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    this.title,
    required this.message,
    this.icon,
    this.buttonText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80.w,
              height: 80.w,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon ?? Iconsax.box_1,
                size: 40.sp,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: 24.h),
            if (title != null) ...[
              Text(
                title!,
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.h),
            ],
            Text(
              message,
              style: TextStyle(
                fontSize: 15.sp,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            if (onAction != null && buttonText != null) ...[
              SizedBox(height: 32.h),
              AppButton(
                text: buttonText!,
                onPressed: onAction,
                isFullWidth: false,
                size: AppButtonSize.medium,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
