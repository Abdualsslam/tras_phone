/// Category Model - Data layer model with JSON serialization
library;

import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/category_entity.dart';

part 'category_model.g.dart';

@JsonSerializable()
class CategoryModel {
  final int id;
  final String name;
  @JsonKey(name: 'name_ar')
  final String? nameAr;
  final String slug;
  @JsonKey(name: 'parent_id')
  final int? parentId;
  final String? icon;
  @JsonKey(name: 'image_url')
  final String? imageUrl;
  final int level;
  @JsonKey(name: 'products_count')
  final int productsCount;
  @JsonKey(name: 'is_active')
  final bool isActive;
  final List<CategoryModel> children;

  const CategoryModel({
    required this.id,
    required this.name,
    this.nameAr,
    required this.slug,
    this.parentId,
    this.icon,
    this.imageUrl,
    this.level = 0,
    this.productsCount = 0,
    this.isActive = true,
    this.children = const [],
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) =>
      _$CategoryModelFromJson(json);
  Map<String, dynamic> toJson() => _$CategoryModelToJson(this);

  CategoryEntity toEntity() {
    return CategoryEntity(
      id: id,
      name: name,
      nameAr: nameAr,
      slug: slug,
      parentId: parentId,
      icon: icon,
      imageUrl: imageUrl,
      level: level,
      productsCount: productsCount,
      isActive: isActive,
      children: children.map((c) => c.toEntity()).toList(),
    );
  }

  static CategoryModel fromEntity(CategoryEntity entity) {
    return CategoryModel(
      id: entity.id,
      name: entity.name,
      nameAr: entity.nameAr,
      slug: entity.slug,
      parentId: entity.parentId,
      icon: entity.icon,
      imageUrl: entity.imageUrl,
      level: entity.level,
      productsCount: entity.productsCount,
      isActive: entity.isActive,
      children: entity.children
          .map((c) => CategoryModel.fromEntity(c))
          .toList(),
    );
  }
}
