import '../../domain/entities/checkout_cart_item_entity.dart';
import 'cart_item_product_model.dart';

/// Cart item with product details
class CheckoutCartItemModel {
  final String productId;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final DateTime addedAt;
  final CartItemProductModel product;

  const CheckoutCartItemModel({
    required this.productId,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    required this.addedAt,
    required this.product,
  });

  factory CheckoutCartItemModel.fromJson(Map<String, dynamic> json) {
    return CheckoutCartItemModel(
      productId: json['productId']?.toString() ?? '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0.0,
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0.0,
      addedAt: json['addedAt'] != null
          ? DateTime.parse(json['addedAt'])
          : DateTime.now(),
      product: CartItemProductModel.fromJson(
        json['product'] ?? <String, dynamic>{},
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'productId': productId,
    'quantity': quantity,
    'unitPrice': unitPrice,
    'totalPrice': totalPrice,
    'addedAt': addedAt.toIso8601String(),
    'product': product.toJson(),
  };

  CheckoutCartItemEntity toEntity() {
    return CheckoutCartItemEntity(
      productId: productId,
      quantity: quantity,
      unitPrice: unitPrice,
      totalPrice: totalPrice,
      addedAt: addedAt,
      product: product.toEntity(),
    );
  }
}
