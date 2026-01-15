import '../../domain/enums/promotion_enums.dart';

class Coupon {
  final String id;
  final String code;
  final String name;
  final String nameAr;
  final String? description;
  final CouponDiscountType discountType;
  final double? discountValue;
  final double? maxDiscountAmount;
  final DateTime startDate;
  final DateTime expiryDate;
  final double? minOrderAmount;
  final bool firstOrderOnly;
  final int? usageLimit;
  final int usageLimitPerCustomer;
  final int usedCount;
  final bool isActive;
  final bool isPublic;

  Coupon({
    required this.id,
    required this.code,
    required this.name,
    required this.nameAr,
    this.description,
    required this.discountType,
    this.discountValue,
    this.maxDiscountAmount,
    required this.startDate,
    required this.expiryDate,
    this.minOrderAmount,
    required this.firstOrderOnly,
    this.usageLimit,
    required this.usageLimitPerCustomer,
    required this.usedCount,
    required this.isActive,
    required this.isPublic,
  });

  factory Coupon.fromJson(Map<String, dynamic> json) {
    return Coupon(
      id: json['_id'] ?? json['id'],
      code: json['code'],
      name: json['name'],
      nameAr: json['nameAr'],
      description: json['description'],
      discountType: CouponDiscountType.fromString(json['discountType']),
      discountValue: json['discountValue']?.toDouble(),
      maxDiscountAmount: json['maxDiscountAmount']?.toDouble(),
      startDate: DateTime.parse(json['startDate']),
      expiryDate: DateTime.parse(json['expiryDate']),
      minOrderAmount: json['minOrderAmount']?.toDouble(),
      firstOrderOnly: json['firstOrderOnly'] ?? false,
      usageLimit: json['usageLimit'],
      usageLimitPerCustomer: json['usageLimitPerCustomer'] ?? 1,
      usedCount: json['usedCount'] ?? 0,
      isActive: json['isActive'] ?? true,
      isPublic: json['isPublic'] ?? false,
    );
  }

  /// الحصول على الاسم حسب اللغة
  String getName(String locale) => locale == 'ar' ? nameAr : name;

  /// هل الكوبون صالح؟
  bool get isValid {
    final now = DateTime.now();
    return isActive && now.isAfter(startDate) && now.isBefore(expiryDate);
  }

  /// نص الخصم
  String get discountText {
    switch (discountType) {
      case CouponDiscountType.percentage:
        return '${discountValue?.toInt()}%';
      case CouponDiscountType.fixedAmount:
        return '${discountValue?.toStringAsFixed(0)} ر.س';
      case CouponDiscountType.freeShipping:
        return 'شحن مجاني';
    }
  }
}
