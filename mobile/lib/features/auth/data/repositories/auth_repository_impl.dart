/// Auth Repository Implementation
library;

import 'dart:convert';
import 'dart:developer' as developer;
import 'package:dartz/dartz.dart';
import '../../../../core/constants/storage_keys.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/entities/session_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _dataSource;
  final LocalStorage _localStorage;
  final SecureStorage _secureStorage;

  UserModel? _cachedUser;

  /// Save user to storage
  Future<void> _saveUserToStorage(UserModel user) async {
    _cachedUser = user;
    await _localStorage.setString(
      StorageKeys.userData,
      jsonEncode(user.toJson()),
    );
  }

  AuthRepositoryImpl({
    required AuthRemoteDataSource dataSource,
    required LocalStorage localStorage,
    required SecureStorage secureStorage,
  }) : _dataSource = dataSource,
       _localStorage = localStorage,
       _secureStorage = secureStorage;

  @override
  Future<bool> isLoggedIn() async {
    try {
      final token = await _secureStorage.read(StorageKeys.accessToken);
      developer.log(
        'isLoggedIn check - token exists: ${token != null && token.isNotEmpty}',
        name: 'AuthRepo',
      );
      if (token != null) {
        developer.log(
          'Token first 20 chars: ${token.substring(0, token.length > 20 ? 20 : token.length)}...',
          name: 'AuthRepo',
        );
      }
      return token != null && token.isNotEmpty;
    } catch (e) {
      developer.log('isLoggedIn error: $e', name: 'AuthRepo');
      return false;
    }
  }

  @override
  Future<bool> isFirstLaunch() async {
    try {
      return _localStorage.getBool(StorageKeys.isFirstLaunch) ?? true;
    } catch (_) {
      return true;
    }
  }

  @override
  Future<void> setFirstLaunchComplete() async {
    await _localStorage.setBool(StorageKeys.isFirstLaunch, false);
  }

  @override
  Future<Either<Failure, UserEntity>> login({
    required String phone,
    required String password,
  }) async {
    try {
      final authResponse = await _dataSource.login(
        phone: phone,
        password: password,
      );

      // Save tokens
      developer.log('Login: Saving accessToken...', name: 'AuthRepo');
      await _secureStorage.write(
        StorageKeys.accessToken,
        authResponse.accessToken,
      );
      await _secureStorage.write(
        StorageKeys.refreshToken,
        authResponse.refreshToken,
      );
      await _localStorage.setBool(StorageKeys.isLoggedIn, true);

      // Verify token was saved
      final savedToken = await _secureStorage.read(StorageKeys.accessToken);
      developer.log(
        'Login: Token saved verification: ${savedToken != null && savedToken.isNotEmpty}',
        name: 'AuthRepo',
      );

      // Save user data to storage for persistence
      await _saveUserToStorage(authResponse.user);
      return Right(authResponse.user.toEntity());
    } catch (e) {
      developer.log('Login error: $e', name: 'AuthRepo');
      return Left(AuthFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> register({
    required String phone,
    required String password,
    String? email,
    String? responsiblePersonName,
    String? shopName,
    String? shopNameAr,
    String? cityId,
    String? businessType,
  }) async {
    try {
      final authResponse = await _dataSource.register(
        phone: phone,
        password: password,
        email: email,
        responsiblePersonName: responsiblePersonName,
        shopName: shopName,
        shopNameAr: shopNameAr,
        cityId: cityId,
        businessType: businessType,
      );

      // Save tokens
      await _secureStorage.write(
        StorageKeys.accessToken,
        authResponse.accessToken,
      );
      await _secureStorage.write(
        StorageKeys.refreshToken,
        authResponse.refreshToken,
      );
      await _localStorage.setBool(StorageKeys.isLoggedIn, true);

      // Save user data to storage for persistence
      await _saveUserToStorage(authResponse.user);
      return Right(authResponse.user.toEntity());
    } catch (e) {
      return Left(AuthFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> sendOtp({
    required String phone,
    required String purpose,
  }) async {
    try {
      await _dataSource.sendOtp(phone: phone, purpose: purpose);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> verifyOtp({
    required String phone,
    required String otp,
    required String purpose,
  }) async {
    try {
      final result = await _dataSource.verifyOtp(
        phone: phone,
        otp: otp,
        purpose: purpose,
      );
      return Right(result);
    } catch (e) {
      return Left(ValidationFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> forgotPassword({
    required String phone,
    String? customerNotes,
  }) async {
    try {
      final requestNumber = await _dataSource.forgotPassword(
        phone: phone,
        customerNotes: customerNotes,
      );
      return Right(requestNumber);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> verifyResetOtp({
    required String phone,
    required String otp,
  }) async {
    try {
      final resetToken = await _dataSource.verifyResetOtp(
        phone: phone,
        otp: otp,
      );
      return Right(resetToken);
    } catch (e) {
      return Left(ValidationFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> resetPassword({
    required String resetToken,
    required String newPassword,
  }) async {
    try {
      final result = await _dataSource.resetPassword(
        resetToken: resetToken,
        newPassword: newPassword,
      );
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> getProfile() async {
    try {
      final user = await _dataSource.getProfile();
      _cachedUser = user;
      return Right(user.toEntity());
    } catch (e) {
      return Left(AuthFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final result = await _dataSource.changePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
      );
      return Right(result);
    } catch (e) {
      return Left(ValidationFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await _dataSource.logout();
      await _clearAllUserData();
      return const Right(null);
    } catch (e) {
      // Still clear local data even if server logout fails
      await _clearAllUserData();
      return const Right(null);
    }
  }

  Future<void> _clearAllUserData() async {
    await _secureStorage.delete(StorageKeys.accessToken);
    await _secureStorage.delete(StorageKeys.refreshToken);
    await _localStorage.setBool(StorageKeys.isLoggedIn, false);
    await _localStorage.remove(StorageKeys.userData);
    _cachedUser = null;
  }

  @override
  UserEntity? getCachedUser() {
    // Try to load from storage if not in memory
    if (_cachedUser == null) {
      final userData = _localStorage.getString(StorageKeys.userData);
      if (userData != null && userData.isNotEmpty) {
        try {
          final json = jsonDecode(userData) as Map<String, dynamic>;
          _cachedUser = UserModel.fromJson(json);
        } catch (_) {
          // Ignore parse errors
        }
      }
    }
    return _cachedUser?.toEntity();
  }

  @override
  Future<Either<Failure, void>> updateFcmToken({
    required String fcmToken,
    Map<String, dynamic>? deviceInfo,
  }) async {
    try {
      await _dataSource.updateFcmToken(
        fcmToken: fcmToken,
        deviceInfo: deviceInfo,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<SessionEntity>>> getSessions() async {
    try {
      final sessions = await _dataSource.getSessions();
      return Right(sessions.map((s) => s.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteSession(String sessionId) async {
    try {
      await _dataSource.deleteSession(sessionId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
