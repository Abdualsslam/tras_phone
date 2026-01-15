/// نوع خصم العرض
enum DiscountType {
  percentage, // نسبة مئوية
  fixedAmount, // مبلغ ثابت
  buyXGetY, // اشتر X واحصل على Y
  freeShipping; // شحن مجاني

  static DiscountType fromString(String value) {
    switch (value) {
      case 'percentage':
        return DiscountType.percentage;
      case 'fixed_amount':
        return DiscountType.fixedAmount;
      case 'buy_x_get_y':
        return DiscountType.buyXGetY;
      case 'free_shipping':
        return DiscountType.freeShipping;
      default:
        return DiscountType.percentage;
    }
  }

  String get displayNameAr {
    switch (this) {
      case DiscountType.percentage:
        return 'نسبة مئوية';
      case DiscountType.fixedAmount:
        return 'مبلغ ثابت';
      case DiscountType.buyXGetY:
        return 'اشتر X واحصل على Y';
      case DiscountType.freeShipping:
        return 'شحن مجاني';
    }
  }
}

/// نطاق العرض
enum PromotionScope {
  all, // جميع المنتجات
  specificProducts, // منتجات محددة
  specificCategories, // فئات محددة
  specificBrands; // علامات تجارية محددة

  static PromotionScope fromString(String value) {
    switch (value) {
      case 'all':
        return PromotionScope.all;
      case 'specific_products':
        return PromotionScope.specificProducts;
      case 'specific_categories':
        return PromotionScope.specificCategories;
      case 'specific_brands':
        return PromotionScope.specificBrands;
      default:
        return PromotionScope.all;
    }
  }
}

/// نوع خصم الكوبون
enum CouponDiscountType {
  percentage,
  fixedAmount,
  freeShipping;

  static CouponDiscountType fromString(String value) {
    switch (value) {
      case 'percentage':
        return CouponDiscountType.percentage;
      case 'fixed_amount':
        return CouponDiscountType.fixedAmount;
      case 'free_shipping':
        return CouponDiscountType.freeShipping;
      default:
        return CouponDiscountType.percentage;
    }
  }
}

/// أخطاء التحقق من الكوبون
enum ValidationError {
  couponNotFound,
  couponExpired,
  couponNotStarted,
  couponInactive,
  usageLimitReached,
  customerUsageLimitReached,
  minOrderNotMet,
  notFirstOrder,
  notApplicable;

  static ValidationError fromString(String value) {
    switch (value) {
      case 'COUPON_NOT_FOUND':
        return ValidationError.couponNotFound;
      case 'COUPON_EXPIRED':
        return ValidationError.couponExpired;
      case 'COUPON_NOT_STARTED':
        return ValidationError.couponNotStarted;
      case 'COUPON_INACTIVE':
        return ValidationError.couponInactive;
      case 'USAGE_LIMIT_REACHED':
        return ValidationError.usageLimitReached;
      case 'CUSTOMER_USAGE_LIMIT_REACHED':
        return ValidationError.customerUsageLimitReached;
      case 'MIN_ORDER_NOT_MET':
        return ValidationError.minOrderNotMet;
      case 'NOT_FIRST_ORDER':
        return ValidationError.notFirstOrder;
      case 'NOT_APPLICABLE':
        return ValidationError.notApplicable;
      default:
        return ValidationError.couponNotFound;
    }
  }

  String get displayNameAr {
    switch (this) {
      case ValidationError.couponNotFound:
        return 'الكوبون غير موجود';
      case ValidationError.couponExpired:
        return 'الكوبون منتهي الصلاحية';
      case ValidationError.couponNotStarted:
        return 'الكوبون لم يبدأ بعد';
      case ValidationError.couponInactive:
        return 'الكوبون غير نشط';
      case ValidationError.usageLimitReached:
        return 'تم استنفاد الكوبون';
      case ValidationError.customerUsageLimitReached:
        return 'استخدمت هذا الكوبون من قبل';
      case ValidationError.minOrderNotMet:
        return 'الحد الأدنى للطلب غير مستوفى';
      case ValidationError.notFirstOrder:
        return 'الكوبون للطلب الأول فقط';
      case ValidationError.notApplicable:
        return 'الكوبون لا ينطبق على هذه المنتجات';
    }
  }
}
