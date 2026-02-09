// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'banners_cache_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BannersCacheData _$BannersCacheDataFromJson(Map<String, dynamic> json) =>
    BannersCacheData(
      banners: (json['banners'] as List<dynamic>)
          .map((e) => e as Map<String, dynamic>)
          .toList(),
      placement: json['placement'] as String,
      cachedAt: json['cachedAt'] as String,
    );

Map<String, dynamic> _$BannersCacheDataToJson(BannersCacheData instance) =>
    <String, dynamic>{
      'banners': instance.banners,
      'placement': instance.placement,
      'cachedAt': instance.cachedAt,
    };
