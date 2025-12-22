/// Formatters - Date, currency, and other formatting utilities
library;

import 'package:intl/intl.dart';
import '../constants/app_constants.dart';

class Formatters {
  Formatters._();

  // ═══════════════════════════════════════════════════════════════════════════
  // CURRENCY FORMATTERS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Format price with currency symbol (Arabic)
  static String currency(double amount, {String? symbol}) {
    final formatter = NumberFormat('#,##0.00', 'ar');
    return '${formatter.format(amount)} ${symbol ?? AppConstants.currencySymbol}';
  }

  /// Format price without symbol
  static String price(double amount) {
    final formatter = NumberFormat('#,##0.00', 'ar');
    return formatter.format(amount);
  }

  /// Format integer with thousand separators
  static String number(int number) {
    final formatter = NumberFormat('#,##0', 'ar');
    return formatter.format(number);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // DATE FORMATTERS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Format date (Arabic) - e.g., "20 ديسمبر 2024"
  static String date(DateTime date, {String? locale}) {
    return DateFormat('d MMMM yyyy', locale ?? 'ar').format(date);
  }

  /// Format short date - e.g., "20/12/2024"
  static String shortDate(DateTime date) {
    return DateFormat('dd/MM/yyyy', 'ar').format(date);
  }

  /// Format time - e.g., "14:30"
  static String time(DateTime date) {
    return DateFormat('HH:mm', 'ar').format(date);
  }

  /// Format date and time - e.g., "20 ديسمبر 2024 - 14:30"
  static String dateTime(DateTime date) {
    return DateFormat('d MMMM yyyy - HH:mm', 'ar').format(date);
  }

  /// Format relative time (e.g., "منذ 5 دقائق")
  static String relativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) {
      return 'الآن';
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return 'منذ $minutes ${minutes == 1 ? 'دقيقة' : 'دقائق'}';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return 'منذ $hours ${hours == 1 ? 'ساعة' : 'ساعات'}';
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      return 'منذ $days ${days == 1 ? 'يوم' : 'أيام'}';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return 'منذ $weeks ${weeks == 1 ? 'أسبوع' : 'أسابيع'}';
    } else {
      return shortDate(date);
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // PHONE FORMATTERS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Format phone number with country code
  static String phone(String phone, {String countryCode = '+966'}) {
    final cleaned = phone.replaceAll(RegExp(r'[^\d]'), '');
    if (cleaned.length == 9) {
      return '$countryCode $cleaned';
    }
    return phone;
  }

  /// Format phone for display (e.g., "05X XXX XXXX")
  static String phoneDisplay(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'[^\d]'), '');
    if (cleaned.length == 9) {
      return '0${cleaned.substring(0, 2)} ${cleaned.substring(2, 5)} ${cleaned.substring(5)}';
    }
    return phone;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // OTHER FORMATTERS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Format order number
  static String orderNumber(String number) {
    return '#$number';
  }

  /// Format quantity
  static String quantity(int qty) {
    return 'x$qty';
  }

  /// Format percentage
  static String percentage(double value) {
    return '${value.toStringAsFixed(0)}%';
  }

  /// Format discount
  static String discount(double value) {
    return '- ${value.toStringAsFixed(0)}%';
  }

  /// Truncate text with ellipsis
  static String truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }
}
