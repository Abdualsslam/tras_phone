// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_cache_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HomeCacheData _$HomeCacheDataFromJson(Map<String, dynamic> json) =>
    HomeCacheData(
      categories: (json['categories'] as List<dynamic>)
          .map((e) => e as Map<String, dynamic>)
          .toList(),
      brands: (json['brands'] as List<dynamic>)
          .map((e) => e as Map<String, dynamic>)
          .toList(),
      featuredProducts: (json['featuredProducts'] as List<dynamic>)
          .map((e) => e as Map<String, dynamic>)
          .toList(),
      newArrivals: (json['newArrivals'] as List<dynamic>)
          .map((e) => e as Map<String, dynamic>)
          .toList(),
      bestSellers: (json['bestSellers'] as List<dynamic>)
          .map((e) => e as Map<String, dynamic>)
          .toList(),
      cachedAt: json['cachedAt'] as String,
    );

Map<String, dynamic> _$HomeCacheDataToJson(HomeCacheData instance) =>
    <String, dynamic>{
      'categories': instance.categories,
      'brands': instance.brands,
      'featuredProducts': instance.featuredProducts,
      'newArrivals': instance.newArrivals,
      'bestSellers': instance.bestSellers,
      'cachedAt': instance.cachedAt,
    };
