/// Auth Mock DataSource - Provides mock data for authentication
library;

import '../models/customer_model.dart';

class AuthMockDataSource {
  // Simulated delay for network calls
  static const _delay = Duration(milliseconds: 800);

  // Mock user database
  static final Map<String, Map<String, dynamic>> _mockUsers = {
    '555123456': {
      'password': 'asdfasdf',
      'user': {
        'id': 1,
        'uuid': 'a1b2c3d4-e5f6-7890-abcd-ef1234567890',
        'phone': '555123456',
        'email': 'test@trasphone.com',
        'user_type': 'customer',
        'status': 'active',
        'avatar': null,
        'phone_verified_at': '2024-01-01T00:00:00Z',
        'email_verified_at': null,
        'language': 'ar',
        'created_at': '2024-01-01T00:00:00Z',
      },
      'customer': {
        'id': 1,
        'customer_code': 'CUST-001',
        'responsible_person_name': 'محمد أحمد',
        'shop_name': 'محل تراس للجوالات',
        'shop_name_ar': 'محل تراس للجوالات',
        'business_type': 'shop',
        'city_id': 1,
        'market_id': 1,
        'address': 'الرياض - حي الملز',
        'price_level_id': 1,
        'credit_limit': 10000.0,
        'credit_used': 2500.0,
        'wallet_balance': 500.0,
        'loyalty_points': 150,
        'loyalty_tier': 'silver',
        'total_orders': 25,
        'total_spent': 15000.0,
        'approved_at': '2024-01-02T00:00:00Z',
        'created_at': '2024-01-01T00:00:00Z',
      },
    },
  };

  // Current logged in user (cached)
  CustomerModel? _currentUser;

  /// Login with phone and password
  Future<CustomerModel> login({
    required String phone,
    required String password,
  }) async {
    await Future.delayed(_delay);

    final userData = _mockUsers[phone];
    if (userData == null) {
      throw Exception('رقم الجوال غير مسجل');
    }

    if (userData['password'] != password) {
      throw Exception('كلمة المرور غير صحيحة');
    }

    final userJson = userData['user'] as Map<String, dynamic>;
    final customerJson = {
      ...userData['customer'] as Map<String, dynamic>,
      'user': userJson,
    };

    _currentUser = CustomerModel.fromJson(customerJson);
    return _currentUser!;
  }

  /// Register new customer
  Future<CustomerModel> register({
    required String phone,
    required String password,
    required String responsiblePersonName,
    required String shopName,
    required int cityId,
  }) async {
    await Future.delayed(_delay);

    if (_mockUsers.containsKey(phone)) {
      throw Exception('رقم الجوال مسجل مسبقاً');
    }

    // Create new user
    final newId = _mockUsers.length + 1;
    final userJson = {
      'id': newId,
      'uuid': 'new-uuid-$newId',
      'phone': phone,
      'email': null,
      'user_type': 'customer',
      'status': 'pending',
      'avatar': null,
      'phone_verified_at': DateTime.now().toIso8601String(),
      'email_verified_at': null,
      'language': 'ar',
      'created_at': DateTime.now().toIso8601String(),
    };

    final customerJson = {
      'id': newId,
      'user': userJson,
      'customer_code': 'CUST-${newId.toString().padLeft(3, '0')}',
      'responsible_person_name': responsiblePersonName,
      'shop_name': shopName,
      'shop_name_ar': shopName,
      'business_type': 'shop',
      'city_id': cityId,
      'market_id': null,
      'address': null,
      'price_level_id': 1,
      'credit_limit': 0.0,
      'credit_used': 0.0,
      'wallet_balance': 0.0,
      'loyalty_points': 0,
      'loyalty_tier': 'bronze',
      'total_orders': 0,
      'total_spent': 0.0,
      'approved_at': null,
      'created_at': DateTime.now().toIso8601String(),
    };

    // Add to mock database
    _mockUsers[phone] = {
      'password': password,
      'user': userJson,
      'customer': customerJson,
    };

    _currentUser = CustomerModel.fromJson(customerJson);
    return _currentUser!;
  }

  /// Send OTP
  Future<bool> sendOtp({required String phone, required String purpose}) async {
    await Future.delayed(_delay);
    // In mock mode, always succeed
    // OTP is always "123456" for testing
    return true;
  }

  /// Verify OTP
  Future<bool> verifyOtp({
    required String phone,
    required String otp,
    required String purpose,
  }) async {
    await Future.delayed(_delay);
    // Accept "123456" as valid OTP for testing
    if (otp != '123456') {
      throw Exception('رمز التحقق غير صحيح');
    }
    return true;
  }

  /// Forgot password
  Future<bool> forgotPassword({required String phone}) async {
    await Future.delayed(_delay);
    if (!_mockUsers.containsKey(phone)) {
      throw Exception('رقم الجوال غير مسجل');
    }
    return true;
  }

  /// Reset password
  Future<bool> resetPassword({
    required String phone,
    required String otp,
    required String newPassword,
  }) async {
    await Future.delayed(_delay);

    if (otp != '123456') {
      throw Exception('رمز التحقق غير صحيح');
    }

    final userData = _mockUsers[phone];
    if (userData == null) {
      throw Exception('رقم الجوال غير مسجل');
    }

    userData['password'] = newPassword;
    return true;
  }

  /// Get current user
  Future<CustomerModel> getCurrentUser() async {
    await Future.delayed(const Duration(milliseconds: 300));

    if (_currentUser == null) {
      throw Exception('المستخدم غير مسجل الدخول');
    }
    return _currentUser!;
  }

  /// Update profile
  Future<CustomerModel> updateProfile({
    String? responsiblePersonName,
    String? shopName,
    String? email,
  }) async {
    await Future.delayed(_delay);

    if (_currentUser == null) {
      throw Exception('المستخدم غير مسجل الدخول');
    }

    // Update mock data
    final phone = _currentUser!.user.phone;
    final userData = _mockUsers[phone]!;

    if (responsiblePersonName != null) {
      (userData['customer']
              as Map<String, dynamic>)['responsible_person_name'] =
          responsiblePersonName;
    }
    if (shopName != null) {
      (userData['customer'] as Map<String, dynamic>)['shop_name'] = shopName;
      (userData['customer'] as Map<String, dynamic>)['shop_name_ar'] = shopName;
    }
    if (email != null) {
      (userData['user'] as Map<String, dynamic>)['email'] = email;
    }

    final customerJson = {
      ...userData['customer'] as Map<String, dynamic>,
      'user': userData['user'],
    };

    _currentUser = CustomerModel.fromJson(customerJson);
    return _currentUser!;
  }

  /// Change password
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await Future.delayed(_delay);

    if (_currentUser == null) {
      throw Exception('المستخدم غير مسجل الدخول');
    }

    final phone = _currentUser!.user.phone;
    final userData = _mockUsers[phone]!;

    if (userData['password'] != currentPassword) {
      throw Exception('كلمة المرور الحالية غير صحيحة');
    }

    userData['password'] = newPassword;
    return true;
  }

  /// Logout
  Future<bool> logout() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _currentUser = null;
    return true;
  }

  /// Get cached user
  CustomerModel? getCachedUser() => _currentUser;

  /// Set cached user (for restoring session)
  void setCachedUser(CustomerModel? user) {
    _currentUser = user;
  }
}
