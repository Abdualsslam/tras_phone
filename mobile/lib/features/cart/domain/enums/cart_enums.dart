/// Cart Enums - Domain enums for cart module
library;

/// Cart statuses
enum CartStatus {
  active,
  abandoned,
  converted,
  expired;

  static CartStatus fromString(String value) {
    return CartStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => CartStatus.active,
    );
  }

  String get displayNameAr {
    switch (this) {
      case CartStatus.active:
        return 'نشطة';
      case CartStatus.abandoned:
        return 'متروكة';
      case CartStatus.converted:
        return 'تم التحويل';
      case CartStatus.expired:
        return 'منتهية';
    }
  }
}
