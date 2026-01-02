// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'brand_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BrandModel _$BrandModelFromJson(Map<String, dynamic> json) => BrandModel(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  nameAr: json['name_ar'] as String?,
  slug: json['slug'] as String,
  logo: json['logo'] as String?,
  banner: json['banner'] as String?,
  productsCount: (json['products_count'] as num?)?.toInt() ?? 0,
  isActive: json['is_active'] as bool? ?? true,
  isFeatured: json['is_featured'] as bool? ?? false,
);

Map<String, dynamic> _$BrandModelToJson(BrandModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'name_ar': instance.nameAr,
      'slug': instance.slug,
      'logo': instance.logo,
      'banner': instance.banner,
      'products_count': instance.productsCount,
      'is_active': instance.isActive,
      'is_featured': instance.isFeatured,
    };
