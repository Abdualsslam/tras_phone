// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationModel _$NotificationModelFromJson(Map<String, dynamic> json) =>
    NotificationModel(
      id: NotificationModel._readId(json, 'id') as String,
      customerId:
          NotificationModel._readOptionalId(json, 'customerId') as String?,
      category: json['category'] as String? ?? 'system',
      title: json['title'] as String,
      titleAr: json['titleAr'] as String,
      body: json['body'] as String,
      bodyAr: json['bodyAr'] as String,
      image: json['image'] as String?,
      actionType: json['actionType'] as String?,
      actionId: json['actionId'] as String?,
      actionUrl: json['actionUrl'] as String?,
      referenceType: json['referenceType'] as String?,
      referenceId: json['referenceId'] as String?,
      isRead: json['isRead'] as bool? ?? false,
      readAt: json['readAt'] == null
          ? null
          : DateTime.parse(json['readAt'] as String),
      isSent: json['isSent'] as bool? ?? false,
      sentAt: json['sentAt'] == null
          ? null
          : DateTime.parse(json['sentAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      data: json['data'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$NotificationModelToJson(NotificationModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'customerId': instance.customerId,
      'category': instance.category,
      'title': instance.title,
      'titleAr': instance.titleAr,
      'body': instance.body,
      'bodyAr': instance.bodyAr,
      'image': instance.image,
      'actionType': instance.actionType,
      'actionId': instance.actionId,
      'actionUrl': instance.actionUrl,
      'referenceType': instance.referenceType,
      'referenceId': instance.referenceId,
      'isRead': instance.isRead,
      'readAt': instance.readAt?.toIso8601String(),
      'isSent': instance.isSent,
      'sentAt': instance.sentAt?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'data': instance.data,
    };

NotificationSettingsModel _$NotificationSettingsModelFromJson(
  Map<String, dynamic> json,
) => NotificationSettingsModel(
  pushEnabled: json['pushEnabled'] as bool? ?? true,
  emailEnabled: json['emailEnabled'] as bool? ?? true,
  smsEnabled: json['smsEnabled'] as bool? ?? false,
  orderUpdates: json['orderUpdates'] as bool? ?? true,
  promotions: json['promotions'] as bool? ?? true,
  priceDrops: json['priceDrops'] as bool? ?? true,
  stockAlerts: json['stockAlerts'] as bool? ?? true,
  newArrivals: json['newArrivals'] as bool? ?? false,
);

Map<String, dynamic> _$NotificationSettingsModelToJson(
  NotificationSettingsModel instance,
) => <String, dynamic>{
  'pushEnabled': instance.pushEnabled,
  'emailEnabled': instance.emailEnabled,
  'smsEnabled': instance.smsEnabled,
  'orderUpdates': instance.orderUpdates,
  'promotions': instance.promotions,
  'priceDrops': instance.priceDrops,
  'stockAlerts': instance.stockAlerts,
  'newArrivals': instance.newArrivals,
};
