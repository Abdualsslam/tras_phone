/// Banner Entity - Domain layer representation of a banner
library;

import 'package:equatable/equatable.dart';
import '../enums/banner_type.dart';
import '../enums/banner_position.dart';
import 'banner_media_entity.dart';
import 'banner_action_entity.dart';
import 'banner_content_entity.dart';
import 'banner_targeting_entity.dart';

class BannerEntity extends Equatable {
  final String id;
  final String nameAr;
  final String nameEn;
  final BannerType type;
  final BannerPosition position;
  final BannerMediaEntity media;
  final BannerActionEntity action;
  final BannerContentEntity content;
  final BannerTargetingEntity targeting;

  // Schedule
  final DateTime? startDate;
  final DateTime? endDate;

  // Status
  final bool isActive;
  final int sortOrder;
  final int priority;

  // Statistics
  final int impressions;
  final int clicks;

  final DateTime createdAt;
  final DateTime updatedAt;

  const BannerEntity({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.type,
    required this.position,
    required this.media,
    required this.action,
    required this.content,
    required this.targeting,
    this.startDate,
    this.endDate,
    this.isActive = true,
    this.sortOrder = 0,
    this.priority = 0,
    this.impressions = 0,
    this.clicks = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  /// الحصول على الاسم حسب اللغة
  String getName(String locale) => locale == 'ar' ? nameAr : nameEn;

  /// هل البانر نشط حالياً؟
  bool get isCurrentlyActive {
    if (!isActive) return false;
    final now = DateTime.now();
    if (startDate != null && now.isBefore(startDate!)) return false;
    if (endDate != null && now.isAfter(endDate!)) return false;
    return true;
  }

  /// معدل النقر (CTR)
  double get clickThroughRate {
    if (impressions == 0) return 0.0;
    return (clicks / impressions) * 100;
  }

  /// هل البانر من نوع Popup؟
  bool get isPopup => type == BannerType.popup;

  @override
  List<Object?> get props => [
        id,
        nameAr,
        nameEn,
        type,
        position,
        media,
        action,
        content,
        targeting,
        startDate,
        endDate,
        isActive,
        sortOrder,
        priority,
        impressions,
        clicks,
        createdAt,
        updatedAt,
      ];
}
