import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tras_phone/core/network/token_manager.dart';
import 'package:tras_phone/core/storage/secure_storage.dart';
import 'package:tras_phone/core/constants/storage_keys.dart';

class MockSecureStorage extends Mock implements SecureStorage {}

void main() {
  late MockSecureStorage mockStorage;
  late TokenManager tokenManager;

  setUp(() {
    mockStorage = MockSecureStorage();
    tokenManager = TokenManager(secureStorage: mockStorage);
  });

  // ─── TokenData tests ───

  group('TokenData', () {
    group('isExpired', () {
      test('returns false when expiresAt is null', () {
        const data = TokenData(
          accessToken: 'access',
          refreshToken: 'refresh',
          expiresAt: null,
        );
        expect(data.isExpired, isFalse);
      });

      test('returns true when expiresAt is in the past', () {
        final data = TokenData(
          accessToken: 'access',
          refreshToken: 'refresh',
          expiresAt: DateTime.now().subtract(const Duration(hours: 1)),
        );
        expect(data.isExpired, isTrue);
      });

      test('returns false when expiresAt is in the future', () {
        final data = TokenData(
          accessToken: 'access',
          refreshToken: 'refresh',
          expiresAt: DateTime.now().add(const Duration(hours: 1)),
        );
        expect(data.isExpired, isFalse);
      });
    });

    group('willExpireSoon', () {
      test('returns false when expiresAt is null', () {
        const data = TokenData(
          accessToken: 'access',
          refreshToken: 'refresh',
          expiresAt: null,
        );
        expect(data.willExpireSoon, isFalse);
      });

      test('returns true when expiresAt is within 5 minutes', () {
        final data = TokenData(
          accessToken: 'access',
          refreshToken: 'refresh',
          expiresAt: DateTime.now().add(const Duration(minutes: 3)),
        );
        expect(data.willExpireSoon, isTrue);
      });

      test('returns false when expiresAt is more than 5 minutes away', () {
        final data = TokenData(
          accessToken: 'access',
          refreshToken: 'refresh',
          expiresAt: DateTime.now().add(const Duration(minutes: 10)),
        );
        expect(data.willExpireSoon, isFalse);
      });

      test('returns true when already expired', () {
        final data = TokenData(
          accessToken: 'access',
          refreshToken: 'refresh',
          expiresAt: DateTime.now().subtract(const Duration(minutes: 1)),
        );
        expect(data.willExpireSoon, isTrue);
      });
    });

    group('fromJson / toJson', () {
      test('round-trips correctly with expiresAt', () {
        final expiresAt = DateTime(2025, 6, 15, 12, 0, 0);
        final original = TokenData(
          accessToken: 'acc',
          refreshToken: 'ref',
          expiresAt: expiresAt,
        );
        final json = original.toJson();
        final restored = TokenData.fromJson(json);

        expect(restored.accessToken, 'acc');
        expect(restored.refreshToken, 'ref');
        expect(restored.expiresAt, expiresAt);
      });

      test('handles null expiresAt', () {
        const original = TokenData(
          accessToken: 'acc',
          refreshToken: 'ref',
        );
        final json = original.toJson();
        final restored = TokenData.fromJson(json);

        expect(restored.accessToken, 'acc');
        expect(restored.refreshToken, 'ref');
        expect(restored.expiresAt, isNull);
      });

      test('toJson produces correct keys', () {
        const data = TokenData(
          accessToken: 'a',
          refreshToken: 'r',
        );
        final json = data.toJson();
        expect(json['access_token'], 'a');
        expect(json['refresh_token'], 'r');
        expect(json.containsKey('expires_at'), isTrue);
      });
    });
  });

  // ─── TokenManager tests ───

  group('TokenManager', () {
    group('getAccessToken', () {
      test('returns token from storage when no cache', () async {
        when(() => mockStorage.read(StorageKeys.accessToken))
            .thenAnswer((_) async => 'stored-token');

        final token = await tokenManager.getAccessToken();
        expect(token, 'stored-token');
      });

      test('returns null when storage has no token', () async {
        when(() => mockStorage.read(StorageKeys.accessToken))
            .thenAnswer((_) async => null);

        final token = await tokenManager.getAccessToken();
        expect(token, isNull);
      });

      test('returns cached token after saveTokens', () async {
        when(() => mockStorage.write(any(), any()))
            .thenAnswer((_) async {});

        await tokenManager.saveTokens(const TokenData(
          accessToken: 'cached-access',
          refreshToken: 'cached-refresh',
        ));

        final token = await tokenManager.getAccessToken();
        expect(token, 'cached-access');
      });
    });

    group('getRefreshToken', () {
      test('returns token from storage when no cache', () async {
        when(() => mockStorage.read(StorageKeys.refreshToken))
            .thenAnswer((_) async => 'refresh-stored');

        final token = await tokenManager.getRefreshToken();
        expect(token, 'refresh-stored');
      });

      test('returns cached refresh token after saveTokens', () async {
        when(() => mockStorage.write(any(), any()))
            .thenAnswer((_) async {});

        await tokenManager.saveTokens(const TokenData(
          accessToken: 'a',
          refreshToken: 'cached-refresh',
        ));

        final token = await tokenManager.getRefreshToken();
        expect(token, 'cached-refresh');
      });
    });

    group('saveTokens', () {
      test('writes both tokens to secure storage', () async {
        when(() => mockStorage.write(any(), any()))
            .thenAnswer((_) async {});

        const tokens = TokenData(
          accessToken: 'new-access',
          refreshToken: 'new-refresh',
        );
        await tokenManager.saveTokens(tokens);

        verify(() => mockStorage.write(StorageKeys.accessToken, 'new-access'))
            .called(1);
        verify(
            () => mockStorage.write(StorageKeys.refreshToken, 'new-refresh'))
            .called(1);
      });
    });

    group('clearTokens', () {
      test('deletes tokens from storage and clears cache', () async {
        when(() => mockStorage.write(any(), any()))
            .thenAnswer((_) async {});
        when(() => mockStorage.delete(any()))
            .thenAnswer((_) async {});

        // First save tokens to populate cache
        await tokenManager.saveTokens(const TokenData(
          accessToken: 'a',
          refreshToken: 'r',
        ));

        await tokenManager.clearTokens();

        verify(() => mockStorage.delete(StorageKeys.accessToken)).called(1);
        verify(() => mockStorage.delete(StorageKeys.refreshToken)).called(1);

        // After clearing, getAccessToken should read from storage again
        when(() => mockStorage.read(StorageKeys.accessToken))
            .thenAnswer((_) async => null);
        final token = await tokenManager.getAccessToken();
        expect(token, isNull);
      });
    });

    group('hasValidTokens', () {
      test('returns true when access token exists', () async {
        when(() => mockStorage.read(StorageKeys.accessToken))
            .thenAnswer((_) async => 'valid-token');

        final result = await tokenManager.hasValidTokens();
        expect(result, isTrue);
      });

      test('returns false when access token is null', () async {
        when(() => mockStorage.read(StorageKeys.accessToken))
            .thenAnswer((_) async => null);

        final result = await tokenManager.hasValidTokens();
        expect(result, isFalse);
      });

      test('returns false when access token is empty', () async {
        when(() => mockStorage.read(StorageKeys.accessToken))
            .thenAnswer((_) async => '');

        final result = await tokenManager.hasValidTokens();
        expect(result, isFalse);
      });
    });

    group('needsRefresh', () {
      test('returns false when no tokens in storage', () async {
        when(() => mockStorage.read(StorageKeys.accessToken))
            .thenAnswer((_) async => null);
        when(() => mockStorage.read(StorageKeys.refreshToken))
            .thenAnswer((_) async => null);

        final result = await tokenManager.needsRefresh();
        expect(result, isFalse);
      });
    });
  });
}
