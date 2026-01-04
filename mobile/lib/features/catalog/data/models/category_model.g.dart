// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CategoryModel _$CategoryModelFromJson(Map<String, dynamic> json) =>
    CategoryModel(
      id: CategoryModel._readId(json, '_id') as String,
      name: json['name'] as String,
      nameAr: json['nameAr'] as String,
      slug: json['slug'] as String,
      description: json['description'] as String?,
      descriptionAr: json['descriptionAr'] as String?,
      image: json['image'] as String?,
      icon: json['icon'] as String?,
      parentId: CategoryModel._readParentId(json, 'parentId') as String?,
      ancestors:
          (json['ancestors'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      level: (json['level'] as num?)?.toInt() ?? 0,
      path: json['path'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      isFeatured: json['isFeatured'] as bool? ?? false,
      displayOrder: (json['displayOrder'] as num?)?.toInt() ?? 0,
      productsCount: (json['productsCount'] as num?)?.toInt() ?? 0,
      childrenCount: (json['childrenCount'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      children:
          (json['children'] as List<dynamic>?)
              ?.map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );

Map<String, dynamic> _$CategoryModelToJson(CategoryModel instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'name': instance.name,
      'nameAr': instance.nameAr,
      'slug': instance.slug,
      'description': instance.description,
      'descriptionAr': instance.descriptionAr,
      'image': instance.image,
      'icon': instance.icon,
      'parentId': instance.parentId,
      'ancestors': instance.ancestors,
      'level': instance.level,
      'path': instance.path,
      'isActive': instance.isActive,
      'isFeatured': instance.isFeatured,
      'displayOrder': instance.displayOrder,
      'productsCount': instance.productsCount,
      'childrenCount': instance.childrenCount,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'children': instance.children,
    };

BreadcrumbItemModel _$BreadcrumbItemModelFromJson(Map<String, dynamic> json) =>
    BreadcrumbItemModel(
      id: CategoryModel._readId(json, '_id') as String,
      name: json['name'] as String,
      nameAr: json['nameAr'] as String,
      slug: json['slug'] as String,
    );

Map<String, dynamic> _$BreadcrumbItemModelToJson(
  BreadcrumbItemModel instance,
) => <String, dynamic>{
  '_id': instance.id,
  'name': instance.name,
  'nameAr': instance.nameAr,
  'slug': instance.slug,
};
