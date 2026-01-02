// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationModel _$NotificationModelFromJson(Map<String, dynamic> json) =>
    NotificationModel(
      id: (json['id'] as num).toInt(),
      type: json['type'] as String,
      title: json['title'] as String,
      titleAr: json['title_ar'] as String?,
      body: json['body'] as String,
      bodyAr: json['body_ar'] as String?,
      icon: json['icon'] as String?,
      imageUrl: json['image_url'] as String?,
      actionType: json['action_type'] as String?,
      actionValue: json['action_value'] as String?,
      isRead: json['is_read'] as bool? ?? false,
      createdAt: json['created_at'] as String,
      data: json['data'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$NotificationModelToJson(NotificationModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'title': instance.title,
      'title_ar': instance.titleAr,
      'body': instance.body,
      'body_ar': instance.bodyAr,
      'icon': instance.icon,
      'image_url': instance.imageUrl,
      'action_type': instance.actionType,
      'action_value': instance.actionValue,
      'is_read': instance.isRead,
      'created_at': instance.createdAt,
      'data': instance.data,
    };

NotificationSettingsModel _$NotificationSettingsModelFromJson(
  Map<String, dynamic> json,
) => NotificationSettingsModel(
  pushEnabled: json['push_enabled'] as bool? ?? true,
  emailEnabled: json['email_enabled'] as bool? ?? true,
  smsEnabled: json['sms_enabled'] as bool? ?? false,
  orderUpdates: json['order_updates'] as bool? ?? true,
  promotions: json['promotions'] as bool? ?? true,
  priceDrops: json['price_drops'] as bool? ?? true,
  stockAlerts: json['stock_alerts'] as bool? ?? true,
  newArrivals: json['new_arrivals'] as bool? ?? false,
);

Map<String, dynamic> _$NotificationSettingsModelToJson(
  NotificationSettingsModel instance,
) => <String, dynamic>{
  'push_enabled': instance.pushEnabled,
  'email_enabled': instance.emailEnabled,
  'sms_enabled': instance.smsEnabled,
  'order_updates': instance.orderUpdates,
  'promotions': instance.promotions,
  'price_drops': instance.priceDrops,
  'stock_alerts': instance.stockAlerts,
  'new_arrivals': instance.newArrivals,
};
