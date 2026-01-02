/// Auth Remote DataSource - Real API implementation
library;

import 'dart:developer' as developer;
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../models/customer_model.dart';

/// Response model for auth endpoints
class AuthResponse {
  final CustomerModel customer;
  final String accessToken;
  final String refreshToken;
  final int? expiresIn;

  const AuthResponse({
    required this.customer,
    required this.accessToken,
    required this.refreshToken,
    this.expiresIn,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    // Handle nested data structure
    final data = json['data'] ?? json;

    return AuthResponse(
      customer: CustomerModel.fromJson(data['customer'] ?? data['user']),
      accessToken: data['access_token'] ?? json['access_token'],
      refreshToken: data['refresh_token'] ?? json['refresh_token'],
      expiresIn: data['expires_in'] ?? json['expires_in'],
    );
  }

  Map<String, dynamic> toTokenJson() => {
    'access_token': accessToken,
    'refresh_token': refreshToken,
    'expires_in': expiresIn,
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
    required String responsiblePersonName,
    required String shopName,
    required int cityId,
    int? marketId,
    String? commercialLicense,
  });

  /// Send OTP for verification
  Future<bool> sendOtp({required String phone, required String purpose});

  /// Verify OTP
  Future<bool> verifyOtp({
    required String phone,
    required String otp,
    required String purpose,
  });

  /// Forgot password - send reset OTP
  Future<bool> forgotPassword({required String phone});

  /// Reset password with OTP
  Future<bool> resetPassword({
    required String phone,
    required String otp,
    required String newPassword,
  });

  /// Get current user profile
  Future<CustomerModel> getCurrentUser();

  /// Update profile
  Future<CustomerModel> updateProfile({
    String? responsiblePersonName,
    String? shopName,
    String? email,
    String? address,
  });

  /// Change password
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  /// Refresh token
  Future<Map<String, dynamic>> refreshToken({required String refreshToken});

  /// Logout
  Future<bool> logout();

  /// Update FCM token
  Future<bool> updateFcmToken({required String fcmToken});
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

    final response = await _apiClient.post(
      ApiEndpoints.login,
      data: {'phone': phone, 'password': password},
    );

    return AuthResponse.fromJson(response.data);
  }

  @override
  Future<AuthResponse> register({
    required String phone,
    required String password,
    required String responsiblePersonName,
    required String shopName,
    required int cityId,
    int? marketId,
    String? commercialLicense,
  }) async {
    developer.log('Registering new user: $phone', name: 'AuthDataSource');

    final response = await _apiClient.post(
      ApiEndpoints.register,
      data: {
        'phone': phone,
        'password': password,
        'password_confirmation': password,
        'responsible_person_name': responsiblePersonName,
        'shop_name': shopName,
        'city_id': cityId,
        if (marketId != null) 'market_id': marketId,
        if (commercialLicense != null) 'commercial_license': commercialLicense,
      },
    );

    return AuthResponse.fromJson(response.data);
  }

  @override
  Future<bool> sendOtp({required String phone, required String purpose}) async {
    developer.log(
      'Sending OTP to: $phone for: $purpose',
      name: 'AuthDataSource',
    );

    final response = await _apiClient.post(
      ApiEndpoints.sendOtp,
      data: {'phone': phone, 'purpose': purpose},
    );

    return response.statusCode == 200;
  }

  @override
  Future<bool> verifyOtp({
    required String phone,
    required String otp,
    required String purpose,
  }) async {
    developer.log('Verifying OTP for: $phone', name: 'AuthDataSource');

    final response = await _apiClient.post(
      ApiEndpoints.verifyOtp,
      data: {'phone': phone, 'otp': otp, 'purpose': purpose},
    );

    return response.statusCode == 200;
  }

  @override
  Future<bool> forgotPassword({required String phone}) async {
    developer.log('Forgot password for: $phone', name: 'AuthDataSource');

    final response = await _apiClient.post(
      ApiEndpoints.forgotPassword,
      data: {'phone': phone},
    );

    return response.statusCode == 200;
  }

  @override
  Future<bool> resetPassword({
    required String phone,
    required String otp,
    required String newPassword,
  }) async {
    developer.log('Resetting password for: $phone', name: 'AuthDataSource');

    final response = await _apiClient.post(
      ApiEndpoints.resetPassword,
      data: {
        'phone': phone,
        'otp': otp,
        'password': newPassword,
        'password_confirmation': newPassword,
      },
    );

    return response.statusCode == 200;
  }

  @override
  Future<CustomerModel> getCurrentUser() async {
    developer.log('Fetching current user', name: 'AuthDataSource');

    final response = await _apiClient.get(ApiEndpoints.me);
    final data = response.data['data'] ?? response.data;

    return CustomerModel.fromJson(data);
  }

  @override
  Future<CustomerModel> updateProfile({
    String? responsiblePersonName,
    String? shopName,
    String? email,
    String? address,
  }) async {
    developer.log('Updating profile', name: 'AuthDataSource');

    final response = await _apiClient.put(
      ApiEndpoints.profile,
      data: {
        if (responsiblePersonName != null)
          'responsible_person_name': responsiblePersonName,
        if (shopName != null) 'shop_name': shopName,
        if (email != null) 'email': email,
        if (address != null) 'address': address,
      },
    );

    final data = response.data['data'] ?? response.data;
    return CustomerModel.fromJson(data);
  }

  @override
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    developer.log('Changing password', name: 'AuthDataSource');

    final response = await _apiClient.put(
      ApiEndpoints.changePassword,
      data: {
        'current_password': currentPassword,
        'password': newPassword,
        'password_confirmation': newPassword,
      },
    );

    return response.statusCode == 200;
  }

  @override
  Future<Map<String, dynamic>> refreshToken({
    required String refreshToken,
  }) async {
    developer.log('Refreshing token', name: 'AuthDataSource');

    final response = await _apiClient.post(
      ApiEndpoints.refreshToken,
      data: {'refresh_token': refreshToken},
    );

    return response.data;
  }

  @override
  Future<bool> logout() async {
    developer.log('Logging out', name: 'AuthDataSource');

    try {
      final response = await _apiClient.post(ApiEndpoints.logout);
      return response.statusCode == 200;
    } catch (e) {
      // Even if logout fails on server, we consider it successful locally
      developer.log(
        'Logout API failed, proceeding locally',
        name: 'AuthDataSource',
      );
      return true;
    }
  }

  @override
  Future<bool> updateFcmToken({required String fcmToken}) async {
    developer.log('Updating FCM token', name: 'AuthDataSource');

    final response = await _apiClient.post(
      ApiEndpoints.fcmToken,
      data: {'fcm_token': fcmToken},
    );

    return response.statusCode == 200;
  }
}
