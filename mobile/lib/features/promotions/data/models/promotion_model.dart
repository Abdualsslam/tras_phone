import 'package:flutter/material.dart';
import '../../domain/enums/promotion_enums.dart';

class Promotion {
  final String id;
  final String name;
  final String nameAr;
  final String code;
  final String? description;
  final String? descriptionAr;
  final DiscountType discountType;
  final double? discountValue;
  final double? maxDiscountAmount;
  final int? buyQuantity;
  final int? getQuantity;
  final double? getDiscountPercentage;
  final DateTime startDate;
  final DateTime endDate;
  final double? minOrderAmount;
  final int? minQuantity;
  final PromotionScope scope;
  final int? usageLimit;
  final int? usageLimitPerCustomer;
  final int usedCount;
  final String? image;
  final String? badgeText;
  final String? badgeColor;
  final bool isActive;
  final bool isAutoApply;
  final int priority;
  final bool isStackable;

  Promotion({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.code,
    this.description,
    this.descriptionAr,
    required this.discountType,
    this.discountValue,
    this.maxDiscountAmount,
    this.buyQuantity,
    this.getQuantity,
    this.getDiscountPercentage,
    required this.startDate,
    required this.endDate,
    this.minOrderAmount,
    this.minQuantity,
    required this.scope,
    this.usageLimit,
    this.usageLimitPerCustomer,
    required this.usedCount,
    this.image,
    this.badgeText,
    this.badgeColor,
    required this.isActive,
    required this.isAutoApply,
    required this.priority,
    required this.isStackable,
  });

  factory Promotion.fromJson(Map<String, dynamic> json) {
    return Promotion(
      id: json['_id'] ?? json['id'],
      name: json['name'],
      nameAr: json['nameAr'],
      code: json['code'],
      description: json['description'],
      descriptionAr: json['descriptionAr'],
      discountType: DiscountType.fromString(json['discountType']),
      discountValue: json['discountValue']?.toDouble(),
      maxDiscountAmount: json['maxDiscountAmount']?.toDouble(),
      buyQuantity: json['buyQuantity'],
      getQuantity: json['getQuantity'],
      getDiscountPercentage: json['getDiscountPercentage']?.toDouble(),
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      minOrderAmount: json['minOrderAmount']?.toDouble(),
      minQuantity: json['minQuantity'],
      scope: PromotionScope.fromString(json['scope']),
      usageLimit: json['usageLimit'],
      usageLimitPerCustomer: json['usageLimitPerCustomer'],
      usedCount: json['usedCount'] ?? 0,
      image: json['image'],
      badgeText: json['badgeText'],
      badgeColor: json['badgeColor'],
      isActive: json['isActive'] ?? true,
      isAutoApply: json['isAutoApply'] ?? false,
      priority: json['priority'] ?? 0,
      isStackable: json['isStackable'] ?? false,
    );
  }

  /// الحصول على الاسم حسب اللغة
  String getName(String locale) => locale == 'ar' ? nameAr : name;

  /// الحصول على الوصف حسب اللغة
  String? getDescription(String locale) =>
      locale == 'ar' ? descriptionAr : description;

  /// هل العرض صالح الآن؟
  bool get isValid {
    final now = DateTime.now();
    return isActive &&
        now.isAfter(startDate) &&
        now.isBefore(endDate) &&
        (usageLimit == null || usedCount < usageLimit!);
  }

  /// عدد الأيام المتبقية
  int get daysRemaining => endDate.difference(DateTime.now()).inDays;

  /// نص الخصم
  String get discountText {
    switch (discountType) {
      case DiscountType.percentage:
        return '${discountValue?.toInt()}%';
      case DiscountType.fixedAmount:
        return '${discountValue?.toStringAsFixed(0)} ر.س';
      case DiscountType.buyXGetY:
        return 'اشتر $buyQuantity واحصل على $getQuantity';
      case DiscountType.freeShipping:
        return 'شحن مجاني';
    }
  }

  /// تحويل اللون hex إلى Color
  Color? getBadgeColor() {
    if (badgeColor == null) return null;
    final hex = badgeColor!.replaceFirst('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }
}
