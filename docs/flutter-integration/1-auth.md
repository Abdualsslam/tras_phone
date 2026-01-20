# 🔐 Auth Module - دليل ربط المصادقة

## 📋 نظرة عامة

هذا الموديول يتعامل مع:
- ✅ تسجيل مستخدم جديد
- ✅ تسجيل الدخول
- ✅ تحديث الـ Token
- ✅ طلب إعادة تعيين كلمة المرور
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

## 🏙️ جلب المدن عند التسجيل

عند إنشاء حساب جديد، يجب جلب قائمة المدن المتاحة لعرضها في dropdown/select للمستخدم.

### جلب المدن

**Endpoint:** `GET /locations/cities` 🌐 (Public - لا يحتاج Token)

**Query Parameters (اختياري):**
- `countryId`: معرف الدولة (لتصفية المدن حسب الدولة)

**Response (200 OK):**
```dart
{
  "success": true,
  "data": [
    {
      "_id": "507f1f77bcf86cd799439011",
      "name": "Riyadh",
      "nameAr": "الرياض",
      "countryId": {
        "_id": "507f1f77bcf86cd799439012",
        "name": "Saudi Arabia",
        "nameAr": "المملكة العربية السعودية"
      },
      "shippingZoneId": {
        "_id": "507f1f77bcf86cd799439013",
        "name": "Central Region",
        "nameAr": "المنطقة الوسطى"
      },
      "latitude": 24.7136,
      "longitude": 46.6753,
      "timezone": "Asia/Riyadh",
      "region": "Central",
      "regionAr": "الوسطى",
      "isActive": true,
      "isCapital": true,
      "displayOrder": 1
    }
  ],
  "message": "Cities retrieved successfully",
  "messageAr": "تم استرجاع المدن بنجاح"
}
```

### Flutter Implementation

#### 1. استخدام Locations Service

```dart
import 'package:your_app/features/locations/data/datasources/locations_remote_datasource.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final LocationsRemoteDataSource _locationsDataSource;
  List<CityModel> _cities = [];
  CityModel? _selectedCity;
  bool _loadingCities = false;

  @override
  void initState() {
    super.initState();
    _loadCities();
  }

  Future<void> _loadCities() async {
    setState(() => _loadingCities = true);
    try {
      // جلب جميع المدن النشطة
      final cities = await _locationsDataSource.getCities();
      setState(() {
        _cities = cities;
        _loadingCities = false;
      });
    } catch (e) {
      setState(() => _loadingCities = false);
      // عرض رسالة خطأ
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل تحميل المدن: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        child: Column(
          children: [
            // ... حقول أخرى (phone, email, password)
            
            // Dropdown للمدن
            DropdownButtonFormField<CityModel>(
              decoration: InputDecoration(
                labelText: 'المدينة',
                border: OutlineInputBorder(),
              ),
              value: _selectedCity,
              items: _cities.map((city) {
                return DropdownMenuItem(
                  value: city,
                  child: Row(
                    children: [
                      if (city.isCapital)
                        Icon(Icons.star, size: 16, color: Colors.amber),
                      if (city.isCapital) SizedBox(width: 8),
                      Text(city.getName('ar')), // أو 'en' حسب اللغة
                    ],
                  ),
                );
              }).toList(),
              onChanged: (city) {
                setState(() => _selectedCity = city);
              },
              validator: (value) {
                if (value == null) {
                  return 'يرجى اختيار المدينة';
                }
                return null;
              },
            ),
            
            // زر التسجيل
            ElevatedButton(
              onPressed: _selectedCity != null ? _register : null,
              child: Text('تسجيل'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _register() async {
    if (_selectedCity == null) return;
    
    // إرسال cityId مع بيانات التسجيل
    await authService.register(
      phone: phoneController.text,
      password: passwordController.text,
      email: emailController.text,
      cityId: _selectedCity!.id, // ⚠️ إرسال معرف المدينة
      // ... باقي الحقول الاختيارية
    );
  }
}
```

#### 2. استخدام LocationsCubit (Bloc Pattern)

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:your_app/features/locations/presentation/cubit/locations_cubit.dart';
import 'package:your_app/features/locations/presentation/widgets/city_selector.dart';

class RegisterScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LocationsCubit()..loadCities(),
      child: Scaffold(
        body: Form(
          child: Column(
            children: [
              // ... حقول أخرى
              
              // استخدام CitySelector Widget
              CitySelector(
                labelText: 'المدينة',
                locale: 'ar',
                onCitySelected: (city) {
                  // حفظ المدينة المختارة
                  _selectedCityId = city.id;
                },
              ),
              
              // ... باقي الحقول
            ],
          ),
        ),
      ),
    );
  }
}
```

#### 3. جلب المدن حسب الدولة (اختياري)

```dart
// جلب المدن لدولة محددة
Future<void> _loadCitiesByCountry(String countryId) async {
  try {
    final cities = await _locationsDataSource.getCities(countryId: countryId);
    setState(() => _cities = cities);
  } catch (e) {
    // معالجة الخطأ
  }
}
```

> 📝 **ملاحظات:**
> - Endpoint `/locations/cities` **عام** ولا يحتاج Token
> - يتم إرجاع المدن النشطة فقط (`isActive: true`)
> - المدن مرتبة حسب `displayOrder` ثم `name`
> - يمكن استخدام `isCapital` لعرض نجمة بجانب العاصمة
> - استخدم `nameAr` للعربية و `name` للإنجليزية

> 🔗 **للمزيد من التفاصيل:** راجع [locations.md](./locations.md) - دليل ربط المواقع والمدن

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
  "userType": "customer",       // مطلوب - 'customer' للتطبيق
  // ═════════════════════════════════════
  // حقول ملف العميل (اختيارية)
  // ═════════════════════════════════════
  "cityId": "507f1f77bcf86cd799439011",  // معرف المدينة (MongoDB ObjectId)
  "responsiblePersonName": "أحمد علي",
  "shopName": "Phone Repair Center",
  "shopNameAr": "مركز صيانة الجوالات",
  "businessType": "shop"  // 'shop' | 'technician' | 'distributor' | 'other'
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
> - `cityId`: معرف المدينة (MongoDB ObjectId) - **يُنصح بإرساله** لإنشاء ملف عميل كامل
> - `responsiblePersonName`: اسم الشخص المسؤول
> - `shopName`: اسم المتجر
> - `shopNameAr`: اسم المتجر بالعربية
> - `businessType`: نوع العمل ('shop' | 'technician' | 'distributor' | 'other')
> 
> ⚠️ **مهم:** إذا تم إرسال `cityId` مع `responsiblePersonName` و `shopName`، سيتم إنشاء ملف عميل تلقائياً عند التسجيل.

**Flutter Code:**
```dart
class AuthService {
  final Dio _dio;
  
  AuthService(this._dio);
  
  Future<AuthResponse> register({
    required String phone,
    required String password,
    String? email,
    // ═════════════════════════════════════
    // حقول ملف العميل (اختيارية)
    // ═════════════════════════════════════
    String? cityId,
    String? responsiblePersonName,
    String? shopName,
    String? shopNameAr,
    String? businessType,
  }) async {
    try {
      final response = await _dio.post('/auth/register', data: {
        'phone': phone,
        'password': password,
        'userType': 'customer', // دائماً customer للتطبيق
        if (email != null) 'email': email,
        // حقول ملف العميل
        if (cityId != null) 'cityId': cityId,
        if (responsiblePersonName != null) 'responsiblePersonName': responsiblePersonName,
        if (shopName != null) 'shopName': shopName,
        if (shopNameAr != null) 'shopNameAr': shopNameAr,
        if (businessType != null) 'businessType': businessType,
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

### 4️⃣ طلب إعادة تعيين كلمة المرور (Request Password Reset)

> 📝 **ملاحظة مهمة:** النظام الحالي يستخدم آلية طلبات يدوية تتم معالجتها من قبل المشرف. بعد تقديم الطلب، سيتم التواصل معك من قبل المشرف لإرسال كلمة مرور مؤقتة.

**الخطوات:**
1. `POST /auth/request-password-reset` - تقديم طلب إعادة تعيين كلمة المرور
2. انتظار معالجة الطلب من قبل المشرف (سيتم التواصل معك)
3. تسجيل الدخول بالكلمة المرور المؤقتة المرسلة من المشرف
4. `PATCH /auth/change-password` - تغيير كلمة المرور إلى كلمة جديدة

#### Step 1: تقديم طلب إعادة تعيين كلمة المرور

**Endpoint:** `POST /auth/request-password-reset`

**Request Body:**
```dart
{
  "phone": "+966501234567",
  "customerNotes": "نسيت كلمة المرور ولا أستطيع الوصول إلى حسابي"  // اختياري
}
```

**Response (201 Created):**
```dart
{
  "success": true,
  "data": {
    "requestNumber": "PWR24120001",  // رقم الطلب الفريد
    "status": "pending"  // حالة الطلب: 'pending' | 'completed' | 'rejected'
  },
  "message": "Password reset request submitted successfully. An admin will contact you soon.",
  "messageAr": "تم تقديم طلب إعادة تعيين كلمة المرور بنجاح. سيتم التواصل معك قريباً."
}
```

> ⚠️ **ملاحظات مهمة:**
> - لا يمكن تقديم طلب جديد إذا كان هناك طلب `pending` موجود مسبقاً
> - سيتم التواصل معك من قبل المشرف لإرسال كلمة المرور المؤقتة
> - احفظ رقم الطلب (`requestNumber`) للمتابعة

**Flutter Code:**
```dart
class PasswordResetRequest {
  final String requestNumber;
  final String status;
  
  PasswordResetRequest({
    required this.requestNumber,
    required this.status,
  });
  
  factory PasswordResetRequest.fromJson(Map<String, dynamic> json) {
    return PasswordResetRequest(
      requestNumber: json['requestNumber'],
      status: json['status'],
    );
  }
}

Future<PasswordResetRequest> requestPasswordReset({
  required String phone,
  String? customerNotes,
}) async {
  try {
    final response = await _dio.post('/auth/request-password-reset', data: {
      'phone': phone,
      if (customerNotes != null) 'customerNotes': customerNotes,
    });
    
    if (response.data['success']) {
      return PasswordResetRequest.fromJson(response.data['data']);
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
| 400 | User not found | المستخدم غير موجود (رقم الهاتف غير مسجل) |
| 409 | A password reset request is already pending. Please wait for admin to process it. | يوجد طلب قيد الانتظار مسبقاً |

#### Step 2 & 3: تسجيل الدخول وتغيير كلمة المرور

بعد أن يستلم العميل كلمة المرور المؤقتة من المشرف:

1. **تسجيل الدخول بالكلمة المؤقتة:**
   - استخدم `POST /auth/login` مع رقم الهاتف وكلمة المرور المؤقتة

2. **تغيير كلمة المرور:**
   - استخدم `PATCH /auth/change-password` (راجع القسم 5️⃣ أدناه)
   - `oldPassword`: كلمة المرور المؤقتة
   - `newPassword`: كلمة المرور الجديدة المطلوبة

---

### 5️⃣ تغيير كلمة المرور (Change Password)

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

### 6️⃣ جلب الملف الشخصي (Get Profile)

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

### 7️⃣ تسجيل الخروج (Logout)

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
| POST | `/auth/request-password-reset` | ❌ | طلب إعادة تعيين كلمة المرور |
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

### إعادة تعيين كلمة المرور

- النظام يستخدم آلية طلبات يدوية تتم معالجتها من قبل المشرف
- لا يمكن تقديم طلب جديد إذا كان هناك طلب `pending` موجود مسبقاً
- بعد معالجة الطلب، سيتم التواصل معك لإرسال كلمة المرور المؤقتة
- يجب تغيير كلمة المرور المؤقتة بعد تسجيل الدخول

---

> 🔗 **التالي:** [products.md](./products.md) - دليل ربط المنتجات
