/// Push Token Model - Data layer model for push notification tokens
library;

import 'package:json_annotation/json_annotation.dart';
import '../../domain/enums/notification_enums.dart';

part 'push_token_model.g.dart';

@JsonSerializable()
class PushTokenModel {
  @JsonKey(name: 'id', readValue: _readId)
  final String id;

  @JsonKey(name: 'customerId', readValue: _readOptionalId)
  final String? customerId;

  final String token;

  @JsonKey(defaultValue: 'fcm')
  final String provider;

  @JsonKey(defaultValue: 'android')
  final String platform;

  final String? deviceId;
  final String? deviceName;
  final String? deviceModel;
  final String? appVersion;
  final String? osVersion;

  @JsonKey(defaultValue: true)
  final bool isActive;

  final DateTime? lastUsedAt;
  final DateTime createdAt;

  const PushTokenModel({
    required this.id,
    this.customerId,
    required this.token,
    this.provider = 'fcm',
    this.platform = 'android',
    this.deviceId,
    this.deviceName,
    this.deviceModel,
    this.appVersion,
    this.osVersion,
    this.isActive = true,
    this.lastUsedAt,
    required this.createdAt,
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

  factory PushTokenModel.fromJson(Map<String, dynamic> json) =>
      _$PushTokenModelFromJson(json);
  Map<String, dynamic> toJson() => _$PushTokenModelToJson(this);

  // Enum helpers
  PushProvider get providerEnum => PushProvider.fromString(provider);
  PushPlatform get platformEnum => PushPlatform.fromString(platform);
}

/// Request model for registering push token
class PushTokenRequest {
  final String token;
  final String provider;
  final String platform;
  final String? deviceId;
  final String? deviceName;
  final String? deviceModel;
  final String? appVersion;
  final String? osVersion;

  const PushTokenRequest({
    required this.token,
    required this.provider,
    required this.platform,
    this.deviceId,
    this.deviceName,
    this.deviceModel,
    this.appVersion,
    this.osVersion,
  });

  Map<String, dynamic> toJson() => {
    'token': token,
    'provider': provider,
    'platform': platform,
    if (deviceId != null) 'deviceId': deviceId,
    if (deviceName != null) 'deviceName': deviceName,
    if (deviceModel != null) 'deviceModel': deviceModel,
    if (appVersion != null) 'appVersion': appVersion,
    if (osVersion != null) 'osVersion': osVersion,
  };
}
