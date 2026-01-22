/// Banner Position Enum
library;

enum BannerPosition {
  homeTop,
  homeMiddle,
  homeBottom,
  categoryTop,
  productTop,
  cartTop,
  checkoutTop,
  globalPopup;

  String get value {
    switch (this) {
      case BannerPosition.homeTop:
        return 'home_top';
      case BannerPosition.homeMiddle:
        return 'home_middle';
      case BannerPosition.homeBottom:
        return 'home_bottom';
      case BannerPosition.categoryTop:
        return 'category_top';
      case BannerPosition.productTop:
        return 'product_top';
      case BannerPosition.cartTop:
        return 'cart_top';
      case BannerPosition.checkoutTop:
        return 'checkout_top';
      case BannerPosition.globalPopup:
        return 'global_popup';
    }
  }

  String getName(String locale) {
    switch (this) {
      case BannerPosition.homeTop:
        return locale == 'ar' ? 'أعلى الصفحة الرئيسية' : 'Home Top';
      case BannerPosition.homeMiddle:
        return locale == 'ar' ? 'وسط الصفحة الرئيسية' : 'Home Middle';
      case BannerPosition.homeBottom:
        return locale == 'ar' ? 'أسفل الصفحة الرئيسية' : 'Home Bottom';
      case BannerPosition.categoryTop:
        return locale == 'ar' ? 'أعلى صفحة الفئة' : 'Category Top';
      case BannerPosition.productTop:
        return locale == 'ar' ? 'أعلى صفحة المنتج' : 'Product Top';
      case BannerPosition.cartTop:
        return locale == 'ar' ? 'أعلى السلة' : 'Cart Top';
      case BannerPosition.checkoutTop:
        return locale == 'ar' ? 'أعلى الدفع' : 'Checkout Top';
      case BannerPosition.globalPopup:
        return locale == 'ar' ? 'منبثق عام' : 'Global Popup';
    }
  }
}
