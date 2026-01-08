/// Cart Item Entity - Domain layer representation of a cart item
library;

import 'package:equatable/equatable.dart';

class CartItemEntity extends Equatable {
  final String productId;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final DateTime addedAt;

  // Product details (populated)
  final String? productName;
  final String? productNameAr;
  final String? productImage;
  final String? productSku;

  const CartItemEntity({
    required this.productId,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    required this.addedAt,
    this.productName,
    this.productNameAr,
    this.productImage,
    this.productSku,
  });

  String getName(String locale) => locale == 'ar' && productNameAr != null
      ? productNameAr!
      : (productName ?? 'منتج');

  CartItemEntity copyWith({
    String? productId,
    int? quantity,
    double? unitPrice,
    double? totalPrice,
    DateTime? addedAt,
    String? productName,
    String? productNameAr,
    String? productImage,
    String? productSku,
  }) {
    return CartItemEntity(
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      totalPrice: totalPrice ?? this.totalPrice,
      addedAt: addedAt ?? this.addedAt,
      productName: productName ?? this.productName,
      productNameAr: productNameAr ?? this.productNameAr,
      productImage: productImage ?? this.productImage,
      productSku: productSku ?? this.productSku,
    );
  }

  @override
  List<Object?> get props => [productId, quantity];
}
