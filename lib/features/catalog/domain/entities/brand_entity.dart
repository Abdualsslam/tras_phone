/// Brand Entity - Domain layer representation of a brand
library;

import 'package:equatable/equatable.dart';

class BrandEntity extends Equatable {
  final int id;
  final String name;
  final String? nameAr;
  final String slug;
  final String? logo;
  final String? banner;
  final int productsCount;
  final bool isActive;
  final bool isFeatured;

  const BrandEntity({
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

  @override
  List<Object?> get props => [id, slug];
}
