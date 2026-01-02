/// Wishlist Item Model - Data layer model with JSON serialization
library;

import 'package:json_annotation/json_annotation.dart';
import '../../../catalog/data/models/product_model.dart';

part 'wishlist_item_model.g.dart';

@JsonSerializable()
class WishlistItemModel {
  final int id;
  @JsonKey(name: 'product_id')
  final int productId;
  final ProductModel? product;
  @JsonKey(name: 'added_at')
  final String? addedAt;
  @JsonKey(name: 'is_in_stock')
  final bool isInStock;
  @JsonKey(name: 'price_dropped')
  final bool priceDropped;
  @JsonKey(name: 'original_price')
  final double? originalPrice;
  @JsonKey(name: 'current_price')
  final double? currentPrice;

  const WishlistItemModel({
    required this.id,
    required this.productId,
    this.product,
    this.addedAt,
    this.isInStock = true,
    this.priceDropped = false,
    this.originalPrice,
    this.currentPrice,
  });

  factory WishlistItemModel.fromJson(Map<String, dynamic> json) =>
      _$WishlistItemModelFromJson(json);
  Map<String, dynamic> toJson() => _$WishlistItemModelToJson(this);

  double? get priceDifference {
    if (originalPrice != null && currentPrice != null) {
      return originalPrice! - currentPrice!;
    }
    return null;
  }
}
