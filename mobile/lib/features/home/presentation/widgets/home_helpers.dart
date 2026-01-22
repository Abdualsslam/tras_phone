import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

/// Helper class for home screen utility functions
class HomeHelpers {
  /// Get icon for category based on slug
  static IconData getCategoryIcon(String slug) {
    switch (slug) {
      case 'screens':
        return Iconsax.mobile;
      case 'batteries':
        return Iconsax.battery_charging;
      case 'charging-ports':
        return Iconsax.flash_1;
      case 'back-covers':
        return Iconsax.back_square;
      case 'cameras':
        return Iconsax.camera;
      case 'speakers':
        return Iconsax.volume_high;
      default:
        return Iconsax.cpu;
    }
  }

  /// Get brand logo path based on slug
  /// TODO: استخدم صور العلامات التجارية من الـ API
  static String? getBrandLogo(String slug) {
    return null;
  }
}
