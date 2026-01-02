# 📱 دليل ربط Flutter مع الـ Backend

هذا المجلد يحتوي على توثيق شامل لكيفية ربط تطبيق Flutter مع الـ Backend API.

## 📂 الهيكل

```
flutter-integration/
├── README.md          # هذا الملف
├── auth.md            # المصادقة والتسجيل
├── products.md        # المنتجات والكاتالوج (قريباً)
├── cart.md            # السلة (قريباً)
├── orders.md          # الطلبات (قريباً)
├── customers.md       # العملاء (قريباً)
└── ...                # المزيد من الـ Modules
```

## 🔗 Base URL

```dart
const String baseUrl = 'https://api.example.com/v1';
```

## 📦 شكل الاستجابة القياسي

جميع الـ API endpoints ترجع استجابة بهذا الشكل:

```dart
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String message;
  final String messageAr;
  final dynamic error;
  
  ApiResponse({
    required this.success,
    this.data,
    required this.message,
    required this.messageAr,
    this.error,
  });
  
  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>)? fromJsonT,
  ) {
    return ApiResponse(
      success: json['success'] ?? false,
      data: json['data'] != null && fromJsonT != null 
          ? fromJsonT(json['data']) 
          : json['data'],
      message: json['message'] ?? '',
      messageAr: json['messageAr'] ?? '',
      error: json['error'],
    );
  }
}
```

## 🔐 إعداد Dio / HTTP Client

```dart
import 'package:dio/dio.dart';

class ApiClient {
  late Dio _dio;
  String? _accessToken;
  String? _refreshToken;
  
  ApiClient() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));
    
    // إضافة Interceptor للـ Token
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        if (_accessToken != null) {
          options.headers['Authorization'] = 'Bearer $_accessToken';
        }
        return handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401 && _refreshToken != null) {
          // محاولة تحديث الـ Token
          try {
            await _refreshAccessToken();
            // إعادة محاولة الطلب الأصلي
            final opts = error.requestOptions;
            opts.headers['Authorization'] = 'Bearer $_accessToken';
            final response = await _dio.fetch(opts);
            return handler.resolve(response);
          } catch (e) {
            // فشل التحديث - تسجيل خروج المستخدم
            logout();
          }
        }
        return handler.next(error);
      },
    ));
  }
  
  Future<void> _refreshAccessToken() async {
    final response = await _dio.post('/auth/refresh', data: {
      'refreshToken': _refreshToken,
    });
    
    if (response.data['success']) {
      _accessToken = response.data['data']['accessToken'];
      _refreshToken = response.data['data']['refreshToken'];
      // حفظ الـ tokens في التخزين المحلي
    }
  }
  
  void setTokens(String accessToken, String refreshToken) {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
  }
  
  void logout() {
    _accessToken = null;
    _refreshToken = null;
    // مسح التخزين المحلي
  }
}
```

## 🚀 البدء السريع

1. ابدأ بقراءة ملف [auth.md](./auth.md) لفهم نظام المصادقة
2. استخدم الـ Models و Methods المعطاة مباشرة في مشروعك
3. كل endpoint موثق مع:
   - الـ Request (المطلوب إرساله)
   - الـ Response (المتوقع استلامه)
   - الـ Errors المحتملة
   - مثال كامل للكود

---

> **ملاحظة**: هذا التوثيق مخصص للـ **تطبيق العميل (Customer App)** وليس للوحة الإدارة.
