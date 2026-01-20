/// Auth Response Model - Response model for auth endpoints
library;

import 'user_model.dart';

/// Response model for authentication endpoints (login, register)
class AuthResponse {
  final UserModel user;
  final String accessToken;
  final String refreshToken;
  final String expiresIn;
  final String? sessionId; // موجود في login فقط

  const AuthResponse({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
    this.sessionId,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    // Handle nested data structure
    final data = json['data'] ?? json;

    return AuthResponse(
      user: UserModel.fromJson(data['user']),
      accessToken: data['accessToken'],
      refreshToken: data['refreshToken'],
      expiresIn: data['expiresIn'] ?? '15m',
      sessionId: data['sessionId'],
    );
  }

  Map<String, dynamic> toTokenJson() => {
    'accessToken': accessToken,
    'refreshToken': refreshToken,
    'expiresIn': expiresIn,
  };
}
