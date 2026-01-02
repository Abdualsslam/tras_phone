// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CategoryModel _$CategoryModelFromJson(Map<String, dynamic> json) =>
    CategoryModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      nameAr: json['name_ar'] as String?,
      slug: json['slug'] as String,
      parentId: (json['parent_id'] as num?)?.toInt(),
      icon: json['icon'] as String?,
      imageUrl: json['image_url'] as String?,
      level: (json['level'] as num?)?.toInt() ?? 0,
      productsCount: (json['products_count'] as num?)?.toInt() ?? 0,
      isActive: json['is_active'] as bool? ?? true,
      children:
          (json['children'] as List<dynamic>?)
              ?.map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$CategoryModelToJson(CategoryModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'name_ar': instance.nameAr,
      'slug': instance.slug,
      'parent_id': instance.parentId,
      'icon': instance.icon,
      'image_url': instance.imageUrl,
      'level': instance.level,
      'products_count': instance.productsCount,
      'is_active': instance.isActive,
      'children': instance.children,
    };
