/// Product Entity - Domain layer representation of a product
library;

import 'package:equatable/equatable.dart';

class ProductEntity extends Equatable {
  final int id;
  final String sku;
  final String name;
  final String? nameAr;
  final String slug;
  final String? description;
  final String? descriptionAr;
  final double price;
  final double? originalPrice;
  final int categoryId;
  final int? brandId;
  final int? deviceId;
  final String? imageUrl;
  final List<String> images;
  final int stockQuantity;
  final bool isActive;
  final bool isFeatured;
  final double? rating;
  final int reviewsCount;
  final DateTime? createdAt;

  const ProductEntity({
    required this.id,
    required this.sku,
    required this.name,
    this.nameAr,
    required this.slug,
    this.description,
    this.descriptionAr,
    required this.price,
    this.originalPrice,
    required this.categoryId,
    this.brandId,
    this.deviceId,
    this.imageUrl,
    this.images = const [],
    this.stockQuantity = 0,
    this.isActive = true,
    this.isFeatured = false,
    this.rating,
    this.reviewsCount = 0,
    this.createdAt,
  });

  bool get hasDiscount => originalPrice != null && originalPrice! > price;
  bool get isInStock => stockQuantity > 0;
  double get discountPercentage {
    if (!hasDiscount) return 0;
    return ((originalPrice! - price) / originalPrice!) * 100;
  }

  @override
  List<Object?> get props => [id, sku];
}
