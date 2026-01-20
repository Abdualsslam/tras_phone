/// Session Entity - Domain layer entity for user sessions
library;

import 'package:equatable/equatable.dart';

class SessionEntity extends Equatable {
  final String id;
  final String userId;
  final String tokenId;
  final String ipAddress;
  final String userAgent;
  final DateTime expiresAt;
  final DateTime lastActivityAt;
  final DateTime createdAt;

  const SessionEntity({
    required this.id,
    required this.userId,
    required this.tokenId,
    required this.ipAddress,
    required this.userAgent,
    required this.expiresAt,
    required this.lastActivityAt,
    required this.createdAt,
  });

  @override
  List<Object> get props => [
        id,
        userId,
        tokenId,
        ipAddress,
        userAgent,
        expiresAt,
        lastActivityAt,
        createdAt,
      ];

  /// Check if session is expired
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  /// Check if session is active
  bool get isActive => !isExpired;
}
