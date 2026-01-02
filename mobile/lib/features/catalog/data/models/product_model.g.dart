// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductModel _$ProductModelFromJson(Map<String, dynamic> json) => ProductModel(
  id: (json['id'] as num).toInt(),
  sku: json['sku'] as String,
  name: json['name'] as String,
  nameAr: json['name_ar'] as String?,
  slug: json['slug'] as String,
  description: json['description'] as String?,
  descriptionAr: json['description_ar'] as String?,
  price: (json['price'] as num).toDouble(),
  originalPrice: (json['original_price'] as num?)?.toDouble(),
  categoryId: (json['category_id'] as num).toInt(),
  brandId: (json['brand_id'] as num?)?.toInt(),
  deviceId: (json['device_id'] as num?)?.toInt(),
  imageUrl: json['image_url'] as String?,
  images:
      (json['images'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  stockQuantity: (json['stock_quantity'] as num?)?.toInt() ?? 0,
  isActive: json['is_active'] as bool? ?? true,
  isFeatured: json['is_featured'] as bool? ?? false,
  rating: (json['rating'] as num?)?.toDouble(),
  reviewsCount: (json['reviews_count'] as num?)?.toInt() ?? 0,
  createdAt: json['created_at'] as String?,
);

Map<String, dynamic> _$ProductModelToJson(ProductModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sku': instance.sku,
      'name': instance.name,
      'name_ar': instance.nameAr,
      'slug': instance.slug,
      'description': instance.description,
      'description_ar': instance.descriptionAr,
      'price': instance.price,
      'original_price': instance.originalPrice,
      'category_id': instance.categoryId,
      'brand_id': instance.brandId,
      'device_id': instance.deviceId,
      'image_url': instance.imageUrl,
      'images': instance.images,
      'stock_quantity': instance.stockQuantity,
      'is_active': instance.isActive,
      'is_featured': instance.isFeatured,
      'rating': instance.rating,
      'reviews_count': instance.reviewsCount,
      'created_at': instance.createdAt,
    };

PaginatedProductsResponse _$PaginatedProductsResponseFromJson(
  Map<String, dynamic> json,
) => PaginatedProductsResponse(
  data: (json['data'] as List<dynamic>)
      .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  meta: PaginationMeta.fromJson(json['meta'] as Map<String, dynamic>),
);

Map<String, dynamic> _$PaginatedProductsResponseToJson(
  PaginatedProductsResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};

PaginationMeta _$PaginationMetaFromJson(Map<String, dynamic> json) =>
    PaginationMeta(
      currentPage: (json['current_page'] as num).toInt(),
      lastPage: (json['last_page'] as num).toInt(),
      perPage: (json['per_page'] as num).toInt(),
      total: (json['total'] as num).toInt(),
    );

Map<String, dynamic> _$PaginationMetaToJson(PaginationMeta instance) =>
    <String, dynamic>{
      'current_page': instance.currentPage,
      'last_page': instance.lastPage,
      'per_page': instance.perPage,
      'total': instance.total,
    };
