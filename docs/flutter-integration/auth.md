# 🔐 Auth Module - دليل ربط المصادقة

## 📋 نظرة عامة

هذا الموديول يتعامل مع:
- ✅ تسجيل مستخدم جديد
- ✅ تسجيل الدخول
- ✅ تحديث الـ Token
- ✅ إرسال OTP والتحقق منه
- ✅ نسيت كلمة المرور
- ✅ تغيير كلمة المرور
- ✅ جلب الملف الشخصي
- ✅ تسجيل الخروج

---

## 📁 Flutter Models

### User Model

```dart
class User {
  final String id;
  final String phone;
  final String? email;
  final String userType; // 'customer' | 'admin'
  final String status; // 'pending' | 'active' | 'suspended' | 'deleted'
  final String? referralCode;
  final DateTime? lastLoginAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.phone,
    this.email,
    required this.userType,
    required this.status,
    this.referralCode,
    this.lastLoginAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? json['id'],
      phone: json['phone'],
      email: json['email'],
      userType: json['userType'],
      status: json['status'],
      referralCode: json['referralCode'],
      lastLoginAt: json['lastLoginAt'] != null 
          ? DateTime.parse(json['lastLoginAt']) 
          : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}
```

### Auth Response Model

```dart
class AuthResponse {
  final User user;
  final String accessToken;
  final String refreshToken;
  final String expiresIn;
  final String? sessionId;  // موجود في login فقط

  AuthResponse({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
    this.sessionId,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      user: User.fromJson(json['user']),
      accessToken: json['accessToken'],
      refreshToken: json['refreshToken'],
      expiresIn: json['expiresIn'],
      sessionId: json['sessionId'],
    );
  }
}
```

### Token Response Model

```dart
class TokenResponse {
  final String accessToken;
  final String refreshToken;
  final String expiresIn;

  TokenResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
  });

  factory TokenResponse.fromJson(Map<String, dynamic> json) {
    return TokenResponse(
      accessToken: json['accessToken'],
      refreshToken: json['refreshToken'],
      expiresIn: json['expiresIn'],
    );
  }
}
```

---

## 📞 API Endpoints

### 1️⃣ تسجيل مستخدم جديد (Register)

**Endpoint:** `POST /auth/register`

**Request Body:**
```dart
{
  "phone": "+966501234567",      // مطلوب - رقم الهاتف بالصيغة الدولية
  "email": "user@example.com",  // اختياري
  "password": "StrongP@ss123",  // مطلوب - 8 أحرف على الأقل
  "userType": "customer"        // مطلوب - 'customer' للتطبيق
}
```

> ⚠️ **شروط كلمة المرور:**
> - 8 أحرف على الأقل
> - حرف كبير واحد على الأقل
> - حرف صغير واحد على الأقل
> - رقم واحد على الأقل
> - رمز خاص واحد على الأقل (@$!%*?&)

**Response (201 Created):**
```dart
{
  "success": true,
  "data": {
    "user": { /* User object */ },
    "accessToken": "eyJhbGciOiJIUzI1NiIs...",
    "refreshToken": "eyJhbGciOiJIUzI1NiIs...",
    "expiresIn": "15m"  // أو "7d" حسب إعدادات JWT_EXPIRATION
  },
  "message": "User registered successfully",
  "messageAr": "تم تسجيل المستخدم بنجاح"
}
```

> 📝 **ملاحظة:** يمكن إرسال بيانات ملف العميل الاختيارية عند التسجيل:
> - `responsiblePersonName`: اسم الشخص المسؤول
> - `shopName`: اسم المتجر
> - `shopNameAr`: اسم المتجر بالعربية
> - `cityId`: معرف المدينة (MongoDB ObjectId)
> - `businessType`: نوع العمل ('shop' | 'technician' | 'distributor' | 'other')

**Flutter Code:**
```dart
class AuthService {
  final Dio _dio;
  
  AuthService(this._dio);
  
  Future<AuthResponse> register({
    required String phone,
    required String password,
    String? email,
  }) async {
    try {
      final response = await _dio.post('/auth/register', data: {
        'phone': phone,
        'password': password,
        'userType': 'customer', // دائماً customer للتطبيق
        if (email != null) 'email': email,
      });
      
      if (response.data['success']) {
        return AuthResponse.fromJson(response.data['data']);
      }
      throw Exception(response.data['messageAr'] ?? response.data['message']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
}
```

**Errors المحتملة:**
| Status | Message | السبب |
|--------|---------|-------|
| 409 | User with this phone or email already exists | المستخدم مسجل مسبقاً |
| 400 | Phone number must be a valid international format | تنسيق الهاتف خاطئ (يجب أن يكون بصيغة دولية مثل +966501234567) |
| 400 | Password must contain at least one uppercase letter, one lowercase letter, one number and one special character | كلمة المرور ضعيفة (يجب أن تحتوي على حرف كبير وصغير ورقم ورمز خاص) |
| 400 | Password must be at least 8 characters | كلمة المرور قصيرة (أقل من 8 أحرف) |
| 400 | Default price level not found. Please contact support. | لم يتم العثور على مستوى السعر الافتراضي (عند إنشاء ملف عميل) |

---

### 2️⃣ تسجيل الدخول (Login)

**Endpoint:** `POST /auth/login`

**Request Body:**
```dart
{
  "phone": "+966501234567",
  "password": "StrongP@ss123"
}
```

**Response (200 OK):**
```dart
{
  "success": true,
  "data": {
    "user": { /* User object */ },
    "accessToken": "eyJhbGciOiJIUzI1NiIs...",
    "refreshToken": "eyJhbGciOiJIUzI1NiIs...",
    "expiresIn": "15m",  // أو "7d" حسب إعدادات JWT_EXPIRATION
    "sessionId": "507f1f77bcf86cd799439011"  // معرف الجلسة
  },
  "message": "Login successful",
  "messageAr": "تم تسجيل الدخول بنجاح"
}
```

**Flutter Code:**
```dart
Future<AuthResponse> login({
  required String phone,
  required String password,
}) async {
  try {
    final response = await _dio.post('/auth/login', data: {
      'phone': phone,
      'password': password,
    });
    
    if (response.data['success']) {
      final authResponse = AuthResponse.fromJson(response.data['data']);
      // حفظ الـ tokens والـ sessionId
      await _saveTokens(
        authResponse.accessToken, 
        authResponse.refreshToken,
        sessionId: authResponse.sessionId,
      );
      return authResponse;
    }
    throw Exception(response.data['messageAr'] ?? response.data['message']);
  } on DioException catch (e) {
    throw _handleError(e);
  }
}
```

**Errors المحتملة:**
| Status | Message | السبب |
|--------|---------|-------|
| 401 | Invalid credentials | بيانات خاطئة |
| 401 | Your account has been suspended | الحساب معلق |
| 401 | Your account has been deleted | الحساب محذوف |
| 401 | Your account is under review. Please wait for activation | الحساب قيد المراجعة (pending) |
| 401 | Your account is not active. Please verify your account or contact support | الحساب غير نشط |
| 401 | Account is locked. Try again in X minutes | تم قفل الحساب (5 محاولات فاشلة لمدة 30 دقيقة) |

---

### 3️⃣ تحديث الـ Token (Refresh)

**Endpoint:** `POST /auth/refresh`

**Request Body:**
```dart
{
  "refreshToken": "eyJhbGciOiJIUzI1NiIs..."
}
```

**Response (200 OK):**
```dart
{
  "success": true,
  "data": {
    "accessToken": "eyJhbGciOiJIUzI1NiIs...",
    "refreshToken": "eyJhbGciOiJIUzI1NiIs...",
    "expiresIn": "15m"  // أو "7d" حسب إعدادات JWT_EXPIRATION
  },
  "message": "Token refreshed successfully",
  "messageAr": "تم تحديث الرمز بنجاح"
}
```

> ⚠️ **ملاحظة:** عند تحديث الـ token، يتم التحقق من أن الحساب نشط (active) قبل إصدار tokens جديدة.

**Flutter Code:**
```dart
Future<TokenResponse> refreshToken(String refreshToken) async {
  try {
    final response = await _dio.post('/auth/refresh', data: {
      'refreshToken': refreshToken,
    });
    
    if (response.data['success']) {
      final tokenResponse = TokenResponse.fromJson(response.data['data']);
      await _saveTokens(tokenResponse.accessToken, tokenResponse.refreshToken);
      return tokenResponse;
    }
    throw Exception(response.data['messageAr'] ?? response.data['message']);
  } on DioException catch (e) {
    throw _handleError(e);
  }
}
```

---

### 4️⃣ إرسال OTP (Send OTP)

**Endpoint:** `POST /auth/send-otp`

**Request Body:**
```dart
{
  "phone": "+966501234567",
  "purpose": "registration"  // 'registration' | 'login' | 'password_reset' | 'phone_change'
}
```

**Response (200 OK):**
```dart
{
  "success": true,
  "data": {
    "otpId": "507f1f77bcf86cd799439011",  // معرف OTP (للاستخدام الداخلي)
    "expiresIn": 300  // ثواني (5 دقائق) - مدة صلاحية OTP
  },
  "message": "OTP sent successfully",
  "messageAr": "تم إرسال رمز التحقق بنجاح"
}
```

> ⚠️ **ملاحظات مهمة:**
> - OTP صالح لمدة 5 دقائق (300 ثانية)
> - لا يمكن إعادة إرسال OTP قبل مرور 60 ثانية من الإرسال السابق
> - الحد الأقصى لمحاولات التحقق من OTP هو 3 محاولات

**Flutter Code:**
```dart
enum OtpPurpose {
  registration,
  login,
  passwordReset,
  phoneChange;
  
  String get value {
    switch (this) {
      case OtpPurpose.registration: return 'registration';
      case OtpPurpose.login: return 'login';
      case OtpPurpose.passwordReset: return 'password_reset';
      case OtpPurpose.phoneChange: return 'phone_change';
    }
  }
}

Future<void> sendOtp({
  required String phone,
  required OtpPurpose purpose,
}) async {
  try {
    final response = await _dio.post('/auth/send-otp', data: {
      'phone': phone,
      'purpose': purpose.value,
    });
    
    if (!response.data['success']) {
      throw Exception(response.data['messageAr'] ?? response.data['message']);
    }
  } on DioException catch (e) {
    throw _handleError(e);
  }
}
```

---

### 5️⃣ التحقق من OTP (Verify OTP)

**Endpoint:** `POST /auth/verify-otp`

**Request Body:**
```dart
{
  "phone": "+966501234567",
  "otp": "123456",  // 6 أرقام بالضبط
  "purpose": "registration"
}
```

**Response (200 OK):**
```dart
{
  "success": true,
  "data": null,
  "message": "OTP verified successfully",
  "messageAr": "تم التحقق من الرمز بنجاح"
}
```

**Flutter Code:**
```dart
Future<bool> verifyOtp({
  required String phone,
  required String otp,
  required OtpPurpose purpose,
}) async {
  try {
    final response = await _dio.post('/auth/verify-otp', data: {
      'phone': phone,
      'otp': otp,
      'purpose': purpose.value,
    });
    
    return response.data['success'] == true;
  } on DioException catch (e) {
    throw _handleError(e);
  }
}
```

**Errors المحتملة:**
| Status | Message | السبب |
|--------|---------|-------|
| 400 | Invalid or expired OTP | OTP غير صحيح أو منتهي الصلاحية |
| 400 | Maximum OTP verification attempts exceeded | تم تجاوز الحد الأقصى لمحاولات التحقق (3 محاولات) |
| 400 | Invalid OTP. X attempts remaining | OTP خاطئ (X = عدد المحاولات المتبقية) |

---

### 6️⃣ نسيت كلمة المرور (Forgot Password)

**الخطوات:**
1. `POST /auth/forgot-password` - إرسال OTP
2. `POST /auth/verify-reset-otp` - التحقق من OTP والحصول على resetToken
3. `POST /auth/reset-password` - تعيين كلمة مرور جديدة

#### Step 1: إرسال OTP

**Endpoint:** `POST /auth/forgot-password`

**Request Body:**
```dart
{
  "phone": "+966501234567"
}
```

**Response:**
```dart
{
  "success": true,
  "data": {
    "message": "Password reset OTP sent successfully",
    "expiresIn": 300  // ثواني (5 دقائق) - مدة صلاحية OTP
  },
  "message": "Password reset OTP sent",
  "messageAr": "تم إرسال رمز إعادة تعيين كلمة المرور"
}
```

#### Step 2: التحقق من OTP

**Endpoint:** `POST /auth/verify-reset-otp`

**Request Body:**
```dart
{
  "phone": "+966501234567",
  "otp": "123456",
  "purpose": "password_reset"  // ⚠️ مطلوب
}
```

**Response:**
```dart
{
  "success": true,
  "data": {
    "resetToken": "a1b2c3d4e5f6..."  // ⚠️ استخدمه في الخطوة التالية
  },
  "message": "OTP verified. Use the reset token to set new password.",
  "messageAr": "تم التحقق. استخدم الرمز لتعيين كلمة مرور جديدة."
}
```

#### Step 3: تعيين كلمة مرور جديدة

**Endpoint:** `POST /auth/reset-password`

**Request Body:**
```dart
{
  "resetToken": "a1b2c3d4e5f6...",
  "newPassword": "NewStrongP@ss123"
}
```

**Response:**
```dart
{
  "success": true,
  "data": null,
  "message": "Password reset successfully",
  "messageAr": "تم إعادة تعيين كلمة المرور بنجاح"
}
```

**Flutter Code (كامل):**
```dart
class PasswordResetFlow {
  final Dio _dio;
  String? _resetToken;
  
  PasswordResetFlow(this._dio);
  
  /// الخطوة 1: طلب OTP
  Future<void> requestReset(String phone) async {
    final response = await _dio.post('/auth/forgot-password', data: {
      'phone': phone,
    });
    
    if (!response.data['success']) {
      throw Exception(response.data['messageAr']);
    }
  }
  
  /// الخطوة 2: التحقق من OTP
  Future<void> verifyOtp(String phone, String otp) async {
    final response = await _dio.post('/auth/verify-reset-otp', data: {
      'phone': phone,
      'otp': otp,
      'purpose': 'password_reset',  // ⚠️ مطلوب
    });
    
    if (response.data['success']) {
      _resetToken = response.data['data']['resetToken'];
    } else {
      throw Exception(response.data['messageAr'] ?? response.data['message']);
    }
  }
  
  /// الخطوة 3: تعيين كلمة مرور جديدة
  Future<void> setNewPassword(String newPassword) async {
    if (_resetToken == null) {
      throw Exception('يجب التحقق من OTP أولاً');
    }
    
    final response = await _dio.post('/auth/reset-password', data: {
      'resetToken': _resetToken,
      'newPassword': newPassword,
    });
    
    if (!response.data['success']) {
      throw Exception(response.data['messageAr']);
    }
    
    _resetToken = null; // تنظيف
  }
}
```

---

### 7️⃣ تغيير كلمة المرور (Change Password)

**Endpoint:** `PATCH /auth/change-password`

**Headers:** `Authorization: Bearer <accessToken>` 🔒

**Request Body:**
```dart
{
  "oldPassword": "OldStrongP@ss123",
  "newPassword": "NewStrongP@ss123"
}
```

**Response (200 OK):**
```dart
{
  "success": true,
  "data": null,
  "message": "Password changed successfully",
  "messageAr": "تم تغيير كلمة المرور بنجاح"
}
```

**Flutter Code:**
```dart
Future<void> changePassword({
  required String oldPassword,
  required String newPassword,
}) async {
  try {
    final response = await _dio.patch('/auth/change-password', data: {
      'oldPassword': oldPassword,
      'newPassword': newPassword,
    });
    
    if (!response.data['success']) {
      throw Exception(response.data['messageAr'] ?? response.data['message']);
    }
  } on DioException catch (e) {
    throw _handleError(e);
  }
}
```

**Errors المحتملة:**
| Status | Message | السبب |
|--------|---------|-------|
| 400 | Current password is incorrect | كلمة المرور الحالية خاطئة |
| 400 | New password must be different from current password | كلمة المرور الجديدة يجب أن تكون مختلفة عن الحالية |
| 400 | Password must contain... | كلمة المرور الجديدة لا تلبي الشروط |

---

### 8️⃣ جلب الملف الشخصي (Get Profile)

**Endpoint:** `GET /auth/me`

**Headers:** `Authorization: Bearer <accessToken>` 🔒

**Response (200 OK):**
```dart
{
  "success": true,
  "data": { /* User object */ },
  "message": "Profile retrieved successfully",
  "messageAr": "تم استرجاع الملف الشخصي بنجاح"
}
```

**Flutter Code:**
```dart
Future<User> getProfile() async {
  try {
    final response = await _dio.get('/auth/me');
    
    if (response.data['success']) {
      return User.fromJson(response.data['data']);
    }
    throw Exception(response.data['messageAr'] ?? response.data['message']);
  } on DioException catch (e) {
    throw _handleError(e);
  }
}
```

> 📝 **ملاحظة:** إذا كان المستخدم من نوع `admin`، ستحتوي البيانات الإضافية على:
> - `isSuperAdmin`: boolean
> - `adminUserId`: string
> - `fullName`: string

---

### 9️⃣ تسجيل الخروج (Logout)

**Endpoint:** `POST /auth/logout`

**Headers:** `Authorization: Bearer <accessToken>` 🔒

**Response (200 OK):**
```dart
{
  "success": true,
  "data": null,
  "message": "Logout successful",
  "messageAr": "تم تسجيل الخروج بنجاح"
}
```

**Flutter Code:**
```dart
Future<void> logout() async {
  try {
    await _dio.post('/auth/logout');
  } finally {
    // دائماً امسح الـ tokens حتى لو فشل الـ request
    await _clearTokens();
  }
}
```

---

## 🛠️ Error Handling Helper

```dart
Exception _handleError(DioException e) {
  if (e.response != null) {
    final data = e.response!.data;
    if (data is Map) {
      // استخدم الرسالة العربية إذا وجدت
      final message = data['messageAr'] ?? data['message'] ?? 'خطأ غير معروف';
      return Exception(message);
    }
  }
  
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return Exception('انتهت مهلة الاتصال');
    case DioExceptionType.connectionError:
      return Exception('لا يوجد اتصال بالإنترنت');
    default:
      return Exception('حدث خطأ غير متوقع');
  }
}
```

---

## 🔄 Auth State Management (مع Provider)

```dart
import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  
  User? _user;
  bool _isLoading = false;
  String? _error;
  
  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _user != null;
  String? get error => _error;
  
  AuthProvider(this._authService);
  
  Future<void> login(String phone, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final response = await _authService.login(
        phone: phone,
        password: password,
      );
      _user = response.user;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    notifyListeners();
  }
  
  Future<void> checkAuthStatus() async {
    try {
      _user = await _authService.getProfile();
    } catch (e) {
      _user = null;
    }
    notifyListeners();
  }
}
```

---

## 📝 ملخص الـ Endpoints

| Method | Endpoint | Auth | الوصف |
|--------|----------|------|-------|
| POST | `/auth/register` | ❌ | تسجيل جديد |
| POST | `/auth/login` | ❌ | تسجيل دخول |
| POST | `/auth/refresh` | ❌ | تحديث Token |
| POST | `/auth/send-otp` | ❌ | إرسال OTP |
| POST | `/auth/verify-otp` | ❌ | التحقق من OTP |
| POST | `/auth/forgot-password` | ❌ | طلب استعادة كلمة المرور |
| POST | `/auth/verify-reset-otp` | ❌ | التحقق من OTP للاستعادة |
| POST | `/auth/reset-password` | ❌ | تعيين كلمة مرور جديدة |
| PATCH | `/auth/change-password` | ✅ | تغيير كلمة المرور |
| GET | `/auth/me` | ✅ | جلب الملف الشخصي |
| POST | `/auth/logout` | ✅ | تسجيل خروج |
| POST | `/auth/fcm-token` | ✅ | تحديث FCM token للإشعارات |
| GET | `/auth/sessions` | ✅ | جلب جميع الجلسات النشطة |
| DELETE | `/auth/sessions/:id` | ✅ | حذف جلسة محددة |

---

---

## 🔔 FCM Token Management

### تحديث FCM Token

**Endpoint:** `POST /auth/fcm-token`

**Headers:** `Authorization: Bearer <accessToken>` 🔒

**Request Body:**
```dart
{
  "fcmToken": "dGhpcyBpcyBhIGZha2UgZmNtIHRva2Vu...",
  "deviceInfo": {  // اختياري
    "platform": "android",
    "version": "1.0.0"
  }
}
```

**Response (200 OK):**
```dart
{
  "success": true,
  "data": {
    "message": "FCM token updated successfully"
  },
  "message": "FCM token updated successfully",
  "messageAr": "تم تحديث رمز الإشعارات بنجاح"
}
```

---

## 📱 Sessions Management

### جلب الجلسات النشطة

**Endpoint:** `GET /auth/sessions`

**Headers:** `Authorization: Bearer <accessToken>` 🔒

**Response (200 OK):**
```dart
{
  "success": true,
  "data": [
    {
      "_id": "507f1f77bcf86cd799439011",
      "userId": "507f1f77bcf86cd799439012",
      "tokenId": "1234567890-abc123",
      "ipAddress": "192.168.1.1",
      "userAgent": "Mozilla/5.0...",
      "expiresAt": "2024-02-15T10:30:00.000Z",
      "lastActivityAt": "2024-01-15T10:30:00.000Z",
      "createdAt": "2024-01-15T10:00:00.000Z"
    }
  ],
  "message": "Sessions retrieved successfully",
  "messageAr": "تم استرجاع الجلسات بنجاح"
}
```

### حذف جلسة محددة

**Endpoint:** `DELETE /auth/sessions/:id`

**Headers:** `Authorization: Bearer <accessToken>` 🔒

**Response (200 OK):**
```dart
{
  "success": true,
  "data": {
    "message": "Session deleted successfully"
  },
  "message": "Session deleted successfully",
  "messageAr": "تم حذف الجلسة بنجاح"
}
```

---

## 📝 ملاحظات إضافية

### حالة الحساب (Account Status)

الحساب يمكن أن يكون في إحدى الحالات التالية:
- `pending`: قيد المراجعة (لا يمكن تسجيل الدخول)
- `active`: نشط (يمكن تسجيل الدخول)
- `suspended`: معلق (لا يمكن تسجيل الدخول)
- `deleted`: محذوف (لا يمكن تسجيل الدخول)

### قفل الحساب (Account Locking)

- بعد 5 محاولات تسجيل دخول فاشلة، يتم قفل الحساب لمدة 30 دقيقة
- عند تسجيل الدخول بنجاح، يتم إعادة تعيين عدد المحاولات الفاشلة

### صلاحية Tokens

- **Access Token**: افتراضياً `15m` (15 دقيقة) أو `7d` (7 أيام) حسب إعدادات `JWT_EXPIRATION`
- **Refresh Token**: افتراضياً `30d` (30 يوم) حسب إعدادات `JWT_REFRESH_EXPIRATION`

### OTP

- مدة صلاحية OTP: 5 دقائق (300 ثانية)
- الحد الأقصى لمحاولات التحقق: 3 محاولات
- لا يمكن إعادة إرسال OTP قبل مرور 60 ثانية من الإرسال السابق

---

> 🔗 **التالي:** [products.md](./products.md) - دليل ربط المنتجات
