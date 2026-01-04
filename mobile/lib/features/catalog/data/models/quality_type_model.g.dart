// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quality_type_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QualityTypeModel _$QualityTypeModelFromJson(Map<String, dynamic> json) =>
    QualityTypeModel(
      id: QualityTypeModel._readId(json, '_id') as String,
      name: json['name'] as String,
      nameAr: json['nameAr'] as String,
      code: json['code'] as String,
      description: json['description'] as String?,
      descriptionAr: json['descriptionAr'] as String?,
      color: json['color'] as String?,
      icon: json['icon'] as String?,
      displayOrder: (json['displayOrder'] as num?)?.toInt() ?? 0,
      isActive: json['isActive'] as bool? ?? true,
      defaultWarrantyDays: (json['defaultWarrantyDays'] as num?)?.toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$QualityTypeModelToJson(QualityTypeModel instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'name': instance.name,
      'nameAr': instance.nameAr,
      'code': instance.code,
      'description': instance.description,
      'descriptionAr': instance.descriptionAr,
      'color': instance.color,
      'icon': instance.icon,
      'displayOrder': instance.displayOrder,
      'isActive': instance.isActive,
      'defaultWarrantyDays': instance.defaultWarrantyDays,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
