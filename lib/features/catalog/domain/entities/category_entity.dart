/// Category Entity - Domain layer representation of a category
library;

import 'package:equatable/equatable.dart';

class CategoryEntity extends Equatable {
  final int id;
  final String name;
  final String? nameAr;
  final String slug;
  final int? parentId;
  final String? icon;
  final String? imageUrl;
  final int level;
  final int productsCount;
  final bool isActive;
  final List<CategoryEntity> children;

  const CategoryEntity({
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

  bool get hasChildren => children.isNotEmpty;
  bool get isParent => parentId == null;

  @override
  List<Object?> get props => [id, slug];
}
