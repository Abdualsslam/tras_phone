import 'package:equatable/equatable.dart';
import 'cart_item_product_entity.dart';

/// Cart item with product details
class CheckoutCartItemEntity extends Equatable {
  final String productId;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final DateTime addedAt;
  final CartItemProductEntity product;

  const CheckoutCartItemEntity({
    required this.productId,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    required this.addedAt,
    required this.product,
  });

  /// Get localized product name
  String getProductName(String locale) => product.getName(locale);

  /// Check if item has stock issues
  bool get hasStockIssue => quantity > product.stockQuantity;

  /// Check if product is inactive
  bool get isProductInactive => !product.isActive;

  @override
  List<Object?> get props => [
    productId,
    quantity,
    unitPrice,
    totalPrice,
    addedAt,
    product,
  ];
}
