/// Product Enums - Domain enums for products module
library;

import 'package:flutter/material.dart';

/// Product statuses
enum ProductStatus {
  draft,
  active,
  inactive,
  outOfStock,
  discontinued;

  static ProductStatus fromString(String value) {
    switch (value) {
      case 'draft':
        return ProductStatus.draft;
      case 'active':
        return ProductStatus.active;
      case 'inactive':
        return ProductStatus.inactive;
      case 'out_of_stock':
        return ProductStatus.outOfStock;
      case 'discontinued':
        return ProductStatus.discontinued;
      default:
        return ProductStatus.draft;
    }
  }

  String get value {
    switch (this) {
      case ProductStatus.outOfStock:
        return 'out_of_stock';
      default:
        return name;
    }
  }

  String get displayNameAr {
    switch (this) {
      case ProductStatus.draft:
        return 'مسودة';
      case ProductStatus.active:
        return 'نشط';
      case ProductStatus.inactive:
        return 'غير نشط';
      case ProductStatus.outOfStock:
        return 'نفد المخزون';
      case ProductStatus.discontinued:
        return 'متوقف';
    }
  }

  Color get color {
    switch (this) {
      case ProductStatus.draft:
        return Colors.grey;
      case ProductStatus.active:
        return Colors.green;
      case ProductStatus.inactive:
        return Colors.orange;
      case ProductStatus.outOfStock:
        return Colors.red;
      case ProductStatus.discontinued:
        return Colors.grey.shade700;
    }
  }
}

/// Product sorting options
enum ProductSortBy {
  price,
  name,
  createdAt,
  viewsCount,
  ordersCount,
  averageRating;

  String get value {
    switch (this) {
      case ProductSortBy.price:
        return 'price';
      case ProductSortBy.name:
        return 'name';
      case ProductSortBy.createdAt:
        return 'createdAt';
      case ProductSortBy.viewsCount:
        return 'viewsCount';
      case ProductSortBy.ordersCount:
        return 'ordersCount';
      case ProductSortBy.averageRating:
        return 'averageRating';
    }
  }

  String get displayNameAr {
    switch (this) {
      case ProductSortBy.price:
        return 'السعر';
      case ProductSortBy.name:
        return 'الاسم';
      case ProductSortBy.createdAt:
        return 'الأحدث';
      case ProductSortBy.viewsCount:
        return 'الأكثر مشاهدة';
      case ProductSortBy.ordersCount:
        return 'الأكثر مبيعاً';
      case ProductSortBy.averageRating:
        return 'التقييم';
    }
  }
}

/// Sort order
enum SortOrder {
  asc,
  desc;

  String get displayNameAr {
    switch (this) {
      case SortOrder.asc:
        return 'تصاعدي';
      case SortOrder.desc:
        return 'تنازلي';
    }
  }
}

/// Review statuses
enum ReviewStatus {
  pending,
  approved,
  rejected;

  static ReviewStatus fromString(String value) {
    return ReviewStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ReviewStatus.pending,
    );
  }

  String get displayNameAr {
    switch (this) {
      case ReviewStatus.pending:
        return 'قيد المراجعة';
      case ReviewStatus.approved:
        return 'مقبول';
      case ReviewStatus.rejected:
        return 'مرفوض';
    }
  }

  Color get color {
    switch (this) {
      case ReviewStatus.pending:
        return Colors.orange;
      case ReviewStatus.approved:
        return Colors.green;
      case ReviewStatus.rejected:
        return Colors.red;
    }
  }
}
