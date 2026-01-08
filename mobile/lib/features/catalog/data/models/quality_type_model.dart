/// Quality Type Model - Data layer model with JSON serialization
library;

import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/quality_type_entity.dart';

part 'quality_type_model.g.dart';

@JsonSerializable()
class QualityTypeModel {
  @JsonKey(name: '_id', readValue: _readId)
  final String id;
  final String name;
  final String nameAr;
  final String code; // "original", "oem", "aaa", "copy"
  final String? description;
  final String? descriptionAr;
  final String? color; // Hex color
  final String? icon;
  @JsonKey(defaultValue: 0)
  final int displayOrder;
  @JsonKey(defaultValue: true)
  final bool isActive;
  final int? defaultWarrantyDays;
  final DateTime createdAt;
  final DateTime updatedAt;

  const QualityTypeModel({
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

  /// Handle both String id and ObjectId map from MongoDB
  static Object? _readId(Map<dynamic, dynamic> json, String key) {
    final value = json['_id'] ?? json['id'];
    if (value is Map) {
      return value['\$oid'] ?? value.toString();
    }
    return value;
  }

  factory QualityTypeModel.fromJson(Map<String, dynamic> json) =>
      _$QualityTypeModelFromJson(json);
  Map<String, dynamic> toJson() => _$QualityTypeModelToJson(this);

  QualityTypeEntity toEntity() {
    return QualityTypeEntity(
      id: id,
      name: name,
      nameAr: nameAr,
      code: code,
      description: description,
      descriptionAr: descriptionAr,
      color: color,
      icon: icon,
      displayOrder: displayOrder,
      isActive: isActive,
      defaultWarrantyDays: defaultWarrantyDays,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
