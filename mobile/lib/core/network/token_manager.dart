/// Token Manager - Handles access and refresh token storage and retrieval
library;

import '../constants/storage_keys.dart';
import '../storage/secure_storage.dart';

/// Token data model
class TokenData {
  final String accessToken;
  final String refreshToken;
  final DateTime? expiresAt;

  const TokenData({
    required this.accessToken,
    required this.refreshToken,
    this.expiresAt,
  });

  factory TokenData.fromJson(Map<String, dynamic> json) {
    return TokenData(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      expiresAt: json['expires_at'] != null
          ? DateTime.tryParse(json['expires_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'access_token': accessToken,
    'refresh_token': refreshToken,
    'expires_at': expiresAt?.toIso8601String(),
  };

  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  bool get willExpireSoon {
    if (expiresAt == null) return false;
    final threshold = DateTime.now().add(const Duration(minutes: 5));
    return threshold.isAfter(expiresAt!);
  }
}

/// Manages authentication tokens securely
class TokenManager {
  final SecureStorage _secureStorage;
  TokenData? _cachedTokens;

  TokenManager({required SecureStorage secureStorage})
    : _secureStorage = secureStorage;

  /// Get current access token
  Future<String?> getAccessToken() async {
    if (_cachedTokens != null) {
      return _cachedTokens!.accessToken;
    }
    return await _secureStorage.read(StorageKeys.accessToken);
  }

  /// Get current refresh token
  Future<String?> getRefreshToken() async {
    if (_cachedTokens != null) {
      return _cachedTokens!.refreshToken;
    }
    return await _secureStorage.read(StorageKeys.refreshToken);
  }

  /// Get full token data
  Future<TokenData?> getTokenData() async {
    if (_cachedTokens != null) {
      return _cachedTokens;
    }

    final accessToken = await _secureStorage.read(StorageKeys.accessToken);
    final refreshToken = await _secureStorage.read(StorageKeys.refreshToken);

    if (accessToken == null || refreshToken == null) {
      return null;
    }

    _cachedTokens = TokenData(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
    return _cachedTokens;
  }

  /// Save tokens after login/refresh
  Future<void> saveTokens(TokenData tokens) async {
    _cachedTokens = tokens;
    await _secureStorage.write(StorageKeys.accessToken, tokens.accessToken);
    await _secureStorage.write(StorageKeys.refreshToken, tokens.refreshToken);
  }

  /// Save tokens from API response
  Future<void> saveTokensFromResponse(Map<String, dynamic> response) async {
    final accessToken = response['access_token'] as String?;
    final refreshToken = response['refresh_token'] as String?;

    if (accessToken == null || refreshToken == null) {
      throw Exception('Invalid token response');
    }

    final expiresIn = response['expires_in'] as int?;
    DateTime? expiresAt;
    if (expiresIn != null) {
      expiresAt = DateTime.now().add(Duration(seconds: expiresIn));
    }

    await saveTokens(
      TokenData(
        accessToken: accessToken,
        refreshToken: refreshToken,
        expiresAt: expiresAt,
      ),
    );
  }

  /// Clear all tokens (logout)
  Future<void> clearTokens() async {
    _cachedTokens = null;
    await _secureStorage.delete(StorageKeys.accessToken);
    await _secureStorage.delete(StorageKeys.refreshToken);
  }

  /// Check if user has valid tokens
  Future<bool> hasValidTokens() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  /// Check if tokens need refresh
  Future<bool> needsRefresh() async {
    final tokens = await getTokenData();
    if (tokens == null) return false;
    return tokens.willExpireSoon;
  }
}
