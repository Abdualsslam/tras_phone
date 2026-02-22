/// Product Model - Data layer model with JSON serialization
library;

import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/product_entity.dart';

part 'product_model.g.dart';

@JsonSerializable()
class ProductModel {
  @JsonKey(name: 'id', readValue: _readId)
  final String id;

  final String sku;
  final String name;
  final String nameAr;
  final String slug;
  final String? description;
  final String? descriptionAr;
  final String? shortDescription;
  final String? shortDescriptionAr;

  // Relations - can be String or populated object
  @JsonKey(name: 'brandId', readValue: _readRelationId)
  final String brandId;

  @JsonKey(name: 'categoryId', readValue: _readRelationId)
  final String categoryId;

  @JsonKey(defaultValue: [])
  final List<String> additionalCategories;

  @JsonKey(name: 'qualityTypeId', readValue: _readRelationId)
  final String qualityTypeId;

  @JsonKey(defaultValue: [])
  final List<String> compatibleDevices;

  @JsonKey(name: 'relatedProducts', readValue: _readRelatedProducts)
  final List<String>? relatedProducts;

  // Images
  final String? mainImage;
  @JsonKey(defaultValue: [])
  final List<String> images;
  final String? video;

  // Pricing
  @JsonKey(defaultValue: 0.0)
  final double basePrice;
  final double? compareAtPrice;

  /// Customer tier price (returned when logged in - see 16-pricing-rules)
  final double? price;

  // Inventory
  @JsonKey(defaultValue: 0)
  final int stockQuantity;
  @JsonKey(defaultValue: 5)
  final int lowStockThreshold;
  @JsonKey(defaultValue: true)
  final bool trackInventory;
  @JsonKey(defaultValue: false)
  final bool allowBackorder;

  // Order
  @JsonKey(defaultValue: 1)
  final int minOrderQuantity;
  final int? maxOrderQuantity;
  @JsonKey(defaultValue: 1)
  final int quantityStep;

  // Status
  @JsonKey(defaultValue: 'active')
  final String status;
  @JsonKey(defaultValue: true)
  final bool isActive;
  @JsonKey(defaultValue: false)
  final bool isFeatured;
  @JsonKey(defaultValue: false)
  final bool isNewArrival;
  @JsonKey(defaultValue: false)
  final bool isBestSeller;

  // Specifications
  final Map<String, dynamic>? specifications;
  final double? weight;
  final String? dimensions;
  final String? color;

  // Warranty
  final int? warrantyDays;
  final String? warrantyDescription;

  // Stats
  @JsonKey(defaultValue: 0)
  final int viewsCount;
  @JsonKey(defaultValue: 0)
  final int ordersCount;
  @JsonKey(defaultValue: 0)
  final int salesCount;
  @JsonKey(defaultValue: 0)
  final int reviewsCount;
  @JsonKey(defaultValue: 0.0)
  final double averageRating;
  @JsonKey(defaultValue: 0)
  final int favoriteCount;

  // Tags
  @JsonKey(defaultValue: [])
  final List<String> tags;

  final DateTime? publishedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Populated relation names (extracted from objects)
  @JsonKey(includeFromJson: false, includeToJson: false)
  final String? brandName;
  @JsonKey(includeFromJson: false, includeToJson: false)
  final String? brandNameAr;
  @JsonKey(includeFromJson: false, includeToJson: false)
  final String? categoryName;
  @JsonKey(includeFromJson: false, includeToJson: false)
  final String? categoryNameAr;
  @JsonKey(includeFromJson: false, includeToJson: false)
  final String? qualityTypeName;
  @JsonKey(includeFromJson: false, includeToJson: false)
  final String? qualityTypeNameAr;

  const ProductModel({
    required this.id,
    required this.sku,
    required this.name,
    required this.nameAr,
    required this.slug,
    this.description,
    this.descriptionAr,
    this.shortDescription,
    this.shortDescriptionAr,
    required this.brandId,
    required this.categoryId,
    this.additionalCategories = const [],
    required this.qualityTypeId,
    this.compatibleDevices = const [],
    this.mainImage,
    this.images = const [],
    this.video,
    this.basePrice = 0,
    this.compareAtPrice,
    this.price,
    this.stockQuantity = 0,
    this.lowStockThreshold = 5,
    this.trackInventory = true,
    this.allowBackorder = false,
    this.minOrderQuantity = 1,
    this.maxOrderQuantity,
    this.quantityStep = 1,
    this.status = 'active',
    this.isActive = true,
    this.isFeatured = false,
    this.isNewArrival = false,
    this.isBestSeller = false,
    this.specifications,
    this.weight,
    this.dimensions,
    this.color,
    this.warrantyDays,
    this.warrantyDescription,
    this.viewsCount = 0,
    this.ordersCount = 0,
    this.salesCount = 0,
    this.reviewsCount = 0,
    this.averageRating = 0,
    this.favoriteCount = 0,
    this.relatedProducts,
    this.tags = const [],
    this.publishedAt,
    required this.createdAt,
    required this.updatedAt,
    this.brandName,
    this.brandNameAr,
    this.categoryName,
    this.categoryNameAr,
    this.qualityTypeName,
    this.qualityTypeNameAr,
  });

  /// Handle MongoDB _id or id field
  static Object? _readId(Map<dynamic, dynamic> json, String key) {
    final value = json['_id'] ?? json['id'];
    if (value is Map) {
      return value['\$oid'] ?? value.toString();
    }
    return value?.toString();
  }

  /// Handle relation IDs which can be String or populated object
  static Object? _readRelationId(Map<dynamic, dynamic> json, String key) {
    final value = json[key];
    if (value is String) return value;
    if (value is Map) {
      return value['_id']?.toString() ?? value['\$oid']?.toString();
    }
    return value?.toString() ?? '';
  }

  /// Handle related products which can be `List<String>` or List of objects
  static Object? _readRelatedProducts(Map<dynamic, dynamic> json, String key) {
    final value = json[key];
    if (value == null) return null;
    if (value is List) {
      return value
          .map((p) {
            if (p is String) return p;
            if (p is Map) {
              return p['_id']?.toString() ??
                  p['\$oid']?.toString() ??
                  p['id']?.toString();
            }
            return p.toString();
          })
          .toList()
          .cast<String>();
    }
    return null;
  }

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final nowIso = DateTime.now().toIso8601String();
    final normalized = Map<String, dynamic>.from(json);

    String normalizeDate(dynamic value) {
      if (value is String && value.isNotEmpty) return value;
      if (value is DateTime) return value.toIso8601String();
      if (value is Map) {
        final map = Map<String, dynamic>.from(value);
        final nested = map['\$date'] ?? map['date'];
        if (nested is String && nested.isNotEmpty) return nested;
      }
      return nowIso;
    }

    normalized['id'] = _readId(json, 'id')?.toString() ?? '';
    normalized['sku'] = (json['sku'] ?? '').toString();
    normalized['name'] = (json['name'] ?? '').toString();
    normalized['nameAr'] = (json['nameAr'] ?? json['name'] ?? '').toString();
    normalized['slug'] =
        (json['slug'] ?? normalized['name'] ?? normalized['id'] ?? '')
            .toString();
    normalized['createdAt'] = normalizeDate(
      json['createdAt'] ?? json['updatedAt'],
    );
    normalized['updatedAt'] = normalizeDate(
      json['updatedAt'] ?? json['createdAt'],
    );

    normalized['brandId'] = _readRelationId(json, 'brandId')?.toString() ?? '';
    normalized['categoryId'] =
        _readRelationId(json, 'categoryId')?.toString() ?? '';
    normalized['qualityTypeId'] =
        _readRelationId(json, 'qualityTypeId')?.toString() ?? '';

    // Extract populated relation data
    String? brandName, brandNameAr;
    String? categoryName, categoryNameAr;
    String? qualityTypeName, qualityTypeNameAr;

    final brandData = json['brandId'];
    if (brandData is Map<String, dynamic>) {
      brandName = brandData['name'] as String?;
      brandNameAr = brandData['nameAr'] as String?;
    }

    final categoryData = json['categoryId'];
    if (categoryData is Map<String, dynamic>) {
      categoryName = categoryData['name'] as String?;
      categoryNameAr = categoryData['nameAr'] as String?;
    }

    final qualityData = json['qualityTypeId'];
    if (qualityData is Map<String, dynamic>) {
      qualityTypeName = qualityData['name'] as String?;
      qualityTypeNameAr = qualityData['nameAr'] as String?;
    }

    final model = _$ProductModelFromJson(normalized);
    return ProductModel(
      id: model.id,
      sku: model.sku,
      name: model.name,
      nameAr: model.nameAr,
      slug: model.slug,
      description: model.description,
      descriptionAr: model.descriptionAr,
      shortDescription: model.shortDescription,
      shortDescriptionAr: model.shortDescriptionAr,
      brandId: model.brandId,
      categoryId: model.categoryId,
      additionalCategories: model.additionalCategories,
      qualityTypeId: model.qualityTypeId,
      compatibleDevices: model.compatibleDevices,
      mainImage: model.mainImage,
      images: model.images,
      video: model.video,
      basePrice: model.basePrice,
      compareAtPrice: model.compareAtPrice,
      price: model.price,
      stockQuantity: model.stockQuantity,
      lowStockThreshold: model.lowStockThreshold,
      trackInventory: model.trackInventory,
      allowBackorder: model.allowBackorder,
      minOrderQuantity: model.minOrderQuantity,
      maxOrderQuantity: model.maxOrderQuantity,
      quantityStep: model.quantityStep,
      status: model.status,
      isActive: model.isActive,
      isFeatured: model.isFeatured,
      isNewArrival: model.isNewArrival,
      isBestSeller: model.isBestSeller,
      specifications: model.specifications,
      weight: model.weight,
      dimensions: model.dimensions,
      color: model.color,
      warrantyDays: model.warrantyDays,
      warrantyDescription: model.warrantyDescription,
      viewsCount: model.viewsCount,
      ordersCount: model.ordersCount,
      salesCount: model.salesCount,
      reviewsCount: model.reviewsCount,
      averageRating: model.averageRating,
      favoriteCount: model.favoriteCount,
      relatedProducts: model.relatedProducts,
      tags: model.tags,
      publishedAt: model.publishedAt,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      brandName: brandName,
      brandNameAr: brandNameAr,
      categoryName: categoryName,
      categoryNameAr: categoryNameAr,
      qualityTypeName: qualityTypeName,
      qualityTypeNameAr: qualityTypeNameAr,
    );
  }

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
      shortDescription: shortDescription,
      shortDescriptionAr: shortDescriptionAr,
      brandId: brandId,
      categoryId: categoryId,
      additionalCategories: additionalCategories,
      qualityTypeId: qualityTypeId,
      compatibleDevices: compatibleDevices,
      mainImage: mainImage,
      images: images,
      video: video,
      basePrice: basePrice,
      compareAtPrice: compareAtPrice,
      tierPrice: price,
      stockQuantity: stockQuantity,
      lowStockThreshold: lowStockThreshold,
      trackInventory: trackInventory,
      allowBackorder: allowBackorder,
      minOrderQuantity: minOrderQuantity,
      maxOrderQuantity: maxOrderQuantity,
      quantityStep: quantityStep,
      status: ProductStatus.fromString(status),
      isActive: isActive,
      isFeatured: isFeatured,
      isNewArrival: isNewArrival,
      isBestSeller: isBestSeller,
      specifications: specifications,
      weight: weight,
      dimensions: dimensions,
      color: color,
      warrantyDays: warrantyDays,
      warrantyDescription: warrantyDescription,
      viewsCount: viewsCount,
      ordersCount: ordersCount,
      salesCount: salesCount,
      reviewsCount: reviewsCount,
      averageRating: averageRating,
      favoriteCount: favoriteCount,
      relatedProducts: relatedProducts,
      tags: tags,
      publishedAt: publishedAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
      brandName: brandName,
      brandNameAr: brandNameAr,
      categoryName: categoryName,
      categoryNameAr: categoryNameAr,
      qualityTypeName: qualityTypeName,
      qualityTypeNameAr: qualityTypeNameAr,
    );
  }
}

/// Response for paginated products
class ProductsResponse {
  final List<ProductModel> products;
  final int total;
  final int page;
  final int pages;

  ProductsResponse({
    required this.products,
    required this.total,
    required this.page,
    required this.pages,
  });

  static int _asInt(dynamic value, {int fallback = 0}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
  }

  factory ProductsResponse.fromJson(Map<String, dynamic> json) {
    final metaRaw = json['meta'] ?? json['pagination'];
    final meta = metaRaw is Map<String, dynamic>
        ? metaRaw
        : metaRaw is Map
        ? Map<String, dynamic>.from(metaRaw)
        : <String, dynamic>{};

    final data = json['data'];
    final dataList = data is List ? data : const [];

    return ProductsResponse(
      products: dataList
          .whereType<Map>()
          .map((p) => ProductModel.fromJson(Map<String, dynamic>.from(p)))
          .toList(),
      total: _asInt(meta['total'], fallback: dataList.length),
      page: _asInt(meta['page'], fallback: 1),
      pages: _asInt(meta['pages'] ?? meta['totalPages'], fallback: 1),
    );
  }

  List<ProductEntity> toEntities() =>
      products.map((p) => p.toEntity()).toList();

  bool get hasNextPage => page < pages;
}
