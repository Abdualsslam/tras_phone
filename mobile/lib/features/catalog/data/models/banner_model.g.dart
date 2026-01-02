// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'banner_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BannerModel _$BannerModelFromJson(Map<String, dynamic> json) => BannerModel(
  id: (json['id'] as num).toInt(),
  title: json['title'] as String,
  titleAr: json['title_ar'] as String?,
  subtitle: json['subtitle'] as String?,
  subtitleAr: json['subtitle_ar'] as String?,
  imageUrl: json['image_url'] as String,
  imageMobileUrl: json['image_mobile_url'] as String?,
  linkType: json['link_type'] as String?,
  linkValue: json['link_value'] as String?,
  placement: json['placement'] as String? ?? 'home_slider',
  sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
  isActive: json['is_active'] as bool? ?? true,
);

Map<String, dynamic> _$BannerModelToJson(BannerModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'title_ar': instance.titleAr,
      'subtitle': instance.subtitle,
      'subtitle_ar': instance.subtitleAr,
      'image_url': instance.imageUrl,
      'image_mobile_url': instance.imageMobileUrl,
      'link_type': instance.linkType,
      'link_value': instance.linkValue,
      'placement': instance.placement,
      'sort_order': instance.sortOrder,
      'is_active': instance.isActive,
    };
