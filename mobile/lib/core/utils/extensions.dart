/// Extensions - Dart extension methods for common types
library;

import 'package:flutter/material.dart';

// ═══════════════════════════════════════════════════════════════════════════
// STRING EXTENSIONS
// ═══════════════════════════════════════════════════════════════════════════

extension StringExtensions on String {
  /// Check if string is empty or contains only whitespace
  bool get isBlank => trim().isEmpty;

  /// Check if string is not empty
  bool get isNotBlank => trim().isNotEmpty;

  /// Capitalize first letter
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Capitalize all words
  String get titleCase {
    return split(' ').map((word) => word.capitalize).join(' ');
  }

  /// Remove all whitespace
  String get removeSpaces => replaceAll(RegExp(r'\s+'), '');

  /// Get initials from name
  String get initials {
    final words = trim().split(' ');
    if (words.isEmpty) return '';
    if (words.length == 1) return words[0][0].toUpperCase();
    return '${words[0][0]}${words[words.length - 1][0]}'.toUpperCase();
  }

  /// Check if string is valid email
  bool get isValidEmail {
    return RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(this);
  }

  /// Check if string is valid phone (9 digits)
  bool get isValidPhone {
    return RegExp(r'^[0-9]{9}$').hasMatch(replaceAll(RegExp(r'[^\d]'), ''));
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// NULLABLE STRING EXTENSIONS
// ═══════════════════════════════════════════════════════════════════════════

extension NullableStringExtensions on String? {
  /// Check if string is null or empty
  bool get isNullOrEmpty => this == null || this!.isEmpty;

  /// Check if string is not null and not empty
  bool get isNotNullOrEmpty => this != null && this!.isNotEmpty;

  /// Return string or default value
  String orDefault([String defaultValue = '']) => this ?? defaultValue;
}

// ═══════════════════════════════════════════════════════════════════════════
// LIST EXTENSIONS
// ═══════════════════════════════════════════════════════════════════════════

extension ListExtensions<T> on List<T> {
  /// Get first item or null if empty
  T? get firstOrNull => isEmpty ? null : first;

  /// Get last item or null if empty
  T? get lastOrNull => isEmpty ? null : last;

  /// Get item at index or null if out of bounds
  T? getOrNull(int index) {
    if (index < 0 || index >= length) return null;
    return this[index];
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// CONTEXT EXTENSIONS
// ═══════════════════════════════════════════════════════════════════════════

extension ContextExtensions on BuildContext {
  /// Get theme
  ThemeData get theme => Theme.of(this);

  /// Get text theme
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// Get color scheme
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// Get screen size
  Size get screenSize => MediaQuery.sizeOf(this);

  /// Get screen width
  double get screenWidth => MediaQuery.sizeOf(this).width;

  /// Get screen height
  double get screenHeight => MediaQuery.sizeOf(this).height;

  /// Check if dark mode
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  /// Get bottom padding (safe area)
  double get bottomPadding => MediaQuery.paddingOf(this).bottom;

  /// Get top padding (safe area)
  double get topPadding => MediaQuery.paddingOf(this).top;

  /// Check if RTL
  bool get isRtl => Directionality.of(this) == TextDirection.rtl;

  /// Show snackbar
  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? colorScheme.error : null,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// DATETIME EXTENSIONS
// ═══════════════════════════════════════════════════════════════════════════

extension DateTimeExtensions on DateTime {
  /// Check if date is today
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Check if date is yesterday
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  /// Check if date is in this week
  bool get isThisWeek {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 7));
    return isAfter(startOfWeek) && isBefore(endOfWeek);
  }

  /// Get start of day
  DateTime get startOfDay => DateTime(year, month, day);

  /// Get end of day
  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59);
}

// ═══════════════════════════════════════════════════════════════════════════
// DOUBLE EXTENSIONS
// ═══════════════════════════════════════════════════════════════════════════

extension DoubleExtensions on double {
  /// Convert to price string
  String get toPriceString => toStringAsFixed(2);

  /// Convert to percentage string
  String get toPercentageString => '${toStringAsFixed(0)}%';
}
