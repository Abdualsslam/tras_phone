/// App Theme Configuration with Apple-inspired design
/// Supports both Light and Dark modes with iOS aesthetics
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  // Font Families - iOS Style
  static const String fontFamilyEn = 'Inter'; // Similar to SF Pro
  static const String fontFamilyAr = 'SFArabic'; // iOS Arabic System Font

  // Border Radius
  static BorderRadius radiusXs = BorderRadius.circular(4.r);
  static BorderRadius radiusSm = BorderRadius.circular(8.r);
  static BorderRadius radiusMd = BorderRadius.circular(12.r);
  static BorderRadius radiusLg = BorderRadius.circular(16.r);
  static BorderRadius radiusXl = BorderRadius.circular(24.r);
  static BorderRadius radiusFull = BorderRadius.circular(100.r);

  // Spacing
  static double spacingXxs = 4.w;
  static double spacingXs = 8.w;
  static double spacingSm = 12.w;
  static double spacingMd = 16.w;
  static double spacingLg = 24.w;
  static double spacingXl = 32.w;
  static double spacingXxl = 48.w;

  // ═══════════════════════════════════════════════════════════════════════════
  // LIGHT THEME
  // ═══════════════════════════════════════════════════════════════════════════
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: fontFamilyAr, // Use SFArabic for Arabic app
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.backgroundLight,

      // Color Scheme
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        primaryContainer: AppColors.primaryLight,
        secondary: AppColors.secondary,
        secondaryContainer: AppColors.secondaryLight,
        surface: AppColors.surfaceLight,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.textPrimaryLight,
        onError: Colors.white,
      ),

      // AppBar Theme
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: true,
        backgroundColor: AppColors.surfaceLight,
        foregroundColor: AppColors.textPrimaryLight,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: TextStyle(
          fontFamily: fontFamilyEn,
          fontSize: 17.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimaryLight,
        ),
        iconTheme: const IconThemeData(color: AppColors.primary),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.cardLight,
        shape: RoundedRectangleBorder(borderRadius: radiusMd),
        margin: EdgeInsets.zero,
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.backgroundLight,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        border: OutlineInputBorder(
          borderRadius: radiusMd,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: radiusMd,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: radiusMd,
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: radiusMd,
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        hintStyle: TextStyle(
          color: AppColors.textTertiaryLight,
          fontSize: 16.sp,
        ),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: Size(double.infinity, 50.h),
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 14.h),
          shape: RoundedRectangleBorder(borderRadius: radiusMd),
          textStyle: TextStyle(
            fontFamily: fontFamilyEn,
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: TextStyle(
            fontFamily: fontFamilyEn,
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          minimumSize: Size(double.infinity, 50.h),
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 14.h),
          shape: RoundedRectangleBorder(borderRadius: radiusMd),
          side: const BorderSide(color: AppColors.primary),
          textStyle: TextStyle(
            fontFamily: fontFamilyEn,
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.surfaceLight,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondaryLight,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: TextStyle(fontSize: 12.sp),
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: AppColors.dividerLight,
        thickness: 0.5,
        space: 0,
      ),

      // Text Theme
      textTheme: _buildTextTheme(isLight: true),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // DARK THEME
  // ═══════════════════════════════════════════════════════════════════════════
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: fontFamilyAr, // Use SFArabic for Arabic app
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.backgroundDark,

      // Color Scheme
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        primaryContainer: AppColors.primaryDark,
        secondary: AppColors.secondary,
        secondaryContainer: AppColors.secondaryDark,
        surface: AppColors.surfaceDark,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.textPrimaryDark,
        onError: Colors.white,
      ),

      // AppBar Theme
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: true,
        backgroundColor: AppColors.surfaceDark,
        foregroundColor: AppColors.textPrimaryDark,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: TextStyle(
          fontFamily: fontFamilyEn,
          fontSize: 17.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimaryDark,
        ),
        iconTheme: const IconThemeData(color: AppColors.primary),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.cardDark,
        shape: RoundedRectangleBorder(borderRadius: radiusMd),
        margin: EdgeInsets.zero,
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceDark,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        border: OutlineInputBorder(
          borderRadius: radiusMd,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: radiusMd,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: radiusMd,
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: radiusMd,
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        hintStyle: TextStyle(
          color: AppColors.textTertiaryDark,
          fontSize: 16.sp,
        ),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: Size(double.infinity, 50.h),
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 14.h),
          shape: RoundedRectangleBorder(borderRadius: radiusMd),
          textStyle: TextStyle(
            fontFamily: fontFamilyEn,
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: TextStyle(
            fontFamily: fontFamilyEn,
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          minimumSize: Size(double.infinity, 50.h),
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 14.h),
          shape: RoundedRectangleBorder(borderRadius: radiusMd),
          side: const BorderSide(color: AppColors.primary),
          textStyle: TextStyle(
            fontFamily: fontFamilyEn,
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.surfaceDark,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondaryDark,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: TextStyle(fontSize: 12.sp),
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: AppColors.dividerDark,
        thickness: 0.5,
        space: 0,
      ),

      // Text Theme
      textTheme: _buildTextTheme(isLight: false),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // TEXT THEME
  // ═══════════════════════════════════════════════════════════════════════════
  static TextTheme _buildTextTheme({required bool isLight}) {
    final Color textPrimary = isLight
        ? AppColors.textPrimaryLight
        : AppColors.textPrimaryDark;
    final Color textSecondary = isLight
        ? AppColors.textSecondaryLight
        : AppColors.textSecondaryDark;

    return TextTheme(
      // Display
      displayLarge: TextStyle(
        fontSize: 34.sp,
        fontWeight: FontWeight.w700,
        color: textPrimary,
        letterSpacing: 0.25,
      ),
      displayMedium: TextStyle(
        fontSize: 28.sp,
        fontWeight: FontWeight.w700,
        color: textPrimary,
        letterSpacing: 0,
      ),
      displaySmall: TextStyle(
        fontSize: 22.sp,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        letterSpacing: 0,
      ),

      // Headline
      headlineLarge: TextStyle(
        fontSize: 20.sp,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        letterSpacing: 0,
      ),
      headlineMedium: TextStyle(
        fontSize: 17.sp,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        letterSpacing: -0.41,
      ),
      headlineSmall: TextStyle(
        fontSize: 15.sp,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        letterSpacing: -0.24,
      ),

      // Title
      titleLarge: TextStyle(
        fontSize: 17.sp,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        letterSpacing: -0.41,
      ),
      titleMedium: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w500,
        color: textPrimary,
        letterSpacing: -0.32,
      ),
      titleSmall: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
        color: textPrimary,
        letterSpacing: -0.08,
      ),

      // Body
      bodyLarge: TextStyle(
        fontSize: 17.sp,
        fontWeight: FontWeight.w400,
        color: textPrimary,
        letterSpacing: -0.41,
      ),
      bodyMedium: TextStyle(
        fontSize: 15.sp,
        fontWeight: FontWeight.w400,
        color: textPrimary,
        letterSpacing: -0.24,
      ),
      bodySmall: TextStyle(
        fontSize: 13.sp,
        fontWeight: FontWeight.w400,
        color: textSecondary,
        letterSpacing: -0.08,
      ),

      // Label
      labelLarge: TextStyle(
        fontSize: 15.sp,
        fontWeight: FontWeight.w500,
        color: textPrimary,
        letterSpacing: -0.24,
      ),
      labelMedium: TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.w500,
        color: textSecondary,
        letterSpacing: 0,
      ),
      labelSmall: TextStyle(
        fontSize: 11.sp,
        fontWeight: FontWeight.w500,
        color: textSecondary,
        letterSpacing: 0.5,
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // BOX SHADOWS
  // ═══════════════════════════════════════════════════════════════════════════
  static List<BoxShadow> get shadowSm => [
    BoxShadow(
      color: AppColors.shadowLight,
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get shadowMd => [
    BoxShadow(
      color: AppColors.shadowMedium,
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get shadowLg => [
    BoxShadow(
      color: AppColors.shadowDark,
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];
}
