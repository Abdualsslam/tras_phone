// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'banner_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BannerModel _$BannerModelFromJson(Map<String, dynamic> json) => BannerModel(
  id: json['_id'] as String?,
  idAlt: json['id'] as String?,
  nameAr: json['nameAr'] as String,
  nameEn: json['nameEn'] as String,
  type: json['type'] as String,
  position: json['position'] as String,
  media: BannerMediaModel.fromJson(json['media'] as Map<String, dynamic>),
  action: json['action'] == null
      ? null
      : BannerActionModel.fromJson(json['action'] as Map<String, dynamic>),
  content: json['content'] == null
      ? null
      : BannerContentModel.fromJson(json['content'] as Map<String, dynamic>),
  targeting: json['targeting'] == null
      ? null
      : BannerTargetingModel.fromJson(
          json['targeting'] as Map<String, dynamic>,
        ),
  startDate: json['startDate'] as String?,
  endDate: json['endDate'] as String?,
  isActive: json['isActive'] as bool? ?? true,
  sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
  priority: (json['priority'] as num?)?.toInt() ?? 0,
  impressions: (json['impressions'] as num?)?.toInt() ?? 0,
  clicks: (json['clicks'] as num?)?.toInt() ?? 0,
  createdAt: json['createdAt'] as String,
  updatedAt: json['updatedAt'] as String,
);

Map<String, dynamic> _$BannerModelToJson(BannerModel instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'id': instance.idAlt,
      'nameAr': instance.nameAr,
      'nameEn': instance.nameEn,
      'type': instance.type,
      'position': instance.position,
      'media': instance.media,
      'action': instance.action,
      'content': instance.content,
      'targeting': instance.targeting,
      'startDate': instance.startDate,
      'endDate': instance.endDate,
      'isActive': instance.isActive,
      'sortOrder': instance.sortOrder,
      'priority': instance.priority,
      'impressions': instance.impressions,
      'clicks': instance.clicks,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
    };
