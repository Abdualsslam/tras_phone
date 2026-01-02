/// Notification Model - Data layer model with JSON serialization
library;

import 'package:json_annotation/json_annotation.dart';

part 'notification_model.g.dart';

@JsonSerializable()
class NotificationModel {
  final int id;
  final String type;
  final String title;
  @JsonKey(name: 'title_ar')
  final String? titleAr;
  final String body;
  @JsonKey(name: 'body_ar')
  final String? bodyAr;
  final String? icon;
  @JsonKey(name: 'image_url')
  final String? imageUrl;
  @JsonKey(name: 'action_type')
  final String? actionType; // 'order', 'product', 'category', 'url', 'screen'
  @JsonKey(name: 'action_value')
  final String? actionValue;
  @JsonKey(name: 'is_read')
  final bool isRead;
  @JsonKey(name: 'created_at')
  final String createdAt;
  final Map<String, dynamic>? data;

  const NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    this.titleAr,
    required this.body,
    this.bodyAr,
    this.icon,
    this.imageUrl,
    this.actionType,
    this.actionValue,
    this.isRead = false,
    required this.createdAt,
    this.data,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationModelFromJson(json);
  Map<String, dynamic> toJson() => _$NotificationModelToJson(this);

  String get displayTitle => titleAr ?? title;
  String get displayBody => bodyAr ?? body;

  bool get hasAction => actionType != null && actionValue != null;
}

/// Notification Settings Model
@JsonSerializable()
class NotificationSettingsModel {
  @JsonKey(name: 'push_enabled')
  final bool pushEnabled;
  @JsonKey(name: 'email_enabled')
  final bool emailEnabled;
  @JsonKey(name: 'sms_enabled')
  final bool smsEnabled;
  @JsonKey(name: 'order_updates')
  final bool orderUpdates;
  @JsonKey(name: 'promotions')
  final bool promotions;
  @JsonKey(name: 'price_drops')
  final bool priceDrops;
  @JsonKey(name: 'stock_alerts')
  final bool stockAlerts;
  @JsonKey(name: 'new_arrivals')
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
