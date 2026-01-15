/// Wallet & Loyalty Enums
library;

import 'package:flutter/material.dart';

/// أنواع معاملات المحفظة
enum WalletTransactionType {
  orderPayment,
  orderRefund,
  walletTopup,
  walletWithdrawal,
  referralReward,
  loyaltyReward,
  adminCredit,
  adminDebit,
  expiredBalance;

  static WalletTransactionType fromString(String value) {
    switch (value) {
      case 'order_payment':
        return WalletTransactionType.orderPayment;
      case 'order_refund':
        return WalletTransactionType.orderRefund;
      case 'wallet_topup':
        return WalletTransactionType.walletTopup;
      case 'wallet_withdrawal':
        return WalletTransactionType.walletWithdrawal;
      case 'referral_reward':
        return WalletTransactionType.referralReward;
      case 'loyalty_reward':
        return WalletTransactionType.loyaltyReward;
      case 'admin_credit':
        return WalletTransactionType.adminCredit;
      case 'admin_debit':
        return WalletTransactionType.adminDebit;
      case 'expired_balance':
        return WalletTransactionType.expiredBalance;
      default:
        return WalletTransactionType.orderPayment;
    }
  }

  String get apiValue {
    switch (this) {
      case WalletTransactionType.orderPayment:
        return 'order_payment';
      case WalletTransactionType.orderRefund:
        return 'order_refund';
      case WalletTransactionType.walletTopup:
        return 'wallet_topup';
      case WalletTransactionType.walletWithdrawal:
        return 'wallet_withdrawal';
      case WalletTransactionType.referralReward:
        return 'referral_reward';
      case WalletTransactionType.loyaltyReward:
        return 'loyalty_reward';
      case WalletTransactionType.adminCredit:
        return 'admin_credit';
      case WalletTransactionType.adminDebit:
        return 'admin_debit';
      case WalletTransactionType.expiredBalance:
        return 'expired_balance';
    }
  }

  String get displayNameAr {
    switch (this) {
      case WalletTransactionType.orderPayment:
        return 'دفع طلب';
      case WalletTransactionType.orderRefund:
        return 'استرداد';
      case WalletTransactionType.walletTopup:
        return 'شحن رصيد';
      case WalletTransactionType.walletWithdrawal:
        return 'سحب';
      case WalletTransactionType.referralReward:
        return 'مكافأة إحالة';
      case WalletTransactionType.loyaltyReward:
        return 'مكافأة ولاء';
      case WalletTransactionType.adminCredit:
        return 'إضافة إدارية';
      case WalletTransactionType.adminDebit:
        return 'خصم إداري';
      case WalletTransactionType.expiredBalance:
        return 'رصيد منتهي';
    }
  }

  String get displayNameEn {
    switch (this) {
      case WalletTransactionType.orderPayment:
        return 'Order Payment';
      case WalletTransactionType.orderRefund:
        return 'Refund';
      case WalletTransactionType.walletTopup:
        return 'Top Up';
      case WalletTransactionType.walletWithdrawal:
        return 'Withdrawal';
      case WalletTransactionType.referralReward:
        return 'Referral Reward';
      case WalletTransactionType.loyaltyReward:
        return 'Loyalty Reward';
      case WalletTransactionType.adminCredit:
        return 'Admin Credit';
      case WalletTransactionType.adminDebit:
        return 'Admin Debit';
      case WalletTransactionType.expiredBalance:
        return 'Expired Balance';
    }
  }

  String getDisplayName(String locale) =>
      locale == 'ar' ? displayNameAr : displayNameEn;
}

/// اتجاه المعاملة
enum TransactionDirection {
  credit,
  debit;

  static TransactionDirection fromString(String value) {
    return TransactionDirection.values.firstWhere(
      (e) => e.name == value,
      orElse: () => TransactionDirection.credit,
    );
  }

  String get displayNameAr => this == credit ? 'إضافة' : 'خصم';
  String get displayNameEn => this == credit ? 'Credit' : 'Debit';
}

/// حالة معاملة المحفظة
enum WalletTransactionStatus {
  pending,
  completed,
  failed,
  cancelled;

  static WalletTransactionStatus fromString(String value) {
    return WalletTransactionStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => WalletTransactionStatus.completed,
    );
  }

  String get displayNameAr {
    switch (this) {
      case WalletTransactionStatus.pending:
        return 'قيد الانتظار';
      case WalletTransactionStatus.completed:
        return 'مكتملة';
      case WalletTransactionStatus.failed:
        return 'فاشلة';
      case WalletTransactionStatus.cancelled:
        return 'ملغاة';
    }
  }

  String get displayNameEn {
    switch (this) {
      case WalletTransactionStatus.pending:
        return 'Pending';
      case WalletTransactionStatus.completed:
        return 'Completed';
      case WalletTransactionStatus.failed:
        return 'Failed';
      case WalletTransactionStatus.cancelled:
        return 'Cancelled';
    }
  }

  Color get color {
    switch (this) {
      case WalletTransactionStatus.pending:
        return Colors.orange;
      case WalletTransactionStatus.completed:
        return Colors.green;
      case WalletTransactionStatus.failed:
        return Colors.red;
      case WalletTransactionStatus.cancelled:
        return Colors.grey;
    }
  }
}

/// أنواع معاملات نقاط الولاء
enum LoyaltyTransactionType {
  orderEarn,
  orderRedeem,
  orderCancel,
  signupBonus,
  referralEarn,
  birthdayBonus,
  tierUpgrade,
  adminGrant,
  adminDeduct,
  pointsExpiry,
  transferOut,
  transferIn;

  static LoyaltyTransactionType fromString(String value) {
    switch (value) {
      case 'order_earn':
        return LoyaltyTransactionType.orderEarn;
      case 'order_redeem':
        return LoyaltyTransactionType.orderRedeem;
      case 'order_cancel':
        return LoyaltyTransactionType.orderCancel;
      case 'signup_bonus':
        return LoyaltyTransactionType.signupBonus;
      case 'referral_earn':
        return LoyaltyTransactionType.referralEarn;
      case 'birthday_bonus':
        return LoyaltyTransactionType.birthdayBonus;
      case 'tier_upgrade':
        return LoyaltyTransactionType.tierUpgrade;
      case 'admin_grant':
        return LoyaltyTransactionType.adminGrant;
      case 'admin_deduct':
        return LoyaltyTransactionType.adminDeduct;
      case 'points_expiry':
        return LoyaltyTransactionType.pointsExpiry;
      case 'transfer_out':
        return LoyaltyTransactionType.transferOut;
      case 'transfer_in':
        return LoyaltyTransactionType.transferIn;
      default:
        return LoyaltyTransactionType.orderEarn;
    }
  }

  String get displayNameAr {
    switch (this) {
      case LoyaltyTransactionType.orderEarn:
        return 'كسب من طلب';
      case LoyaltyTransactionType.orderRedeem:
        return 'استخدام في طلب';
      case LoyaltyTransactionType.orderCancel:
        return 'إلغاء نقاط';
      case LoyaltyTransactionType.signupBonus:
        return 'مكافأة تسجيل';
      case LoyaltyTransactionType.referralEarn:
        return 'مكافأة إحالة';
      case LoyaltyTransactionType.birthdayBonus:
        return 'مكافأة عيد ميلاد';
      case LoyaltyTransactionType.tierUpgrade:
        return 'ترقية مستوى';
      case LoyaltyTransactionType.adminGrant:
        return 'إضافة إدارية';
      case LoyaltyTransactionType.adminDeduct:
        return 'خصم إداري';
      case LoyaltyTransactionType.pointsExpiry:
        return 'انتهاء صلاحية';
      case LoyaltyTransactionType.transferOut:
        return 'تحويل صادر';
      case LoyaltyTransactionType.transferIn:
        return 'تحويل وارد';
    }
  }

  String get displayNameEn {
    switch (this) {
      case LoyaltyTransactionType.orderEarn:
        return 'Order Earn';
      case LoyaltyTransactionType.orderRedeem:
        return 'Order Redeem';
      case LoyaltyTransactionType.orderCancel:
        return 'Order Cancel';
      case LoyaltyTransactionType.signupBonus:
        return 'Signup Bonus';
      case LoyaltyTransactionType.referralEarn:
        return 'Referral Earn';
      case LoyaltyTransactionType.birthdayBonus:
        return 'Birthday Bonus';
      case LoyaltyTransactionType.tierUpgrade:
        return 'Tier Upgrade';
      case LoyaltyTransactionType.adminGrant:
        return 'Admin Grant';
      case LoyaltyTransactionType.adminDeduct:
        return 'Admin Deduct';
      case LoyaltyTransactionType.pointsExpiry:
        return 'Points Expiry';
      case LoyaltyTransactionType.transferOut:
        return 'Transfer Out';
      case LoyaltyTransactionType.transferIn:
        return 'Transfer In';
    }
  }

  String getDisplayName(String locale) =>
      locale == 'ar' ? displayNameAr : displayNameEn;
}

/// اتجاه النقاط
enum PointsDirection {
  earn,
  redeem,
  expire,
  adjust;

  static PointsDirection fromString(String value) {
    return PointsDirection.values.firstWhere(
      (e) => e.name == value,
      orElse: () => PointsDirection.earn,
    );
  }

  String get displayNameAr {
    switch (this) {
      case PointsDirection.earn:
        return 'كسب';
      case PointsDirection.redeem:
        return 'استخدام';
      case PointsDirection.expire:
        return 'انتهاء';
      case PointsDirection.adjust:
        return 'تعديل';
    }
  }
}
