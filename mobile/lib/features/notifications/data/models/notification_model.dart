/// Notification Model - Data layer model with JSON serialization
library;

import 'package:json_annotation/json_annotation.dart';
import '../../domain/enums/notification_enums.dart';

part 'notification_model.g.dart';

@JsonSerializable()
class NotificationModel {
  @JsonKey(name: 'id', readValue: _readId)
  final String id;

  @JsonKey(name: 'customerId', readValue: _readOptionalId)
  final String? customerId;

  @JsonKey(defaultValue: 'system')
  final String category;

  // Content
  final String title;
  final String titleAr;
  final String body;
  final String bodyAr;
  final String? image;

  // Action
  final String? actionType;
  final String? actionId;
  final String? actionUrl;

  // Reference
  final String? referenceType;
  final String? referenceId;

  // Status
  @JsonKey(defaultValue: false)
  final bool isRead;
  final DateTime? readAt;
  @JsonKey(defaultValue: false)
  final bool isSent;
  final DateTime? sentAt;

  final DateTime createdAt;
  final DateTime updatedAt;

  // Extra data
  final Map<String, dynamic>? data;

  const NotificationModel({
    required this.id,
    this.customerId,
    this.category = 'system',
    required this.title,
    required this.titleAr,
    required this.body,
    required this.bodyAr,
    this.image,
    this.actionType,
    this.actionId,
    this.actionUrl,
    this.referenceType,
    this.referenceId,
    this.isRead = false,
    this.readAt,
    this.isSent = false,
    this.sentAt,
    required this.createdAt,
    required this.updatedAt,
    this.data,
  });

  /// Handle MongoDB _id or id field
  static Object? _readId(Map<dynamic, dynamic> json, String key) {
    final value = json['_id'] ?? json['id'];
    if (value is Map) {
      return value['\$oid'] ?? value.toString();
    }
    return value?.toString();
  }

  /// Handle optional ID fields
  static Object? _readOptionalId(Map<dynamic, dynamic> json, String key) {
    final value = json[key];
    if (value == null) return null;
    if (value is String) return value;
    if (value is Map) {
      return value['_id']?.toString() ?? value['\$oid']?.toString();
    }
    return value.toString();
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationModelFromJson(json);
  Map<String, dynamic> toJson() => _$NotificationModelToJson(this);

  // Enum helpers
  NotificationCategory get categoryEnum =>
      NotificationCategory.fromString(category);
  NotificationActionType? get actionTypeEnum => actionType != null
      ? NotificationActionType.fromString(actionType!)
      : null;

  /// Get title based on locale
  String getTitle(String locale) => locale == 'ar' ? titleAr : title;

  /// Get body based on locale
  String getBody(String locale) => locale == 'ar' ? bodyAr : body;

  /// Check if notification has action
  bool get hasAction =>
      actionType != null && (actionId != null || actionUrl != null);
}

/// Notifications list response with meta
class NotificationsResponse {
  final List<NotificationModel> notifications;
  final int total;
  final int unreadCount;

  NotificationsResponse({
    required this.notifications,
    required this.total,
    required this.unreadCount,
  });

  factory NotificationsResponse.fromJson(Map<String, dynamic> json) {
    return NotificationsResponse(
      notifications: (json['data'] as List? ?? [])
          .map((n) => NotificationModel.fromJson(n))
          .toList(),
      total: json['meta']?['total'] ?? 0,
      unreadCount: json['meta']?['unreadCount'] ?? 0,
    );
  }
}

/// Notification Settings Model
@JsonSerializable()
class NotificationSettingsModel {
  @JsonKey(defaultValue: true)
  final bool pushEnabled;
  @JsonKey(defaultValue: true)
  final bool emailEnabled;
  @JsonKey(defaultValue: false)
  final bool smsEnabled;
  @JsonKey(defaultValue: true)
  final bool orderUpdates;
  @JsonKey(defaultValue: true)
  final bool promotions;
  @JsonKey(defaultValue: true)
  final bool priceDrops;
  @JsonKey(defaultValue: true)
  final bool stockAlerts;
  @JsonKey(defaultValue: false)
  final bool newArrivals;

  const NotificationSettingsModel({
    this.pushEnabled = true,
    this.emailEnabled = true,
    this.smsEnabled = false,
    this.orderUpdates = true,
    this.promotions = true,
    this.priceDrops = true,
    this.stockAlerts = true,
    this.newArrivals = false,
  });

  factory NotificationSettingsModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationSettingsModelFromJson(json);
  Map<String, dynamic> toJson() => _$NotificationSettingsModelToJson(this);

  NotificationSettingsModel copyWith({
    bool? pushEnabled,
    bool? emailEnabled,
    bool? smsEnabled,
    bool? orderUpdates,
    bool? promotions,
    bool? priceDrops,
    bool? stockAlerts,
    bool? newArrivals,
  }) {
    return NotificationSettingsModel(
      pushEnabled: pushEnabled ?? this.pushEnabled,
      emailEnabled: emailEnabled ?? this.emailEnabled,
      smsEnabled: smsEnabled ?? this.smsEnabled,
      orderUpdates: orderUpdates ?? this.orderUpdates,
      promotions: promotions ?? this.promotions,
      priceDrops: priceDrops ?? this.priceDrops,
      stockAlerts: stockAlerts ?? this.stockAlerts,
      newArrivals: newArrivals ?? this.newArrivals,
    );
  }
}
