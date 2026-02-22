// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductModel _$ProductModelFromJson(Map<String, dynamic> json) => ProductModel(
  id: ProductModel._readId(json, 'id') as String,
  sku: json['sku'] as String,
  name: json['name'] as String,
  nameAr: json['nameAr'] as String,
  slug: json['slug'] as String,
  description: json['description'] as String?,
  descriptionAr: json['descriptionAr'] as String?,
  shortDescription: json['shortDescription'] as String?,
  shortDescriptionAr: json['shortDescriptionAr'] as String?,
  brandId: ProductModel._readRelationId(json, 'brandId') as String,
  categoryId: ProductModel._readRelationId(json, 'categoryId') as String,
  additionalCategories:
      (json['additionalCategories'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      [],
  qualityTypeId: ProductModel._readRelationId(json, 'qualityTypeId') as String,
  compatibleDevices:
      (json['compatibleDevices'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      [],
  mainImage: json['mainImage'] as String?,
  images:
      (json['images'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      [],
  video: json['video'] as String?,
  basePrice: (json['basePrice'] as num?)?.toDouble() ?? 0.0,
  compareAtPrice: (json['compareAtPrice'] as num?)?.toDouble(),
  price: (json['price'] as num?)?.toDouble(),
  stockQuantity: (json['stockQuantity'] as num?)?.toInt() ?? 0,
  lowStockThreshold: (json['lowStockThreshold'] as num?)?.toInt() ?? 5,
  trackInventory: json['trackInventory'] as bool? ?? true,
  allowBackorder: json['allowBackorder'] as bool? ?? false,
  minOrderQuantity: (json['minOrderQuantity'] as num?)?.toInt() ?? 1,
  maxOrderQuantity: (json['maxOrderQuantity'] as num?)?.toInt(),
  quantityStep: (json['quantityStep'] as num?)?.toInt() ?? 1,
  status: json['status'] as String? ?? 'active',
  isActive: json['isActive'] as bool? ?? true,
  isFeatured: json['isFeatured'] as bool? ?? false,
  isNewArrival: json['isNewArrival'] as bool? ?? false,
  isBestSeller: json['isBestSeller'] as bool? ?? false,
  specifications: json['specifications'] as Map<String, dynamic>?,
  weight: (json['weight'] as num?)?.toDouble(),
  dimensions: json['dimensions'] as String?,
  color: json['color'] as String?,
  warrantyDays: (json['warrantyDays'] as num?)?.toInt(),
  warrantyDescription: json['warrantyDescription'] as String?,
  viewsCount: (json['viewsCount'] as num?)?.toInt() ?? 0,
  ordersCount: (json['ordersCount'] as num?)?.toInt() ?? 0,
  salesCount: (json['salesCount'] as num?)?.toInt() ?? 0,
  reviewsCount: (json['reviewsCount'] as num?)?.toInt() ?? 0,
  averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0.0,
  favoriteCount: (json['favoriteCount'] as num?)?.toInt() ?? 0,
  relatedProducts:
      (ProductModel._readRelatedProducts(json, 'relatedProducts')
              as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
  tags:
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
  publishedAt: json['publishedAt'] == null
      ? null
      : DateTime.parse(json['publishedAt'] as String),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$ProductModelToJson(ProductModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sku': instance.sku,
      'name': instance.name,
      'nameAr': instance.nameAr,
      'slug': instance.slug,
      'description': instance.description,
      'descriptionAr': instance.descriptionAr,
      'shortDescription': instance.shortDescription,
      'shortDescriptionAr': instance.shortDescriptionAr,
      'brandId': instance.brandId,
      'categoryId': instance.categoryId,
      'additionalCategories': instance.additionalCategories,
      'qualityTypeId': instance.qualityTypeId,
      'compatibleDevices': instance.compatibleDevices,
      'relatedProducts': instance.relatedProducts,
      'mainImage': instance.mainImage,
      'images': instance.images,
      'video': instance.video,
      'basePrice': instance.basePrice,
      'compareAtPrice': instance.compareAtPrice,
      'price': instance.price,
      'stockQuantity': instance.stockQuantity,
      'lowStockThreshold': instance.lowStockThreshold,
      'trackInventory': instance.trackInventory,
      'allowBackorder': instance.allowBackorder,
      'minOrderQuantity': instance.minOrderQuantity,
      'maxOrderQuantity': instance.maxOrderQuantity,
      'quantityStep': instance.quantityStep,
      'status': instance.status,
      'isActive': instance.isActive,
      'isFeatured': instance.isFeatured,
      'isNewArrival': instance.isNewArrival,
      'isBestSeller': instance.isBestSeller,
      'specifications': instance.specifications,
      'weight': instance.weight,
      'dimensions': instance.dimensions,
      'color': instance.color,
      'warrantyDays': instance.warrantyDays,
      'warrantyDescription': instance.warrantyDescription,
      'viewsCount': instance.viewsCount,
      'ordersCount': instance.ordersCount,
      'salesCount': instance.salesCount,
      'reviewsCount': instance.reviewsCount,
      'averageRating': instance.averageRating,
      'favoriteCount': instance.favoriteCount,
      'tags': instance.tags,
      'publishedAt': instance.publishedAt?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
