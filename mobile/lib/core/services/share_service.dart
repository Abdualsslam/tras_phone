/// Share Service - Handles app sharing functionality
library;

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class ShareService {
  /// Share app link
  /// You can customize the app link and message based on your app store URLs
  Future<void> shareApp({
    String? appLink,
    String? message,
    BuildContext? context,
  }) async {
    try {
      // Default app link - replace with your actual app store links
      final defaultAppLink = appLink ??
          'https://play.google.com/store/apps/details?id=com.trasphone.app';

      // Get localized message if context is provided
      String shareMessage;
      if (message != null) {
        shareMessage = message;
      } else if (context != null) {
        final locale = Localizations.localeOf(context);
        shareMessage = locale.languageCode == 'ar'
            ? 'جرب تطبيق تراس فون - أفضل منصة لقطع غيار الهواتف المحمولة!\n\n$defaultAppLink'
            : 'Try TRAS Phone app - The best platform for mobile phone spare parts!\n\n$defaultAppLink';
      } else {
        shareMessage =
            'Try TRAS Phone app - The best platform for mobile phone spare parts!\n\n$defaultAppLink';
      }

      await Share.share(
        shareMessage,
        subject: 'TRAS Phone App',
      );
    } catch (e) {
      // Handle sharing errors
      rethrow;
    }
  }
}
