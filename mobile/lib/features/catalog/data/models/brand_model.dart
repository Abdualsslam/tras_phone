/// Brand Model - Data layer model with JSON serialization
library;

import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/brand_entity.dart';

part 'brand_model.g.dart';

@JsonSerializable()
class BrandModel {
  final int id;
  final String name;
  @JsonKey(name: 'name_ar')
  final String? nameAr;
  final String slug;
  final String? logo;
  final String? banner;
  @JsonKey(name: 'products_count')
  final int productsCount;
  @JsonKey(name: 'is_active')
  final bool isActive;
  @JsonKey(name: 'is_featured')
  final bool isFeatured;

  const BrandModel({
    required this.id,
    required this.name,
    this.nameAr,
    required this.slug,
    this.logo,
    this.banner,
    this.productsCount = 0,
    this.isActive = true,
    this.isFeatured = false,
  });

  factory BrandModel.fromJson(Map<String, dynamic> json) =>
      _$BrandModelFromJson(json);
  Map<String, dynamic> toJson() => _$BrandModelToJson(this);

  BrandEntity toEntity() {
    return BrandEntity(
      id: id,
      name: name,
      nameAr: nameAr,
      slug: slug,
      logo: logo,
      banner: banner,
      productsCount: productsCount,
      isActive: isActive,
      isFeatured: isFeatured,
    );
  }

  static BrandModel fromEntity(BrandEntity entity) {
    return BrandModel(
      id: entity.id,
      name: entity.name,
      nameAr: entity.nameAr,
      slug: entity.slug,
      logo: entity.logo,
      banner: entity.banner,
      productsCount: entity.productsCount,
      isActive: entity.isActive,
      isFeatured: entity.isFeatured,
    );
  }
}
