// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wishlist_item_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WishlistItemModel _$WishlistItemModelFromJson(Map<String, dynamic> json) =>
    WishlistItemModel(
      id: (json['id'] as num).toInt(),
      productId: (json['product_id'] as num).toInt(),
      product: json['product'] == null
          ? null
          : ProductModel.fromJson(json['product'] as Map<String, dynamic>),
      addedAt: json['added_at'] as String?,
      isInStock: json['is_in_stock'] as bool? ?? true,
      priceDropped: json['price_dropped'] as bool? ?? false,
      originalPrice: (json['original_price'] as num?)?.toDouble(),
      currentPrice: (json['current_price'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$WishlistItemModelToJson(WishlistItemModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'product_id': instance.productId,
      'product': instance.product,
      'added_at': instance.addedAt,
      'is_in_stock': instance.isInStock,
      'price_dropped': instance.priceDropped,
      'original_price': instance.originalPrice,
      'current_price': instance.currentPrice,
    };
