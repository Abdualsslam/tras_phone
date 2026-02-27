/// AppError - Error display widgets
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import '../../config/theme/app_colors.dart';
import '../buttons/app_button.dart';

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

    final isNetwork = message.toLowerCase().contains('network') || 
                      message.contains('اتصال') || 
                      message.toLowerCase().contains('internet') ||
                      message.toLowerCase().contains('socketexception') ||
                      message.toLowerCase().contains('no connection');

    final displayIcon = isNetwork ? Icons.wifi_off_rounded : (icon ?? Iconsax.warning_2);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final displayTitle = isNetwork ? (isArabic ? 'لا يوجد اتصال' : 'No Connection') : title;
    final displayMessage = isNetwork 
        ? (isArabic ? 'تحقق من اتصالك بالإنترنت وحاول مرة أخرى' : 'Please check your internet connection and try again') 
        : _cleanMessage(message);
    final displayButtonText = isNetwork 
        ? (isArabic ? 'إعادة المحاولة' : 'Try Again') 
        : (buttonText ?? (isArabic ? 'إعادة المحاولة' : 'Try Again'));
    final containerColor = isNetwork ? AppColors.warning.withValues(alpha: 0.1) : AppColors.error.withValues(alpha: 0.1);
    final iconColor = isNetwork ? AppColors.warning : AppColors.error;

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
                color: containerColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                displayIcon,
                size: 40.sp,
                color: iconColor,
              ),
            ),
            SizedBox(height: 24.h),
            if (displayTitle != null) ...[
              Text(
                displayTitle,
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
              displayMessage,
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
                text: displayButtonText,
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

  static String _cleanMessage(String message) {
    String clean = message;
    
    final prefixes = [
      'AppException:', 'ServerException:', 'NetworkException:', 
      'CacheException:', 'AuthException:', 'UnauthorizedException:', 
      'ConflictException:', 'ValidationException:', 'Exception:', 'Failure:'
    ];
    for (final prefix in prefixes) {
      if (clean.contains(prefix)) {
        clean = clean.split(prefix).last.trim();
        break;
      }
    }

    if (clean.contains('(code:')) {
      clean = clean.split('(code:').first.trim();
    }

    if (clean.startsWith('Exception: ')) {
      clean = clean.substring(11).trim();
    }

    return clean;
  }
}

/// Network error state
class NetworkError extends StatelessWidget {
  final VoidCallback? onRetry;

  const NetworkError({super.key, this.onRetry});

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    return AppError(
      icon: Icons.wifi_off_rounded,
      title: isArabic ? 'لا يوجد اتصال' : 'No Connection',
      message: isArabic 
          ? 'تحقق من اتصالك بالإنترنت وحاول مرة أخرى' 
          : 'Please check your internet connection and try again',
      onRetry: onRetry,
    );
  }
}
