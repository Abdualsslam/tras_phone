/// Auth Error Helper - Centralizes error message parsing for auth screens
library;

import 'package:flutter/material.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../../../../core/errors/exceptions.dart';

class AuthErrorHelper {
  /// Parse and clean an auth error message
  static String cleanMessage(String message, {bool isArabic = true}) {
    String clean = message;

    // Remove exception prefixes
    for (final prefix in [
      'AppException:',
      'ConflictException:',
      'Exception:',
    ]) {
      if (clean.contains(prefix)) {
        clean = clean.split(prefix).last.trim();
        break;
      }
    }

    // Remove code suffix
    if (clean.contains('(code:')) {
      clean = clean.split('(code:').first.trim();
    }

    // Replace with localized messages for known error types
    if (_isAccountUnderReview(message)) {
      return isArabic
          ? AccountUnderReviewException.arabicMessage
          : AccountUnderReviewException.englishMessage;
    }

    if (_isAccountRejected(message)) {
      return isArabic
          ? AccountRejectedException.arabicMessage
          : AccountRejectedException.englishMessage;
    }

    if (_isUserAlreadyExists(message)) {
      return isArabic
          ? ConflictException.userAlreadyExistsAr
          : ConflictException.userAlreadyExistsEn;
    }

    if (_isInvalidCredentials(message)) {
      return isArabic ? 'بيانات الدخول غير صحيحة' : 'Invalid credentials';
    }

    return clean;
  }

  static bool _isAccountUnderReview(String message) =>
      message.contains('account is under review') ||
      message.contains('قيد المراجعة') ||
      message.contains('ACCOUNT_UNDER_REVIEW') ||
      message.contains('under review');

  static bool _isAccountRejected(String message) =>
      message.contains('account has been rejected') ||
      message.contains('تم رفض') ||
      message.contains('ACCOUNT_REJECTED') ||
      message.contains('has been rejected');

  static bool _isUserAlreadyExists(String message) =>
      message.contains('phone or email already exists') ||
      message.contains('already exists') ||
      message.contains('موجود بالفعل') ||
      message.contains('CONFLICT') ||
      message.contains('ConflictException');

  static bool _isInvalidCredentials(String message) =>
      message.contains('Invalid credentials') ||
      message.contains('invalid credentials') ||
      message.contains('بيانات الدخول غير صحيحة') ||
      message.contains('رقم الجوال أو كلمة المرور غير صحيحة');

  /// Get background color for error snackbar
  static Color getBackgroundColor(String message) =>
      _isAccountUnderReview(message) ? AppColors.warning : AppColors.error;

  /// Get icon for error snackbar
  static IconData getIcon(String message) =>
      _isAccountUnderReview(message) ? Icons.warning_amber : Icons.info_outline;

  /// Show a standardized auth error snackbar
  static void showErrorSnackBar(
    BuildContext context,
    String message, {
    bool isArabic = true,
  }) {
    final cleanMsg = cleanMessage(message, isArabic: isArabic);
    final bgColor = getBackgroundColor(message);
    final icon = getIcon(message);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                cleanMsg,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
                textDirection:
                    isArabic ? TextDirection.rtl : TextDirection.ltr,
                textAlign: isArabic ? TextAlign.right : TextAlign.left,
              ),
            ),
          ],
        ),
        backgroundColor: bgColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      ),
    );
  }
}
