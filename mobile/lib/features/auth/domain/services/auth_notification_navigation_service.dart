library;

import 'dart:developer' as developer;

import 'package:url_launcher/url_launcher.dart';

import '../../../../routes/app_router.dart';

class AuthNotificationNavigationService {
  void handleNotificationTap(Map<String, dynamic> data) {
    try {
      final actionType = data['actionType'] as String?;
      final actionId = data['actionId'] as String?;
      final actionUrl = data['actionUrl'] as String?;
      final notificationId = data['notificationId'] as String?;

      if (actionType != null && actionId != null) {
        switch (actionType) {
          case 'order':
            appRouter.push('/orders/$actionId');
            return;
          case 'product':
            appRouter.push('/products/$actionId');
            return;
          case 'promotion':
            appRouter.push('/promotions/$actionId');
            return;
          case 'url':
            if (actionUrl != null) {
              launchUrl(
                Uri.parse(actionUrl),
                mode: LaunchMode.externalApplication,
              );
              return;
            }
            break;
        }
      }

      if (notificationId != null) {
        appRouter.push('/notification/$notificationId');
      } else {
        appRouter.push('/notifications');
      }
    } catch (e) {
      developer.log('Error handling notification tap: $e', name: 'AuthNotificationNavigationService');
    }
  }
}
