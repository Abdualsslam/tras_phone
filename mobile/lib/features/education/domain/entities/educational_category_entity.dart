/// Educational Category Entity
library;

import 'package:equatable/equatable.dart';

class EducationalCategoryEntity extends Equatable {
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

  const EducationalCategoryEntity({
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

  @override
  List<Object?> get props => [
        id,
        name,
        nameAr,
        slug,
        description,
        descriptionAr,
        icon,
        image,
        parentId,
        contentCount,
        sortOrder,
        isActive,
        createdAt,
        updatedAt,
      ];
}
