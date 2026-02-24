import '../../domain/entities/cart_item_product_entity.dart';

/// Product details in cart item
class CartItemProductModel {
  final String name;
  final String nameAr;
  final String? image;
  final String sku;
  final bool isActive;
  final int stockQuantity;

  const CartItemProductModel({
    required this.name,
    required this.nameAr,
    this.image,
    required this.sku,
    required this.isActive,
    required this.stockQuantity,
  });

  factory CartItemProductModel.fromJson(Map<String, dynamic> json) {
    return CartItemProductModel(
      name: json['name'] ?? '',
      nameAr: json['nameAr'] ?? '',
      image: json['image'],
      sku: json['sku'] ?? '',
      isActive: json['isActive'] ?? true,
      stockQuantity: (json['stockQuantity'] as num?)?.toInt() ?? 999999,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'nameAr': nameAr,
    'image': image,
    'sku': sku,
    'isActive': isActive,
    'stockQuantity': stockQuantity,
  };

  CartItemProductEntity toEntity() {
    return CartItemProductEntity(
      name: name,
      nameAr: nameAr,
      image: image,
      sku: sku,
      isActive: isActive,
      stockQuantity: stockQuantity,
    );
  }
}
