/// Validators - Form validation utilities
library;

import '../constants/app_constants.dart';

class Validators {
  Validators._();

  /// Phone number validation
  static String? phone(String? value) {
    if (value == null || value.isEmpty) {
      return 'رقم الجوال مطلوب';
    }
    final cleaned = value.replaceAll(RegExp(r'[^\d]'), '');
    if (!AppConstants.phonePattern.hasMatch(cleaned)) {
      return 'رقم الجوال غير صحيح';
    }
    return null;
  }

  /// Email validation
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'البريد الإلكتروني مطلوب';
    }
    if (!AppConstants.emailPattern.hasMatch(value)) {
      return 'البريد الإلكتروني غير صحيح';
    }
    return null;
  }

  /// Password validation
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'كلمة المرور مطلوبة';
    }
    if (value.length < AppConstants.minPasswordLength) {
      return 'كلمة المرور يجب أن تكون ${AppConstants.minPasswordLength} أحرف على الأقل';
    }
    return null;
  }

  /// Confirm password validation
  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'تأكيد كلمة المرور مطلوب';
    }
    if (value != password) {
      return 'كلمة المرور غير متطابقة';
    }
    return null;
  }

  /// Required field validation
  static String? required(String? value, [String? fieldName]) {
    if (value == null || value.trim().isEmpty) {
      return fieldName != null ? '$fieldName مطلوب' : 'هذا الحقل مطلوب';
    }
    return null;
  }

  /// OTP validation
  static String? otp(String? value) {
    if (value == null || value.isEmpty) {
      return 'رمز التحقق مطلوب';
    }
    if (value.length != AppConstants.otpLength) {
      return 'رمز التحقق يجب أن يكون ${AppConstants.otpLength} أرقام';
    }
    return null;
  }

  /// Name validation
  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'الاسم مطلوب';
    }
    if (value.trim().length < 2) {
      return 'الاسم يجب أن يكون حرفين على الأقل';
    }
    return null;
  }

  /// Shop name validation
  static String? shopName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'اسم المحل مطلوب';
    }
    if (value.trim().length < 3) {
      return 'اسم المحل يجب أن يكون 3 أحرف على الأقل';
    }
    return null;
  }

  /// Min length validation
  static String? minLength(String? value, int minLength, [String? fieldName]) {
    if (value == null || value.length < minLength) {
      return '${fieldName ?? 'الحقل'} يجب أن يكون $minLength أحرف على الأقل';
    }
    return null;
  }

  /// Max length validation
  static String? maxLength(String? value, int maxLength, [String? fieldName]) {
    if (value != null && value.length > maxLength) {
      return '${fieldName ?? 'الحقل'} يجب أن لا يتجاوز $maxLength حرف';
    }
    return null;
  }
}
