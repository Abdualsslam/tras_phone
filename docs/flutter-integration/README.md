# 📱 دليل ربط Flutter مع الـ Backend

هذا المجلد يحتوي على توثيق شامل لكيفية ربط تطبيق Flutter مع الـ Backend API.

## 📂 الهيكل

```
flutter-integration/
├── README.md           # هذا الملف
├── auth.md             # المصادقة والتسجيل
├── products.md         # المنتجات
├── catalog.md          # الكاتالوج (الفئات والعلامات التجارية)
├── orders.md           # الطلبات والسلة
├── customers.md        # بيانات العميل والعناوين
├── notifications.md    # الإشعارات
├── wallet.md           # المحفظة ونظام الولاء
├── locations.md        # المواقع والمدن ومناطق الشحن
├── returns.md          # المرتجعات
├── promotions.md       # العروض والكوبونات
└── support.md          # الدعم الفني والمحادثة المباشرة
```

## 📋 قائمة الـ Modules

| Module | ملف التوثيق | الوصف |
|--------|-------------|-------|
| 🔐 Auth | [auth.md](./auth.md) | التسجيل، تسجيل الدخول، OTP، تحديث التوكن |
| 📦 Products | [products.md](./products.md) | عرض المنتجات، البحث، التفاصيل، المراجعات |
| 📂 Catalog | [catalog.md](./catalog.md) | الفئات، العلامات التجارية، مستويات الأسعار |
| 🛒 Orders | [orders.md](./orders.md) | السلة، إنشاء الطلبات، التتبع |
| 👤 Customers | [customers.md](./customers.md) | الملف الشخصي، العناوين، المفضلة |
| 🔔 Notifications | [notifications.md](./notifications.md) | الإشعارات، FCM Token |
| 💰 Wallet | [wallet.md](./wallet.md) | المحفظة، نقاط الولاء، المستويات |
| 📍 Locations | [locations.md](./locations.md) | المدن، الأحياء، حساب الشحن |
| 🔄 Returns | [returns.md](./returns.md) | طلبات الإرجاع، أسباب الإرجاع |
| 🎁 Promotions | [promotions.md](./promotions.md) | العروض، الكوبونات، التحقق من الصلاحية |
| 🎧 Support | [support.md](./support.md) | التذاكر، المحادثة المباشرة، التقييم |

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

## 🔒 الـ Endpoints حسب المصادقة

### 🌐 Public Endpoints (بدون Token)

هذه الـ endpoints لا تحتاج تسجيل دخول:

| Endpoint | الوصف |
|----------|-------|
| `POST /auth/register` | التسجيل |
| `POST /auth/login` | تسجيل الدخول |
| `POST /auth/verify-otp` | التحقق من OTP |
| `GET /catalog/*` | الكاتالوج (الفئات، العلامات) |
| `GET /products` | قائمة المنتجات |
| `GET /products/:id` | تفاصيل منتج |
| `GET /promotions/active` | العروض النشطة |
| `GET /promotions/coupons/public` | الكوبونات العامة |
| `GET /locations/*` | المواقع والمدن |
| `GET /returns/reasons` | أسباب الإرجاع |
| `GET /tickets/categories` | فئات التذاكر |
| `GET /wallet/tiers` | مستويات الولاء |

### 🔒 Protected Endpoints (تحتاج Token)

بقية الـ endpoints تحتاج `Authorization: Bearer <token>`

## 🚀 البدء السريع

1. **ابدأ بالمصادقة**: اقرأ [auth.md](./auth.md) لفهم نظام التسجيل وتسجيل الدخول
2. **استعرض المنتجات**: اقرأ [products.md](./products.md) و [catalog.md](./catalog.md)
3. **أنشئ الطلبات**: اقرأ [orders.md](./orders.md) لفهم السلة والطلبات
4. **أضف الميزات الإضافية**: Wallet، Promotions، Support حسب الحاجة

## 📝 كل ملف توثيق يحتوي على:

- ✅ **Flutter Models** كاملة مع `fromJson`
- ✅ **Enums** مع الترجمة العربية
- ✅ **API Endpoints** مفصلة
- ✅ **Request/Response** أمثلة
- ✅ **Service class** جاهز للاستخدام
- ✅ **أمثلة UI** عملية
- ✅ **الأخطاء المحتملة** وكيفية التعامل معها

## 🛠️ الأدوات المطلوبة

```yaml
dependencies:
  dio: ^5.0.0
  flutter_secure_storage: ^9.0.0  # لتخزين الـ tokens
  shared_preferences: ^2.2.0      # للتخزين المحلي
```

---

> **ملاحظة**: هذا التوثيق مخصص للـ **تطبيق العميل (Customer App)** وليس للوحة الإدارة.
