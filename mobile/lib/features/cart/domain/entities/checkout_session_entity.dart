/// Checkout Session Entity - Domain layer representation of checkout session
library;

import 'package:equatable/equatable.dart';
import '../../../profile/domain/entities/address_entity.dart';
import '../../../orders/domain/entities/payment_method_entity.dart';

/// Product details in cart item
class CartItemProductEntity extends Equatable {
  final String name;
  final String nameAr;
  final String? image;
  final String sku;
  final bool isActive;
  final int stockQuantity;

  const CartItemProductEntity({
    required this.name,
    required this.nameAr,
    this.image,
    required this.sku,
    required this.isActive,
    required this.stockQuantity,
  });

  /// Get localized name
  String getName(String locale) =>
      locale == 'ar' && nameAr.isNotEmpty ? nameAr : name;

  @override
  List<Object?> get props =>
      [name, nameAr, image, sku, isActive, stockQuantity];
}

/// Cart item with product details
class CheckoutCartItemEntity extends Equatable {
  final String productId;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final DateTime addedAt;
  final CartItemProductEntity product;

  const CheckoutCartItemEntity({
    required this.productId,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    required this.addedAt,
    required this.product,
  });

  /// Get localized product name
  String getProductName(String locale) => product.getName(locale);

  /// Check if item has stock issues
  bool get hasStockIssue => quantity > product.stockQuantity;

  /// Check if product is inactive
  bool get isProductInactive => !product.isActive;

  @override
  List<Object?> get props =>
      [productId, quantity, unitPrice, totalPrice, addedAt, product];
}

/// Cart with populated product details
class CheckoutCartEntity extends Equatable {
  final String id;
  final String customerId;
  final String status;
  final List<CheckoutCartItemEntity> items;
  final int itemsCount;
  final double subtotal;
  final double discount;
  final double taxAmount;
  final double shippingCost;
  final double total;
  final String? couponCode;
  final double couponDiscount;

  const CheckoutCartEntity({
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

  bool get isEmpty => items.isEmpty;
  bool get isNotEmpty => items.isNotEmpty;
  bool get hasCoupon => couponCode != null && couponCode!.isNotEmpty;

  /// Check if any item has stock issues
  bool get hasStockIssues => items.any((item) => item.hasStockIssue);

  /// Check if any item is inactive
  bool get hasInactiveProducts => items.any((item) => item.isProductInactive);

  /// Get items with stock issues
  List<CheckoutCartItemEntity> get itemsWithStockIssues =>
      items.where((item) => item.hasStockIssue).toList();

  /// Get inactive product items
  List<CheckoutCartItemEntity> get inactiveProductItems =>
      items.where((item) => item.isProductInactive).toList();

  @override
  List<Object?> get props => [
        id,
        items,
        itemsCount,
        subtotal,
        total,
        couponCode,
        couponDiscount,
      ];
}

/// Customer basic info for checkout
class CheckoutCustomerEntity extends Equatable {
  final String id;
  final String? name;
  final String? phone;
  final String? priceLevelId;

  const CheckoutCustomerEntity({
    required this.id,
    this.name,
    this.phone,
    this.priceLevelId,
  });

  @override
  List<Object?> get props => [id, name, phone, priceLevelId];
}

/// Coupon validation result for checkout
class CheckoutCouponEntity extends Equatable {
  final bool isValid;
  final String? code;
  final double? discountAmount;
  final String? discountType;
  final String? message;

  const CheckoutCouponEntity({
    required this.isValid,
    this.code,
    this.discountAmount,
    this.discountType,
    this.message,
  });

  @override
  List<Object?> get props =>
      [isValid, code, discountAmount, discountType, message];
}

/// Full checkout session entity
class CheckoutSessionEntity extends Equatable {
  final CheckoutCartEntity cart;
  final List<AddressEntity> addresses;
  final List<PaymentMethodEntity> paymentMethods;
  final CheckoutCustomerEntity customer;
  final CheckoutCouponEntity? coupon;

  const CheckoutSessionEntity({
    required this.cart,
    required this.addresses,
    required this.paymentMethods,
    required this.customer,
    this.coupon,
  });

  /// Check if checkout can proceed
  bool get canCheckout =>
      cart.isNotEmpty &&
      !cart.hasStockIssues &&
      !cart.hasInactiveProducts;

  /// Get default address
  AddressEntity? get defaultAddress =>
      addresses.isNotEmpty
          ? addresses.firstWhere(
              (a) => a.isDefault,
              orElse: () => addresses.first,
            )
          : null;

  /// Check if coupon is applied and valid
  bool get hasCouponApplied => coupon != null && coupon!.isValid;

  /// Get coupon discount amount (0 if no valid coupon)
  double get appliedCouponDiscount =>
      hasCouponApplied ? (coupon!.discountAmount ?? 0) : 0;

  /// Calculate final total with coupon discount
  double get finalTotal => cart.subtotal - appliedCouponDiscount + 
      cart.taxAmount + cart.shippingCost;

  @override
  List<Object?> get props =>
      [cart, addresses, paymentMethods, customer, coupon];
}
