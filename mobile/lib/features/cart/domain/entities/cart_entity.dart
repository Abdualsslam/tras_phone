/// Cart Entity - Domain layer representation of the shopping cart
library;

import 'package:equatable/equatable.dart';
import 'cart_item_entity.dart';

class CartEntity extends Equatable {
  final List<CartItemEntity> items;
  final double subtotal;
  final double shippingCost;
  final double discount;
  final String? couponCode;
  final DateTime updatedAt;

  const CartEntity({
    this.items = const [],
    this.subtotal = 0,
    this.shippingCost = 0,
    this.discount = 0,
    this.couponCode,
    required this.updatedAt,
  });

  double get total => subtotal + shippingCost - discount;
  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);
  bool get isEmpty => items.isEmpty;
  bool get isNotEmpty => items.isNotEmpty;

  CartEntity copyWith({
    List<CartItemEntity>? items,
    double? subtotal,
    double? shippingCost,
    double? discount,
    String? couponCode,
    DateTime? updatedAt,
  }) {
    return CartEntity(
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      shippingCost: shippingCost ?? this.shippingCost,
      discount: discount ?? this.discount,
      couponCode: couponCode ?? this.couponCode,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [items, subtotal, discount, couponCode];
}
