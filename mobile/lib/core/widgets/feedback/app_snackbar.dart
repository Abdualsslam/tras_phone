/// AppSnackbar - Custom snackbar component
library;

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../config/theme/app_colors.dart';

class AppSnackbar {
  static void showNetworkError(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final title = isArabic ? 'لا يوجد اتصال' : 'No Connection';
    final message = isArabic 
        ? 'تحقق من اتصالك بالإنترنت وحاول مرة أخرى' 
        : 'Please check your internet connection and try again';

    _show(
      context,
      title: title,
      message: message,
      icon: Icons.wifi_off_rounded,
      backgroundColor: AppColors.warning,
      textColor: Colors.black87,
      iconColor: Colors.black87,
    );
  }

  static void showError(BuildContext context, String message) {
    if (_isNetworkError(message)) {
      showNetworkError(context);
      return;
    }

    final cleanMsg = _cleanMessage(message);

    _show(
      context,
      message: cleanMsg,
      icon: Iconsax.warning_2,
      backgroundColor: AppColors.error,
    );
  }

  static void showSuccess(BuildContext context, String message) {
    _show(
      context,
      message: message,
      icon: Iconsax.tick_circle,
      backgroundColor: AppColors.success,
    );
  }

  static bool _isNetworkError(String message) {
    final lower = message.toLowerCase();
    return lower.contains('network_error') || 
           lower.contains('socketexception') ||
           lower.contains('لا يوجد اتصال') ||
           lower.contains('network failure') ||
           lower.contains('no internet') ||
           lower.contains('failed host lookup') ||
           lower.contains('networkexception');
  }

  static String _cleanMessage(String message) {
    String clean = message;
    
    // Remove exception prefixes
    final prefixes = [
      'AppException:', 'ServerException:', 'NetworkException:', 
      'CacheException:', 'AuthException:', 'UnauthorizedException:', 
      'ConflictException:', 'ValidationException:', 'Exception:', 'Failure:'
    ];
    for (final prefix in prefixes) {
      if (clean.contains(prefix)) {
        clean = clean.split(prefix).last.trim();
        break; // Only remove the first matched prefix
      }
    }

    // Remove code suffix like (code: NETWORK_ERROR)
    if (clean.contains('(code:')) {
      clean = clean.split('(code:').first.trim();
    }

    // Remove generic "Exception: " at the beginning if present
    if (clean.startsWith('Exception: ')) {
      clean = clean.substring(11).trim();
    }

    return clean;
  }

  static void _show(
    BuildContext context, {
    String? title,
    required String message,
    required IconData icon,
    required Color backgroundColor,
    Color textColor = Colors.white,
    Color iconColor = Colors.white,
  }) {
    // Hide current snackbar if any
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: textColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 24.sp),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (title != null) ...[
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    SizedBox(height: 4.h),
                  ],
                  Text(
                    message,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: title != null ? FontWeight.w500 : FontWeight.w600,
                      color: textColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        margin: EdgeInsets.only(
          bottom: 20.h,
          left: 16.w,
          right: 16.w,
        ),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        duration: const Duration(seconds: 4),
        elevation: 6,
      ),
    );
  }
}
