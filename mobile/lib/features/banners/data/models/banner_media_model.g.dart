// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'banner_media_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BannerMediaModel _$BannerMediaModelFromJson(Map<String, dynamic> json) =>
    BannerMediaModel(
      imageDesktopAr: json['imageDesktopAr'] as String,
      imageDesktopEn: json['imageDesktopEn'] as String,
      imageMobileAr: json['imageMobileAr'] as String?,
      imageMobileEn: json['imageMobileEn'] as String?,
      videoUrl: json['videoUrl'] as String?,
      altTextAr: json['altTextAr'] as String?,
      altTextEn: json['altTextEn'] as String?,
    );

Map<String, dynamic> _$BannerMediaModelToJson(BannerMediaModel instance) =>
    <String, dynamic>{
      'imageDesktopAr': instance.imageDesktopAr,
      'imageDesktopEn': instance.imageDesktopEn,
      'imageMobileAr': instance.imageMobileAr,
      'imageMobileEn': instance.imageMobileEn,
      'videoUrl': instance.videoUrl,
      'altTextAr': instance.altTextAr,
      'altTextEn': instance.altTextEn,
    };
