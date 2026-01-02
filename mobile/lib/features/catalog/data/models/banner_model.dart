/// Banner Model - Data layer model with JSON serialization
library;

import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/banner_entity.dart';

part 'banner_model.g.dart';

@JsonSerializable()
class BannerModel {
  final int id;
  final String title;
  @JsonKey(name: 'title_ar')
  final String? titleAr;
  final String? subtitle;
  @JsonKey(name: 'subtitle_ar')
  final String? subtitleAr;
  @JsonKey(name: 'image_url')
  final String imageUrl;
  @JsonKey(name: 'image_mobile_url')
  final String? imageMobileUrl;
  @JsonKey(name: 'link_type')
  final String? linkType;
  @JsonKey(name: 'link_value')
  final String? linkValue;
  final String placement;
  @JsonKey(name: 'sort_order')
  final int sortOrder;
  @JsonKey(name: 'is_active')
  final bool isActive;

  const BannerModel({
    required this.id,
    required this.title,
    this.titleAr,
    this.subtitle,
    this.subtitleAr,
    required this.imageUrl,
    this.imageMobileUrl,
    this.linkType,
    this.linkValue,
    this.placement = 'home_slider',
    this.sortOrder = 0,
    this.isActive = true,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) =>
      _$BannerModelFromJson(json);
  Map<String, dynamic> toJson() => _$BannerModelToJson(this);

  BannerEntity toEntity() {
    return BannerEntity(
      id: id,
      title: title,
      titleAr: titleAr,
      subtitle: subtitle,
      subtitleAr: subtitleAr,
      imageUrl: imageUrl,
      imageMobileUrl: imageMobileUrl,
      linkType: linkType,
      linkValue: linkValue,
      placement: placement,
      isActive: isActive,
    );
  }
}
