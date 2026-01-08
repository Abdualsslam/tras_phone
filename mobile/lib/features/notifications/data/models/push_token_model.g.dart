// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'push_token_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PushTokenModel _$PushTokenModelFromJson(Map<String, dynamic> json) =>
    PushTokenModel(
      id: PushTokenModel._readId(json, 'id') as String,
      customerId: PushTokenModel._readOptionalId(json, 'customerId') as String?,
      token: json['token'] as String,
      provider: json['provider'] as String? ?? 'fcm',
      platform: json['platform'] as String? ?? 'android',
      deviceId: json['deviceId'] as String?,
      deviceName: json['deviceName'] as String?,
      deviceModel: json['deviceModel'] as String?,
      appVersion: json['appVersion'] as String?,
      osVersion: json['osVersion'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      lastUsedAt: json['lastUsedAt'] == null
          ? null
          : DateTime.parse(json['lastUsedAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$PushTokenModelToJson(PushTokenModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'customerId': instance.customerId,
      'token': instance.token,
      'provider': instance.provider,
      'platform': instance.platform,
      'deviceId': instance.deviceId,
      'deviceName': instance.deviceName,
      'deviceModel': instance.deviceModel,
      'appVersion': instance.appVersion,
      'osVersion': instance.osVersion,
      'isActive': instance.isActive,
      'lastUsedAt': instance.lastUsedAt?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
    };
