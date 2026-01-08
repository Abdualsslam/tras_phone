/// Auth Repository Implementation
library;

import 'package:dartz/dartz.dart';
import '../../../../core/constants/storage_keys.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _dataSource;
  final LocalStorage _localStorage;
  final SecureStorage _secureStorage;

  UserModel? _cachedUser;

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
      return token != null && token.isNotEmpty;
    } catch (_) {
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
      await _secureStorage.write(
        StorageKeys.accessToken,
        authResponse.accessToken,
      );
      await _secureStorage.write(
        StorageKeys.refreshToken,
        authResponse.refreshToken,
      );
      await _localStorage.setBool(StorageKeys.isLoggedIn, true);

      _cachedUser = authResponse.user;
      return Right(authResponse.user.toEntity());
    } catch (e) {
      return Left(AuthFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> register({
    required String phone,
    required String password,
    String? email,
  }) async {
    try {
      final authResponse = await _dataSource.register(
        phone: phone,
        password: password,
        email: email,
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

      _cachedUser = authResponse.user;
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
  Future<Either<Failure, void>> forgotPassword({required String phone}) async {
    try {
      await _dataSource.forgotPassword(phone: phone);
      return const Right(null);
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
      await _secureStorage.delete(StorageKeys.accessToken);
      await _secureStorage.delete(StorageKeys.refreshToken);
      await _localStorage.setBool(StorageKeys.isLoggedIn, false);
      _cachedUser = null;
      return const Right(null);
    } catch (e) {
      // Still clear local data even if server logout fails
      await _secureStorage.delete(StorageKeys.accessToken);
      await _secureStorage.delete(StorageKeys.refreshToken);
      await _localStorage.setBool(StorageKeys.isLoggedIn, false);
      _cachedUser = null;
      return const Right(null);
    }
  }

  @override
  UserEntity? getCachedUser() {
    return _cachedUser?.toEntity();
  }
}
