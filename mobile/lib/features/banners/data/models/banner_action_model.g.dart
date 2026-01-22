// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'banner_action_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BannerActionModel _$BannerActionModelFromJson(Map<String, dynamic> json) =>
    BannerActionModel(
      type: json['type'] as String,
      url: json['url'] as String?,
      refId: json['refId'] as String?,
      refModel: json['refModel'] as String?,
      openInNewTab: json['openInNewTab'] as bool? ?? false,
    );

Map<String, dynamic> _$BannerActionModelToJson(BannerActionModel instance) =>
    <String, dynamic>{
      'type': instance.type,
      'url': instance.url,
      'refId': instance.refId,
      'refModel': instance.refModel,
      'openInNewTab': instance.openInNewTab,
    };
