/// Product Offer Extension - Extension methods for products with direct offers
library;

import '../entities/product_entity.dart';

/// Extension on ProductEntity for offer-related functionality
extension ProductOfferExtension on ProductEntity {
  /// هل المنتج له عرض مباشر؟
  bool get hasDirectOffer {
    return compareAtPrice != null && compareAtPrice! > basePrice;
  }

  /// حساب نسبة الخصم (كـ double)
  double get discountPercentageDouble {
    if (!hasDirectOffer) return 0.0;
    return ((compareAtPrice! - basePrice) / compareAtPrice!) * 100;
  }

  /// السعر الأصلي (قبل الخصم)
  double get originalPriceForOffer => compareAtPrice ?? basePrice;

  /// السعر الحالي (بعد الخصم)
  double get currentPriceForOffer => basePrice;

  /// نص الخصم للعرض
  String get discountText {
    if (!hasDirectOffer) return '';
    final discount = discountPercentage.round();
    return 'خصم $discount%';
  }

  /// هل المنتج في عرض الآن؟
  bool get isOnOffer => hasDirectOffer;

  /// حساب المبلغ الموفّر
  double get savedAmount {
    if (!hasDirectOffer) return 0.0;
    return compareAtPrice! - basePrice;
  }

  /// نص المبلغ الموفّر
  String get savedAmountText {
    if (!hasDirectOffer) return '';
    return 'وفر ${savedAmount.toStringAsFixed(0)} ر.س';
  }
}
