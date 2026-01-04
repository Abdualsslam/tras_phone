/// Cart Model - Data layer model with JSON serialization
library;

import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/cart_entity.dart';
import '../../domain/enums/cart_enums.dart';
import 'cart_item_model.dart';

part 'cart_model.g.dart';

@JsonSerializable()
class CartModel {
  @JsonKey(name: 'id', readValue: _readId)
  final String id;

  @JsonKey(name: 'customerId', readValue: _readCustomerId)
  final String customerId;

  @JsonKey(defaultValue: 'active')
  final String status;

  @JsonKey(defaultValue: [])
  final List<CartItemModel> items;

  @JsonKey(defaultValue: 0)
  final int itemsCount;

  @JsonKey(defaultValue: 0.0)
  final double subtotal;

  @JsonKey(defaultValue: 0.0)
  final double discount;

  @JsonKey(defaultValue: 0.0)
  final double taxAmount;

  @JsonKey(defaultValue: 0.0)
  final double shippingCost;

  @JsonKey(defaultValue: 0.0)
  final double total;

  final String? couponId;
  final String? couponCode;

  @JsonKey(defaultValue: 0.0)
  final double couponDiscount;

  final DateTime? lastActivityAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CartModel({
    required this.id,
    required this.customerId,
    this.status = 'active',
    this.items = const [],
    this.itemsCount = 0,
    this.subtotal = 0,
    this.discount = 0,
    this.taxAmount = 0,
    this.shippingCost = 0,
    this.total = 0,
    this.couponId,
    this.couponCode,
    this.couponDiscount = 0,
    this.lastActivityAt,
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

  factory CartModel.fromJson(Map<String, dynamic> json) =>
      _$CartModelFromJson(json);
  Map<String, dynamic> toJson() => _$CartModelToJson(this);

  CartEntity toEntity() {
    return CartEntity(
      id: id,
      customerId: customerId,
      status: CartStatus.fromString(status),
      items: items.map((i) => i.toEntity()).toList(),
      itemsCount: itemsCount,
      subtotal: subtotal,
      discount: discount,
      taxAmount: taxAmount,
      shippingCost: shippingCost,
      total: total,
      couponId: couponId,
      couponCode: couponCode,
      couponDiscount: couponDiscount,
      lastActivityAt: lastActivityAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

/// Request model for adding item to cart
class AddToCartRequest {
  final String productId;
  final int quantity;
  final double unitPrice;

  const AddToCartRequest({
    required this.productId,
    required this.quantity,
    required this.unitPrice,
  });

  Map<String, dynamic> toJson() => {
    'productId': productId,
    'quantity': quantity,
    'unitPrice': unitPrice,
  };
}

/// Request model for updating cart item
class UpdateCartItemRequest {
  final int quantity;

  const UpdateCartItemRequest({required this.quantity});

  Map<String, dynamic> toJson() => {'quantity': quantity};
}

/// Request model for applying coupon
class ApplyCouponRequest {
  final String? couponId;
  final String? couponCode;
  final double discountAmount;

  const ApplyCouponRequest({
    this.couponId,
    this.couponCode,
    required this.discountAmount,
  });

  Map<String, dynamic> toJson() => {
    if (couponId != null) 'couponId': couponId,
    if (couponCode != null) 'couponCode': couponCode,
    'discountAmount': discountAmount,
  };
}
