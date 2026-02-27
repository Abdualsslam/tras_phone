import 'package:equatable/equatable.dart';
import '../../../profile/domain/entities/address_entity.dart';
import '../../../orders/domain/entities/payment_method_entity.dart';
import 'checkout_cart_entity.dart';
import 'checkout_customer_entity.dart';
import 'checkout_coupon_entity.dart';

export 'cart_item_product_entity.dart';
export 'checkout_cart_item_entity.dart';
export 'checkout_cart_entity.dart';
export 'checkout_customer_entity.dart';
export 'checkout_coupon_entity.dart';

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
      cart.isNotEmpty && !cart.hasStockIssues && !cart.hasInactiveProducts;

  /// Get default address
  AddressEntity? get defaultAddress => addresses.isNotEmpty
      ? addresses.firstWhere((a) => a.isDefault, orElse: () => addresses.first)
      : null;

  /// Check if coupon is applied and valid
  bool get hasCouponApplied => coupon != null && coupon!.isValid;

  /// Get coupon discount amount (0 if no valid coupon)
  double get appliedCouponDiscount =>
      hasCouponApplied ? (coupon!.discountAmount ?? 0) : 0;

  /// Calculate final total with coupon discount
  double get finalTotal =>
      cart.subtotal -
      appliedCouponDiscount +
      cart.taxAmount +
      cart.shippingCost;

  @override
  List<Object?> get props => [
    cart,
    addresses,
    paymentMethods,
    customer,
    coupon,
  ];
}
