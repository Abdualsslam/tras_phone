/// Order Model - Data layer model with JSON serialization
library;

import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/order_entity.dart';
import 'shipping_address_model.dart';

part 'order_model.g.dart';

/// Order Item Model
@JsonSerializable()
class OrderItemModel {
  /// MongoDB ObjectId for order item - used for returns API (orderItemId)
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
    this.unitPrice = 0,
    this.discount = 0,
    this.total = 0,
    this.attributes,
  });

  /// Handle _id for order item (MongoDB ObjectId)
  static Object? _readOrderItemId(Map<dynamic, dynamic> json, String key) {
    final value = json['_id'] ?? json['id'];
    if (value == null) return null;
    if (value is String) return value;
    if (value is Map) {
      return value['\$oid']?.toString() ?? value.toString();
    }
    return value.toString();
  }

  /// Handle productId which can be String or populated object
  static Object? _readProductId(Map<dynamic, dynamic> json, String key) {
    final value = json['productId'];
    if (value is String) return value;
    if (value is Map) {
      return value['_id']?.toString() ?? value['\$oid']?.toString();
    }
    return value?.toString();
  }

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
      unitPrice: unitPrice,
      discount: discount,
      total: total,
      attributes: attributes,
    );
  }
}

/// Order Model
@JsonSerializable()
class OrderModel {
  @JsonKey(name: 'id', readValue: _readId)
  final String id;

  final String orderNumber;

  @JsonKey(name: 'customerId', readValue: _readCustomerId)
  final String customerId;

  /// Price level ID used when order was created (from pricing rules)
  @JsonKey(name: 'priceLevelId', readValue: _readPriceLevelId)
  final String? priceLevelId;

  @JsonKey(defaultValue: 'pending')
  final String status;

  // Amounts
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
  final double walletAmountUsed;
  @JsonKey(defaultValue: 0)
  final int loyaltyPointsUsed;
  @JsonKey(defaultValue: 0.0)
  final double loyaltyPointsValue;
  @JsonKey(defaultValue: 0.0)
  final double total;
  @JsonKey(defaultValue: 0.0)
  final double paidAmount;

  // Payment
  @JsonKey(defaultValue: 'unpaid')
  final String paymentStatus;
  final String? paymentMethod;

  // Shipping
  @JsonKey(name: 'shippingAddressId', readValue: _readShippingAddressId)
  final String? shippingAddressId;
  final ShippingAddressModel? shippingAddress;
  final DateTime? estimatedDeliveryDate;

  // Coupon
  final String? couponId;
  final String? couponCode;

  // Source
  @JsonKey(defaultValue: 'mobile')
  final String source;

  // Notes
  final String? customerNotes;

  // Timestamps
  final DateTime? confirmedAt;
  final DateTime? shippedAt;
  final DateTime? deliveredAt;
  final DateTime? completedAt;
  final DateTime? cancelledAt;
  final String? cancellationReason;

  // Rating
  final int? customerRating; // 1-5
  final String? customerRatingComment;
  final DateTime? ratedAt;

  // Items
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
    this.walletAmountUsed = 0,
    this.loyaltyPointsUsed = 0,
    this.loyaltyPointsValue = 0,
    this.total = 0,
    this.paidAmount = 0,
    this.paymentStatus = 'unpaid',
    this.paymentMethod,
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
    this.customerRating,
    this.customerRatingComment,
    this.ratedAt,
    this.items = const [],
    this.cancellable = false,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Handle MongoDB _id or id field
  static Object? _readId(Map<dynamic, dynamic> json, String key) {
    final value = json['_id'] ?? json['id'];
    if (value is Map) {
      return value['\$oid'] ?? value.toString();
    }
    return value?.toString();
  }

  /// Handle customerId which can be String or populated object
  static Object? _readCustomerId(Map<dynamic, dynamic> json, String key) {
    final value = json['customerId'];
    if (value is String) return value;
    if (value is Map) {
      return value['_id']?.toString() ?? value['\$oid']?.toString();
    }
    return value?.toString();
  }

  /// Handle shippingAddressId which can be String or populated object
  static Object? _readShippingAddressId(
    Map<dynamic, dynamic> json,
    String key,
  ) {
    final value = json['shippingAddressId'];
    if (value == null) return null;
    if (value is String) return value;
    if (value is Map) {
      return value['_id']?.toString() ?? value['\$oid']?.toString();
    }
    return value.toString();
  }

  /// Handle priceLevelId which can be String or populated object
  static Object? _readPriceLevelId(
    Map<dynamic, dynamic> json,
    String key,
  ) {
    final value = json['priceLevelId'];
    if (value == null) return null;
    if (value is String) return value;
    if (value is Map) {
      return value['_id']?.toString() ?? value['\$oid']?.toString();
    }
    return value.toString();
  }

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
      walletAmountUsed: walletAmountUsed,
      loyaltyPointsUsed: loyaltyPointsUsed,
      loyaltyPointsValue: loyaltyPointsValue,
      total: total,
      paidAmount: paidAmount,
      paymentStatus: PaymentStatus.fromString(paymentStatus),
      paymentMethod: paymentMethod != null
          ? OrderPaymentMethod.fromString(paymentMethod!)
          : null,
      shippingAddressId: shippingAddressId,
      shippingAddress: shippingAddress != null
          ? ShippingAddressEntity(
              fullName: shippingAddress!.fullName,
              phone: shippingAddress!.phone,
              address: shippingAddress!.address,
              city: shippingAddress!.city,
              district: shippingAddress!.district,
              postalCode: shippingAddress!.postalCode,
              notes: shippingAddress!.notes,
            )
          : null,
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
      customerRating: customerRating,
      customerRatingComment: customerRatingComment,
      ratedAt: ratedAt,
      items: items.map((i) => i.toEntity()).toList(),
      cancellable: cancellable,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

/// Request model for creating an order
class CreateOrderRequest {
  final String? shippingAddressId;
  final ShippingAddressModel? shippingAddress;
  final String? paymentMethod;
  final String? customerNotes;
  final String? couponCode;

  const CreateOrderRequest({
    this.shippingAddressId,
    this.shippingAddress,
    this.paymentMethod,
    this.customerNotes,
    this.couponCode,
  });

  Map<String, dynamic> toJson() => {
    if (shippingAddressId != null) 'shippingAddressId': shippingAddressId,
    if (shippingAddress != null) 'shippingAddress': shippingAddress!.toJson(),
    if (paymentMethod != null) 'paymentMethod': paymentMethod,
    if (customerNotes != null) 'customerNotes': customerNotes,
    if (couponCode != null) 'couponCode': couponCode,
  };
}

/// Response for paginated orders
class OrdersResponse {
  final List<OrderModel> orders;
  final int total;

  OrdersResponse({required this.orders, required this.total});

  factory OrdersResponse.fromJson(Map<String, dynamic> json) {
    return OrdersResponse(
      orders: (json['data'] as List? ?? [])
          .map((o) => OrderModel.fromJson(o))
          .toList(),
      total: json['meta']?['total'] ?? 0,
    );
  }

  List<OrderEntity> toEntities() => orders.map((o) => o.toEntity()).toList();
}
