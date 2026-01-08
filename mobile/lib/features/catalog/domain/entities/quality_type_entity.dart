/// Quality Type Entity - Domain layer representation of quality levels
library;

import 'dart:ui';
import 'package:equatable/equatable.dart';

class QualityTypeEntity extends Equatable {
  final String id;
  final String name;
  final String nameAr;
  final String code; // "original", "oem", "aaa", "copy"
  final String? description;
  final String? descriptionAr;
  final String? color; // Badge color (hex)
  final String? icon;
  final int displayOrder;
  final bool isActive;
  final int? defaultWarrantyDays;
  final DateTime createdAt;
  final DateTime updatedAt;

  const QualityTypeEntity({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.code,
    this.description,
    this.descriptionAr,
    this.color,
    this.icon,
    required this.displayOrder,
    required this.isActive,
    this.defaultWarrantyDays,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Get name by locale
  String getName(String locale) => locale == 'ar' ? nameAr : name;

  /// Get description by locale
  String? getDescription(String locale) =>
      locale == 'ar' ? descriptionAr : description;

  /// Convert hex color to Color
  Color? getColor() {
    if (color == null) return null;
    final hex = color!.replaceFirst('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  @override
  List<Object?> get props => [id, code];
}
