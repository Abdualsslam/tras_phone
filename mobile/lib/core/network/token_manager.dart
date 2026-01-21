/// Token Manager - Handles access and refresh token storage and retrieval
library;

import 'dart:convert';
import 'dart:developer' as developer;
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
    if (expiresAt == null) {
      // No expiration info - assume not expired
      return false;
    }
    final now = DateTime.now();
    final expired = now.isAfter(expiresAt!);
    return expired;
  }

  bool get willExpireSoon {
    if (expiresAt == null) {
      // No expiration info - assume it won't expire soon
      return false;
    }
    final threshold = DateTime.now().add(const Duration(minutes: 5));
    final expiringSoon = threshold.isAfter(expiresAt!);
    return expiringSoon;
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
    final accessToken = await _secureStorage.read(StorageKeys.accessToken);
    final refreshToken = await _secureStorage.read(StorageKeys.refreshToken);

    if (accessToken == null || refreshToken == null) {
      _cachedTokens = null;
      return null;
    }

    // If cached and still valid, return it
    if (_cachedTokens != null &&
        _cachedTokens!.accessToken == accessToken &&
        _cachedTokens!.expiresAt != null &&
        !_cachedTokens!.isExpired) {
      return _cachedTokens;
    }

    // Extract expiration from JWT
    DateTime? expiresAt;
    try {
      final parts = accessToken.split('.');
      if (parts.length == 3) {
        final payload = parts[1];
        // Add padding if needed
        String normalized = payload;
        switch (payload.length % 4) {
          case 1:
            normalized += '===';
            break;
          case 2:
            normalized += '==';
            break;
          case 3:
            normalized += '=';
            break;
        }
        final decoded = base64Url.decode(normalized);
        final json = jsonDecode(utf8.decode(decoded)) as Map<String, dynamic>;
        final exp = json['exp'] as int?;
        if (exp != null) {
          expiresAt = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
          developer.log(
            'Token expires at: $expiresAt (${expiresAt.difference(DateTime.now()).inMinutes} minutes from now)',
            name: 'TokenManager',
          );
        }
      }
    } catch (e) {
      developer.log(
        'Failed to decode JWT expiration: $e',
        name: 'TokenManager',
        error: e,
      );
      // Failed to decode - ignore and continue without expiration
    }

    _cachedTokens = TokenData(
      accessToken: accessToken,
      refreshToken: refreshToken,
      expiresAt: expiresAt,
    );
    return _cachedTokens;
  }

  /// Save tokens after login/refresh
  Future<void> saveTokens(TokenData tokens) async {
    // Clear old cache first
    _cachedTokens = null;
    
    await _secureStorage.write(StorageKeys.accessToken, tokens.accessToken);
    await _secureStorage.write(StorageKeys.refreshToken, tokens.refreshToken);
    
    // Set new cache
    _cachedTokens = tokens;
    
    developer.log(
      'Tokens cached with expiresAt: ${tokens.expiresAt}',
      name: 'TokenManager',
    );
  }

  /// Save tokens from API response
  Future<void> saveTokensFromResponse(Map<String, dynamic> response) async {
    final data = response['data'] ?? response;
    final accessToken = data['accessToken'] as String?;
    final refreshToken = data['refreshToken'] as String?;

    if (accessToken == null || refreshToken == null) {
      throw Exception('Invalid token response');
    }

    DateTime? expiresAt;
    final expiresInRaw = data['expiresIn'];
    if (expiresInRaw != null) {
      int? expiresInSeconds;
      if (expiresInRaw is int) {
        expiresInSeconds = expiresInRaw;
      } else if (expiresInRaw is String) {
        // Parse duration strings like '15m', '1h', '7d'
        expiresInSeconds = _parseDurationString(expiresInRaw);
      }
      if (expiresInSeconds != null) {
        expiresAt = DateTime.now().add(Duration(seconds: expiresInSeconds));
      }
    }

    developer.log(
      'Saving new tokens - accessToken: ${accessToken.substring(0, 20)}..., expiresAt from API: $expiresAt',
      name: 'TokenManager',
    );
    
    // Clear cache before saving new tokens
    _cachedTokens = null;
    
    await saveTokens(
      TokenData(
        accessToken: accessToken,
        refreshToken: refreshToken,
        expiresAt: expiresAt,
      ),
    );
    
    // Force re-read to extract JWT expiration if API didn't provide it
    if (expiresAt == null) {
      developer.log(
        'No expiresAt from API, extracting from JWT...',
        name: 'TokenManager',
      );
      final tokenData = await getTokenData();
      developer.log(
        'Extracted expiresAt from JWT: ${tokenData?.expiresAt}',
        name: 'TokenManager',
      );
    }
    
    developer.log('Tokens saved successfully', name: 'TokenManager');
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

  /// Parse duration string like '15m', '1h', '7d' to seconds
  static int? _parseDurationString(String duration) {
    final match = RegExp(r'^(\d+)([smhd])$').firstMatch(duration.trim());
    if (match == null) return null;
    
    final value = int.tryParse(match.group(1)!);
    if (value == null) return null;
    
    final unit = match.group(2)!;
    return switch (unit) {
      's' => value,
      'm' => value * 60,
      'h' => value * 3600,
      'd' => value * 86400,
      _ => null,
    };
  }
}
