/// Cart Item Model - Data layer model with JSON serialization
library;

import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/cart_item_entity.dart';

part 'cart_item_model.g.dart';

@JsonSerializable(createFactory: false)
class CartItemModel {
  @JsonKey(name: 'productId', readValue: _readProductId)
  final String productId;

  final int quantity;

  @JsonKey(defaultValue: 0.0)
  final double unitPrice;

  @JsonKey(defaultValue: 0.0)
  final double totalPrice;

  final DateTime addedAt;

  // Product details (populated when productId is an object)
  final String? productName;
  final String? productNameAr;
  final String? productImage;
  final String? productSku;

  const CartItemModel({
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

  /// Handle productId which can be String or populated Product object
  static Object? _readProductId(Map<dynamic, dynamic> json, String key) {
    final value = json['productId'];
    if (value is String) return value;
    if (value is Map) {
      return value['_id']?.toString() ?? value['\$oid']?.toString();
    }
    return value?.toString();
  }

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    // Extract product details if productId is populated
    String? name, nameAr, image, sku;
    final productData = json['productId'];
    if (productData is Map<String, dynamic>) {
      name = productData['name'] as String?;
      nameAr = productData['nameAr'] as String?;
      image =
          productData['images']?[0] as String? ??
          productData['image'] as String?;
      sku = productData['sku'] as String?;
    }

    return CartItemModel(
      productId: _readProductId(json, 'productId')?.toString() ?? '',
      quantity: json['quantity'] as int,
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0.0,
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0.0,
      addedAt: json['addedAt'] != null
          ? DateTime.parse(json['addedAt'] as String)
          : DateTime.now(),
      productName: name,
      productNameAr: nameAr,
      productImage: image,
      productSku: sku,
    );
  }

  Map<String, dynamic> toJson() => _$CartItemModelToJson(this);

  CartItemEntity toEntity() {
    return CartItemEntity(
      productId: productId,
      quantity: quantity,
      unitPrice: unitPrice,
      totalPrice: totalPrice,
      addedAt: addedAt,
      productName: productName,
      productNameAr: productNameAr,
      productImage: productImage,
      productSku: productSku,
    );
  }
}
