# 👤 Customer Profile Module - دليل ربط بروفايل العملاء

## 📋 نظرة عامة

هذا الموديول يتعامل مع:
- ✅ جلب بيانات بروفايل العميل
- ✅ تحديث بيانات البروفايل
- ✅ حذف حساب العميل
- ✅ إدارة العناوين (إضافة، تحديث، حذف، تعيين افتراضي)
- ✅ عرض إحصائيات العميل (الطلبات، الإنفاق، نقاط الولاء)

> **ملاحظة**: جميع الـ endpoints هنا تتطلب JWT Token في الـ Header.

---

## 📁 Flutter Models

### Customer Model

```dart
class Customer {
  final String id;
  final String? userId;
  final String customerCode;
  final String responsiblePersonName;
  final String shopName;
  final String? shopNameAr;
  final String businessType; // 'shop' | 'technician' | 'distributor' | 'other'
  
  // Location
  final String? cityId;
  final String? marketId;
  final String? address;
  final double? latitude;
  final double? longitude;
  
  // Pricing & Credit
  final String? priceLevelId;
  final double creditLimit;
  final double creditUsed;
  
  // Wallet
  final double walletBalance;
  
  // Loyalty
  final int loyaltyPoints;
  final String loyaltyTier; // 'bronze' | 'silver' | 'gold' | 'platinum'
  
  // Statistics
  final int totalOrders;
  final double totalSpent;
  final double averageOrderValue;
  final DateTime? lastOrderAt;
  
  // Preferences
  final String? preferredPaymentMethod;
  final String? preferredShippingTime;
  final String preferredContactMethod; // 'phone' | 'whatsapp' | 'email'
  
  // Social
  final String? instagramHandle;
  final String? twitterHandle;
  
  final DateTime? approvedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Populated fields
  final User? user;
  final City? city;
  final Market? market;
  final PriceLevel? priceLevel;

  Customer({
    required this.id,
    this.userId,
    required this.customerCode,
    required this.responsiblePersonName,
    required this.shopName,
    this.shopNameAr,
    required this.businessType,
    this.cityId,
    this.marketId,
    this.address,
    this.latitude,
    this.longitude,
    this.priceLevelId,
    this.creditLimit = 0.0,
    this.creditUsed = 0.0,
    this.walletBalance = 0.0,
    this.loyaltyPoints = 0,
    this.loyaltyTier = 'bronze',
    this.totalOrders = 0,
    this.totalSpent = 0.0,
    this.averageOrderValue = 0.0,
    this.lastOrderAt,
    this.preferredPaymentMethod,
    this.preferredShippingTime,
    this.preferredContactMethod = 'whatsapp',
    this.instagramHandle,
    this.twitterHandle,
    this.approvedAt,
    required this.createdAt,
    required this.updatedAt,
    this.user,
    this.city,
    this.market,
    this.priceLevel,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['_id'] ?? json['id'],
      userId: json['userId'] is String 
          ? json['userId'] 
          : json['userId']?['_id']?.toString(),
      customerCode: json['customerCode'],
      responsiblePersonName: json['responsiblePersonName'],
      shopName: json['shopName'],
      shopNameAr: json['shopNameAr'],
      businessType: json['businessType'] ?? 'shop',
      cityId: json['cityId'] is String 
          ? json['cityId'] 
          : json['cityId']?['_id']?.toString(),
      marketId: json['marketId'] is String 
          ? json['marketId'] 
          : json['marketId']?['_id']?.toString(),
      address: json['address'],
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      priceLevelId: json['priceLevelId'] is String 
          ? json['priceLevelId'] 
          : json['priceLevelId']?['_id']?.toString(),
      creditLimit: (json['creditLimit'] as num?)?.toDouble() ?? 0.0,
      creditUsed: (json['creditUsed'] as num?)?.toDouble() ?? 0.0,
      walletBalance: (json['walletBalance'] as num?)?.toDouble() ?? 0.0,
      loyaltyPoints: json['loyaltyPoints'] ?? 0,
      loyaltyTier: json['loyaltyTier'] ?? 'bronze',
      totalOrders: json['totalOrders'] ?? 0,
      totalSpent: (json['totalSpent'] as num?)?.toDouble() ?? 0.0,
      averageOrderValue: (json['averageOrderValue'] as num?)?.toDouble() ?? 0.0,
      lastOrderAt: json['lastOrderAt'] != null 
          ? DateTime.parse(json['lastOrderAt']) 
          : null,
      preferredPaymentMethod: json['preferredPaymentMethod'],
      preferredShippingTime: json['preferredShippingTime'],
      preferredContactMethod: json['preferredContactMethod'] ?? 'whatsapp',
      instagramHandle: json['instagramHandle'],
      twitterHandle: json['twitterHandle'],
      approvedAt: json['approvedAt'] != null 
          ? DateTime.parse(json['approvedAt']) 
          : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      user: json['userId'] is Map ? User.fromJson(json['userId']) : null,
      city: json['cityId'] is Map ? City.fromJson(json['cityId']) : null,
      market: json['marketId'] is Map ? Market.fromJson(json['marketId']) : null,
      priceLevel: json['priceLevelId'] is Map 
          ? PriceLevel.fromJson(json['priceLevelId']) 
          : null,
    );
  }

  /// الحصول على اسم المتجر حسب اللغة
  String getShopName(String locale) => 
      locale == 'ar' && shopNameAr != null ? shopNameAr! : shopName;
  
  /// هل الحساب معتمد؟
  bool get isApproved => approvedAt != null;
  
  /// الرصيد المتاح من الائتمان
  double get availableCredit => creditLimit - creditUsed;
  
  /// هل يمكن الطلب بالائتمان؟
  bool canOrderOnCredit(double amount) => availableCredit >= amount;
}

class User {
  final String id;
  final String phone;
  final String? email;
  final String userType;
  final String status;

  User({
    required this.id,
    required this.phone,
    this.email,
    required this.userType,
    required this.status,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? json['id'],
      phone: json['phone'],
      email: json['email'],
      userType: json['userType'],
      status: json['status'],
    );
  }
}

class City {
  final String id;
  final String name;
  final String? nameAr;

  City({
    required this.id,
    required this.name,
    this.nameAr,
  });

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      id: json['_id'] ?? json['id'],
      name: json['name'],
      nameAr: json['nameAr'],
    );
  }

  String getName(String locale) => 
      locale == 'ar' && nameAr != null ? nameAr! : name;
}

class Market {
  final String id;
  final String name;
  final String? nameAr;

  Market({
    required this.id,
    required this.name,
    this.nameAr,
  });

  factory Market.fromJson(Map<String, dynamic> json) {
    return Market(
      id: json['_id'] ?? json['id'],
      name: json['name'],
      nameAr: json['nameAr'],
    );
  }
}

class PriceLevel {
  final String id;
  final String name;
  final double discount;

  PriceLevel({
    required this.id,
    required this.name,
    required this.discount,
  });

  factory PriceLevel.fromJson(Map<String, dynamic> json) {
    return PriceLevel(
      id: json['_id'] ?? json['id'],
      name: json['name'],
      discount: (json['discount'] as num).toDouble(),
    );
  }
}
```

### Update Customer Profile DTO

```dart
class UpdateCustomerProfileDto {
  final String? responsiblePersonName;
  final String? shopName;
  final String? shopNameAr;
  final String? businessType;
  final String? cityId;
  final String? marketId;
  final String? address;
  final double? latitude;
  final double? longitude;
  final String? preferredPaymentMethod;
  final String? preferredShippingTime;
  final String? preferredContactMethod;
  final String? instagramHandle;
  final String? twitterHandle;

  UpdateCustomerProfileDto({
    this.responsiblePersonName,
    this.shopName,
    this.shopNameAr,
    this.businessType,
    this.cityId,
    this.marketId,
    this.address,
    this.latitude,
    this.longitude,
    this.preferredPaymentMethod,
    this.preferredShippingTime,
    this.preferredContactMethod,
    this.instagramHandle,
    this.twitterHandle,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (responsiblePersonName != null) map['responsiblePersonName'] = responsiblePersonName;
    if (shopName != null) map['shopName'] = shopName;
    if (shopNameAr != null) map['shopNameAr'] = shopNameAr;
    if (businessType != null) map['businessType'] = businessType;
    if (cityId != null) map['cityId'] = cityId;
    if (marketId != null) map['marketId'] = marketId;
    if (address != null) map['address'] = address;
    if (latitude != null) map['latitude'] = latitude;
    if (longitude != null) map['longitude'] = longitude;
    if (preferredPaymentMethod != null) map['preferredPaymentMethod'] = preferredPaymentMethod;
    if (preferredShippingTime != null) map['preferredShippingTime'] = preferredShippingTime;
    if (preferredContactMethod != null) map['preferredContactMethod'] = preferredContactMethod;
    if (instagramHandle != null) map['instagramHandle'] = instagramHandle;
    if (twitterHandle != null) map['twitterHandle'] = twitterHandle;
    return map;
  }
}
```

### Delete Account DTO

```dart
class DeleteAccountDto {
  final String? reason;

  DeleteAccountDto({this.reason});

  Map<String, dynamic> toJson() => {
    if (reason != null) 'reason': reason,
  };
}
```

---

## 📞 API Endpoints

### 1️⃣ جلب بروفايل العميل (Get Profile)

**Endpoint:** `GET /customer/profile`

**Headers:** `Authorization: Bearer <accessToken>` 🔒

**Response (200 OK):**
```dart
{
  "success": true,
  "data": {
    "_id": "507f1f77bcf86cd799439011",
    "userId": {
      "_id": "507f1f77bcf86cd799439010",
      "phone": "+966501234567",
      "email": "customer@example.com",
      "userType": "customer",
      "status": "active"
    },
    "customerCode": "CUST-001",
    "responsiblePersonName": "أحمد محمد",
    "shopName": "Phone Repair Center",
    "shopNameAr": "مركز صيانة الجوالات",
    "businessType": "shop",
    "cityId": {
      "_id": "507f1f77bcf86cd799439001",
      "name": "Riyadh",
      "nameAr": "الرياض"
    },
    "marketId": {
      "_id": "507f1f77bcf86cd799439002",
      "name": "Al-Batha Market",
      "nameAr": "سوق البطحاء"
    },
    "address": "حي الملز، شارع الأمير سلطان",
    "latitude": 24.7136,
    "longitude": 46.6753,
    "priceLevelId": {
      "_id": "507f1f77bcf86cd799439003",
      "name": "Level 1",
      "discount": 10.0
    },
    "creditLimit": 5000.0,
    "creditUsed": 1200.0,
    "walletBalance": 250.50,
    "loyaltyPoints": 1500,
    "loyaltyTier": "silver",
    "totalOrders": 45,
    "totalSpent": 12500.75,
    "averageOrderValue": 277.79,
    "lastOrderAt": "2024-01-15T10:30:00.000Z",
    "preferredPaymentMethod": "wallet",
    "preferredShippingTime": "morning",
    "preferredContactMethod": "whatsapp",
    "instagramHandle": "@phone_repair",
    "twitterHandle": "@phone_repair",
    "approvedAt": "2024-01-01T00:00:00.000Z",
    "createdAt": "2024-01-01T00:00:00.000Z",
    "updatedAt": "2024-01-15T10:30:00.000Z"
  },
  "message": "Profile retrieved successfully",
  "messageAr": "تم استرجاع البروفايل بنجاح"
}
```

**Flutter Code:**
```dart
class CustomerProfileService {
  final Dio _dio;
  
  CustomerProfileService(this._dio);
  
  Future<Customer> getProfile() async {
    try {
      final response = await _dio.get('/customer/profile');
      
      if (response.data['success']) {
        return Customer.fromJson(response.data['data']);
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
| 401 | Unauthorized | Token غير صحيح أو منتهي الصلاحية |
| 404 | Customer profile not found | ملف العميل غير موجود |

---

### 2️⃣ تحديث بروفايل العميل (Update Profile)

**Endpoint:** `PUT /customer/profile`

**Headers:** `Authorization: Bearer <accessToken>` 🔒

**Request Body (جميع الحقول اختيارية):**
```dart
{
  "responsiblePersonName": "أحمد محمد علي",
  "shopName": "Phone Repair Center Updated",
  "shopNameAr": "مركز صيانة الجوالات المحدث",
  "businessType": "technician",
  "cityId": "507f1f77bcf86cd799439001",
  "marketId": "507f1f77bcf86cd799439002",
  "address": "حي الملز، شارع الأمير سلطان، مبنى 5",
  "latitude": 24.7136,
  "longitude": 46.6753,
  "preferredPaymentMethod": "bank_transfer",
  "preferredShippingTime": "evening",
  "preferredContactMethod": "phone",
  "instagramHandle": "@new_handle",
  "twitterHandle": "@new_handle"
}
```

**Response (200 OK):**
```dart
{
  "success": true,
  "data": {
    "_id": "507f1f77bcf86cd799439011",
    "responsiblePersonName": "أحمد محمد علي",
    "shopName": "Phone Repair Center Updated",
    "shopNameAr": "مركز صيانة الجوالات المحدث",
    "businessType": "technician",
    ...
    "updatedAt": "2024-01-16T14:20:00.000Z"
  },
  "message": "Profile updated successfully",
  "messageAr": "تم تحديث البروفايل بنجاح"
}
```

**Flutter Code:**
```dart
Future<Customer> updateProfile(UpdateCustomerProfileDto dto) async {
  try {
    final response = await _dio.put(
      '/customer/profile',
      data: dto.toJson(),
    );
    
    if (response.data['success']) {
      return Customer.fromJson(response.data['data']);
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
| 400 | Validation error | بيانات غير صحيحة |
| 401 | Unauthorized | Token غير صحيح |
| 404 | Customer profile not found | ملف العميل غير موجود |

---

### 3️⃣ حذف حساب العميل (Delete Account)

**Endpoint:** `DELETE /customer/profile`

**Headers:** `Authorization: Bearer <accessToken>` 🔒

**Request Body (اختياري):**
```dart
{
  "reason": "لا أريد استخدام الخدمة بعد الآن"
}
```

**Response (200 OK):**
```dart
{
  "success": true,
  "data": null,
  "message": "Account deleted successfully",
  "messageAr": "تم حذف الحساب بنجاح"
}
```

> ⚠️ **ملاحظة مهمة**: هذا حذف ناعم (Soft Delete) - البيانات محفوظة ولكن الحساب غير نشط.

**Flutter Code:**
```dart
Future<void> deleteAccount({String? reason}) async {
  try {
    final response = await _dio.delete(
      '/customer/profile',
      data: reason != null ? {'reason': reason} : null,
    );
    
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
| 401 | Unauthorized | Token غير صحيح |
| 404 | Customer profile not found | ملف العميل غير موجود |

---

## 📍 إدارة العناوين

> **ملاحظة**: للتفاصيل الكاملة عن إدارة العناوين، راجع [6-addresses.md](./6-addresses.md)

### 4️⃣ جلب جميع العناوين

**Endpoint:** `GET /customer/addresses`

**Headers:** `Authorization: Bearer <accessToken>` 🔒

**Response:**
```dart
{
  "success": true,
  "data": [
    {
      "_id": "507f1f77bcf86cd799439011",
      "customerId": "507f1f77bcf86cd799439010",
      "label": "المنزل",
      "recipientName": "أحمد محمد",
      "phone": "0501234567",
      "cityId": {
        "_id": "507f1f77bcf86cd799439001",
        "name": "Riyadh",
        "nameAr": "الرياض"
      },
      "addressLine": "حي الملز، شارع الأمير سلطان، مبنى 5، شقة 12",
      "isDefault": true,
      "createdAt": "2024-01-15T10:30:00.000Z",
      "updatedAt": "2024-01-15T10:30:00.000Z"
    }
  ],
  "message": "Addresses retrieved successfully",
  "messageAr": "تم استرجاع العناوين بنجاح"
}
```

### 5️⃣ جلب عنوان محدد

**Endpoint:** `GET /customer/addresses/:addressId`

**Headers:** `Authorization: Bearer <accessToken>` 🔒

### 6️⃣ إضافة عنوان جديد

**Endpoint:** `POST /customer/addresses`

**Headers:** `Authorization: Bearer <accessToken>` 🔒

**Request Body:**
```dart
{
  "label": "المنزل",
  "recipientName": "أحمد محمد",
  "phone": "0501234567",
  "cityId": "507f1f77bcf86cd799439001",
  "marketId": "507f1f77bcf86cd799439002",
  "addressLine": "حي الملز، شارع الأمير سلطان، مبنى 5، شقة 12",
  "latitude": 24.7136,
  "longitude": 46.6753,
  "isDefault": true
}
```

### 7️⃣ تحديث عنوان

**Endpoint:** `PUT /customer/addresses/:addressId`

**Headers:** `Authorization: Bearer <accessToken>` 🔒

### 8️⃣ حذف عنوان

**Endpoint:** `DELETE /customer/addresses/:addressId`

**Headers:** `Authorization: Bearer <accessToken>` 🔒

---

## 🛠️ CustomerProfileService الكامل

```dart
import 'package:dio/dio.dart';

class CustomerProfileService {
  final Dio _dio;
  
  CustomerProfileService(this._dio);
  
  // ═════════════════════════════════════
  // Profile Operations
  // ═════════════════════════════════════
  
  /// جلب بروفايل العميل
  Future<Customer> getProfile() async {
    try {
      final response = await _dio.get('/customer/profile');
      
      if (response.data['success']) {
        return Customer.fromJson(response.data['data']);
      }
      throw Exception(response.data['messageAr'] ?? response.data['message']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  /// تحديث بروفايل العميل
  Future<Customer> updateProfile(UpdateCustomerProfileDto dto) async {
    try {
      final response = await _dio.put(
        '/customer/profile',
        data: dto.toJson(),
      );
      
      if (response.data['success']) {
        return Customer.fromJson(response.data['data']);
      }
      throw Exception(response.data['messageAr'] ?? response.data['message']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  /// حذف حساب العميل
  Future<void> deleteAccount({String? reason}) async {
    try {
      final response = await _dio.delete(
        '/customer/profile',
        data: reason != null ? {'reason': reason} : null,
      );
      
      if (!response.data['success']) {
        throw Exception(response.data['messageAr'] ?? response.data['message']);
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  // ═════════════════════════════════════
  // Addresses Operations
  // ═════════════════════════════════════
  
  /// جلب جميع العناوين
  Future<List<Address>> getAddresses() async {
    try {
      final response = await _dio.get('/customer/addresses');
      
      if (response.data['success']) {
        return (response.data['data'] as List)
            .map((a) => Address.fromJson(a))
            .toList();
      }
      throw Exception(response.data['messageAr'] ?? response.data['message']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  /// جلب عنوان محدد
  Future<Address> getAddressById(String addressId) async {
    try {
      final response = await _dio.get('/customer/addresses/$addressId');
      
      if (response.data['success']) {
        return Address.fromJson(response.data['data']);
      }
      throw Exception(response.data['messageAr'] ?? response.data['message']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  /// إضافة عنوان جديد
  Future<Address> createAddress(AddressRequest request) async {
    try {
      final response = await _dio.post(
        '/customer/addresses',
        data: request.toJson(),
      );
      
      if (response.data['success']) {
        return Address.fromJson(response.data['data']);
      }
      throw Exception(response.data['messageAr'] ?? response.data['message']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  /// تحديث عنوان
  Future<Address> updateAddress(
    String addressId,
    Map<String, dynamic> updates,
  ) async {
    try {
      final response = await _dio.put(
        '/customer/addresses/$addressId',
        data: updates,
      );
      
      if (response.data['success']) {
        return Address.fromJson(response.data['data']);
      }
      throw Exception(response.data['messageAr'] ?? response.data['message']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  /// حذف عنوان
  Future<void> deleteAddress(String addressId) async {
    try {
      final response = await _dio.delete('/customer/addresses/$addressId');
      
      if (!response.data['success']) {
        throw Exception(response.data['messageAr'] ?? response.data['message']);
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  /// تعيين عنوان كافتراضي
  Future<Address> setDefaultAddress(String addressId) async {
    return updateAddress(addressId, {'isDefault': true});
  }
  
  // ═════════════════════════════════════
  // Error Handling
  // ═════════════════════════════════════
  
  Exception _handleError(DioException e) {
    if (e.response != null) {
      final data = e.response!.data;
      if (data is Map) {
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
}
```

---

## 🎯 State Management - ProfileCubit

```dart
import 'package:flutter_bloc/flutter_bloc.dart';

// States
abstract class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final Customer customer;
  
  ProfileLoaded(this.customer);
}

class ProfileError extends ProfileState {
  final String message;
  
  ProfileError(this.message);
}

class ProfileUpdated extends ProfileState {
  final Customer customer;
  
  ProfileUpdated(this.customer);
}

// Cubit
class ProfileCubit extends Cubit<ProfileState> {
  final CustomerProfileService _service;
  Customer? _customer;
  
  ProfileCubit(this._service) : super(ProfileInitial());
  
  Customer? get customer => _customer;
  
  /// جلب البروفايل
  Future<void> loadProfile() async {
    emit(ProfileLoading());
    try {
      _customer = await _service.getProfile();
      emit(ProfileLoaded(_customer!));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }
  
  /// تحديث البروفايل
  Future<void> updateProfile(UpdateCustomerProfileDto dto) async {
    emit(ProfileLoading());
    try {
      _customer = await _service.updateProfile(dto);
      emit(ProfileUpdated(_customer!));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }
  
  /// حذف الحساب
  Future<void> deleteAccount({String? reason}) async {
    emit(ProfileLoading());
    try {
      await _service.deleteAccount(reason: reason);
      _customer = null;
      emit(ProfileInitial());
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }
}
```

---

## 🏗️ UI Examples

### Profile Screen

```dart
class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileCubit(CustomerProfileService(dio))
        ..loadProfile(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('الملف الشخصي'),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => Navigator.pushNamed(context, '/profile/edit'),
            ),
          ],
        ),
        body: BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, state) {
            if (state is ProfileLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ProfileError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(state.message),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.read<ProfileCubit>().loadProfile(),
                      child: const Text('إعادة المحاولة'),
                    ),
                  ],
                ),
              );
            } else if (state is ProfileLoaded || state is ProfileUpdated) {
              final customer = (state is ProfileLoaded 
                  ? state.customer 
                  : (state as ProfileUpdated).customer);
              
              return RefreshIndicator(
                onRefresh: () => context.read<ProfileCubit>().loadProfile(),
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Profile Header
                    _buildProfileHeader(customer),
                    const SizedBox(height: 24),
                    
                    // Business Info
                    _buildSectionTitle('معلومات العمل'),
                    _buildInfoCard(
                      icon: Icons.business,
                      title: 'اسم المتجر',
                      value: customer.getShopName('ar'),
                    ),
                    _buildInfoCard(
                      icon: Icons.person,
                      title: 'اسم المسؤول',
                      value: customer.responsiblePersonName,
                    ),
                    _buildInfoCard(
                      icon: Icons.category,
                      title: 'نوع العمل',
                      value: _getBusinessTypeName(customer.businessType),
                    ),
                    _buildInfoCard(
                      icon: Icons.code,
                      title: 'كود العميل',
                      value: customer.customerCode,
                    ),
                    const SizedBox(height: 24),
                    
                    // Location Info
                    _buildSectionTitle('الموقع'),
                    if (customer.city != null)
                      _buildInfoCard(
                        icon: Icons.location_city,
                        title: 'المدينة',
                        value: customer.city!.getName('ar'),
                      ),
                    if (customer.address != null)
                      _buildInfoCard(
                        icon: Icons.location_on,
                        title: 'العنوان',
                        value: customer.address!,
                      ),
                    const SizedBox(height: 24),
                    
                    // Statistics
                    _buildSectionTitle('الإحصائيات'),
                    _buildStatsGrid(customer),
                    const SizedBox(height: 24),
                    
                    // Wallet & Credit
                    _buildSectionTitle('المحفظة والائتمان'),
                    _buildWalletCard(customer),
                    const SizedBox(height: 24),
                    
                    // Actions
                    ElevatedButton.icon(
                      onPressed: () => Navigator.pushNamed(context, '/addresses'),
                      icon: const Icon(Icons.location_on),
                      label: const Text('إدارة العناوين'),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () => _showDeleteAccountDialog(context),
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      label: const Text('حذف الحساب', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
  
  Widget _buildProfileHeader(Customer customer) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.blue.shade100,
              child: Icon(Icons.person, size: 40, color: Colors.blue),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    customer.responsiblePersonName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    customer.getShopName('ar'),
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  if (customer.isApproved)
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        '✓ معتمد',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
  
  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(value),
      ),
    );
  }
  
  Widget _buildStatsGrid(Customer customer) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 2,
      children: [
        _buildStatCard(
          'إجمالي الطلبات',
          customer.totalOrders.toString(),
          Icons.shopping_cart,
          Colors.blue,
        ),
        _buildStatCard(
          'إجمالي الإنفاق',
          '${customer.totalSpent.toStringAsFixed(2)} ر.س',
          Icons.payments,
          Colors.green,
        ),
        _buildStatCard(
          'متوسط قيمة الطلب',
          '${customer.averageOrderValue.toStringAsFixed(2)} ر.س',
          Icons.trending_up,
          Colors.orange,
        ),
        _buildStatCard(
          'نقاط الولاء',
          customer.loyaltyPoints.toString(),
          Icons.stars,
          Colors.purple,
        ),
      ],
    );
  }
  
  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildWalletCard(Customer customer) {
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'رصيد المحفظة',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${customer.walletBalance.toStringAsFixed(2)} ر.س',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'حد الائتمان',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Text(
                      '${customer.creditLimit.toStringAsFixed(2)} ر.س',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'المستخدم',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Text(
                      '${customer.creditUsed.toStringAsFixed(2)} ر.س',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: customer.creditLimit > 0 
                  ? customer.creditUsed / customer.creditLimit 
                  : 0,
              backgroundColor: Colors.grey.shade300,
            ),
            const SizedBox(height: 4),
            Text(
              'المتاح: ${customer.availableCredit.toStringAsFixed(2)} ر.س',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  String _getBusinessTypeName(String type) {
    switch (type) {
      case 'shop':
        return 'متجر';
      case 'technician':
        return 'فني';
      case 'distributor':
        return 'موزع';
      case 'other':
        return 'أخرى';
      default:
        return type;
    }
  }
  
  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف الحساب'),
        content: const Text(
          'هل أنت متأكد من حذف حسابك؟ هذا الإجراء لا يمكن التراجع عنه.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              context.read<ProfileCubit>().deleteAccount();
              Navigator.pop(context);
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            },
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
```

### Edit Profile Screen

```dart
class EditProfileScreen extends StatefulWidget {
  final Customer customer;
  
  const EditProfileScreen({required this.customer});
  
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _responsiblePersonNameController;
  late TextEditingController _shopNameController;
  late TextEditingController _shopNameArController;
  late TextEditingController _addressController;
  String? _selectedBusinessType;
  String? _selectedCityId;
  String? _selectedPaymentMethod;
  String? _selectedContactMethod;
  
  @override
  void initState() {
    super.initState();
    final c = widget.customer;
    _responsiblePersonNameController = TextEditingController(
      text: c.responsiblePersonName,
    );
    _shopNameController = TextEditingController(text: c.shopName);
    _shopNameArController = TextEditingController(text: c.shopNameAr);
    _addressController = TextEditingController(text: c.address);
    _selectedBusinessType = c.businessType;
    _selectedCityId = c.cityId;
    _selectedPaymentMethod = c.preferredPaymentMethod;
    _selectedContactMethod = c.preferredContactMethod;
  }
  
  @override
  void dispose() {
    _responsiblePersonNameController.dispose();
    _shopNameController.dispose();
    _shopNameArController.dispose();
    _addressController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تعديل الملف الشخصي'),
      ),
      body: BlocListener<ProfileCubit, ProfileState>(
        listener: (context, state) {
          if (state is ProfileUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('تم تحديث البروفايل بنجاح')),
            );
            Navigator.pop(context);
          } else if (state is ProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                controller: _responsiblePersonNameController,
                decoration: const InputDecoration(
                  labelText: 'اسم المسؤول *',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال اسم المسؤول';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _shopNameController,
                decoration: const InputDecoration(
                  labelText: 'اسم المتجر (إنجليزي) *',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال اسم المتجر';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _shopNameArController,
                decoration: const InputDecoration(
                  labelText: 'اسم المتجر (عربي)',
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedBusinessType,
                decoration: const InputDecoration(
                  labelText: 'نوع العمل *',
                ),
                items: const [
                  DropdownMenuItem(value: 'shop', child: Text('متجر')),
                  DropdownMenuItem(value: 'technician', child: Text('فني')),
                  DropdownMenuItem(value: 'distributor', child: Text('موزع')),
                  DropdownMenuItem(value: 'other', child: Text('أخرى')),
                ],
                onChanged: (value) => setState(() => _selectedBusinessType = value),
                validator: (value) {
                  if (value == null) {
                    return 'الرجاء اختيار نوع العمل';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'العنوان',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveProfile,
                child: const Text('حفظ التعديلات'),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      final dto = UpdateCustomerProfileDto(
        responsiblePersonName: _responsiblePersonNameController.text,
        shopName: _shopNameController.text,
        shopNameAr: _shopNameArController.text.isEmpty 
            ? null 
            : _shopNameArController.text,
        businessType: _selectedBusinessType,
        address: _addressController.text.isEmpty 
            ? null 
            : _addressController.text,
        preferredPaymentMethod: _selectedPaymentMethod,
        preferredContactMethod: _selectedContactMethod,
      );
      
      context.read<ProfileCubit>().updateProfile(dto);
    }
  }
}
```

---

## 📝 ملخص الـ Endpoints

| Method | Endpoint | Auth | الوصف |
|--------|----------|------|-------|
| GET | `/customer/profile` | ✅ | جلب بروفايل العميل |
| PUT | `/customer/profile` | ✅ | تحديث بروفايل العميل |
| DELETE | `/customer/profile` | ✅ | حذف حساب العميل |
| GET | `/customer/addresses` | ✅ | جلب جميع العناوين |
| GET | `/customer/addresses/:id` | ✅ | جلب عنوان محدد |
| POST | `/customer/addresses` | ✅ | إضافة عنوان جديد |
| PUT | `/customer/addresses/:id` | ✅ | تحديث عنوان |
| DELETE | `/customer/addresses/:id` | ✅ | حذف عنوان |

---

## ⚠️ ملاحظات مهمة

### حالة الحساب (Account Status)
- الحساب يمكن أن يكون في حالة `pending` (قيد المراجعة) حتى يتم اعتماده من قبل الإدارة
- عند حذف الحساب، يتم عمل Soft Delete - البيانات محفوظة ولكن الحساب غير نشط

### الائتمان (Credit)
- `creditLimit`: الحد الأقصى للائتمان المسموح به
- `creditUsed`: المبلغ المستخدم من الائتمان
- `availableCredit`: المبلغ المتاح = `creditLimit - creditUsed`

### نقاط الولاء (Loyalty Points)
- يتم تجميع النقاط عند إتمام الطلبات
- يمكن استبدال النقاط (راجع [wallet.md](./10-wallet.md))

### العناوين
- يمكن للعميل إضافة عناوين متعددة
- عنوان واحد فقط يمكن أن يكون افتراضي (`isDefault: true`)
- عند تعيين عنوان كافتراضي، يتم إلغاء العنوان الافتراضي السابق تلقائياً

---

## 🔗 Related Documentation

- [Auth Module](./1-auth.md) - المصادقة والتسجيل
- [Addresses Module](./6-addresses.md) - إدارة العناوين بالتفصيل
- [Wallet Module](./10-wallet.md) - المحفظة ونقاط الولاء
- [Orders Module](./7-orders.md) - الطلبات والإحصائيات

---

> 🔗 **السابق:** [12-support.md](./12-support.md) - دليل الدعم الفني  
> 🔗 **التالي:** [README.md](./README.md) - الفهرس العام
