/// Customer Enums - Domain enums for customer module
library;

import 'package:flutter/material.dart';

/// Business type for customer shops
enum BusinessType {
  shop,
  technician,
  distributor,
  other;

  static BusinessType fromString(String value) {
    return BusinessType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => BusinessType.shop,
    );
  }

  String get displayName {
    switch (this) {
      case BusinessType.shop:
        return 'متجر';
      case BusinessType.technician:
        return 'فني';
      case BusinessType.distributor:
        return 'موزع';
      case BusinessType.other:
        return 'آخر';
    }
  }
}

/// Loyalty tier levels
enum LoyaltyTier {
  bronze,
  silver,
  gold,
  platinum;

  static LoyaltyTier fromString(String value) {
    return LoyaltyTier.values.firstWhere(
      (e) => e.name == value,
      orElse: () => LoyaltyTier.bronze,
    );
  }

  String get displayName {
    switch (this) {
      case LoyaltyTier.bronze:
        return 'برونزي';
      case LoyaltyTier.silver:
        return 'فضي';
      case LoyaltyTier.gold:
        return 'ذهبي';
      case LoyaltyTier.platinum:
        return 'بلاتيني';
    }
  }

  Color get color {
    switch (this) {
      case LoyaltyTier.bronze:
        return const Color(0xFFCD7F32);
      case LoyaltyTier.silver:
        return const Color(0xFFC0C0C0);
      case LoyaltyTier.gold:
        return const Color(0xFFFFD700);
      case LoyaltyTier.platinum:
        return const Color(0xFFE5E4E2);
    }
  }

  IconData get icon {
    switch (this) {
      case LoyaltyTier.bronze:
        return Icons.star_border;
      case LoyaltyTier.silver:
        return Icons.star_half;
      case LoyaltyTier.gold:
        return Icons.star;
      case LoyaltyTier.platinum:
        return Icons.auto_awesome;
    }
  }
}

/// Payment method types
enum PaymentMethod {
  cod,
  bankTransfer,
  wallet;

  static PaymentMethod fromString(String value) {
    switch (value) {
      case 'cod':
        return PaymentMethod.cod;
      case 'bank_transfer':
        return PaymentMethod.bankTransfer;
      case 'wallet':
        return PaymentMethod.wallet;
      default:
        return PaymentMethod.cod;
    }
  }

  String get value {
    switch (this) {
      case PaymentMethod.cod:
        return 'cod';
      case PaymentMethod.bankTransfer:
        return 'bank_transfer';
      case PaymentMethod.wallet:
        return 'wallet';
    }
  }

  String get displayName {
    switch (this) {
      case PaymentMethod.cod:
        return 'الدفع عند الاستلام';
      case PaymentMethod.bankTransfer:
        return 'تحويل بنكي';
      case PaymentMethod.wallet:
        return 'المحفظة';
    }
  }
}

/// Contact method preferences
enum ContactMethod {
  phone,
  whatsapp,
  email;

  static ContactMethod fromString(String value) {
    return ContactMethod.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ContactMethod.whatsapp,
    );
  }

  String get displayName {
    switch (this) {
      case ContactMethod.phone:
        return 'هاتف';
      case ContactMethod.whatsapp:
        return 'واتساب';
      case ContactMethod.email:
        return 'بريد إلكتروني';
    }
  }
}

/// Referral status
enum ReferralStatus {
  pending,
  completed,
  expired,
  cancelled;

  static ReferralStatus fromString(String value) {
    return ReferralStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ReferralStatus.pending,
    );
  }

  String get displayName {
    switch (this) {
      case ReferralStatus.pending:
        return 'قيد الانتظار';
      case ReferralStatus.completed:
        return 'مكتملة';
      case ReferralStatus.expired:
        return 'منتهية';
      case ReferralStatus.cancelled:
        return 'ملغية';
    }
  }

  Color get color {
    switch (this) {
      case ReferralStatus.pending:
        return Colors.orange;
      case ReferralStatus.completed:
        return Colors.green;
      case ReferralStatus.expired:
        return Colors.grey;
      case ReferralStatus.cancelled:
        return Colors.red;
    }
  }
}
