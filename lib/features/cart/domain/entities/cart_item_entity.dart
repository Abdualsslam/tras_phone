/// Cart Item Entity - Domain layer representation of a cart item
library;

import 'package:equatable/equatable.dart';
import '../../../catalog/domain/entities/product_entity.dart';

class CartItemEntity extends Equatable {
  final int id;
  final ProductEntity product;
  final int quantity;
  final double unitPrice;
  final DateTime addedAt;

  const CartItemEntity({
    required this.id,
    required this.product,
    required this.quantity,
    required this.unitPrice,
    required this.addedAt,
  });

  double get totalPrice => unitPrice * quantity;

  CartItemEntity copyWith({
    int? id,
    ProductEntity? product,
    int? quantity,
    double? unitPrice,
    DateTime? addedAt,
  }) {
    return CartItemEntity(
      id: id ?? this.id,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  @override
  List<Object?> get props => [id, product.id, quantity];
}
