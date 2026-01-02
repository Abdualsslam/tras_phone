/// Cart Model - Data layer model with JSON serialization
library;

import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/cart_entity.dart';
import 'cart_item_model.dart';

part 'cart_model.g.dart';

@JsonSerializable()
class CartModel {
  final List<CartItemModel> items;
  final double subtotal;
  @JsonKey(name: 'shipping_cost')
  final double shippingCost;
  final double discount;
  @JsonKey(name: 'coupon_code')
  final String? couponCode;
  final double total;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  const CartModel({
    this.items = const [],
    this.subtotal = 0,
    this.shippingCost = 0,
    this.discount = 0,
    this.couponCode,
    this.total = 0,
    this.updatedAt,
  });

  factory CartModel.fromJson(Map<String, dynamic> json) =>
      _$CartModelFromJson(json);
  Map<String, dynamic> toJson() => _$CartModelToJson(this);

  CartEntity toEntity() {
    return CartEntity(
      items: items.map((i) => i.toEntity()).toList(),
      subtotal: subtotal,
      shippingCost: shippingCost,
      discount: discount,
      couponCode: couponCode,
      updatedAt: updatedAt != null
          ? DateTime.tryParse(updatedAt!) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

/// Request model for adding item to cart
@JsonSerializable()
class AddToCartRequest {
  @JsonKey(name: 'product_id')
  final int productId;
  final int quantity;

  const AddToCartRequest({required this.productId, this.quantity = 1});

  factory AddToCartRequest.fromJson(Map<String, dynamic> json) =>
      _$AddToCartRequestFromJson(json);
  Map<String, dynamic> toJson() => _$AddToCartRequestToJson(this);
}

/// Request model for updating cart item
@JsonSerializable()
class UpdateCartItemRequest {
  final int quantity;

  const UpdateCartItemRequest({required this.quantity});

  factory UpdateCartItemRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateCartItemRequestFromJson(json);
  Map<String, dynamic> toJson() => _$UpdateCartItemRequestToJson(this);
}

/// Request model for applying coupon
@JsonSerializable()
class ApplyCouponRequest {
  final String code;

  const ApplyCouponRequest({required this.code});

  factory ApplyCouponRequest.fromJson(Map<String, dynamic> json) =>
      _$ApplyCouponRequestFromJson(json);
  Map<String, dynamic> toJson() => _$ApplyCouponRequestToJson(this);
}
