/// Order Model - Data layer model with JSON serialization
library;

import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/order_entity.dart';

part 'order_model.g.dart';

/// Order Item Model
@JsonSerializable()
class OrderItemModel {
  final int id;
  @JsonKey(name: 'product_id')
  final int productId;
  @JsonKey(name: 'product_name')
  final String productName;
  @JsonKey(name: 'product_name_ar')
  final String? productNameAr;
  @JsonKey(name: 'product_image')
  final String? productImage;
  final int quantity;
  @JsonKey(name: 'unit_price')
  final double unitPrice;
  @JsonKey(name: 'total_price')
  final double totalPrice;

  const OrderItemModel({
    required this.id,
    required this.productId,
    required this.productName,
    this.productNameAr,
    this.productImage,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) =>
      _$OrderItemModelFromJson(json);
  Map<String, dynamic> toJson() => _$OrderItemModelToJson(this);

  OrderItemEntity toEntity() {
    return OrderItemEntity(
      id: id,
      productId: productId,
      productName: productNameAr ?? productName,
      productImage: productImage,
      quantity: quantity,
      unitPrice: unitPrice,
      totalPrice: totalPrice,
    );
  }
}

/// Order Model
@JsonSerializable()
class OrderModel {
  final int id;
  @JsonKey(name: 'order_number')
  final String orderNumber;
  final String status;
  final List<OrderItemModel> items;
  final double subtotal;
  @JsonKey(name: 'shipping_cost')
  final double shippingCost;
  final double discount;
  final double total;
  @JsonKey(name: 'coupon_code')
  final String? couponCode;
  @JsonKey(name: 'shipping_address')
  final String? shippingAddress;
  @JsonKey(name: 'payment_method')
  final String? paymentMethod;
  final String? notes;
  @JsonKey(name: 'created_at')
  final String createdAt;
  @JsonKey(name: 'delivered_at')
  final String? deliveredAt;

  const OrderModel({
    required this.id,
    required this.orderNumber,
    required this.status,
    this.items = const [],
    required this.subtotal,
    this.shippingCost = 0,
    this.discount = 0,
    required this.total,
    this.couponCode,
    this.shippingAddress,
    this.paymentMethod,
    this.notes,
    required this.createdAt,
    this.deliveredAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) =>
      _$OrderModelFromJson(json);
  Map<String, dynamic> toJson() => _$OrderModelToJson(this);

  OrderEntity toEntity() {
    return OrderEntity(
      id: id,
      orderNumber: orderNumber,
      status: _parseStatus(status),
      items: items.map((i) => i.toEntity()).toList(),
      subtotal: subtotal,
      shippingCost: shippingCost,
      discount: discount,
      total: total,
      couponCode: couponCode,
      shippingAddress: shippingAddress,
      paymentMethod: paymentMethod,
      notes: notes,
      createdAt: DateTime.tryParse(createdAt) ?? DateTime.now(),
      deliveredAt: deliveredAt != null ? DateTime.tryParse(deliveredAt!) : null,
    );
  }

  OrderStatus _parseStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return OrderStatus.pending;
      case 'confirmed':
        return OrderStatus.confirmed;
      case 'processing':
        return OrderStatus.processing;
      case 'shipped':
        return OrderStatus.shipped;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
        return OrderStatus.cancelled;
      case 'returned':
        return OrderStatus.returned;
      default:
        return OrderStatus.pending;
    }
  }
}

/// Request model for creating an order (checkout)
@JsonSerializable()
class CreateOrderRequest {
  @JsonKey(name: 'shipping_address_id')
  final int? shippingAddressId;
  @JsonKey(name: 'shipping_address')
  final String? shippingAddress;
  @JsonKey(name: 'payment_method')
  final String paymentMethod;
  final String? notes;
  @JsonKey(name: 'coupon_code')
  final String? couponCode;

  const CreateOrderRequest({
    this.shippingAddressId,
    this.shippingAddress,
    required this.paymentMethod,
    this.notes,
    this.couponCode,
  });

  factory CreateOrderRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateOrderRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateOrderRequestToJson(this);
}

/// Response for paginated orders
@JsonSerializable()
class PaginatedOrdersResponse {
  final List<OrderModel> data;
  final OrdersPaginationMeta meta;

  const PaginatedOrdersResponse({required this.data, required this.meta});

  factory PaginatedOrdersResponse.fromJson(Map<String, dynamic> json) =>
      _$PaginatedOrdersResponseFromJson(json);
  Map<String, dynamic> toJson() => _$PaginatedOrdersResponseToJson(this);

  List<OrderEntity> toEntities() => data.map((o) => o.toEntity()).toList();
}

@JsonSerializable()
class OrdersPaginationMeta {
  @JsonKey(name: 'current_page')
  final int currentPage;
  @JsonKey(name: 'last_page')
  final int lastPage;
  @JsonKey(name: 'per_page')
  final int perPage;
  final int total;

  const OrdersPaginationMeta({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  factory OrdersPaginationMeta.fromJson(Map<String, dynamic> json) =>
      _$OrdersPaginationMetaFromJson(json);
  Map<String, dynamic> toJson() => _$OrdersPaginationMetaToJson(this);

  bool get hasNextPage => currentPage < lastPage;
}
