/// Product Model - Data layer model with JSON serialization
library;

import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/product_entity.dart';

part 'product_model.g.dart';

@JsonSerializable()
class ProductModel {
  final int id;
  final String sku;
  final String name;
  @JsonKey(name: 'name_ar')
  final String? nameAr;
  final String slug;
  final String? description;
  @JsonKey(name: 'description_ar')
  final String? descriptionAr;
  final double price;
  @JsonKey(name: 'original_price')
  final double? originalPrice;
  @JsonKey(name: 'category_id')
  final int categoryId;
  @JsonKey(name: 'brand_id')
  final int? brandId;
  @JsonKey(name: 'device_id')
  final int? deviceId;
  @JsonKey(name: 'image_url')
  final String? imageUrl;
  final List<String> images;
  @JsonKey(name: 'stock_quantity')
  final int stockQuantity;
  @JsonKey(name: 'is_active')
  final bool isActive;
  @JsonKey(name: 'is_featured')
  final bool isFeatured;
  final double? rating;
  @JsonKey(name: 'reviews_count')
  final int reviewsCount;
  @JsonKey(name: 'created_at')
  final String? createdAt;

  const ProductModel({
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

  factory ProductModel.fromJson(Map<String, dynamic> json) =>
      _$ProductModelFromJson(json);
  Map<String, dynamic> toJson() => _$ProductModelToJson(this);

  ProductEntity toEntity() {
    return ProductEntity(
      id: id,
      sku: sku,
      name: name,
      nameAr: nameAr,
      slug: slug,
      description: description,
      descriptionAr: descriptionAr,
      price: price,
      originalPrice: originalPrice,
      categoryId: categoryId,
      brandId: brandId,
      deviceId: deviceId,
      imageUrl: imageUrl,
      images: images,
      stockQuantity: stockQuantity,
      isActive: isActive,
      isFeatured: isFeatured,
      rating: rating,
      reviewsCount: reviewsCount,
      createdAt: createdAt != null ? DateTime.tryParse(createdAt!) : null,
    );
  }

  static ProductModel fromEntity(ProductEntity entity) {
    return ProductModel(
      id: entity.id,
      sku: entity.sku,
      name: entity.name,
      nameAr: entity.nameAr,
      slug: entity.slug,
      description: entity.description,
      descriptionAr: entity.descriptionAr,
      price: entity.price,
      originalPrice: entity.originalPrice,
      categoryId: entity.categoryId,
      brandId: entity.brandId,
      deviceId: entity.deviceId,
      imageUrl: entity.imageUrl,
      images: entity.images,
      stockQuantity: entity.stockQuantity,
      isActive: entity.isActive,
      isFeatured: entity.isFeatured,
      rating: entity.rating,
      reviewsCount: entity.reviewsCount,
      createdAt: entity.createdAt?.toIso8601String(),
    );
  }
}

/// Paginated response for products
@JsonSerializable()
class PaginatedProductsResponse {
  final List<ProductModel> data;
  final PaginationMeta meta;

  const PaginatedProductsResponse({required this.data, required this.meta});

  factory PaginatedProductsResponse.fromJson(Map<String, dynamic> json) =>
      _$PaginatedProductsResponseFromJson(json);
  Map<String, dynamic> toJson() => _$PaginatedProductsResponseToJson(this);

  List<ProductEntity> toEntities() => data.map((p) => p.toEntity()).toList();
}

@JsonSerializable()
class PaginationMeta {
  @JsonKey(name: 'current_page')
  final int currentPage;
  @JsonKey(name: 'last_page')
  final int lastPage;
  @JsonKey(name: 'per_page')
  final int perPage;
  final int total;

  const PaginationMeta({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) =>
      _$PaginationMetaFromJson(json);
  Map<String, dynamic> toJson() => _$PaginationMetaToJson(this);

  bool get hasNextPage => currentPage < lastPage;
}
