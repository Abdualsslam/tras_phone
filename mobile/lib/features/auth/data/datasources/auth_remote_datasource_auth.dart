part of 'auth_remote_datasource.dart';

class _AuthRemoteAuthDelegate {
  final _AuthRemoteSupport _support;

  const _AuthRemoteAuthDelegate({required _AuthRemoteSupport support})
    : _support = support;

  Future<AuthResponse> login({
    required String phone,
    required String password,
  }) async {
    _support.log('Attempting login for phone: $phone');
    final formattedPhone = _support.formatPhone(phone);
    _support.log('Formatted phone for API: $formattedPhone');

    final response = await _support.apiClient.post(
      ApiEndpoints.login,
      data: {
        'phone': formattedPhone,
        'password': password,
        'deviceIntegrity': await _support.buildIntegrityPayload(
          requestType: 'auth.login',
        ),
      },
    );

    _support.log('Login successful');
    return AuthResponse.fromJson(_support.extractMap(response.data));
  }

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
    _support.log('Registering new user: $phone');
    if (cityId != null) {
      _support.log('CityId received: $cityId (type: ${cityId.runtimeType})');
    }

    final formattedPhone = _support.formatPhone(phone);

    try {
      final requestData = {
        'phone': formattedPhone,
        'password': password,
        'userType': 'customer',
        'deviceIntegrity': await _support.buildIntegrityPayload(
          requestType: 'auth.register',
        ),
        if (email != null) 'email': email,
        if (responsiblePersonName != null)
          'responsiblePersonName': responsiblePersonName,
        if (shopName != null) 'shopName': shopName,
        if (shopNameAr != null) 'shopNameAr': shopNameAr,
        if (cityId != null) 'cityId': cityId,
        if (businessType != null) 'businessType': businessType,
      };

      _support.log('Registration request data: $requestData');
      final response = await _support.apiClient.post(
        ApiEndpoints.register,
        data: requestData,
      );

      return AuthResponse.fromJson(_support.extractMap(response.data));
    } catch (error) {
      _support.rethrowRegistrationError(error);
    }
  }

  Future<void> sendOtp({required String phone, required String purpose}) async {
    _support.log('Sending OTP to: $phone for: $purpose');

    final response = await _support.apiClient.post(
      ApiEndpoints.sendOtp,
      data: {'phone': _support.formatPhone(phone), 'purpose': purpose},
    );

    _support.ensureSuccess(
      _support.extractMap(response.data),
      fallbackMessage: 'فشل إرسال OTP',
    );
  }

  Future<bool> verifyOtp({
    required String phone,
    required String otp,
    required String purpose,
  }) async {
    _support.log('Verifying OTP for: $phone');

    final response = await _support.apiClient.post(
      ApiEndpoints.verifyOtp,
      data: {
        'phone': _support.formatPhone(phone),
        'otp': otp,
        'purpose': purpose,
      },
    );

    return _support.extractMap(response.data)['success'] == true;
  }

  Future<String> forgotPassword({
    required String phone,
    String? customerNotes,
  }) async {
    _support.log('Requesting password reset for: $phone');

    final response = await _support.apiClient.post(
      ApiEndpoints.requestPasswordReset,
      data: {
        'phone': _support.formatPhone(phone),
        if (customerNotes != null) 'customerNotes': customerNotes,
      },
    );

    final body = _support.extractMap(response.data);
    _support.ensureSuccess(
      body,
      fallbackMessage: 'فشل تقديم طلب إعادة تعيين كلمة المرور',
    );

    return _support.extractMap(body['data'])['requestNumber']?.toString() ?? '';
  }

  Future<String> verifyResetOtp({
    required String phone,
    required String otp,
  }) async {
    _support.log('Verifying reset OTP for: $phone');

    final response = await _support.apiClient.post(
      ApiEndpoints.verifyResetOtp,
      data: {
        'phone': _support.formatPhone(phone),
        'otp': otp,
        'purpose': 'password_reset',
      },
    );

    final body = _support.extractMap(response.data);
    _support.ensureSuccess(body, fallbackMessage: 'رمز التحقق غير صحيح');
    return _support.extractMap(body['data'])['resetToken']?.toString() ?? '';
  }

  Future<bool> resetPassword({
    required String resetToken,
    required String newPassword,
  }) async {
    _support.log('Resetting password');

    final response = await _support.apiClient.post(
      ApiEndpoints.resetPassword,
      data: {'resetToken': resetToken, 'newPassword': newPassword},
    );

    return _support.extractMap(response.data)['success'] == true;
  }

  Future<UserModel> getProfile() async {
    _support.log('Fetching current user profile');
    final response = await _support.apiClient.get(ApiEndpoints.me);
    return UserModel.fromJson(
      _support.extractMap(_support.extractPayload(response.data)),
    );
  }

  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    _support.log('Changing password');

    final response = await _support.apiClient.patch(
      ApiEndpoints.changePassword,
      data: {'oldPassword': oldPassword, 'newPassword': newPassword},
    );

    return _support.extractMap(response.data)['success'] == true;
  }

  Future<TokenResponse> refreshToken({required String refreshToken}) async {
    _support.log('Refreshing token');

    final response = await _support.apiClient.post(
      ApiEndpoints.refreshToken,
      data: {'refreshToken': refreshToken},
    );

    return TokenResponse.fromJson(_support.extractMap(response.data));
  }

  Future<void> logout() async {
    _support.log('Logging out');

    try {
      await _support.apiClient.post(ApiEndpoints.logout);
    } catch (error) {
      _support.log('Logout API failed, proceeding locally: $error');
    }
  }
}
