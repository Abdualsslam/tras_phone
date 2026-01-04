/// Category Model - Data layer model with JSON serialization
library;

import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/category_entity.dart';

part 'category_model.g.dart';

@JsonSerializable()
class CategoryModel {
  @JsonKey(name: '_id', readValue: _readId)
  final String id;
  final String name;
  final String nameAr;
  final String slug;
  final String? description;
  final String? descriptionAr;
  final String? image;
  final String? icon;
  @JsonKey(readValue: _readParentId)
  final String? parentId;
  @JsonKey(defaultValue: [])
  final List<String> ancestors;
  @JsonKey(defaultValue: 0)
  final int level;
  final String? path;
  @JsonKey(defaultValue: true)
  final bool isActive;
  @JsonKey(defaultValue: false)
  final bool isFeatured;
  @JsonKey(defaultValue: 0)
  final int displayOrder;
  @JsonKey(defaultValue: 0)
  final int productsCount;
  @JsonKey(defaultValue: 0)
  final int childrenCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  @JsonKey(defaultValue: [])
  final List<CategoryModel> children;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.slug,
    this.description,
    this.descriptionAr,
    this.image,
    this.icon,
    this.parentId,
    this.ancestors = const [],
    required this.level,
    this.path,
    required this.isActive,
    required this.isFeatured,
    required this.displayOrder,
    required this.productsCount,
    required this.childrenCount,
    required this.createdAt,
    required this.updatedAt,
    this.children = const [],
  });

  /// Handle both String id and ObjectId map from MongoDB
  static Object? _readId(Map<dynamic, dynamic> json, String key) {
    final value = json['_id'] ?? json['id'];
    if (value is Map) {
      return value['\$oid'] ?? value.toString();
    }
    return value;
  }

  /// Handle parentId which can be null, String, or ObjectId map
  static Object? _readParentId(Map<dynamic, dynamic> json, String key) {
    final value = json['parentId'];
    if (value == null) return null;
    if (value is Map) {
      return value['\$oid'] ?? value.toString();
    }
    return value;
  }

  factory CategoryModel.fromJson(Map<String, dynamic> json) =>
      _$CategoryModelFromJson(json);
  Map<String, dynamic> toJson() => _$CategoryModelToJson(this);

  CategoryEntity toEntity() {
    return CategoryEntity(
      id: id,
      name: name,
      nameAr: nameAr,
      slug: slug,
      description: description,
      descriptionAr: descriptionAr,
      image: image,
      icon: icon,
      parentId: parentId,
      ancestors: ancestors,
      level: level,
      path: path,
      isActive: isActive,
      isFeatured: isFeatured,
      displayOrder: displayOrder,
      productsCount: productsCount,
      childrenCount: childrenCount,
      createdAt: createdAt,
      updatedAt: updatedAt,
      children: children.map((c) => c.toEntity()).toList(),
    );
  }
}

/// Breadcrumb item model for JSON serialization
@JsonSerializable()
class BreadcrumbItemModel {
  @JsonKey(name: '_id', readValue: CategoryModel._readId)
  final String id;
  final String name;
  final String nameAr;
  final String slug;

  const BreadcrumbItemModel({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.slug,
  });

  factory BreadcrumbItemModel.fromJson(Map<String, dynamic> json) =>
      _$BreadcrumbItemModelFromJson(json);
  Map<String, dynamic> toJson() => _$BreadcrumbItemModelToJson(this);

  BreadcrumbItem toEntity() {
    return BreadcrumbItem(id: id, name: name, nameAr: nameAr, slug: slug);
  }
}
