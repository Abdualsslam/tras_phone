// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wishlist_item_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WishlistItemModel _$WishlistItemModelFromJson(Map<String, dynamic> json) =>
    WishlistItemModel(
      id: WishlistItemModel._readId(json, '_id') as String,
      customerId:
          WishlistItemModel._readRelationId(json, 'customerId') as String?,
      productData: WishlistItemModel._readProductData(json, 'productId'),
      addedAt: json['createdAt'] as String?,
      notifyOnPriceChange: json['notifyOnPriceChange'] as bool? ?? false,
      notifyOnBackInStock: json['notifyOnBackInStock'] as bool? ?? false,
      note: json['note'] as String?,
    );

Map<String, dynamic> _$WishlistItemModelToJson(WishlistItemModel instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'customerId': instance.customerId,
      'productId': instance.productData,
      'createdAt': instance.addedAt,
      'notifyOnPriceChange': instance.notifyOnPriceChange,
      'notifyOnBackInStock': instance.notifyOnBackInStock,
      'note': instance.note,
    };
