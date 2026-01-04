/// Device Model - Data layer model with JSON serialization
library;

import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/device_entity.dart';
import 'brand_model.dart';

part 'device_model.g.dart';

@JsonSerializable()
class DeviceModel {
  @JsonKey(name: '_id', readValue: _readId)
  final String id;
  @JsonKey(readValue: _readBrandId)
  final String brandId;
  final String name;
  final String nameAr;
  final String slug;
  final String? modelNumber;
  final String? image;
  final String? screenSize;
  final int? releaseYear;
  final List<String>? colors;
  final List<String>? storageOptions;
  @JsonKey(defaultValue: true)
  final bool isActive;
  @JsonKey(defaultValue: false)
  final bool isPopular;
  @JsonKey(defaultValue: 0)
  final int displayOrder;
  @JsonKey(defaultValue: 0)
  final int productsCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Can be populated if brand is included
  @JsonKey(includeFromJson: false, includeToJson: false)
  final BrandModel? brand;

  const DeviceModel({
    required this.id,
    required this.brandId,
    required this.name,
    required this.nameAr,
    required this.slug,
    this.modelNumber,
    this.image,
    this.screenSize,
    this.releaseYear,
    this.colors,
    this.storageOptions,
    required this.isActive,
    required this.isPopular,
    required this.displayOrder,
    required this.productsCount,
    required this.createdAt,
    required this.updatedAt,
    this.brand,
  });

  /// Handle both String id and ObjectId map from MongoDB
  static Object? _readId(Map<dynamic, dynamic> json, String key) {
    final value = json['_id'] ?? json['id'];
    if (value is Map) {
      return value['\$oid'] ?? value.toString();
    }
    return value;
  }

  /// Handle brandId which can be String or populated Brand object
  static Object? _readBrandId(Map<dynamic, dynamic> json, String key) {
    final value = json['brandId'];
    if (value is Map) {
      return value['_id'] ?? value['\$oid'] ?? value.toString();
    }
    return value;
  }

  factory DeviceModel.fromJson(Map<String, dynamic> json) {
    final model = _$DeviceModelFromJson(json);
    // Check if brandId is a populated object
    final brandData = json['brandId'];
    if (brandData is Map<String, dynamic>) {
      return DeviceModel(
        id: model.id,
        brandId: model.brandId,
        name: model.name,
        nameAr: model.nameAr,
        slug: model.slug,
        modelNumber: model.modelNumber,
        image: model.image,
        screenSize: model.screenSize,
        releaseYear: model.releaseYear,
        colors: model.colors,
        storageOptions: model.storageOptions,
        isActive: model.isActive,
        isPopular: model.isPopular,
        displayOrder: model.displayOrder,
        productsCount: model.productsCount,
        createdAt: model.createdAt,
        updatedAt: model.updatedAt,
        brand: BrandModel.fromJson(brandData),
      );
    }
    return model;
  }

  Map<String, dynamic> toJson() => _$DeviceModelToJson(this);

  DeviceEntity toEntity() {
    return DeviceEntity(
      id: id,
      brandId: brandId,
      name: name,
      nameAr: nameAr,
      slug: slug,
      modelNumber: modelNumber,
      image: image,
      screenSize: screenSize,
      releaseYear: releaseYear,
      colors: colors,
      storageOptions: storageOptions,
      isActive: isActive,
      isPopular: isPopular,
      displayOrder: displayOrder,
      productsCount: productsCount,
      createdAt: createdAt,
      updatedAt: updatedAt,
      brand: brand?.toEntity(),
    );
  }
}
