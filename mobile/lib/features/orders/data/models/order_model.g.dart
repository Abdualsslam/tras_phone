// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderItemModel _$OrderItemModelFromJson(Map<String, dynamic> json) =>
    OrderItemModel(
      id: (json['id'] as num).toInt(),
      productId: (json['product_id'] as num).toInt(),
      productName: json['product_name'] as String,
      productNameAr: json['product_name_ar'] as String?,
      productImage: json['product_image'] as String?,
      quantity: (json['quantity'] as num).toInt(),
      unitPrice: (json['unit_price'] as num).toDouble(),
      totalPrice: (json['total_price'] as num).toDouble(),
    );

Map<String, dynamic> _$OrderItemModelToJson(OrderItemModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'product_id': instance.productId,
      'product_name': instance.productName,
      'product_name_ar': instance.productNameAr,
      'product_image': instance.productImage,
      'quantity': instance.quantity,
      'unit_price': instance.unitPrice,
      'total_price': instance.totalPrice,
    };

OrderModel _$OrderModelFromJson(Map<String, dynamic> json) => OrderModel(
  id: (json['id'] as num).toInt(),
  orderNumber: json['order_number'] as String,
  status: json['status'] as String,
  items:
      (json['items'] as List<dynamic>?)
          ?.map((e) => OrderItemModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  subtotal: (json['subtotal'] as num).toDouble(),
  shippingCost: (json['shipping_cost'] as num?)?.toDouble() ?? 0,
  discount: (json['discount'] as num?)?.toDouble() ?? 0,
  total: (json['total'] as num).toDouble(),
  couponCode: json['coupon_code'] as String?,
  shippingAddress: json['shipping_address'] as String?,
  paymentMethod: json['payment_method'] as String?,
  notes: json['notes'] as String?,
  createdAt: json['created_at'] as String,
  deliveredAt: json['delivered_at'] as String?,
);

Map<String, dynamic> _$OrderModelToJson(OrderModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'order_number': instance.orderNumber,
      'status': instance.status,
      'items': instance.items,
      'subtotal': instance.subtotal,
      'shipping_cost': instance.shippingCost,
      'discount': instance.discount,
      'total': instance.total,
      'coupon_code': instance.couponCode,
      'shipping_address': instance.shippingAddress,
      'payment_method': instance.paymentMethod,
      'notes': instance.notes,
      'created_at': instance.createdAt,
      'delivered_at': instance.deliveredAt,
    };

CreateOrderRequest _$CreateOrderRequestFromJson(Map<String, dynamic> json) =>
    CreateOrderRequest(
      shippingAddressId: (json['shipping_address_id'] as num?)?.toInt(),
      shippingAddress: json['shipping_address'] as String?,
      paymentMethod: json['payment_method'] as String,
      notes: json['notes'] as String?,
      couponCode: json['coupon_code'] as String?,
    );

Map<String, dynamic> _$CreateOrderRequestToJson(CreateOrderRequest instance) =>
    <String, dynamic>{
      'shipping_address_id': instance.shippingAddressId,
      'shipping_address': instance.shippingAddress,
      'payment_method': instance.paymentMethod,
      'notes': instance.notes,
      'coupon_code': instance.couponCode,
    };

PaginatedOrdersResponse _$PaginatedOrdersResponseFromJson(
  Map<String, dynamic> json,
) => PaginatedOrdersResponse(
  data: (json['data'] as List<dynamic>)
      .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  meta: OrdersPaginationMeta.fromJson(json['meta'] as Map<String, dynamic>),
);

Map<String, dynamic> _$PaginatedOrdersResponseToJson(
  PaginatedOrdersResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};

OrdersPaginationMeta _$OrdersPaginationMetaFromJson(
  Map<String, dynamic> json,
) => OrdersPaginationMeta(
  currentPage: (json['current_page'] as num).toInt(),
  lastPage: (json['last_page'] as num).toInt(),
  perPage: (json['per_page'] as num).toInt(),
  total: (json['total'] as num).toInt(),
);

Map<String, dynamic> _$OrdersPaginationMetaToJson(
  OrdersPaginationMeta instance,
) => <String, dynamic>{
  'current_page': instance.currentPage,
  'last_page': instance.lastPage,
  'per_page': instance.perPage,
  'total': instance.total,
};
