/// Banner Model - Data layer model with JSON serialization
library;

import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/banner_entity.dart';
import '../../domain/entities/banner_action_entity.dart';
import '../../domain/entities/banner_content_entity.dart';
import '../../domain/entities/banner_targeting_entity.dart';
import '../../domain/enums/banner_type.dart';
import '../../domain/enums/banner_position.dart';
import '../../domain/enums/banner_action_type.dart';
import 'banner_media_model.dart';
import 'banner_action_model.dart';
import 'banner_content_model.dart';
import 'banner_targeting_model.dart';

part 'banner_model.g.dart';

@JsonSerializable()
class BannerModel {
  @JsonKey(name: '_id')
  final String? id;
  @JsonKey(name: 'id')
  final String? idAlt;
  @JsonKey(name: 'nameAr')
  final String nameAr;
  @JsonKey(name: 'nameEn')
  final String nameEn;
  final String type;
  final String position;
  @JsonKey(name: 'media')
  final BannerMediaModel media;
  @JsonKey(name: 'action')
  final BannerActionModel? action;
  @JsonKey(name: 'content')
  final BannerContentModel? content;
  @JsonKey(name: 'targeting')
  final BannerTargetingModel? targeting;
  @JsonKey(name: 'startDate')
  final String? startDate;
  @JsonKey(name: 'endDate')
  final String? endDate;
  @JsonKey(name: 'isActive', defaultValue: true)
  final bool isActive;
  @JsonKey(name: 'sortOrder', defaultValue: 0)
  final int sortOrder;
  @JsonKey(name: 'priority', defaultValue: 0)
  final int priority;
  @JsonKey(name: 'impressions', defaultValue: 0)
  final int impressions;
  @JsonKey(name: 'clicks', defaultValue: 0)
  final int clicks;
  @JsonKey(name: 'createdAt')
  final String createdAt;
  @JsonKey(name: 'updatedAt')
  final String updatedAt;

  const BannerModel({
    this.id,
    this.idAlt,
    required this.nameAr,
    required this.nameEn,
    required this.type,
    required this.position,
    required this.media,
    this.action,
    this.content,
    this.targeting,
    this.startDate,
    this.endDate,
    this.isActive = true,
    this.sortOrder = 0,
    this.priority = 0,
    this.impressions = 0,
    this.clicks = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) =>
      _$BannerModelFromJson(json);

  Map<String, dynamic> toJson() => _$BannerModelToJson(this);

  BannerEntity toEntity() {
    return BannerEntity(
      id: id ?? idAlt ?? '',
      nameAr: nameAr,
      nameEn: nameEn,
      type: BannerType.values.firstWhere(
        (e) => e.value == type,
        orElse: () => BannerType.promotional,
      ),
      position: BannerPosition.values.firstWhere(
        (e) => e.value == position,
        orElse: () => BannerPosition.homeTop,
      ),
      media: media.toEntity(),
      action: action?.toEntity() ??
          const BannerActionEntity(type: BannerActionType.none),
      content: content?.toEntity() ?? const BannerContentEntity(),
      targeting: targeting?.toEntity() ?? const BannerTargetingEntity(),
      startDate: startDate != null ? DateTime.parse(startDate!) : null,
      endDate: endDate != null ? DateTime.parse(endDate!) : null,
      isActive: isActive,
      sortOrder: sortOrder,
      priority: priority,
      impressions: impressions,
      clicks: clicks,
      createdAt: DateTime.parse(createdAt),
      updatedAt: DateTime.parse(updatedAt),
    );
  }
}
