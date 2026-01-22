// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'banner_targeting_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BannerTargetingModel _$BannerTargetingModelFromJson(
  Map<String, dynamic> json,
) => BannerTargetingModel(
  customerSegments:
      (json['customerSegments'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      [],
  categories: (json['categories'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  userTypes:
      (json['userTypes'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      ['all'],
  devices:
      (json['devices'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      [],
);

Map<String, dynamic> _$BannerTargetingModelToJson(
  BannerTargetingModel instance,
) => <String, dynamic>{
  'customerSegments': instance.customerSegments,
  'categories': instance.categories,
  'userTypes': instance.userTypes,
  'devices': instance.devices,
};
