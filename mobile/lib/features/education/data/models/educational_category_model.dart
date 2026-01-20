/// Educational Category Model
library;

import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/educational_category_entity.dart';

part 'educational_category_model.g.dart';

@JsonSerializable()
class EducationalCategoryModel {
  @JsonKey(name: '_id', readValue: _readId)
  final String id;
  final String name;
  final String? nameAr;
  final String slug;
  final String? description;
  final String? descriptionAr;
  final String? icon;
  final String? image;
  final String? parentId;
  final int contentCount;
  final int sortOrder;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const EducationalCategoryModel({
    required this.id,
    required this.name,
    this.nameAr,
    required this.slug,
    this.description,
    this.descriptionAr,
    this.icon,
    this.image,
    this.parentId,
    required this.contentCount,
    required this.sortOrder,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Handle MongoDB _id or id field
  static Object? _readId(Map<dynamic, dynamic> json, String key) {
    final value = json['_id'] ?? json['id'];
    if (value is Map) {
      return value['\$oid'] ?? value.toString();
    }
    return value?.toString();
  }

  factory EducationalCategoryModel.fromJson(Map<String, dynamic> json) =>
      _$EducationalCategoryModelFromJson(json);

  Map<String, dynamic> toJson() => _$EducationalCategoryModelToJson(this);

  EducationalCategoryEntity toEntity() {
    return EducationalCategoryEntity(
      id: id,
      name: name,
      nameAr: nameAr,
      slug: slug,
      description: description,
      descriptionAr: descriptionAr,
      icon: icon,
      image: image,
      parentId: parentId,
      contentCount: contentCount,
      sortOrder: sortOrder,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
