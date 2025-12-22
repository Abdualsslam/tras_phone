/// Order Entity - Domain layer representation of an order
library;

import 'package:equatable/equatable.dart';

enum OrderStatus {
  pending,
  confirmed,
  processing,
  shipped,
  delivered,
  cancelled,
  returned,
}

class OrderItemEntity extends Equatable {
  final int id;
  final int productId;
  final String productName;
  final String? productImage;
  final int quantity;
  final double unitPrice;
  final double totalPrice;

  const OrderItemEntity({
    required this.id,
    required this.productId,
    required this.productName,
    this.productImage,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
  });

  @override
  List<Object?> get props => [id, productId];
}

class OrderEntity extends Equatable {
  final int id;
  final String orderNumber;
  final OrderStatus status;
  final List<OrderItemEntity> items;
  final double subtotal;
  final double shippingCost;
  final double discount;
  final double total;
  final String? couponCode;
  final String? shippingAddress;
  final String? paymentMethod;
  final String? notes;
  final DateTime createdAt;
  final DateTime? deliveredAt;

  const OrderEntity({
    required this.id,
    required this.orderNumber,
    required this.status,
    this.items = const [],
    required this.subtotal,
    this.shippingCost = 0,
    this.discount = 0,
    required this.total,
    this.couponCode,
    this.shippingAddress,
    this.paymentMethod,
    this.notes,
    required this.createdAt,
    this.deliveredAt,
  });

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  String get statusText {
    switch (status) {
      case OrderStatus.pending:
        return 'قيد الانتظار';
      case OrderStatus.confirmed:
        return 'تم التأكيد';
      case OrderStatus.processing:
        return 'قيد التجهيز';
      case OrderStatus.shipped:
        return 'تم الشحن';
      case OrderStatus.delivered:
        return 'تم التوصيل';
      case OrderStatus.cancelled:
        return 'ملغي';
      case OrderStatus.returned:
        return 'مرتجع';
    }
  }

  @override
  List<Object?> get props => [id, orderNumber, status];
}
