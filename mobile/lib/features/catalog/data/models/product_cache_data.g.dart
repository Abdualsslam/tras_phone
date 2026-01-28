// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_cache_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductCacheData _$ProductCacheDataFromJson(Map<String, dynamic> json) =>
    ProductCacheData(
      product: json['product'] as Map<String, dynamic>?,
      products: (json['products'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList(),
      pagination: json['pagination'] as Map<String, dynamic>?,
      filter: json['filter'] as Map<String, dynamic>?,
      cachedAt: json['cachedAt'] as String,
    );

Map<String, dynamic> _$ProductCacheDataToJson(ProductCacheData instance) =>
    <String, dynamic>{
      'product': instance.product,
      'products': instance.products,
      'pagination': instance.pagination,
      'filter': instance.filter,
      'cachedAt': instance.cachedAt,
    };
