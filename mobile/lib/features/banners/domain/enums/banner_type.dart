/// Banner Type Enum
library;

enum BannerType {
  hero,
  promotional,
  category,
  popup,
  sidebar,
  inline;

  String get value {
    switch (this) {
      case BannerType.hero:
        return 'hero';
      case BannerType.promotional:
        return 'promotional';
      case BannerType.category:
        return 'category';
      case BannerType.popup:
        return 'popup';
      case BannerType.sidebar:
        return 'sidebar';
      case BannerType.inline:
        return 'inline';
    }
  }

  String getName(String locale) {
    switch (this) {
      case BannerType.hero:
        return locale == 'ar' ? 'بانر رئيسي' : 'Hero';
      case BannerType.promotional:
        return locale == 'ar' ? 'ترويجي' : 'Promotional';
      case BannerType.category:
        return locale == 'ar' ? 'فئة' : 'Category';
      case BannerType.popup:
        return locale == 'ar' ? 'منبثق' : 'Popup';
      case BannerType.sidebar:
        return locale == 'ar' ? 'شريط جانبي' : 'Sidebar';
      case BannerType.inline:
        return locale == 'ar' ? 'ضمني' : 'Inline';
    }
  }
}
