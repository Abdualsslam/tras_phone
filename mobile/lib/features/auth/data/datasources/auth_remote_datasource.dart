/// Auth Remote DataSource - Real API implementation
library;

import 'dart:developer' as developer;
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/user_model.dart';
import '../models/token_response.dart';
import '../models/auth_response.dart';
import '../models/session_model.dart';

/// Abstract interface for auth data source
abstract class AuthRemoteDataSource {
  /// Login with phone and password
  Future<AuthResponse> login({required String phone, required String password});

  /// Register new customer
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

  /// Send OTP for verification
  Future<void> sendOtp({required String phone, required String purpose});

  /// Verify OTP
  Future<bool> verifyOtp({
    required String phone,
    required String otp,
    required String purpose,
  });

  /// Forgot password - request password reset
  Future<String> forgotPassword({
    required String phone,
    String? customerNotes,
  });

  /// Verify OTP for password reset - returns resetToken
  Future<String> verifyResetOtp({required String phone, required String otp});

  /// Reset password with resetToken
  Future<bool> resetPassword({
    required String resetToken,
    required String newPassword,
  });

  /// Get current user profile
  Future<UserModel> getProfile();

  /// Change password
  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
  });

  /// Refresh token
  Future<TokenResponse> refreshToken({required String refreshToken});

  /// Logout
  Future<void> logout();

  /// Update FCM token
  Future<void> updateFcmToken({
    required String fcmToken,
    Map<String, dynamic>? deviceInfo,
  });

  /// Get all active sessions
  Future<List<SessionModel>> getSessions();

  /// Delete a specific session
  Future<void> deleteSession(String sessionId);
}

/// Implementation of AuthRemoteDataSource using API client
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient _apiClient;

  AuthRemoteDataSourceImpl({required ApiClient apiClient})
    : _apiClient = apiClient;

  @override
  Future<AuthResponse> login({
    required String phone,
    required String password,
  }) async {
    developer.log('Attempting login for phone: $phone', name: 'AuthDataSource');

    // Format phone to international format (+966)
    final formattedPhone = Formatters.phoneToInternational(phone);
    developer.log('Formatted phone for API: $formattedPhone', name: 'AuthDataSource');

    final response = await _apiClient.post(
      ApiEndpoints.login,
      data: {'phone': formattedPhone, 'password': password},
    );

    final authResponse = AuthResponse.fromJson(response.data);
    developer.log('Login successful', name: 'AuthDataSource');
    return authResponse;
  }

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
  }) async {
    developer.log('Registering new user: $phone', name: 'AuthDataSource');
    if (cityId != null) {
      developer.log('CityId received: $cityId (type: ${cityId.runtimeType})', name: 'AuthDataSource');
    }

    // Format phone to international format
    final formattedPhone = Formatters.phoneToInternational(phone);

    try {
      final requestData = {
        'phone': formattedPhone,
        'password': password,
        'userType': 'customer', // Always customer for mobile app
        if (email != null) 'email': email,
        if (responsiblePersonName != null)
          'responsiblePersonName': responsiblePersonName,
        if (shopName != null) 'shopName': shopName,
        if (shopNameAr != null) 'shopNameAr': shopNameAr,
        if (cityId != null) 'cityId': cityId,
        if (businessType != null) 'businessType': businessType,
      };
      developer.log('Registration request data: $requestData', name: 'AuthDataSource');
      
      final response = await _apiClient.post(
        ApiEndpoints.register,
        data: requestData,
      );

      return AuthResponse.fromJson(response.data);
    } on ServerException catch (e) {
      // Extract error message from API response
      developer.log('Registration failed: ${e.message}', name: 'AuthDataSource');
      throw Exception(e.message);
    } catch (e) {
      developer.log('Registration error: $e', name: 'AuthDataSource', error: e);
      rethrow;
    }
  }

  @override
  Future<void> sendOtp({required String phone, required String purpose}) async {
    developer.log(
      'Sending OTP to: $phone for: $purpose',
      name: 'AuthDataSource',
    );

    // Format phone to international format
    final formattedPhone = Formatters.phoneToInternational(phone);

    final response = await _apiClient.post(
      ApiEndpoints.sendOtp,
      data: {'phone': formattedPhone, 'purpose': purpose},
    );

    if (response.data['success'] != true) {
      throw Exception(
        response.data['messageAr'] ??
            response.data['message'] ??
            'فشل إرسال OTP',
      );
    }
  }

  @override
  Future<bool> verifyOtp({
    required String phone,
    required String otp,
    required String purpose,
  }) async {
    developer.log('Verifying OTP for: $phone', name: 'AuthDataSource');

    // Format phone to international format
    final formattedPhone = Formatters.phoneToInternational(phone);

    final response = await _apiClient.post(
      ApiEndpoints.verifyOtp,
      data: {'phone': formattedPhone, 'otp': otp, 'purpose': purpose},
    );

    return response.data['success'] == true;
  }

  @override
  Future<String> forgotPassword({
    required String phone,
    String? customerNotes,
  }) async {
    developer.log('Requesting password reset for: $phone', name: 'AuthDataSource');

    // Format phone to international format
    final formattedPhone = Formatters.phoneToInternational(phone);

    final response = await _apiClient.post(
      ApiEndpoints.requestPasswordReset,
      data: {
        'phone': formattedPhone,
        if (customerNotes != null) 'customerNotes': customerNotes,
      },
    );

    if (response.data['success'] != true) {
      throw Exception(
        response.data['messageAr'] ??
            response.data['message'] ??
            'فشل تقديم طلب إعادة تعيين كلمة المرور',
      );
    }

    // Return request number
    return response.data['data']['requestNumber'] ?? '';
  }

  @override
  Future<String> verifyResetOtp({
    required String phone,
    required String otp,
  }) async {
    developer.log('Verifying reset OTP for: $phone', name: 'AuthDataSource');

    // Format phone to international format
    final formattedPhone = Formatters.phoneToInternational(phone);

    final response = await _apiClient.post(
      ApiEndpoints.verifyResetOtp,
      data: {'phone': formattedPhone, 'otp': otp, 'purpose': 'password_reset'},
    );

    if (response.data['success'] != true) {
      throw Exception(
        response.data['messageAr'] ??
            response.data['message'] ??
            'رمز التحقق غير صحيح',
      );
    }

    return response.data['data']['resetToken'];
  }

  @override
  Future<bool> resetPassword({
    required String resetToken,
    required String newPassword,
  }) async {
    developer.log('Resetting password', name: 'AuthDataSource');

    final response = await _apiClient.post(
      ApiEndpoints.resetPassword,
      data: {'resetToken': resetToken, 'newPassword': newPassword},
    );

    return response.data['success'] == true;
  }

  @override
  Future<UserModel> getProfile() async {
    developer.log('Fetching current user profile', name: 'AuthDataSource');

    final response = await _apiClient.get(ApiEndpoints.me);
    final data = response.data['data'] ?? response.data;

    return UserModel.fromJson(data);
  }

  @override
  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    developer.log('Changing password', name: 'AuthDataSource');

    final response = await _apiClient.patch(
      ApiEndpoints.changePassword,
      data: {'oldPassword': oldPassword, 'newPassword': newPassword},
    );

    return response.data['success'] == true;
  }

  @override
  Future<TokenResponse> refreshToken({required String refreshToken}) async {
    developer.log('Refreshing token', name: 'AuthDataSource');

    final response = await _apiClient.post(
      ApiEndpoints.refreshToken,
      data: {'refreshToken': refreshToken},
    );

    return TokenResponse.fromJson(response.data);
  }

  @override
  Future<void> logout() async {
    developer.log('Logging out', name: 'AuthDataSource');

    try {
      await _apiClient.post(ApiEndpoints.logout);
    } catch (e) {
      // Even if logout fails on server, we consider it successful locally
      developer.log(
        'Logout API failed, proceeding locally: $e',
        name: 'AuthDataSource',
      );
    }
  }

  @override
  Future<void> updateFcmToken({
    required String fcmToken,
    Map<String, dynamic>? deviceInfo,
  }) async {
    developer.log('Updating FCM token', name: 'AuthDataSource');

    final response = await _apiClient.post(
      ApiEndpoints.fcmToken,
      data: {
        'fcmToken': fcmToken,
        if (deviceInfo != null) 'deviceInfo': deviceInfo,
      },
    );

    if (response.data['success'] != true) {
      throw Exception(
        response.data['messageAr'] ??
            response.data['message'] ??
            'فشل تحديث رمز الإشعارات',
      );
    }
  }

  @override
  Future<List<SessionModel>> getSessions() async {
    developer.log('Fetching active sessions', name: 'AuthDataSource');

    final response = await _apiClient.get(ApiEndpoints.sessions);
    final data = response.data['data'] ?? [];

    if (data is List) {
      return data
          .map((json) => SessionModel.fromJson(json as Map<String, dynamic>))
          .toList();
    }

    return [];
  }

  @override
  Future<void> deleteSession(String sessionId) async {
    developer.log('Deleting session: $sessionId', name: 'AuthDataSource');

    final response = await _apiClient.delete(
      ApiEndpoints.deleteSession(sessionId),
    );

    if (response.data['success'] != true) {
      throw Exception(
        response.data['messageAr'] ??
            response.data['message'] ??
            'فشل حذف الجلسة',
      );
    }
  }
}
