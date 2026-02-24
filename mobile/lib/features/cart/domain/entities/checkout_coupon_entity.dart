import 'package:equatable/equatable.dart';

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
  List<Object?> get props => [
    isValid,
    code,
    discountAmount,
    discountType,
    message,
  ];
}
