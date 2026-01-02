/// Cart Item Model - Data layer model with JSON serialization
library;

import 'package:json_annotation/json_annotation.dart';
import '../../../catalog/data/models/product_model.dart';
import '../../../catalog/domain/entities/product_entity.dart';
import '../../domain/entities/cart_item_entity.dart';

part 'cart_item_model.g.dart';

@JsonSerializable()
class CartItemModel {
  final int id;
  @JsonKey(name: 'product_id')
  final int productId;
  final ProductModel? product;
  final int quantity;
  @JsonKey(name: 'unit_price')
  final double unitPrice;
  @JsonKey(name: 'total_price')
  final double? totalPrice;
  @JsonKey(name: 'added_at')
  final String? addedAt;

  const CartItemModel({
    required this.id,
    required this.productId,
    this.product,
    required this.quantity,
    required this.unitPrice,
    this.totalPrice,
    this.addedAt,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) =>
      _$CartItemModelFromJson(json);
  Map<String, dynamic> toJson() => _$CartItemModelToJson(this);

  CartItemEntity toEntity() {
    return CartItemEntity(
      id: id,
      product: product?.toEntity() ?? _createPlaceholderProduct(),
      quantity: quantity,
      unitPrice: unitPrice,
      addedAt: addedAt != null
          ? DateTime.tryParse(addedAt!) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  /// Create placeholder product when product details not included in response
  ProductEntity _createPlaceholderProduct() {
    return ProductEntity(
      id: productId,
      sku: 'PRODUCT-$productId',
      name: 'Product $productId',
      slug: 'product-$productId',
      price: unitPrice,
      categoryId: 0,
    );
  }
}
