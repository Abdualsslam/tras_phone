import '../../../promotions/data/models/coupon_validation_model.dart';
import '../../domain/entities/checkout_coupon_entity.dart';

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
