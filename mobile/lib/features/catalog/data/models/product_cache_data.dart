/// Product Cache Data Model - Stores cached product data
library;

import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/product_entity.dart';
import 'product_model.dart';
import 'product_filter_query.dart';

part 'product_cache_data.g.dart';

@JsonSerializable()
class ProductCacheData {
  // For single product
  final Map<String, dynamic>? product;

  // For product lists
  final List<Map<String, dynamic>>? products;
  final Map<String, dynamic>? pagination;
  final Map<String, dynamic>? filter;

  final String cachedAt;

  const ProductCacheData({
    this.product,
    this.products,
    this.pagination,
    this.filter,
    required this.cachedAt,
  });

  factory ProductCacheData.fromJson(Map<String, dynamic> json) =>
      _$ProductCacheDataFromJson(json);

  Map<String, dynamic> toJson() => _$ProductCacheDataToJson(this);

  /// Create from single product entity
  factory ProductCacheData.fromProduct(ProductEntity product) {
    return ProductCacheData(
      product: _productToJson(product),
      cachedAt: DateTime.now().toIso8601String(),
    );
  }

  /// Create from products list
  factory ProductCacheData.fromProductsList({
    required List<ProductEntity> products,
    Map<String, dynamic>? pagination,
    ProductFilterQuery? filter,
  }) {
    return ProductCacheData(
      products: products.map((p) => _productToJson(p)).toList(),
      pagination: pagination,
      filter: filter?.toQueryParameters(),
      cachedAt: DateTime.now().toIso8601String(),
    );
  }

  /// Convert single product to entity
  ProductEntity? toProduct() {
    if (product == null) return null;
    try {
      return ProductModel.fromJson(product!).toEntity();
    } catch (e) {
      return null;
    }
  }

  /// Convert products list to entities
  List<ProductEntity> toProductsList() {
    if (products == null) return [];
    try {
      return products!
          .map((json) => ProductModel.fromJson(json).toEntity())
          .toList();
    } catch (e) {
      return [];
    }
  }

  DateTime get cachedAtDateTime => DateTime.parse(cachedAt);

  /// Helper method to convert ProductEntity to JSON
  static Map<String, dynamic> _productToJson(ProductEntity entity) {
    return {
      'id': entity.id,
      'sku': entity.sku,
      'name': entity.name,
      'nameAr': entity.nameAr,
      'slug': entity.slug,
      'description': entity.description,
      'descriptionAr': entity.descriptionAr,
      'shortDescription': entity.shortDescription,
      'shortDescriptionAr': entity.shortDescriptionAr,
      'brandId': entity.brandId,
      'categoryId': entity.categoryId,
      'additionalCategories': entity.additionalCategories,
      'qualityTypeId': entity.qualityTypeId,
      'compatibleDevices': entity.compatibleDevices,
      'mainImage': entity.mainImage,
      'images': entity.images,
      'video': entity.video,
      'basePrice': entity.basePrice,
      'compareAtPrice': entity.compareAtPrice,
      if (entity.tierPrice != null) 'price': entity.tierPrice,
      'stockQuantity': entity.stockQuantity,
      'lowStockThreshold': entity.lowStockThreshold,
      'trackInventory': entity.trackInventory,
      'allowBackorder': entity.allowBackorder,
      'minOrderQuantity': entity.minOrderQuantity,
      'maxOrderQuantity': entity.maxOrderQuantity,
      'quantityStep': entity.quantityStep,
      'status': entity.status.toString().split('.').last,
      'isActive': entity.isActive,
      'isFeatured': entity.isFeatured,
      'isNewArrival': entity.isNewArrival,
      'isBestSeller': entity.isBestSeller,
      'specifications': entity.specifications,
      'weight': entity.weight,
      'dimensions': entity.dimensions,
      'color': entity.color,
      'warrantyDays': entity.warrantyDays,
      'warrantyDescription': entity.warrantyDescription,
      'viewsCount': entity.viewsCount,
      'ordersCount': entity.ordersCount,
      'salesCount': entity.salesCount,
      'reviewsCount': entity.reviewsCount,
      'averageRating': entity.averageRating,
      'favoriteCount': entity.favoriteCount,
      'relatedProducts': entity.relatedProducts,
      'relatedEducationalContent': entity.relatedEducationalContent,
      'tags': entity.tags,
      'publishedAt': entity.publishedAt?.toIso8601String(),
      'createdAt': entity.createdAt.toIso8601String(),
      'updatedAt': entity.updatedAt.toIso8601String(),
      'brandName': entity.brandName,
      'brandNameAr': entity.brandNameAr,
      'categoryName': entity.categoryName,
      'categoryNameAr': entity.categoryNameAr,
      'qualityTypeName': entity.qualityTypeName,
      'qualityTypeNameAr': entity.qualityTypeNameAr,
    };
  }
}
