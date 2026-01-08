/// Category Entity - Domain layer representation of a category
library;

import 'package:equatable/equatable.dart';

class CategoryEntity extends Equatable {
  final String id;
  final String name;
  final String nameAr;
  final String slug;
  final String? description;
  final String? descriptionAr;
  final String? image;
  final String? icon;
  final String? parentId;
  final List<String> ancestors;
  final int level;
  final String? path;
  final bool isActive;
  final bool isFeatured;
  final int displayOrder;
  final int productsCount;
  final int childrenCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  // For tree structure
  final List<CategoryEntity> children;

  const CategoryEntity({
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

  /// Is this a root category?
  bool get isRoot => parentId == null && level == 0;

  /// Does it have children?
  bool get hasChildren => childrenCount > 0 || children.isNotEmpty;

  /// Get name by locale
  String getName(String locale) => locale == 'ar' ? nameAr : name;

  /// Get description by locale
  String? getDescription(String locale) =>
      locale == 'ar' ? descriptionAr : description;

  @override
  List<Object?> get props => [id, slug];
}

/// Breadcrumb item for category navigation
class BreadcrumbItem extends Equatable {
  final String id;
  final String name;
  final String nameAr;
  final String slug;

  const BreadcrumbItem({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.slug,
  });

  String getName(String locale) => locale == 'ar' ? nameAr : name;

  @override
  List<Object?> get props => [id, slug];
}

/// Category with breadcrumb for navigation
class CategoryWithBreadcrumb {
  final CategoryEntity category;
  final List<BreadcrumbItem> breadcrumb;

  const CategoryWithBreadcrumb({
    required this.category,
    required this.breadcrumb,
  });
}
