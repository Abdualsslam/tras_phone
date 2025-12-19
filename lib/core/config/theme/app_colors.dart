/// App-wide color palette with Apple-inspired design
/// Uses a modern, clean color scheme with glassmorphism support
library;

import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Brand Colors
  static const Color primary = Color(0xFF007AFF); // iOS Blue
  static const Color primaryLight = Color(0xFF5AC8FA);
  static const Color primaryDark = Color(0xFF0051D4);

  // Secondary Colors
  static const Color secondary = Color(0xFF5856D6); // iOS Purple
  static const Color secondaryLight = Color(0xFF787AFF);
  static const Color secondaryDark = Color(0xFF3634A3);

  // Accent Colors
  static const Color accent = Color(0xFFFF9500); // iOS Orange
  static const Color accentLight = Color(0xFFFFCC00);
  static const Color accentDark = Color(0xFFFF3B30);

  // Success/Error/Warning
  static const Color success = Color(0xFF34C759); // iOS Green
  static const Color error = Color(0xFFFF3B30); // iOS Red
  static const Color warning = Color(0xFFFFCC00); // iOS Yellow
  static const Color info = Color(0xFF5AC8FA); // iOS Teal

  // Neutral Colors - Light Mode
  static const Color backgroundLight = Color(0xFFF2F2F7);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color dividerLight = Color(0xFFE5E5EA);
  static const Color textPrimaryLight = Color(0xFF000000);
  static const Color textSecondaryLight = Color(0xFF8E8E93);
  static const Color textTertiaryLight = Color(0xFFC7C7CC);

  // Neutral Colors - Dark Mode
  static const Color backgroundDark = Color(0xFF000000);
  static const Color surfaceDark = Color(0xFF1C1C1E);
  static const Color cardDark = Color(0xFF2C2C2E);
  static const Color dividerDark = Color(0xFF38383A);
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFF8E8E93);
  static const Color textTertiaryDark = Color(0xFF48484A);

  // Glassmorphism Colors
  static Color glassLight = Colors.white.withValues(alpha: 0.7);
  static Color glassDark = Colors.black.withValues(alpha: 0.5);
  static Color glassBorder = Colors.white.withValues(alpha: 0.2);

  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [accent, accentLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [Color(0xFF1C1C1E), Color(0xFF2C2C2E)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Shadow Colors
  static Color shadowLight = Colors.black.withValues(alpha: 0.08);
  static Color shadowMedium = Colors.black.withValues(alpha: 0.12);
  static Color shadowDark = Colors.black.withValues(alpha: 0.20);
}
