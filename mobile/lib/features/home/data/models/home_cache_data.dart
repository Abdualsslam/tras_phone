/// Home Cache Data Model - Stores cached home screen data
library;

import 'package:json_annotation/json_annotation.dart';
import '../../../catalog/domain/entities/brand_entity.dart';
import '../../../catalog/domain/entities/category_entity.dart';
import '../../../catalog/domain/entities/product_entity.dart';
import '../../../catalog/data/models/category_model.dart';
import '../../../catalog/data/models/brand_model.dart';
import '../../../catalog/data/models/product_model.dart';

part 'home_cache_data.g.dart';

@JsonSerializable()
class HomeCacheData {
  final List<Map<String, dynamic>> categories;
  final List<Map<String, dynamic>> brands;
  final List<Map<String, dynamic>> featuredProducts;
  final List<Map<String, dynamic>> newArrivals;
  final List<Map<String, dynamic>> bestSellers;
  final String cachedAt;

  const HomeCacheData({
    required this.categories,
    required this.brands,
    required this.featuredProducts,
    required this.newArrivals,
    required this.bestSellers,
    required this.cachedAt,
  });

  factory HomeCacheData.fromJson(Map<String, dynamic> json) =>
      _$HomeCacheDataFromJson(json);

  Map<String, dynamic> toJson() => _$HomeCacheDataToJson(this);

  /// Create from entities
  factory HomeCacheData.fromEntities({
    required List<CategoryEntity> categories,
    required List<BrandEntity> brands,
    required List<ProductEntity> featuredProducts,
    required List<ProductEntity> newArrivals,
    required List<ProductEntity> bestSellers,
  }) {
    return HomeCacheData(
      categories: categories.map((e) => _categoryToJson(e)).toList(),
      brands: brands.map((e) => _brandToJson(e)).toList(),
      featuredProducts: featuredProducts.map((e) => _productToJson(e)).toList(),
      newArrivals: newArrivals.map((e) => _productToJson(e)).toList(),
      bestSellers: bestSellers.map((e) => _productToJson(e)).toList(),
      cachedAt: DateTime.now().toIso8601String(),
    );
  }

  /// Convert to entities
  ({
    List<CategoryEntity> categories,
    List<BrandEntity> brands,
    List<ProductEntity> featuredProducts,
    List<ProductEntity> newArrivals,
    List<ProductEntity> bestSellers,
  }) toEntities() {
    return (
      categories: categories
          .map((json) => CategoryModel.fromJson(json).toEntity())
          .toList(),
      brands: brands.map((json) => BrandModel.fromJson(json).toEntity()).toList(),
      featuredProducts: featuredProducts
          .map((json) => ProductModel.fromJson(json).toEntity())
          .toList(),
      newArrivals: newArrivals
          .map((json) => ProductModel.fromJson(json).toEntity())
          .toList(),
      bestSellers: bestSellers
          .map((json) => ProductModel.fromJson(json).toEntity())
          .toList(),
    );
  }

  DateTime get cachedAtDateTime => DateTime.parse(cachedAt);

  /// Helper methods to convert entities to JSON
  static Map<String, dynamic> _categoryToJson(CategoryEntity entity) {
    return {
      '_id': entity.id,
      'name': entity.name,
      'nameAr': entity.nameAr,
      'slug': entity.slug,
      'description': entity.description,
      'descriptionAr': entity.descriptionAr,
      'image': entity.image,
      'icon': entity.icon,
      'parentId': entity.parentId,
      'ancestors': entity.ancestors,
      'level': entity.level,
      'path': entity.path,
      'isActive': entity.isActive,
      'isFeatured': entity.isFeatured,
      'displayOrder': entity.displayOrder,
      'productsCount': entity.productsCount,
      'childrenCount': entity.childrenCount,
      'createdAt': entity.createdAt.toIso8601String(),
      'updatedAt': entity.updatedAt.toIso8601String(),
      'children': entity.children.map((c) => _categoryToJson(c)).toList(),
    };
  }

  static Map<String, dynamic> _brandToJson(BrandEntity entity) {
    return {
      '_id': entity.id,
      'name': entity.name,
      'nameAr': entity.nameAr,
      'slug': entity.slug,
      'description': entity.description,
      'descriptionAr': entity.descriptionAr,
      'logo': entity.logo,
      'website': entity.website,
      'isActive': entity.isActive,
      'isFeatured': entity.isFeatured,
      'displayOrder': entity.displayOrder,
      'productsCount': entity.productsCount,
      'createdAt': entity.createdAt.toIso8601String(),
      'updatedAt': entity.updatedAt.toIso8601String(),
    };
  }

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
      'wishlistCount': entity.wishlistCount,
      'relatedProducts': entity.relatedProducts,
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
