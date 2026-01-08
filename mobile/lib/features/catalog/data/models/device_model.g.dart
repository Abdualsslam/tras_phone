// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeviceModel _$DeviceModelFromJson(Map<String, dynamic> json) => DeviceModel(
  id: DeviceModel._readId(json, '_id') as String,
  brandId: DeviceModel._readBrandId(json, 'brandId') as String,
  name: json['name'] as String,
  nameAr: json['nameAr'] as String,
  slug: json['slug'] as String,
  modelNumber: json['modelNumber'] as String?,
  image: json['image'] as String?,
  screenSize: json['screenSize'] as String?,
  releaseYear: (json['releaseYear'] as num?)?.toInt(),
  colors: (json['colors'] as List<dynamic>?)?.map((e) => e as String).toList(),
  storageOptions: (json['storageOptions'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  isActive: json['isActive'] as bool? ?? true,
  isPopular: json['isPopular'] as bool? ?? false,
  displayOrder: (json['displayOrder'] as num?)?.toInt() ?? 0,
  productsCount: (json['productsCount'] as num?)?.toInt() ?? 0,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$DeviceModelToJson(DeviceModel instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'brandId': instance.brandId,
      'name': instance.name,
      'nameAr': instance.nameAr,
      'slug': instance.slug,
      'modelNumber': instance.modelNumber,
      'image': instance.image,
      'screenSize': instance.screenSize,
      'releaseYear': instance.releaseYear,
      'colors': instance.colors,
      'storageOptions': instance.storageOptions,
      'isActive': instance.isActive,
      'isPopular': instance.isPopular,
      'displayOrder': instance.displayOrder,
      'productsCount': instance.productsCount,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
