/// Order Enums - Domain enums for orders module
library;

import 'package:flutter/material.dart';

/// Order statuses (10 states)
enum OrderStatus {
  pending,
  confirmed,
  processing,
  readyForPickup,
  shipped,
  outForDelivery,
  delivered,
  completed,
  cancelled,
  refunded;

  static OrderStatus fromString(String value) {
    switch (value) {
      case 'pending':
        return OrderStatus.pending;
      case 'confirmed':
        return OrderStatus.confirmed;
      case 'processing':
        return OrderStatus.processing;
      case 'ready_for_pickup':
        return OrderStatus.readyForPickup;
      case 'shipped':
        return OrderStatus.shipped;
      case 'out_for_delivery':
        return OrderStatus.outForDelivery;
      case 'delivered':
        return OrderStatus.delivered;
      case 'completed':
        return OrderStatus.completed;
      case 'cancelled':
        return OrderStatus.cancelled;
      case 'refunded':
        return OrderStatus.refunded;
      default:
        return OrderStatus.pending;
    }
  }

  String get value {
    switch (this) {
      case OrderStatus.readyForPickup:
        return 'ready_for_pickup';
      case OrderStatus.outForDelivery:
        return 'out_for_delivery';
      default:
        return name;
    }
  }

  String get displayNameAr {
    switch (this) {
      case OrderStatus.pending:
        return 'في الانتظار';
      case OrderStatus.confirmed:
        return 'تم التأكيد';
      case OrderStatus.processing:
        return 'قيد المعالجة';
      case OrderStatus.readyForPickup:
        return 'جاهز للاستلام';
      case OrderStatus.shipped:
        return 'تم الشحن';
      case OrderStatus.outForDelivery:
        return 'في الطريق';
      case OrderStatus.delivered:
        return 'تم التوصيل';
      case OrderStatus.completed:
        return 'مكتمل';
      case OrderStatus.cancelled:
        return 'ملغي';
      case OrderStatus.refunded:
        return 'مسترجع';
    }
  }

  Color get color {
    switch (this) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.confirmed:
        return Colors.blue;
      case OrderStatus.processing:
        return Colors.indigo;
      case OrderStatus.readyForPickup:
        return Colors.purple;
      case OrderStatus.shipped:
        return Colors.cyan;
      case OrderStatus.outForDelivery:
        return Colors.teal;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.completed:
        return const Color(0xFF2E7D32);
      case OrderStatus.cancelled:
        return Colors.red;
      case OrderStatus.refunded:
        return Colors.grey;
    }
  }

  IconData get icon {
    switch (this) {
      case OrderStatus.pending:
        return Icons.hourglass_empty;
      case OrderStatus.confirmed:
        return Icons.check_circle_outline;
      case OrderStatus.processing:
        return Icons.autorenew;
      case OrderStatus.readyForPickup:
        return Icons.inventory;
      case OrderStatus.shipped:
        return Icons.local_shipping;
      case OrderStatus.outForDelivery:
        return Icons.delivery_dining;
      case OrderStatus.delivered:
        return Icons.done_all;
      case OrderStatus.completed:
        return Icons.verified;
      case OrderStatus.cancelled:
        return Icons.cancel;
      case OrderStatus.refunded:
        return Icons.replay;
    }
  }

  /// Step index for timeline
  int get stepIndex {
    switch (this) {
      case OrderStatus.pending:
        return 0;
      case OrderStatus.confirmed:
        return 1;
      case OrderStatus.processing:
        return 2;
      case OrderStatus.readyForPickup:
        return 3;
      case OrderStatus.shipped:
        return 3;
      case OrderStatus.outForDelivery:
        return 4;
      case OrderStatus.delivered:
        return 5;
      case OrderStatus.completed:
        return 6;
      case OrderStatus.cancelled:
        return -1;
      case OrderStatus.refunded:
        return -1;
    }
  }

  bool get isCancelled => this == OrderStatus.cancelled;
  bool get canCancel =>
      this == OrderStatus.pending || this == OrderStatus.confirmed;
}

/// Payment statuses
enum PaymentStatus {
  unpaid,
  partial,
  paid,
  refunded;

  static PaymentStatus fromString(String value) {
    return PaymentStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => PaymentStatus.unpaid,
    );
  }

  String get displayNameAr {
    switch (this) {
      case PaymentStatus.unpaid:
        return 'غير مدفوع';
      case PaymentStatus.partial:
        return 'مدفوع جزئياً';
      case PaymentStatus.paid:
        return 'مدفوع';
      case PaymentStatus.refunded:
        return 'مسترجع';
    }
  }

  Color get color {
    switch (this) {
      case PaymentStatus.unpaid:
        return Colors.red;
      case PaymentStatus.partial:
        return Colors.orange;
      case PaymentStatus.paid:
        return Colors.green;
      case PaymentStatus.refunded:
        return Colors.grey;
    }
  }
}

/// Order payment methods
enum OrderPaymentMethod {
  cashOnDelivery,
  creditCard,
  mada,
  applePay,
  stcPay,
  bankTransfer,
  wallet,
  credit;

  static OrderPaymentMethod fromString(String value) {
    switch (value.toLowerCase()) {
      case 'cash_on_delivery':
      case 'cash':
      case 'cod':
        return OrderPaymentMethod.cashOnDelivery;
      case 'credit_card':
      case 'card':
        return OrderPaymentMethod.creditCard;
      case 'mada':
        return OrderPaymentMethod.mada;
      case 'apple_pay':
        return OrderPaymentMethod.applePay;
      case 'stc_pay':
        return OrderPaymentMethod.stcPay;
      case 'bank_transfer':
        return OrderPaymentMethod.bankTransfer;
      case 'wallet':
        return OrderPaymentMethod.wallet;
      case 'credit':
        return OrderPaymentMethod.credit;
      default:
        return OrderPaymentMethod.cashOnDelivery;
    }
  }

  String get value {
    switch (this) {
      case OrderPaymentMethod.cashOnDelivery:
        return 'cash_on_delivery';
      case OrderPaymentMethod.creditCard:
        return 'credit_card';
      case OrderPaymentMethod.mada:
        return 'mada';
      case OrderPaymentMethod.applePay:
        return 'apple_pay';
      case OrderPaymentMethod.stcPay:
        return 'stc_pay';
      case OrderPaymentMethod.bankTransfer:
        return 'bank_transfer';
      case OrderPaymentMethod.wallet:
        return 'wallet';
      case OrderPaymentMethod.credit:
        return 'credit';
    }
  }

  String get displayNameAr {
    switch (this) {
      case OrderPaymentMethod.cashOnDelivery:
        return 'الدفع عند الاستلام';
      case OrderPaymentMethod.creditCard:
        return 'بطاقة ائتمان';
      case OrderPaymentMethod.mada:
        return 'بطاقة مدى';
      case OrderPaymentMethod.applePay:
        return 'Apple Pay';
      case OrderPaymentMethod.stcPay:
        return 'STC Pay';
      case OrderPaymentMethod.bankTransfer:
        return 'تحويل بنكي';
      case OrderPaymentMethod.wallet:
        return 'المحفظة';
      case OrderPaymentMethod.credit:
        return 'آجل';
    }
  }

  IconData get icon {
    switch (this) {
      case OrderPaymentMethod.cashOnDelivery:
        return Icons.money;
      case OrderPaymentMethod.creditCard:
      case OrderPaymentMethod.mada:
      case OrderPaymentMethod.applePay:
      case OrderPaymentMethod.stcPay:
        return Icons.credit_card;
      case OrderPaymentMethod.bankTransfer:
        return Icons.account_balance;
      case OrderPaymentMethod.wallet:
        return Icons.account_balance_wallet;
      case OrderPaymentMethod.credit:
        return Icons.schedule;
    }
  }
}

/// Order sources
enum OrderSource {
  web,
  mobile,
  admin,
  api;

  static OrderSource fromString(String value) {
    return OrderSource.values.firstWhere(
      (e) => e.name == value,
      orElse: () => OrderSource.mobile,
    );
  }
}
