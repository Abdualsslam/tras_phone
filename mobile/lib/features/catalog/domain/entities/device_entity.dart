/// Device Entity - Domain layer representation of a device/model
library;

import 'package:equatable/equatable.dart';
import 'brand_entity.dart';

class DeviceEntity extends Equatable {
  final String id;
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
  final bool isActive;
  final bool isPopular;
  final int displayOrder;
  final int productsCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Can be populated if brand is included
  final BrandEntity? brand;

  const DeviceEntity({
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

  /// Get name by locale
  String getName(String locale) => locale == 'ar' ? nameAr : name;

  @override
  List<Object?> get props => [id, slug, brandId];
}
