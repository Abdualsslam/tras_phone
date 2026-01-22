/// Banner Navigation Helper
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../domain/entities/banner_entity.dart';
import '../../domain/enums/banner_action_type.dart';

/// Helper class for banner navigation
class BannerNavigationHelper {
  /// Handle banner tap navigation
  static Future<void> handleBannerTap(
    BuildContext context,
    BannerEntity banner,
  ) async {
    if (!banner.action.isClickable) return;

    final action = banner.action;
    final path = action.navigationPath;

    switch (action.type) {
      case BannerActionType.link:
        if (action.url != null) {
          await _openUrl(action.url!);
        }
        break;

      case BannerActionType.product:
        if (path != null) {
          context.push(path);
        }
        break;

      case BannerActionType.category:
        if (path != null) {
          context.push(path);
        }
        break;

      case BannerActionType.brand:
        if (path != null) {
          context.push(path);
        }
        break;

      case BannerActionType.page:
        if (path != null) {
          context.push(path);
        }
        break;

      case BannerActionType.none:
        // Do nothing
        break;
    }
  }

  /// Open URL in browser
  static Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
