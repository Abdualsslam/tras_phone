// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderItemModel _$OrderItemModelFromJson(Map<String, dynamic> json) =>
    OrderItemModel(
      id: OrderItemModel._readOrderItemId(json, '_id') as String?,
      productId: OrderItemModel._readProductId(json, 'productId') as String,
      variantId: json['variantId'] as String?,
      sku: json['sku'] as String?,
      name: json['name'] as String,
      nameAr: json['nameAr'] as String?,
      image: json['image'] as String?,
      quantity: (json['quantity'] as num).toInt(),
      returnedQuantity: (json['returnedQuantity'] as num?)?.toInt() ?? 0,
      returnableQuantity: (json['returnableQuantity'] as num?)?.toInt() ?? 0,
      reservedQuantity: (json['reservedQuantity'] as num?)?.toInt() ?? 0,
      isEffectivelyFullyReturned:
          json['isEffectivelyFullyReturned'] as bool? ?? false,
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0.0,
      discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      attributes: json['attributes'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$OrderItemModelToJson(OrderItemModel instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'productId': instance.productId,
      'variantId': instance.variantId,
      'sku': instance.sku,
      'name': instance.name,
      'nameAr': instance.nameAr,
      'image': instance.image,
      'quantity': instance.quantity,
      'returnedQuantity': instance.returnedQuantity,
      'returnableQuantity': instance.returnableQuantity,
      'reservedQuantity': instance.reservedQuantity,
      'isEffectivelyFullyReturned': instance.isEffectivelyFullyReturned,
      'unitPrice': instance.unitPrice,
      'discount': instance.discount,
      'total': instance.total,
      'attributes': instance.attributes,
    };

OrderModel _$OrderModelFromJson(Map<String, dynamic> json) => OrderModel(
  id: OrderModel._readId(json, 'id') as String,
  orderNumber: json['orderNumber'] as String,
  customerId: OrderModel._readCustomerId(json, 'customerId') as String,
  priceLevelId: OrderModel._readPriceLevelId(json, 'priceLevelId') as String?,
  status: json['status'] as String? ?? 'pending',
  subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
  taxAmount: (json['taxAmount'] as num?)?.toDouble() ?? 0.0,
  shippingCost: (json['shippingCost'] as num?)?.toDouble() ?? 0.0,
  discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
  couponDiscount: (json['couponDiscount'] as num?)?.toDouble() ?? 0.0,
  walletAmountUsed: (json['walletAmountUsed'] as num?)?.toDouble() ?? 0.0,
  loyaltyPointsUsed: (json['loyaltyPointsUsed'] as num?)?.toInt() ?? 0,
  loyaltyPointsValue: (json['loyaltyPointsValue'] as num?)?.toDouble() ?? 0.0,
  total: (json['total'] as num?)?.toDouble() ?? 0.0,
  paidAmount: (json['paidAmount'] as num?)?.toDouble() ?? 0.0,
  paymentStatus: json['paymentStatus'] as String? ?? 'unpaid',
  paymentMethod: json['paymentMethod'] as String?,
  shippingAddressId:
      OrderModel._readShippingAddressId(json, 'shippingAddressId') as String?,
  shippingAddress: json['shippingAddress'] == null
      ? null
      : ShippingAddressModel.fromJson(
          json['shippingAddress'] as Map<String, dynamic>,
        ),
  estimatedDeliveryDate: json['estimatedDeliveryDate'] == null
      ? null
      : DateTime.parse(json['estimatedDeliveryDate'] as String),
  couponId: json['couponId'] as String?,
  couponCode: json['couponCode'] as String?,
  source: json['source'] as String? ?? 'mobile',
  customerNotes: json['customerNotes'] as String?,
  confirmedAt: json['confirmedAt'] == null
      ? null
      : DateTime.parse(json['confirmedAt'] as String),
  shippedAt: json['shippedAt'] == null
      ? null
      : DateTime.parse(json['shippedAt'] as String),
  deliveredAt: json['deliveredAt'] == null
      ? null
      : DateTime.parse(json['deliveredAt'] as String),
  completedAt: json['completedAt'] == null
      ? null
      : DateTime.parse(json['completedAt'] as String),
  cancelledAt: json['cancelledAt'] == null
      ? null
      : DateTime.parse(json['cancelledAt'] as String),
  cancellationReason: json['cancellationReason'] as String?,
  customerRating: (json['customerRating'] as num?)?.toInt(),
  customerRatingComment: json['customerRatingComment'] as String?,
  ratedAt: json['ratedAt'] == null
      ? null
      : DateTime.parse(json['ratedAt'] as String),
  items:
      (json['items'] as List<dynamic>?)
          ?.map((e) => OrderItemModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  cancellable: json['cancellable'] as bool? ?? false,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$OrderModelToJson(
  OrderModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'orderNumber': instance.orderNumber,
  'customerId': instance.customerId,
  'priceLevelId': instance.priceLevelId,
  'status': instance.status,
  'subtotal': instance.subtotal,
  'taxAmount': instance.taxAmount,
  'shippingCost': instance.shippingCost,
  'discount': instance.discount,
  'couponDiscount': instance.couponDiscount,
  'walletAmountUsed': instance.walletAmountUsed,
  'loyaltyPointsUsed': instance.loyaltyPointsUsed,
  'loyaltyPointsValue': instance.loyaltyPointsValue,
  'total': instance.total,
  'paidAmount': instance.paidAmount,
  'paymentStatus': instance.paymentStatus,
  'paymentMethod': instance.paymentMethod,
  'shippingAddressId': instance.shippingAddressId,
  'shippingAddress': instance.shippingAddress,
  'estimatedDeliveryDate': instance.estimatedDeliveryDate?.toIso8601String(),
  'couponId': instance.couponId,
  'couponCode': instance.couponCode,
  'source': instance.source,
  'customerNotes': instance.customerNotes,
  'confirmedAt': instance.confirmedAt?.toIso8601String(),
  'shippedAt': instance.shippedAt?.toIso8601String(),
  'deliveredAt': instance.deliveredAt?.toIso8601String(),
  'completedAt': instance.completedAt?.toIso8601String(),
  'cancelledAt': instance.cancelledAt?.toIso8601String(),
  'cancellationReason': instance.cancellationReason,
  'customerRating': instance.customerRating,
  'customerRatingComment': instance.customerRatingComment,
  'ratedAt': instance.ratedAt?.toIso8601String(),
  'items': instance.items,
  'cancellable': instance.cancellable,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};
