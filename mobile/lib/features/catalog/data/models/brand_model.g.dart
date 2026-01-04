// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'brand_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BrandModel _$BrandModelFromJson(Map<String, dynamic> json) => BrandModel(
  id: BrandModel._readId(json, '_id') as String,
  name: json['name'] as String,
  nameAr: json['nameAr'] as String,
  slug: json['slug'] as String,
  description: json['description'] as String?,
  descriptionAr: json['descriptionAr'] as String?,
  logo: json['logo'] as String?,
  website: json['website'] as String?,
  isActive: json['isActive'] as bool? ?? true,
  isFeatured: json['isFeatured'] as bool? ?? false,
  displayOrder: (json['displayOrder'] as num?)?.toInt() ?? 0,
  productsCount: (json['productsCount'] as num?)?.toInt() ?? 0,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$BrandModelToJson(BrandModel instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'name': instance.name,
      'nameAr': instance.nameAr,
      'slug': instance.slug,
      'description': instance.description,
      'descriptionAr': instance.descriptionAr,
      'logo': instance.logo,
      'website': instance.website,
      'isActive': instance.isActive,
      'isFeatured': instance.isFeatured,
      'displayOrder': instance.displayOrder,
      'productsCount': instance.productsCount,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
