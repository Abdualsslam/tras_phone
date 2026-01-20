// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'educational_category_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EducationalCategoryModel _$EducationalCategoryModelFromJson(
  Map<String, dynamic> json,
) => EducationalCategoryModel(
  id: EducationalCategoryModel._readId(json, '_id') as String,
  name: json['name'] as String,
  nameAr: json['nameAr'] as String?,
  slug: json['slug'] as String,
  description: json['description'] as String?,
  descriptionAr: json['descriptionAr'] as String?,
  icon: json['icon'] as String?,
  image: json['image'] as String?,
  parentId: json['parentId'] as String?,
  contentCount: (json['contentCount'] as num).toInt(),
  sortOrder: (json['sortOrder'] as num).toInt(),
  isActive: json['isActive'] as bool,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$EducationalCategoryModelToJson(
  EducationalCategoryModel instance,
) => <String, dynamic>{
  '_id': instance.id,
  'name': instance.name,
  'nameAr': instance.nameAr,
  'slug': instance.slug,
  'description': instance.description,
  'descriptionAr': instance.descriptionAr,
  'icon': instance.icon,
  'image': instance.image,
  'parentId': instance.parentId,
  'contentCount': instance.contentCount,
  'sortOrder': instance.sortOrder,
  'isActive': instance.isActive,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};
