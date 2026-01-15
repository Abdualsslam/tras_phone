/// Return Enums - All enums for the returns module
library;

import 'package:flutter/material.dart';

/// حالة طلب الإرجاع
enum ReturnStatus {
  pending, // في انتظار المراجعة
  approved, // تمت الموافقة
  rejected, // مرفوض
  pickupScheduled, // تم جدولة الاستلام
  pickedUp, // تم الاستلام
  inspecting, // قيد الفحص
  completed, // مكتمل
  cancelled; // ملغي

  static ReturnStatus fromString(String value) {
    switch (value) {
      case 'pending':
        return ReturnStatus.pending;
      case 'approved':
        return ReturnStatus.approved;
      case 'rejected':
        return ReturnStatus.rejected;
      case 'pickup_scheduled':
        return ReturnStatus.pickupScheduled;
      case 'picked_up':
        return ReturnStatus.pickedUp;
      case 'inspecting':
        return ReturnStatus.inspecting;
      case 'completed':
        return ReturnStatus.completed;
      case 'cancelled':
        return ReturnStatus.cancelled;
      default:
        return ReturnStatus.pending;
    }
  }

  String toApiString() {
    switch (this) {
      case ReturnStatus.pending:
        return 'pending';
      case ReturnStatus.approved:
        return 'approved';
      case ReturnStatus.rejected:
        return 'rejected';
      case ReturnStatus.pickupScheduled:
        return 'pickup_scheduled';
      case ReturnStatus.pickedUp:
        return 'picked_up';
      case ReturnStatus.inspecting:
        return 'inspecting';
      case ReturnStatus.completed:
        return 'completed';
      case ReturnStatus.cancelled:
        return 'cancelled';
    }
  }

  String get displayNameAr {
    switch (this) {
      case ReturnStatus.pending:
        return 'في انتظار المراجعة';
      case ReturnStatus.approved:
        return 'تمت الموافقة';
      case ReturnStatus.rejected:
        return 'مرفوض';
      case ReturnStatus.pickupScheduled:
        return 'تم جدولة الاستلام';
      case ReturnStatus.pickedUp:
        return 'تم الاستلام';
      case ReturnStatus.inspecting:
        return 'قيد الفحص';
      case ReturnStatus.completed:
        return 'مكتمل';
      case ReturnStatus.cancelled:
        return 'ملغي';
    }
  }

  Color get color {
    switch (this) {
      case ReturnStatus.pending:
        return Colors.orange;
      case ReturnStatus.approved:
        return Colors.blue;
      case ReturnStatus.rejected:
        return Colors.red;
      case ReturnStatus.pickupScheduled:
        return Colors.purple;
      case ReturnStatus.pickedUp:
        return Colors.indigo;
      case ReturnStatus.inspecting:
        return Colors.teal;
      case ReturnStatus.completed:
        return Colors.green;
      case ReturnStatus.cancelled:
        return Colors.grey;
    }
  }
}

/// نوع الإرجاع
enum ReturnType {
  refund, // استرداد مالي
  exchange, // استبدال
  storeCredit; // رصيد متجر

  static ReturnType fromString(String value) {
    switch (value) {
      case 'refund':
        return ReturnType.refund;
      case 'exchange':
        return ReturnType.exchange;
      case 'store_credit':
        return ReturnType.storeCredit;
      default:
        return ReturnType.refund;
    }
  }

  String toApiString() {
    switch (this) {
      case ReturnType.refund:
        return 'refund';
      case ReturnType.exchange:
        return 'exchange';
      case ReturnType.storeCredit:
        return 'store_credit';
    }
  }

  String get displayNameAr {
    switch (this) {
      case ReturnType.refund:
        return 'استرداد مالي';
      case ReturnType.exchange:
        return 'استبدال';
      case ReturnType.storeCredit:
        return 'رصيد متجر';
    }
  }
}

/// فئة سبب الإرجاع
enum ReasonCategory {
  defective, // عيب في المنتج
  wrongItem, // منتج خاطئ
  notAsDescribed, // لا يطابق الوصف
  changedMind, // تغيير الرأي
  damaged, // تالف
  other; // أخرى

  static ReasonCategory fromString(String value) {
    switch (value) {
      case 'defective':
        return ReasonCategory.defective;
      case 'wrong_item':
        return ReasonCategory.wrongItem;
      case 'not_as_described':
        return ReasonCategory.notAsDescribed;
      case 'changed_mind':
        return ReasonCategory.changedMind;
      case 'damaged':
        return ReasonCategory.damaged;
      case 'other':
        return ReasonCategory.other;
      default:
        return ReasonCategory.other;
    }
  }

  String toApiString() {
    switch (this) {
      case ReasonCategory.defective:
        return 'defective';
      case ReasonCategory.wrongItem:
        return 'wrong_item';
      case ReasonCategory.notAsDescribed:
        return 'not_as_described';
      case ReasonCategory.changedMind:
        return 'changed_mind';
      case ReasonCategory.damaged:
        return 'damaged';
      case ReasonCategory.other:
        return 'other';
    }
  }

  String get displayNameAr {
    switch (this) {
      case ReasonCategory.defective:
        return 'عيب في المنتج';
      case ReasonCategory.wrongItem:
        return 'منتج خاطئ';
      case ReasonCategory.notAsDescribed:
        return 'لا يطابق الوصف';
      case ReasonCategory.changedMind:
        return 'تغيير الرأي';
      case ReasonCategory.damaged:
        return 'تالف';
      case ReasonCategory.other:
        return 'أخرى';
    }
  }
}

/// حالة فحص العنصر
enum InspectionStatus {
  pending,
  inspected,
  approved,
  rejected;

  static InspectionStatus fromString(String value) {
    return InspectionStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => InspectionStatus.pending,
    );
  }

  String get displayNameAr {
    switch (this) {
      case InspectionStatus.pending:
        return 'في الانتظار';
      case InspectionStatus.inspected:
        return 'تم الفحص';
      case InspectionStatus.approved:
        return 'مقبول';
      case InspectionStatus.rejected:
        return 'مرفوض';
    }
  }
}

/// حالة العنصر
enum ItemCondition {
  good, // جيد
  damaged, // تالف
  used, // مستخدم
  missingParts, // أجزاء ناقصة
  notOriginal; // غير أصلي

  static ItemCondition fromString(String value) {
    switch (value) {
      case 'good':
        return ItemCondition.good;
      case 'damaged':
        return ItemCondition.damaged;
      case 'used':
        return ItemCondition.used;
      case 'missing_parts':
        return ItemCondition.missingParts;
      case 'not_original':
        return ItemCondition.notOriginal;
      default:
        return ItemCondition.good;
    }
  }

  String toApiString() {
    switch (this) {
      case ItemCondition.good:
        return 'good';
      case ItemCondition.damaged:
        return 'damaged';
      case ItemCondition.used:
        return 'used';
      case ItemCondition.missingParts:
        return 'missing_parts';
      case ItemCondition.notOriginal:
        return 'not_original';
    }
  }

  String get displayNameAr {
    switch (this) {
      case ItemCondition.good:
        return 'جيد';
      case ItemCondition.damaged:
        return 'تالف';
      case ItemCondition.used:
        return 'مستخدم';
      case ItemCondition.missingParts:
        return 'أجزاء ناقصة';
      case ItemCondition.notOriginal:
        return 'غير أصلي';
    }
  }
}
