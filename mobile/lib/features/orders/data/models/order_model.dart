/// Order Model - Data layer model with JSON serialization
library;

import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/order_entity.dart';
import 'shipping_address_model.dart';

part 'order_model.g.dart';
part 'order_model_parsing.dart';
part 'orders_response.dart';

@JsonSerializable()
class OrderItemModel {
  @JsonKey(name: '_id', readValue: _readOrderItemId)
  final String? id;
  @JsonKey(name: 'productId', readValue: _readProductId)
  final String productId;
  final String? variantId;
  final String? sku;
  final String name;
  final String? nameAr;
  final String? image;
  final int quantity;
  @JsonKey(defaultValue: 0)
  final int returnedQuantity;
  @JsonKey(defaultValue: 0)
  final int returnableQuantity;
  @JsonKey(defaultValue: 0)
  final int reservedQuantity;
  @JsonKey(defaultValue: false)
  final bool isEffectivelyFullyReturned;
  @JsonKey(defaultValue: 0.0)
  final double unitPrice;
  @JsonKey(defaultValue: 0.0)
  final double discount;
  @JsonKey(defaultValue: 0.0)
  final double total;
  final Map<String, dynamic>? attributes;

  const OrderItemModel({
    this.id,
    required this.productId,
    this.variantId,
    this.sku,
    required this.name,
    this.nameAr,
    this.image,
    required this.quantity,
    this.returnedQuantity = 0,
    this.returnableQuantity = 0,
    this.reservedQuantity = 0,
    this.isEffectivelyFullyReturned = false,
    this.unitPrice = 0,
    this.discount = 0,
    this.total = 0,
    this.attributes,
  });

  static Object? _readOrderItemId(Map<dynamic, dynamic> json, String key) =>
      _orderItemReadId(json, key);

  static Object? _readProductId(Map<dynamic, dynamic> json, String key) =>
      _orderItemReadProductId(json, key);

  factory OrderItemModel.fromJson(Map<String, dynamic> json) =>
      _$OrderItemModelFromJson(json);

  Map<String, dynamic> toJson() => _$OrderItemModelToJson(this);

  OrderItemEntity toEntity() {
    return OrderItemEntity(
      id: id,
      productId: productId,
      variantId: variantId,
      sku: sku,
      name: name,
      nameAr: nameAr,
      image: image,
      quantity: quantity,
      returnedQuantity: returnedQuantity,
      returnableQuantity: returnableQuantity > 0
          ? returnableQuantity
          : (quantity - returnedQuantity - reservedQuantity).clamp(0, quantity),
      reservedQuantity: reservedQuantity,
      isEffectivelyFullyReturned:
          isEffectivelyFullyReturned || (returnedQuantity >= quantity),
      unitPrice: unitPrice,
      discount: discount,
      total: total,
      attributes: attributes,
    );
  }
}

@JsonSerializable()
class OrderModel {
  @JsonKey(name: 'id', readValue: _readId)
  final String id;
  final String orderNumber;
  @JsonKey(name: 'customerId', readValue: _readCustomerId)
  final String customerId;
  @JsonKey(name: 'priceLevelId', readValue: _readPriceLevelId)
  final String? priceLevelId;
  @JsonKey(defaultValue: 'pending')
  final String status;
  @JsonKey(defaultValue: 0.0)
  final double subtotal;
  @JsonKey(defaultValue: 0.0)
  final double taxAmount;
  @JsonKey(defaultValue: 0.0)
  final double shippingCost;
  @JsonKey(defaultValue: 0.0)
  final double discount;
  @JsonKey(defaultValue: 0.0)
  final double couponDiscount;
  @JsonKey(defaultValue: 0.0)
  final double walletBalanceBefore;
  @JsonKey(defaultValue: 0.0)
  final double walletAmountUsed;
  @JsonKey(defaultValue: 0.0)
  final double walletBalanceAfter;
  @JsonKey(defaultValue: 0.0)
  final double remainingAfterWallet;
  @JsonKey(defaultValue: 0)
  final int loyaltyPointsUsed;
  @JsonKey(defaultValue: 0.0)
  final double loyaltyPointsValue;
  @JsonKey(defaultValue: 0.0)
  final double total;
  @JsonKey(defaultValue: 0.0)
  final double paidAmount;
  @JsonKey(defaultValue: 'unpaid')
  final String paymentStatus;
  final String? paymentMethod;
  @JsonKey(defaultValue: 'not_required')
  final String transferStatus;
  final String? transferReceiptImage;
  final String? transferReference;
  final DateTime? transferDate;
  final DateTime? transferVerifiedAt;
  final String? rejectionReason;
  @JsonKey(name: 'shippingAddressId', readValue: _readShippingAddressId)
  final String? shippingAddressId;
  final ShippingAddressModel? shippingAddress;
  final DateTime? estimatedDeliveryDate;
  final String? couponId;
  final String? couponCode;
  @JsonKey(defaultValue: 'mobile')
  final String source;
  final String? customerNotes;
  final DateTime? confirmedAt;
  final DateTime? shippedAt;
  final DateTime? deliveredAt;
  final DateTime? completedAt;
  final DateTime? cancelledAt;
  final String? cancellationReason;
  final String? shippingLabelUrl;
  final int? customerRating;
  final String? customerRatingComment;
  final DateTime? ratedAt;
  @JsonKey(defaultValue: [])
  final List<OrderItemModel> items;
  @JsonKey(defaultValue: false)
  final bool cancellable;
  final DateTime createdAt;
  final DateTime updatedAt;

  const OrderModel({
    required this.id,
    required this.orderNumber,
    required this.customerId,
    this.priceLevelId,
    this.status = 'pending',
    this.subtotal = 0,
    this.taxAmount = 0,
    this.shippingCost = 0,
    this.discount = 0,
    this.couponDiscount = 0,
    this.walletBalanceBefore = 0,
    this.walletAmountUsed = 0,
    this.walletBalanceAfter = 0,
    this.remainingAfterWallet = 0,
    this.loyaltyPointsUsed = 0,
    this.loyaltyPointsValue = 0,
    this.total = 0,
    this.paidAmount = 0,
    this.paymentStatus = 'unpaid',
    this.paymentMethod,
    this.transferStatus = 'not_required',
    this.transferReceiptImage,
    this.transferReference,
    this.transferDate,
    this.transferVerifiedAt,
    this.rejectionReason,
    this.shippingAddressId,
    this.shippingAddress,
    this.estimatedDeliveryDate,
    this.couponId,
    this.couponCode,
    this.source = 'mobile',
    this.customerNotes,
    this.confirmedAt,
    this.shippedAt,
    this.deliveredAt,
    this.completedAt,
    this.cancelledAt,
    this.cancellationReason,
    this.shippingLabelUrl,
    this.customerRating,
    this.customerRatingComment,
    this.ratedAt,
    this.items = const [],
    this.cancellable = false,
    required this.createdAt,
    required this.updatedAt,
  });

  static Object? _readId(Map<dynamic, dynamic> json, String key) =>
      _orderReadId(json, key);

  static Object? _readCustomerId(Map<dynamic, dynamic> json, String key) =>
      _orderReadCustomerId(json, key);

  static Object? _readShippingAddressId(
    Map<dynamic, dynamic> json,
    String key,
  ) => _orderReadShippingAddressId(json, key);

  static Object? _readPriceLevelId(Map<dynamic, dynamic> json, String key) =>
      _orderReadPriceLevelId(json, key);

  factory OrderModel.fromJson(Map<String, dynamic> json) =>
      _$OrderModelFromJson(json);

  Map<String, dynamic> toJson() => _$OrderModelToJson(this);

  OrderEntity toEntity() {
    return OrderEntity(
      id: id,
      orderNumber: orderNumber,
      customerId: customerId,
      priceLevelId: priceLevelId,
      status: OrderStatus.fromString(status),
      subtotal: subtotal,
      taxAmount: taxAmount,
      shippingCost: shippingCost,
      discount: discount,
      couponDiscount: couponDiscount,
      walletBalanceBefore: walletBalanceBefore,
      walletAmountUsed: walletAmountUsed,
      walletBalanceAfter: walletBalanceAfter,
      remainingAfterWallet: remainingAfterWallet > 0
          ? remainingAfterWallet
          : (total - walletAmountUsed).clamp(0, total).toDouble(),
      loyaltyPointsUsed: loyaltyPointsUsed,
      loyaltyPointsValue: loyaltyPointsValue,
      total: total,
      paidAmount: paidAmount,
      paymentStatus: PaymentStatus.fromString(paymentStatus),
      paymentMethod: paymentMethod != null
          ? OrderPaymentMethod.fromString(paymentMethod!)
          : null,
      transferStatus: transferStatus,
      transferReceiptImage: transferReceiptImage,
      transferReference: transferReference,
      transferDate: transferDate,
      transferVerifiedAt: transferVerifiedAt,
      paymentRejectionReason: rejectionReason,
      shippingAddressId: shippingAddressId,
      shippingAddress: _mapShippingAddressEntity(shippingAddress),
      estimatedDeliveryDate: estimatedDeliveryDate,
      couponId: couponId,
      couponCode: couponCode,
      source: OrderSource.fromString(source),
      customerNotes: customerNotes,
      confirmedAt: confirmedAt,
      shippedAt: shippedAt,
      deliveredAt: deliveredAt,
      completedAt: completedAt,
      cancelledAt: cancelledAt,
      cancellationReason: cancellationReason,
      shippingLabelUrl: shippingLabelUrl,
      customerRating: customerRating,
      customerRatingComment: customerRatingComment,
      ratedAt: ratedAt,
      items: items.map((item) => item.toEntity()).toList(),
      cancellable: cancellable,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

ShippingAddressEntity? _mapShippingAddressEntity(
  ShippingAddressModel? shippingAddress,
) {
  if (shippingAddress == null) return null;
  return ShippingAddressEntity(
    fullName: shippingAddress.fullName,
    phone: shippingAddress.phone,
    address: shippingAddress.address,
    city: shippingAddress.city,
    district: shippingAddress.district,
    postalCode: shippingAddress.postalCode,
    notes: shippingAddress.notes,
  );
}
