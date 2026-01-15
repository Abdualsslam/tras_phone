import '../../domain/enums/promotion_enums.dart';
import 'coupon_model.dart';

class CouponValidation {
  final bool isValid;
  final Coupon? coupon;
  final double? discountAmount;
  final String? message;
  final String? messageAr;
  final ValidationError? error;

  CouponValidation({
    required this.isValid,
    this.coupon,
    this.discountAmount,
    this.message,
    this.messageAr,
    this.error,
  });

  factory CouponValidation.fromJson(Map<String, dynamic> json) {
    return CouponValidation(
      isValid: json['isValid'] ?? false,
      coupon: json['coupon'] != null ? Coupon.fromJson(json['coupon']) : null,
      discountAmount: json['discountAmount']?.toDouble(),
      message: json['message'],
      messageAr: json['messageAr'],
      error:
          json['error'] != null
              ? ValidationError.fromString(json['error'])
              : null,
    );
  }

  /// الحصول على الرسالة حسب اللغة
  String getMessage(String locale) =>
      locale == 'ar' ? (messageAr ?? '') : (message ?? '');
}

/// عنصر سلة للتحقق من الكوبون
class CartItemForValidation {
  final String productId;
  final String? categoryId;
  final int quantity;
  final double price;

  CartItemForValidation({
    required this.productId,
    this.categoryId,
    required this.quantity,
    required this.price,
  });

  Map<String, dynamic> toJson() => {
    'productId': productId,
    if (categoryId != null) 'categoryId': categoryId,
    'quantity': quantity,
    'price': price,
  };
}
