// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'banner_content_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BannerContentModel _$BannerContentModelFromJson(Map<String, dynamic> json) =>
    BannerContentModel(
      headingAr: json['headingAr'] as String?,
      headingEn: json['headingEn'] as String?,
      subheadingAr: json['subheadingAr'] as String?,
      subheadingEn: json['subheadingEn'] as String?,
      buttonTextAr: json['buttonTextAr'] as String?,
      buttonTextEn: json['buttonTextEn'] as String?,
      textColor: json['textColor'] as String?,
      overlayColor: json['overlayColor'] as String?,
      overlayOpacity: (json['overlayOpacity'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$BannerContentModelToJson(BannerContentModel instance) =>
    <String, dynamic>{
      'headingAr': instance.headingAr,
      'headingEn': instance.headingEn,
      'subheadingAr': instance.subheadingAr,
      'subheadingEn': instance.subheadingEn,
      'buttonTextAr': instance.buttonTextAr,
      'buttonTextEn': instance.buttonTextEn,
      'textColor': instance.textColor,
      'overlayColor': instance.overlayColor,
      'overlayOpacity': instance.overlayOpacity,
    };
