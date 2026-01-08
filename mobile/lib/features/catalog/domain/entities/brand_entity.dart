/// Brand Entity - Domain layer representation of a brand
library;

import 'package:equatable/equatable.dart';

class BrandEntity extends Equatable {
  final String id;
  final String name;
  final String nameAr;
  final String slug;
  final String? description;
  final String? descriptionAr;
  final String? logo;
  final String? website;
  final bool isActive;
  final bool isFeatured;
  final int displayOrder;
  final int productsCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const BrandEntity({
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

  /// Get name by locale
  String getName(String locale) => locale == 'ar' ? nameAr : name;

  /// Get description by locale
  String? getDescription(String locale) =>
      locale == 'ar' ? descriptionAr : description;

  @override
  List<Object?> get props => [id, slug];
}
