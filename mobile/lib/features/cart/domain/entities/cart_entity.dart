/// Cart Entity - Domain layer representation of the shopping cart
library;

import 'package:equatable/equatable.dart';
import 'cart_item_entity.dart';
import '../enums/cart_enums.dart';

export '../enums/cart_enums.dart';

class CartEntity extends Equatable {
  final String id;
  final String customerId;
  final CartStatus status;
  final List<CartItemEntity> items;
  final int itemsCount;
  final double subtotal;
  final double discount;
  final double taxAmount;
  final double shippingCost;
  final double total;
  final String? couponId;
  final String? couponCode;
  final double couponDiscount;
  final DateTime? lastActivityAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CartEntity({
    required this.id,
    required this.customerId,
    this.status = CartStatus.active,
    this.items = const [],
    this.itemsCount = 0,
    this.subtotal = 0,
    this.discount = 0,
    this.taxAmount = 0,
    this.shippingCost = 0,
    this.total = 0,
    this.couponId,
    this.couponCode,
    this.couponDiscount = 0,
    this.lastActivityAt,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isEmpty => items.isEmpty;
  bool get isNotEmpty => items.isNotEmpty;
  bool get hasCoupon => couponCode != null && couponCode!.isNotEmpty;

  CartEntity copyWith({
    String? id,
    String? customerId,
    CartStatus? status,
    List<CartItemEntity>? items,
    int? itemsCount,
    double? subtotal,
    double? discount,
    double? taxAmount,
    double? shippingCost,
    double? total,
    String? couponId,
    String? couponCode,
    double? couponDiscount,
    DateTime? lastActivityAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CartEntity(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      status: status ?? this.status,
      items: items ?? this.items,
      itemsCount: itemsCount ?? this.itemsCount,
      subtotal: subtotal ?? this.subtotal,
      discount: discount ?? this.discount,
      taxAmount: taxAmount ?? this.taxAmount,
      shippingCost: shippingCost ?? this.shippingCost,
      total: total ?? this.total,
      couponId: couponId ?? this.couponId,
      couponCode: couponCode ?? this.couponCode,
      couponDiscount: couponDiscount ?? this.couponDiscount,
      lastActivityAt: lastActivityAt ?? this.lastActivityAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [id, items, subtotal, couponCode];
}
