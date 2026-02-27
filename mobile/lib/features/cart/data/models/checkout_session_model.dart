import '../../../profile/data/models/address_model.dart';
import '../../../orders/data/models/payment_method_model.dart';
import '../../domain/entities/checkout_session_entity.dart';
import 'checkout_cart_model.dart';
import 'checkout_customer_model.dart';
import 'checkout_coupon_model.dart';

export 'cart_item_product_model.dart';
export 'checkout_cart_item_model.dart';
export 'checkout_cart_model.dart';
export 'checkout_customer_model.dart';
export 'checkout_coupon_model.dart';

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
    final paymentMethodsRaw = json['paymentMethods'] ?? json['payment_methods'];
    final paymentMethodsList = paymentMethodsRaw is List
        ? paymentMethodsRaw
              .map(
                (e) => PaymentMethodModel.fromJson(
                  e is Map<String, dynamic>
                      ? e
                      : Map<String, dynamic>.from(e as Map),
                ),
              )
              .toList()
        : <PaymentMethodModel>[];

    return CheckoutSessionModel(
      cart: CheckoutCartModel.fromJson(json['cart'] ?? <String, dynamic>{}),
      addresses:
          (json['addresses'] as List<dynamic>?)
              ?.map(
                (e) => AddressModel.fromJson(
                  e is Map<String, dynamic>
                      ? e
                      : Map<String, dynamic>.from(e as Map),
                ),
              )
              .toList() ??
          [],
      paymentMethods: paymentMethodsList,
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
