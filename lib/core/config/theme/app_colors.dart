/// App-wide color palette with Apple-inspired design
/// Updated to match TRAS Phone brand logo - Coral Orange identity
library;

import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Brand Colors (from logo - Coral Orange)
  static const Color primary = Color(
    0xFFE85D3D,
  ); // Coral Orange (main logo color)
  static const Color primaryLight = Color(0xFFFF7F5C); // Lighter Coral
  static const Color primaryDark = Color(0xFFD14325); // Darker Orange

  // Secondary Colors (complementary)
  static const Color secondary = Color(0xFF2D3748); // Dark Gray/Charcoal
  static const Color secondaryLight = Color(0xFF4A5568);
  static const Color secondaryDark = Color(0xFF1A202C);

  // Accent Colors (warm tones to complement orange)
  static const Color accent = Color(0xFFFF9F43); // Warm Orange/Gold
  static const Color accentLight = Color(0xFFFFBE76);
  static const Color accentDark = Color(0xFFE67E22);

  // Success/Error/Warning
  static const Color success = Color(0xFF00D68F); // Modern Green
  static const Color error = Color(0xFFFF4757); // Soft Red
  static const Color warning = Color(0xFFFFBE21); // Warm Yellow
  static const Color info = Color(0xFF3498DB); // Soft Blue

  // Neutral Colors - Light Mode
  static const Color backgroundLight = Color(0xFFF8F9FA);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color dividerLight = Color(0xFFE9ECEF);
  static const Color textPrimaryLight = Color(0xFF212529);
  static const Color textSecondaryLight = Color(0xFF6C757D);
  static const Color textTertiaryLight = Color(0xFFADB5BD);

  // Neutral Colors - Dark Mode
  static const Color backgroundDark = Color(0xFF0D1117);
  static const Color surfaceDark = Color(0xFF161B22);
  static const Color cardDark = Color(0xFF21262D);
  static const Color dividerDark = Color(0xFF30363D);
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFF8B949E);
  static const Color textTertiaryDark = Color(0xFF484F58);

  // Glassmorphism Colors
  static Color glassLight = Colors.white.withValues(alpha: 0.7);
  static Color glassDark = const Color(0xFF21262D).withValues(alpha: 0.8);
  static Color glassBorder = const Color(0xFFE85D3D).withValues(alpha: 0.2);

  // Gradient Colors (matching logo warm tones)
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFE85D3D), Color(0xFFFF7F5C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFFE85D3D), Color(0xFFFF9F43)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [Color(0xFF0D1117), Color(0xFF161B22)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient warmGradient = LinearGradient(
    colors: [Color(0xFFE85D3D), Color(0xFFFF9F43), Color(0xFFFFBE76)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Shadow Colors
  static Color shadowLight = Colors.black.withValues(alpha: 0.06);
  static Color shadowMedium = Colors.black.withValues(alpha: 0.10);
  static Color shadowDark = Colors.black.withValues(alpha: 0.16);
  static Color shadowPrimary = const Color(0xFFE85D3D).withValues(alpha: 0.25);
}
