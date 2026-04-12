/// Auth Repository Implementation
library;

import 'dart:convert';
import 'dart:developer' as developer;

import 'package:dartz/dartz.dart';

import '../../../../core/constants/storage_keys.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../domain/entities/session_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/auth_response.dart';
import '../models/user_model.dart';

part 'auth_repository_impl_support.dart';
part 'auth_repository_impl_auth.dart';
part 'auth_repository_impl_sessions.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _dataSource;
  final LocalStorage _localStorage;
  final SecureStorage _secureStorage;
  late final _AuthRepositorySupport _support = _AuthRepositorySupport(
    dataSource: _dataSource,
    localStorage: _localStorage,
    secureStorage: _secureStorage,
  );
  late final _AuthRepositoryAuthDelegate _auth = _AuthRepositoryAuthDelegate(
    support: _support,
  );
  late final _AuthRepositorySessionsDelegate _sessions =
      _AuthRepositorySessionsDelegate(support: _support);

  AuthRepositoryImpl({
    required AuthRemoteDataSource dataSource,
    required LocalStorage localStorage,
    required SecureStorage secureStorage,
  }) : _dataSource = dataSource,
       _localStorage = localStorage,
       _secureStorage = secureStorage;

  @override
  Future<bool> isLoggedIn() => _support.isLoggedIn();

  @override
  Future<bool> isFirstLaunch() => _support.isFirstLaunch();

  @override
  Future<void> setFirstLaunchComplete() => _support.setFirstLaunchComplete();

  @override
  Future<Either<Failure, UserEntity>> login({
    required String phone,
    required String password,
  }) => _auth.login(phone: phone, password: password);

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
  }) => _auth.register(
    phone: phone,
    password: password,
    email: email,
    responsiblePersonName: responsiblePersonName,
    shopName: shopName,
    shopNameAr: shopNameAr,
    cityId: cityId,
    businessType: businessType,
  );

  @override
  Future<Either<Failure, void>> sendOtp({
    required String phone,
    required String purpose,
  }) => _auth.sendOtp(phone: phone, purpose: purpose);

  @override
  Future<Either<Failure, bool>> verifyOtp({
    required String phone,
    required String otp,
    required String purpose,
  }) => _auth.verifyOtp(phone: phone, otp: otp, purpose: purpose);

  @override
  Future<Either<Failure, String>> forgotPassword({
    required String phone,
    String? customerNotes,
  }) => _auth.forgotPassword(phone: phone, customerNotes: customerNotes);

  @override
  Future<Either<Failure, String>> verifyResetOtp({
    required String phone,
    required String otp,
  }) => _auth.verifyResetOtp(phone: phone, otp: otp);

  @override
  Future<Either<Failure, bool>> resetPassword({
    required String resetToken,
    required String newPassword,
  }) => _auth.resetPassword(resetToken: resetToken, newPassword: newPassword);

  @override
  Future<Either<Failure, UserEntity>> getProfile() => _auth.getProfile();

  @override
  Future<Either<Failure, bool>> changePassword({
    required String oldPassword,
    required String newPassword,
  }) =>
      _auth.changePassword(oldPassword: oldPassword, newPassword: newPassword);

  @override
  Future<Either<Failure, void>> logout() => _auth.logout();

  @override
  Future<({String phone, String password})?> getStoredBiometricCredentials() =>
      _support.getStoredBiometricCredentials();

  @override
  Future<void> saveBiometricCredentials({
    required String phone,
    required String password,
  }) => _support.saveBiometricCredentials(phone: phone, password: password);

  @override
  Future<void> clearBiometricCredentials() =>
      _support.clearBiometricCredentials();

  @override
  UserEntity? getCachedUser() => _support.getCachedUser();

  @override
  Future<Either<Failure, void>> updateFcmToken({
    required String fcmToken,
    Map<String, dynamic>? deviceInfo,
  }) => _sessions.updateFcmToken(fcmToken: fcmToken, deviceInfo: deviceInfo);

  @override
  Future<Either<Failure, List<SessionEntity>>> getSessions() =>
      _sessions.getSessions();

  @override
  Future<Either<Failure, void>> deleteSession(String sessionId) =>
      _sessions.deleteSession(sessionId);
}
