// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CartModel _$CartModelFromJson(Map<String, dynamic> json) => CartModel(
  items:
      (json['items'] as List<dynamic>?)
          ?.map((e) => CartItemModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0,
  shippingCost: (json['shipping_cost'] as num?)?.toDouble() ?? 0,
  discount: (json['discount'] as num?)?.toDouble() ?? 0,
  couponCode: json['coupon_code'] as String?,
  total: (json['total'] as num?)?.toDouble() ?? 0,
  updatedAt: json['updated_at'] as String?,
);

Map<String, dynamic> _$CartModelToJson(CartModel instance) => <String, dynamic>{
  'items': instance.items,
  'subtotal': instance.subtotal,
  'shipping_cost': instance.shippingCost,
  'discount': instance.discount,
  'coupon_code': instance.couponCode,
  'total': instance.total,
  'updated_at': instance.updatedAt,
};

AddToCartRequest _$AddToCartRequestFromJson(Map<String, dynamic> json) =>
    AddToCartRequest(
      productId: (json['product_id'] as num).toInt(),
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
    );

Map<String, dynamic> _$AddToCartRequestToJson(AddToCartRequest instance) =>
    <String, dynamic>{
      'product_id': instance.productId,
      'quantity': instance.quantity,
    };

UpdateCartItemRequest _$UpdateCartItemRequestFromJson(
  Map<String, dynamic> json,
) => UpdateCartItemRequest(quantity: (json['quantity'] as num).toInt());

Map<String, dynamic> _$UpdateCartItemRequestToJson(
  UpdateCartItemRequest instance,
) => <String, dynamic>{'quantity': instance.quantity};

ApplyCouponRequest _$ApplyCouponRequestFromJson(Map<String, dynamic> json) =>
    ApplyCouponRequest(code: json['code'] as String);

Map<String, dynamic> _$ApplyCouponRequestToJson(ApplyCouponRequest instance) =>
    <String, dynamic>{'code': instance.code};
