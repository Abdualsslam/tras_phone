// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CartModel _$CartModelFromJson(Map<String, dynamic> json) => CartModel(
  id: CartModel._readId(json, 'id') as String,
  customerId: CartModel._readCustomerId(json, 'customerId') as String,
  status: json['status'] as String? ?? 'active',
  items:
      (json['items'] as List<dynamic>?)
          ?.map((e) => CartItemModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  itemsCount: (json['itemsCount'] as num?)?.toInt() ?? 0,
  subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
  discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
  taxAmount: (json['taxAmount'] as num?)?.toDouble() ?? 0.0,
  shippingCost: (json['shippingCost'] as num?)?.toDouble() ?? 0.0,
  total: (json['total'] as num?)?.toDouble() ?? 0.0,
  couponId: json['couponId'] as String?,
  couponCode: json['couponCode'] as String?,
  couponDiscount: (json['couponDiscount'] as num?)?.toDouble() ?? 0.0,
  lastActivityAt: json['lastActivityAt'] == null
      ? null
      : DateTime.parse(json['lastActivityAt'] as String),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$CartModelToJson(CartModel instance) => <String, dynamic>{
  'id': instance.id,
  'customerId': instance.customerId,
  'status': instance.status,
  'items': instance.items,
  'itemsCount': instance.itemsCount,
  'subtotal': instance.subtotal,
  'discount': instance.discount,
  'taxAmount': instance.taxAmount,
  'shippingCost': instance.shippingCost,
  'total': instance.total,
  'couponId': instance.couponId,
  'couponCode': instance.couponCode,
  'couponDiscount': instance.couponDiscount,
  'lastActivityAt': instance.lastActivityAt?.toIso8601String(),
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};
