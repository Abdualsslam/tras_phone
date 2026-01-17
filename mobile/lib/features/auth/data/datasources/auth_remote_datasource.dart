/// Auth Remote DataSource - Real API implementation
library;

import 'dart:developer' as developer;
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/user_model.dart';
import '../models/token_response.dart';

/// Response model for auth endpoints
class AuthResponse {
  final UserModel user;
  final String accessToken;
  final String refreshToken;
  final String expiresIn;

  const AuthResponse({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    // Handle nested data structure
    final data = json['data'] ?? json;

    return AuthResponse(
      user: UserModel.fromJson(data['user']),
      accessToken: data['accessToken'],
      refreshToken: data['refreshToken'],
      expiresIn: data['expiresIn'] ?? '15m',
    );
  }

  Map<String, dynamic> toTokenJson() => {
    'accessToken': accessToken,
    'refreshToken': refreshToken,
    'expiresIn': expiresIn,
  };
}

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

  /// Forgot password - send reset OTP
  Future<void> forgotPassword({required String phone});

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
  Future<void> forgotPassword({required String phone}) async {
    developer.log('Forgot password for: $phone', name: 'AuthDataSource');

    // Format phone to international format
    final formattedPhone = Formatters.phoneToInternational(phone);

    final response = await _apiClient.post(
      ApiEndpoints.forgotPassword,
      data: {'phone': formattedPhone},
    );

    if (response.data['success'] != true) {
      throw Exception(
        response.data['messageAr'] ??
            response.data['message'] ??
            'فشل إرسال رمز إعادة التعيين',
      );
    }
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
}
