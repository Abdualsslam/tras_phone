/// Auth Remote DataSource - Real API implementation
library;

import 'dart:developer' as developer;

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/security/app_security_service.dart';
import '../../../../core/utils/formatters.dart';
import '../models/auth_response.dart';
import '../models/session_model.dart';
import '../models/token_response.dart';
import '../models/user_model.dart';

part 'auth_remote_datasource_support.dart';
part 'auth_remote_datasource_auth.dart';
part 'auth_remote_datasource_sessions.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponse> login({required String phone, required String password});

  Future<AuthResponse> register({
    required String phone,
    required String password,
    String? email,
    String? responsiblePersonName,
    String? shopName,
    String? shopNameAr,
    String? cityId,
    String? businessType,
  });

  Future<void> sendOtp({required String phone, required String purpose});

  Future<bool> verifyOtp({
    required String phone,
    required String otp,
    required String purpose,
  });

  Future<String> forgotPassword({required String phone, String? customerNotes});

  Future<String> verifyResetOtp({required String phone, required String otp});

  Future<bool> resetPassword({
    required String resetToken,
    required String newPassword,
  });

  Future<UserModel> getProfile();

  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
  });

  Future<TokenResponse> refreshToken({required String refreshToken});

  Future<void> logout();

  Future<void> updateFcmToken({
    required String fcmToken,
    Map<String, dynamic>? deviceInfo,
  });

  Future<List<SessionModel>> getSessions();

  Future<void> deleteSession(String sessionId);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient _apiClient;
  final AppSecurityService _appSecurityService;
  late final _AuthRemoteSupport _support = _AuthRemoteSupport(
    apiClient: _apiClient,
    appSecurityService: _appSecurityService,
  );
  late final _AuthRemoteAuthDelegate _auth = _AuthRemoteAuthDelegate(
    support: _support,
  );
  late final _AuthRemoteSessionsDelegate _sessions =
      _AuthRemoteSessionsDelegate(support: _support);

  AuthRemoteDataSourceImpl({
    required ApiClient apiClient,
    required AppSecurityService appSecurityService,
  }) : _apiClient = apiClient,
       _appSecurityService = appSecurityService;

  @override
  Future<AuthResponse> login({
    required String phone,
    required String password,
  }) => _auth.login(phone: phone, password: password);

  @override
  Future<AuthResponse> register({
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
  Future<void> sendOtp({required String phone, required String purpose}) =>
      _auth.sendOtp(phone: phone, purpose: purpose);

  @override
  Future<bool> verifyOtp({
    required String phone,
    required String otp,
    required String purpose,
  }) => _auth.verifyOtp(phone: phone, otp: otp, purpose: purpose);

  @override
  Future<String> forgotPassword({
    required String phone,
    String? customerNotes,
  }) => _auth.forgotPassword(phone: phone, customerNotes: customerNotes);

  @override
  Future<String> verifyResetOtp({required String phone, required String otp}) =>
      _auth.verifyResetOtp(phone: phone, otp: otp);

  @override
  Future<bool> resetPassword({
    required String resetToken,
    required String newPassword,
  }) => _auth.resetPassword(resetToken: resetToken, newPassword: newPassword);

  @override
  Future<UserModel> getProfile() => _auth.getProfile();

  @override
  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
  }) =>
      _auth.changePassword(oldPassword: oldPassword, newPassword: newPassword);

  @override
  Future<TokenResponse> refreshToken({required String refreshToken}) =>
      _auth.refreshToken(refreshToken: refreshToken);

  @override
  Future<void> logout() => _auth.logout();

  @override
  Future<void> updateFcmToken({
    required String fcmToken,
    Map<String, dynamic>? deviceInfo,
  }) => _sessions.updateFcmToken(fcmToken: fcmToken, deviceInfo: deviceInfo);

  @override
  Future<List<SessionModel>> getSessions() => _sessions.getSessions();

  @override
  Future<void> deleteSession(String sessionId) =>
      _sessions.deleteSession(sessionId);
}
