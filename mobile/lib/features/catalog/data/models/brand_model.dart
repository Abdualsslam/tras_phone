/// Brand Model - Data layer model with JSON serialization
library;

import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/brand_entity.dart';

part 'brand_model.g.dart';

@JsonSerializable()
class BrandModel {
  @JsonKey(name: '_id', readValue: _readId)
  final String id;
  final String name;
  final String nameAr;
  final String slug;
  final String? description;
  final String? descriptionAr;
  final String? logo;
  final String? website;
  @JsonKey(defaultValue: true)
  final bool isActive;
  @JsonKey(defaultValue: false)
  final bool isFeatured;
  @JsonKey(defaultValue: 0)
  final int displayOrder;
  @JsonKey(defaultValue: 0)
  final int productsCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const BrandModel({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.slug,
    this.description,
    this.descriptionAr,
    this.logo,
    this.website,
    required this.isActive,
    required this.isFeatured,
    required this.displayOrder,
    required this.productsCount,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Handle both String id and ObjectId map from MongoDB
  static Object? _readId(Map<dynamic, dynamic> json, String key) {
    final value = json['_id'] ?? json['id'];
    if (value is Map) {
      return value['\$oid'] ?? value.toString();
    }
    return value;
  }

  factory BrandModel.fromJson(Map<String, dynamic> json) =>
      _$BrandModelFromJson(json);
  Map<String, dynamic> toJson() => _$BrandModelToJson(this);

  BrandEntity toEntity() {
    return BrandEntity(
      id: id,
      name: name,
      nameAr: nameAr,
      slug: slug,
      description: description,
      descriptionAr: descriptionAr,
      logo: logo,
      website: website,
      isActive: isActive,
      isFeatured: isFeatured,
      displayOrder: displayOrder,
      productsCount: productsCount,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
