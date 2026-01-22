/// Banner Action Type Enum
library;

enum BannerActionType {
  link,
  product,
  category,
  brand,
  page,
  none;

  String get value {
    switch (this) {
      case BannerActionType.link:
        return 'link';
      case BannerActionType.product:
        return 'product';
      case BannerActionType.category:
        return 'category';
      case BannerActionType.brand:
        return 'brand';
      case BannerActionType.page:
        return 'page';
      case BannerActionType.none:
        return 'none';
    }
  }
}
