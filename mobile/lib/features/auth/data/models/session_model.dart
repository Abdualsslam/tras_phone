/// Session Model - Data layer model for user sessions
library;

import '../../domain/entities/session_entity.dart';

class SessionModel {
  final String id;
  final String userId;
  final String tokenId;
  final String ipAddress;
  final String userAgent;
  final DateTime expiresAt;
  final DateTime lastActivityAt;
  final DateTime createdAt;

  const SessionModel({
    required this.id,
    required this.userId,
    required this.tokenId,
    required this.ipAddress,
    required this.userAgent,
    required this.expiresAt,
    required this.lastActivityAt,
    required this.createdAt,
  });

  /// Handle both String id and ObjectId map from MongoDB
  static String _readId(Map<dynamic, dynamic> json) {
    final value = json['_id'] ?? json['id'];
    if (value is Map) {
      return value['\$oid']?.toString() ?? value.toString();
    }
    return value?.toString() ?? '';
  }

  /// Handle optional ID fields
  static String? _readOptionalId(Map<dynamic, dynamic> json, String key) {
    final value = json[key];
    if (value == null) return null;
    if (value is String) return value;
    if (value is Map) {
      return value['_id']?.toString() ?? value['\$oid']?.toString();
    }
    return value.toString();
  }

  factory SessionModel.fromJson(Map<String, dynamic> json) {
    return SessionModel(
      id: _readId(json),
      userId: _readOptionalId(json, 'userId') ?? '',
      tokenId: json['tokenId'] as String? ?? '',
      ipAddress: json['ipAddress'] as String? ?? '',
      userAgent: json['userAgent'] as String? ?? '',
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      lastActivityAt: DateTime.parse(json['lastActivityAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'userId': userId,
    'tokenId': tokenId,
    'ipAddress': ipAddress,
    'userAgent': userAgent,
    'expiresAt': expiresAt.toIso8601String(),
    'lastActivityAt': lastActivityAt.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
  };

  SessionEntity toEntity() {
    return SessionEntity(
      id: id,
      userId: userId,
      tokenId: tokenId,
      ipAddress: ipAddress,
      userAgent: userAgent,
      expiresAt: expiresAt,
      lastActivityAt: lastActivityAt,
      createdAt: createdAt,
    );
  }
}
