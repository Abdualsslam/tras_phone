/// Product Model - Data layer model with JSON serialization
library;

import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/product_entity.dart';

part 'product_model.g.dart';
part 'product_model_parsing.dart';
part 'products_response.dart';

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
  @JsonKey(includeFromJson: false, includeToJson: false)
  final List<String> compatibleDeviceNames;
  @JsonKey(includeFromJson: false, includeToJson: false)
  final List<String> compatibleDeviceNamesAr;

  @JsonKey(name: 'relatedProducts', readValue: _readRelatedProducts)
  final List<String>? relatedProducts;

  @JsonKey(
    name: 'relatedEducationalContent',
    readValue: _readRelatedEducationalContent,
  )
  final List<String>? relatedEducationalContent;

  final String? mainImage;
  @JsonKey(defaultValue: [])
  final List<String> images;
  final String? video;

  @JsonKey(defaultValue: 0.0)
  final double basePrice;
  final double? compareAtPrice;
  final double? price;

  @JsonKey(defaultValue: 0)
  final int stockQuantity;
  @JsonKey(defaultValue: 5)
  final int lowStockThreshold;
  @JsonKey(defaultValue: true)
  final bool trackInventory;
  @JsonKey(defaultValue: false)
  final bool allowBackorder;

  @JsonKey(defaultValue: 1)
  final int minOrderQuantity;
  final int? maxOrderQuantity;
  @JsonKey(defaultValue: 1)
  final int quantityStep;

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

  final Map<String, dynamic>? specifications;
  final double? weight;
  final String? dimensions;
  final String? color;

  final int? warrantyDays;
  final String? warrantyDescription;

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

  @JsonKey(defaultValue: [])
  final List<String> tags;

  final DateTime? publishedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

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
    this.compatibleDeviceNames = const [],
    this.compatibleDeviceNamesAr = const [],
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
    this.relatedEducationalContent,
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

  static Object? _readId(Map<dynamic, dynamic> json, String key) =>
      _productReadId(json, key);

  static Object? _readRelationId(Map<dynamic, dynamic> json, String key) =>
      _productReadRelationId(json, key);

  static Object? _readRelatedProducts(Map<dynamic, dynamic> json, String key) =>
      _productReadRelatedProducts(json, key);

  static Object? _readRelatedEducationalContent(
    Map<dynamic, dynamic> json,
    String key,
  ) => _productReadRelatedEducationalContent(json, key);

  factory ProductModel.fromJson(Map<String, dynamic> json) =>
      _ProductModelParser.parse(json);

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
      compatibleDeviceNames: compatibleDeviceNames,
      compatibleDeviceNamesAr: compatibleDeviceNamesAr,
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
      relatedEducationalContent: relatedEducationalContent,
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
