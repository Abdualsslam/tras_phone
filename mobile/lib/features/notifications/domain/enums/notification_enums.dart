/// Notification Enums - Domain enums for notifications module
library;

import 'package:flutter/material.dart';

/// Notification categories
enum NotificationCategory {
  order,
  payment,
  promotion,
  system,
  account,
  support,
  marketing;

  static NotificationCategory fromString(String value) {
    return NotificationCategory.values.firstWhere(
      (e) => e.name == value,
      orElse: () => NotificationCategory.system,
    );
  }

  String get displayNameAr {
    switch (this) {
      case NotificationCategory.order:
        return 'الطلبات';
      case NotificationCategory.payment:
        return 'المدفوعات';
      case NotificationCategory.promotion:
        return 'العروض';
      case NotificationCategory.system:
        return 'النظام';
      case NotificationCategory.account:
        return 'الحساب';
      case NotificationCategory.support:
        return 'الدعم';
      case NotificationCategory.marketing:
        return 'التسويق';
    }
  }

  IconData get icon {
    switch (this) {
      case NotificationCategory.order:
        return Icons.shopping_bag;
      case NotificationCategory.payment:
        return Icons.payment;
      case NotificationCategory.promotion:
        return Icons.local_offer;
      case NotificationCategory.system:
        return Icons.settings;
      case NotificationCategory.account:
        return Icons.person;
      case NotificationCategory.support:
        return Icons.support_agent;
      case NotificationCategory.marketing:
        return Icons.campaign;
    }
  }

  Color get color {
    switch (this) {
      case NotificationCategory.order:
        return Colors.blue;
      case NotificationCategory.payment:
        return Colors.green;
      case NotificationCategory.promotion:
        return Colors.orange;
      case NotificationCategory.system:
        return Colors.grey;
      case NotificationCategory.account:
        return Colors.purple;
      case NotificationCategory.support:
        return Colors.teal;
      case NotificationCategory.marketing:
        return Colors.pink;
    }
  }
}

/// Notification action types
enum NotificationActionType {
  order,
  product,
  promotion,
  url;

  static NotificationActionType fromString(String value) {
    return NotificationActionType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => NotificationActionType.url,
    );
  }
}

/// Push notification providers
enum PushProvider {
  fcm,
  apns,
  web;

  static PushProvider fromString(String value) {
    return PushProvider.values.firstWhere(
      (e) => e.name == value,
      orElse: () => PushProvider.fcm,
    );
  }
}

/// Push notification platforms
enum PushPlatform {
  ios,
  android,
  web;

  static PushPlatform fromString(String value) {
    return PushPlatform.values.firstWhere(
      (e) => e.name == value,
      orElse: () => PushPlatform.android,
    );
  }
}
