/// Checkout Session Model - Data layer model for checkout session
library;

import '../../../profile/data/models/address_model.dart';
import '../../../orders/data/models/payment_method_model.dart';
import '../../../promotions/data/models/coupon_validation_model.dart';
import '../../domain/entities/checkout_session_entity.dart';

/// Product details in cart item
class CartItemProductModel {
  final String name;
  final String nameAr;
  final String? image;
  final String sku;
  final bool isActive;
  final int stockQuantity;

  const CartItemProductModel({
    required this.name,
    required this.nameAr,
    this.image,
    required this.sku,
    required this.isActive,
    required this.stockQuantity,
  });

  factory CartItemProductModel.fromJson(Map<String, dynamic> json) {
    return CartItemProductModel(
      name: json['name'] ?? '',
      nameAr: json['nameAr'] ?? '',
      image: json['image'],
      sku: json['sku'] ?? '',
      isActive: json['isActive'] ?? true,
      stockQuantity: (json['stockQuantity'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'nameAr': nameAr,
    'image': image,
    'sku': sku,
    'isActive': isActive,
    'stockQuantity': stockQuantity,
  };

  CartItemProductEntity toEntity() {
    return CartItemProductEntity(
      name: name,
      nameAr: nameAr,
      image: image,
      sku: sku,
      isActive: isActive,
      stockQuantity: stockQuantity,
    );
  }
}

/// Cart item with product details
class CheckoutCartItemModel {
  final String productId;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final DateTime addedAt;
  final CartItemProductModel product;

  const CheckoutCartItemModel({
    required this.productId,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    required this.addedAt,
    required this.product,
  });

  factory CheckoutCartItemModel.fromJson(Map<String, dynamic> json) {
    return CheckoutCartItemModel(
      productId: json['productId']?.toString() ?? '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0.0,
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0.0,
      addedAt: json['addedAt'] != null
          ? DateTime.parse(json['addedAt'])
          : DateTime.now(),
      product: CartItemProductModel.fromJson(
        json['product'] ?? <String, dynamic>{},
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'productId': productId,
    'quantity': quantity,
    'unitPrice': unitPrice,
    'totalPrice': totalPrice,
    'addedAt': addedAt.toIso8601String(),
    'product': product.toJson(),
  };

  CheckoutCartItemEntity toEntity() {
    return CheckoutCartItemEntity(
      productId: productId,
      quantity: quantity,
      unitPrice: unitPrice,
      totalPrice: totalPrice,
      addedAt: addedAt,
      product: product.toEntity(),
    );
  }
}

/// Cart with populated product details
class CheckoutCartModel {
  final String id;
  final String customerId;
  final String status;
  final List<CheckoutCartItemModel> items;
  final int itemsCount;
  final double subtotal;
  final double discount;
  final double taxAmount;
  final double shippingCost;
  final double total;
  final String? couponCode;
  final double couponDiscount;

  const CheckoutCartModel({
    required this.id,
    required this.customerId,
    required this.status,
    required this.items,
    required this.itemsCount,
    required this.subtotal,
    required this.discount,
    required this.taxAmount,
    required this.shippingCost,
    required this.total,
    this.couponCode,
    required this.couponDiscount,
  });

  factory CheckoutCartModel.fromJson(Map<String, dynamic> json) {
    // Handle MongoDB _id or id field
    String? extractId(dynamic value) {
      if (value is String) return value;
      if (value is Map) {
        return value['_id']?.toString() ?? value['\$oid']?.toString();
      }
      return value?.toString();
    }

    return CheckoutCartModel(
      id: extractId(json['_id'] ?? json['id']) ?? '',
      customerId: extractId(json['customerId']) ?? '',
      status: json['status'] ?? 'active',
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => CheckoutCartItemModel.fromJson(e))
              .toList() ??
          [],
      itemsCount: (json['itemsCount'] as num?)?.toInt() ?? 0,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
      taxAmount: (json['taxAmount'] as num?)?.toDouble() ?? 0.0,
      shippingCost: (json['shippingCost'] as num?)?.toDouble() ?? 0.0,
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      couponCode: json['couponCode'],
      couponDiscount: (json['couponDiscount'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'customerId': customerId,
    'status': status,
    'items': items.map((e) => e.toJson()).toList(),
    'itemsCount': itemsCount,
    'subtotal': subtotal,
    'discount': discount,
    'taxAmount': taxAmount,
    'shippingCost': shippingCost,
    'total': total,
    'couponCode': couponCode,
    'couponDiscount': couponDiscount,
  };

  CheckoutCartEntity toEntity() {
    return CheckoutCartEntity(
      id: id,
      customerId: customerId,
      status: status,
      items: items.map((e) => e.toEntity()).toList(),
      itemsCount: itemsCount,
      subtotal: subtotal,
      discount: discount,
      taxAmount: taxAmount,
      shippingCost: shippingCost,
      total: total,
      couponCode: couponCode,
      couponDiscount: couponDiscount,
    );
  }
}

/// Customer basic info for checkout
class CheckoutCustomerModel {
  final String id;
  final String? name;
  final String? phone;
  final String? priceLevelId;

  const CheckoutCustomerModel({
    required this.id,
    this.name,
    this.phone,
    this.priceLevelId,
  });

  factory CheckoutCustomerModel.fromJson(Map<String, dynamic> json) {
    return CheckoutCustomerModel(
      id: json['id']?.toString() ?? '',
      name: json['name'],
      phone: json['phone'],
      priceLevelId: json['priceLevelId'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'phone': phone,
    'priceLevelId': priceLevelId,
  };

  CheckoutCustomerEntity toEntity() {
    return CheckoutCustomerEntity(
      id: id,
      name: name,
      phone: phone,
      priceLevelId: priceLevelId,
    );
  }
}

/// Coupon validation result for checkout
class CheckoutCouponModel {
  final bool isValid;
  final String? code;
  final double? discountAmount;
  final String? discountType;
  final String? message;

  const CheckoutCouponModel({
    required this.isValid,
    this.code,
    this.discountAmount,
    this.discountType,
    this.message,
  });

  factory CheckoutCouponModel.fromJson(Map<String, dynamic> json) {
    return CheckoutCouponModel(
      isValid: json['isValid'] ?? false,
      code: json['code'],
      discountAmount: (json['discountAmount'] as num?)?.toDouble(),
      discountType: json['discountType'],
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() => {
    'isValid': isValid,
    'code': code,
    'discountAmount': discountAmount,
    'discountType': discountType,
    'message': message,
  };

  CheckoutCouponEntity toEntity() {
    return CheckoutCouponEntity(
      isValid: isValid,
      code: code,
      discountAmount: discountAmount,
      discountType: discountType,
      message: message,
    );
  }

  /// Convert to CouponValidation for compatibility
  CouponValidation toCouponValidation() {
    return CouponValidation(
      isValid: isValid,
      discountAmount: discountAmount,
      message: message,
    );
  }
}

/// Full checkout session response
class CheckoutSessionModel {
  final CheckoutCartModel cart;
  final List<AddressModel> addresses;
  final List<PaymentMethodModel> paymentMethods;
  final CheckoutCustomerModel customer;
  final CheckoutCouponModel? coupon;

  const CheckoutSessionModel({
    required this.cart,
    required this.addresses,
    required this.paymentMethods,
    required this.customer,
    this.coupon,
  });

  factory CheckoutSessionModel.fromJson(Map<String, dynamic> json) {
    return CheckoutSessionModel(
      cart: CheckoutCartModel.fromJson(json['cart'] ?? <String, dynamic>{}),
      addresses: (json['addresses'] as List<dynamic>?)
              ?.map((e) => AddressModel.fromJson(e))
              .toList() ??
          [],
      paymentMethods: (json['paymentMethods'] as List<dynamic>?)
              ?.map((e) => PaymentMethodModel.fromJson(e))
              .toList() ??
          [],
      customer: CheckoutCustomerModel.fromJson(
        json['customer'] ?? <String, dynamic>{},
      ),
      coupon: json['coupon'] != null
          ? CheckoutCouponModel.fromJson(json['coupon'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'cart': cart.toJson(),
    'addresses': addresses.map((e) => e.toJson()).toList(),
    'paymentMethods': paymentMethods.map((e) => e.toJson()).toList(),
    'customer': customer.toJson(),
    'coupon': coupon?.toJson(),
  };

  CheckoutSessionEntity toEntity() {
    return CheckoutSessionEntity(
      cart: cart.toEntity(),
      addresses: addresses.map((e) => e.toEntity()).toList(),
      paymentMethods: paymentMethods.map((e) => e.toEntity()).toList(),
      customer: customer.toEntity(),
      coupon: coupon?.toEntity(),
    );
  }
}
