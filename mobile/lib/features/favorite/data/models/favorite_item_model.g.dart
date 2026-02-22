// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favorite_item_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FavoriteItemModel _$FavoriteItemModelFromJson(Map<String, dynamic> json) =>
    FavoriteItemModel(
      id: FavoriteItemModel._readId(json, '_id') as String,
      customerId:
          FavoriteItemModel._readRelationId(json, 'customerId') as String?,
      productData: FavoriteItemModel._readProductData(json, 'productId'),
      addedAt: json['createdAt'] as String?,
      notifyOnPriceChange: json['notifyOnPriceChange'] as bool? ?? false,
      notifyOnBackInStock: json['notifyOnBackInStock'] as bool? ?? false,
      note: json['note'] as String?,
    );

Map<String, dynamic> _$FavoriteItemModelToJson(FavoriteItemModel instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'customerId': instance.customerId,
      'productId': instance.productData,
      'createdAt': instance.addedAt,
      'notifyOnPriceChange': instance.notifyOnPriceChange,
      'notifyOnBackInStock': instance.notifyOnBackInStock,
      'note': instance.note,
    };
