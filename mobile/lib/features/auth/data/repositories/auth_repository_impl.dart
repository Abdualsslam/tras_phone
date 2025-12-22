/// Auth Repository Implementation
library;

import 'package:dartz/dartz.dart';
import '../../../../core/constants/storage_keys.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../domain/entities/customer_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_mock_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthMockDataSource _dataSource;
  final LocalStorage _localStorage;
  final SecureStorage _secureStorage;

  AuthRepositoryImpl({
    required AuthMockDataSource dataSource,
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
  Future<Either<Failure, CustomerEntity>> login({
    required String phone,
    required String password,
  }) async {
    try {
      final customer = await _dataSource.login(
        phone: phone,
        password: password,
      );

      // Save mock token
      await _secureStorage.write(
        StorageKeys.accessToken,
        'mock_token_${customer.id}',
      );
      await _localStorage.setBool(StorageKeys.isLoggedIn, true);

      return Right(customer.toEntity());
    } catch (e) {
      return Left(AuthFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, CustomerEntity>> register({
    required String phone,
    required String password,
    required String responsiblePersonName,
    required String shopName,
    required int cityId,
  }) async {
    try {
      final customer = await _dataSource.register(
        phone: phone,
        password: password,
        responsiblePersonName: responsiblePersonName,
        shopName: shopName,
        cityId: cityId,
      );

      // Save mock token
      await _secureStorage.write(
        StorageKeys.accessToken,
        'mock_token_${customer.id}',
      );
      await _localStorage.setBool(StorageKeys.isLoggedIn, true);

      return Right(customer.toEntity());
    } catch (e) {
      return Left(AuthFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> sendOtp({
    required String phone,
    required String purpose,
  }) async {
    try {
      final result = await _dataSource.sendOtp(phone: phone, purpose: purpose);
      return Right(result);
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
  Future<Either<Failure, bool>> forgotPassword({required String phone}) async {
    try {
      final result = await _dataSource.forgotPassword(phone: phone);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> resetPassword({
    required String phone,
    required String otp,
    required String newPassword,
  }) async {
    try {
      final result = await _dataSource.resetPassword(
        phone: phone,
        otp: otp,
        newPassword: newPassword,
      );
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, CustomerEntity>> getCurrentUser() async {
    try {
      final customer = await _dataSource.getCurrentUser();
      return Right(customer.toEntity());
    } catch (e) {
      return Left(AuthFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, CustomerEntity>> updateProfile({
    String? responsiblePersonName,
    String? shopName,
    String? email,
  }) async {
    try {
      final customer = await _dataSource.updateProfile(
        responsiblePersonName: responsiblePersonName,
        shopName: shopName,
        email: email,
      );
      return Right(customer.toEntity());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final result = await _dataSource.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      return Right(result);
    } catch (e) {
      return Left(ValidationFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> logout() async {
    try {
      await _dataSource.logout();
      await _secureStorage.delete(StorageKeys.accessToken);
      await _localStorage.setBool(StorageKeys.isLoggedIn, false);
      return const Right(true);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  CustomerEntity? getCachedUser() {
    return _dataSource.getCachedUser()?.toEntity();
  }
}
