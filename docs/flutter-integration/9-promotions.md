# 🎁 Promotions Module - دليل ربط العروض والكوبونات

## 📋 نظرة عامة

هذا الموديول يتعامل مع:
- ✅ العروض الترويجية (Promotions)
- ✅ كوبونات الخصم (Coupons)
- ✅ التحقق من صلاحية الكوبون

> **ملاحظة**: معظم الـ endpoints **عامة** 🌐

---

## 📁 Flutter Models

### Promotion Model

```dart
class Promotion {
  final String id;
  final String name;
  final String nameAr;
  final String code;
  final String? description;
  final String? descriptionAr;
  final DiscountType discountType;
  final double? discountValue;
  final double? maxDiscountAmount;
  final int? buyQuantity;
  final int? getQuantity;
  final double? getDiscountPercentage;
  final DateTime startDate;
  final DateTime endDate;
  final double? minOrderAmount;
  final int? minQuantity;
  final PromotionScope scope;
  final int? usageLimit;
  final int? usageLimitPerCustomer;
  final int usedCount;
  final String? image;
  final String? badgeText;
  final String? badgeColor;
  final bool isActive;
  final bool isAutoApply;
  final int priority;
  final bool isStackable;

  Promotion({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.code,
    this.description,
    this.descriptionAr,
    required this.discountType,
    this.discountValue,
    this.maxDiscountAmount,
    this.buyQuantity,
    this.getQuantity,
    this.getDiscountPercentage,
    required this.startDate,
    required this.endDate,
    this.minOrderAmount,
    this.minQuantity,
    required this.scope,
    this.usageLimit,
    this.usageLimitPerCustomer,
    required this.usedCount,
    this.image,
    this.badgeText,
    this.badgeColor,
    required this.isActive,
    required this.isAutoApply,
    required this.priority,
    required this.isStackable,
  });

  factory Promotion.fromJson(Map<String, dynamic> json) {
    return Promotion(
      id: json['_id'] ?? json['id'],
      name: json['name'],
      nameAr: json['nameAr'],
      code: json['code'],
      description: json['description'],
      descriptionAr: json['descriptionAr'],
      discountType: DiscountType.fromString(json['discountType']),
      discountValue: json['discountValue']?.toDouble(),
      maxDiscountAmount: json['maxDiscountAmount']?.toDouble(),
      buyQuantity: json['buyQuantity'],
      getQuantity: json['getQuantity'],
      getDiscountPercentage: json['getDiscountPercentage']?.toDouble(),
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      minOrderAmount: json['minOrderAmount']?.toDouble(),
      minQuantity: json['minQuantity'],
      scope: PromotionScope.fromString(json['scope']),
      usageLimit: json['usageLimit'],
      usageLimitPerCustomer: json['usageLimitPerCustomer'],
      usedCount: json['usedCount'] ?? 0,
      image: json['image'],
      badgeText: json['badgeText'],
      badgeColor: json['badgeColor'],
      isActive: json['isActive'] ?? true,
      isAutoApply: json['isAutoApply'] ?? false,
      priority: json['priority'] ?? 0,
      isStackable: json['isStackable'] ?? false,
    );
  }

  /// الحصول على الاسم حسب اللغة
  String getName(String locale) => locale == 'ar' ? nameAr : name;
  
  /// الحصول على الوصف حسب اللغة
  String? getDescription(String locale) => 
      locale == 'ar' ? descriptionAr : description;
  
  /// هل العرض صالح الآن؟
  bool get isValid {
    final now = DateTime.now();
    return isActive && 
           now.isAfter(startDate) && 
           now.isBefore(endDate) &&
           (usageLimit == null || usedCount < usageLimit!);
  }
  
  /// عدد الأيام المتبقية
  int get daysRemaining => endDate.difference(DateTime.now()).inDays;
  
  /// نص الخصم
  String get discountText {
    switch (discountType) {
      case DiscountType.percentage:
        return '${discountValue?.toInt()}%';
      case DiscountType.fixedAmount:
        return '${discountValue?.toStringAsFixed(0)} ر.س';
      case DiscountType.buyXGetY:
        return 'اشتر $buyQuantity واحصل على $getQuantity';
      case DiscountType.freeShipping:
        return 'شحن مجاني';
    }
  }
  
  /// تحويل اللون hex إلى Color
  Color? getBadgeColor() {
    if (badgeColor == null) return null;
    final hex = badgeColor!.replaceFirst('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }
}
```

### Coupon Model

```dart
class Coupon {
  final String id;
  final String code;
  final String name;
  final String nameAr;
  final String? description;
  final CouponDiscountType discountType;
  final double? discountValue;
  final double? maxDiscountAmount;
  final DateTime startDate;
  final DateTime expiryDate;
  final double? minOrderAmount;
  final bool firstOrderOnly;
  final int? usageLimit;
  final int usageLimitPerCustomer;
  final int usedCount;
  final bool isActive;
  final bool isPublic;

  Coupon({
    required this.id,
    required this.code,
    required this.name,
    required this.nameAr,
    this.description,
    required this.discountType,
    this.discountValue,
    this.maxDiscountAmount,
    required this.startDate,
    required this.expiryDate,
    this.minOrderAmount,
    required this.firstOrderOnly,
    this.usageLimit,
    required this.usageLimitPerCustomer,
    required this.usedCount,
    required this.isActive,
    required this.isPublic,
  });

  factory Coupon.fromJson(Map<String, dynamic> json) {
    return Coupon(
      id: json['_id'] ?? json['id'],
      code: json['code'],
      name: json['name'],
      nameAr: json['nameAr'],
      description: json['description'],
      discountType: CouponDiscountType.fromString(json['discountType']),
      discountValue: json['discountValue']?.toDouble(),
      maxDiscountAmount: json['maxDiscountAmount']?.toDouble(),
      startDate: DateTime.parse(json['startDate']),
      expiryDate: DateTime.parse(json['expiryDate']),
      minOrderAmount: json['minOrderAmount']?.toDouble(),
      firstOrderOnly: json['firstOrderOnly'] ?? false,
      usageLimit: json['usageLimit'],
      usageLimitPerCustomer: json['usageLimitPerCustomer'] ?? 1,
      usedCount: json['usedCount'] ?? 0,
      isActive: json['isActive'] ?? true,
      isPublic: json['isPublic'] ?? false,
    );
  }

  /// الحصول على الاسم حسب اللغة
  String getName(String locale) => locale == 'ar' ? nameAr : name;
  
  /// هل الكوبون صالح؟
  bool get isValid {
    final now = DateTime.now();
    return isActive && 
           now.isAfter(startDate) && 
           now.isBefore(expiryDate);
  }
  
  /// نص الخصم
  String get discountText {
    switch (discountType) {
      case CouponDiscountType.percentage:
        return '${discountValue?.toInt()}%';
      case CouponDiscountType.fixedAmount:
        return '${discountValue?.toStringAsFixed(0)} ر.س';
      case CouponDiscountType.freeShipping:
        return 'شحن مجاني';
    }
  }
}
```

### CouponValidation Model

```dart
class CouponValidation {
  final bool isValid;
  final Coupon? coupon;
  final double? discountAmount;
  final String? message;
  final String? messageAr;
  final ValidationError? error;

  CouponValidation({
    required this.isValid,
    this.coupon,
    this.discountAmount,
    this.message,
    this.messageAr,
    this.error,
  });

  factory CouponValidation.fromJson(Map<String, dynamic> json) {
    return CouponValidation(
      isValid: json['isValid'] ?? false,
      coupon: json['coupon'] != null 
          ? Coupon.fromJson(json['coupon']) 
          : null,
      discountAmount: json['discountAmount']?.toDouble(),
      message: json['message'],
      messageAr: json['messageAr'],
      error: json['error'] != null 
          ? ValidationError.fromString(json['error']) 
          : null,
    );
  }

  /// الحصول على الرسالة حسب اللغة
  String getMessage(String locale) => 
      locale == 'ar' ? (messageAr ?? '') : (message ?? '');
}
```

### Enums

```dart
/// نوع خصم العرض
enum DiscountType {
  percentage,    // نسبة مئوية
  fixedAmount,   // مبلغ ثابت
  buyXGetY,      // اشتر X واحصل على Y
  freeShipping;  // شحن مجاني

  static DiscountType fromString(String value) {
    switch (value) {
      case 'percentage': return DiscountType.percentage;
      case 'fixed_amount': return DiscountType.fixedAmount;
      case 'buy_x_get_y': return DiscountType.buyXGetY;
      case 'free_shipping': return DiscountType.freeShipping;
      default: return DiscountType.percentage;
    }
  }

  String get displayNameAr {
    switch (this) {
      case DiscountType.percentage: return 'نسبة مئوية';
      case DiscountType.fixedAmount: return 'مبلغ ثابت';
      case DiscountType.buyXGetY: return 'اشتر X واحصل على Y';
      case DiscountType.freeShipping: return 'شحن مجاني';
    }
  }
}

/// نطاق العرض
enum PromotionScope {
  all,                 // جميع المنتجات
  specificProducts,    // منتجات محددة
  specificCategories,  // فئات محددة
  specificBrands;      // علامات تجارية محددة

  static PromotionScope fromString(String value) {
    switch (value) {
      case 'all': return PromotionScope.all;
      case 'specific_products': return PromotionScope.specificProducts;
      case 'specific_categories': return PromotionScope.specificCategories;
      case 'specific_brands': return PromotionScope.specificBrands;
      default: return PromotionScope.all;
    }
  }
}

/// نوع خصم الكوبون
enum CouponDiscountType {
  percentage,
  fixedAmount,
  freeShipping;

  static CouponDiscountType fromString(String value) {
    switch (value) {
      case 'percentage': return CouponDiscountType.percentage;
      case 'fixed_amount': return CouponDiscountType.fixedAmount;
      case 'free_shipping': return CouponDiscountType.freeShipping;
      default: return CouponDiscountType.percentage;
    }
  }
}

/// أخطاء التحقق من الكوبون
enum ValidationError {
  couponNotFound,
  couponExpired,
  couponNotStarted,
  couponInactive,
  usageLimitReached,
  customerUsageLimitReached,
  minOrderNotMet,
  notFirstOrder,
  notApplicable;

  static ValidationError fromString(String value) {
    switch (value) {
      case 'COUPON_NOT_FOUND': return ValidationError.couponNotFound;
      case 'COUPON_EXPIRED': return ValidationError.couponExpired;
      case 'COUPON_NOT_STARTED': return ValidationError.couponNotStarted;
      case 'COUPON_INACTIVE': return ValidationError.couponInactive;
      case 'USAGE_LIMIT_REACHED': return ValidationError.usageLimitReached;
      case 'CUSTOMER_USAGE_LIMIT_REACHED': return ValidationError.customerUsageLimitReached;
      case 'MIN_ORDER_NOT_MET': return ValidationError.minOrderNotMet;
      case 'NOT_FIRST_ORDER': return ValidationError.notFirstOrder;
      case 'NOT_APPLICABLE': return ValidationError.notApplicable;
      default: return ValidationError.couponNotFound;
    }
  }

  String get displayNameAr {
    switch (this) {
      case ValidationError.couponNotFound: return 'الكوبون غير موجود';
      case ValidationError.couponExpired: return 'الكوبون منتهي الصلاحية';
      case ValidationError.couponNotStarted: return 'الكوبون لم يبدأ بعد';
      case ValidationError.couponInactive: return 'الكوبون غير نشط';
      case ValidationError.usageLimitReached: return 'تم استنفاد الكوبون';
      case ValidationError.customerUsageLimitReached: return 'استخدمت هذا الكوبون من قبل';
      case ValidationError.minOrderNotMet: return 'الحد الأدنى للطلب غير مستوفى';
      case ValidationError.notFirstOrder: return 'الكوبون للطلب الأول فقط';
      case ValidationError.notApplicable: return 'الكوبون لا ينطبق على هذه المنتجات';
    }
  }
}
```

---

## 📞 API Endpoints

### 🎁 Promotions

#### 1️⃣ جلب العروض النشطة

**Endpoint:** `GET /promotions/active` 🌐 (Public)

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "_id": "507f1f77bcf86cd799439011",
      "name": "Summer Sale",
      "nameAr": "تخفيضات الصيف",
      "code": "SUMMER2024",
      "description": "Up to 30% off on all products",
      "descriptionAr": "خصم يصل إلى 30% على جميع المنتجات",
      "discountType": "percentage",
      "discountValue": 30,
      "maxDiscountAmount": 500,
      "startDate": "2024-06-01T00:00:00Z",
      "endDate": "2024-08-31T23:59:59Z",
      "minOrderAmount": 200,
      "minQuantity": null,
      "scope": "all",
      "usageLimit": 10000,
      "usageLimitPerCustomer": 5,
      "usedCount": 1523,
      "image": "https://example.com/summer-sale.jpg",
      "badgeText": "HOT",
      "badgeColor": "#FF5722",
      "isActive": true,
      "isAutoApply": true,
      "priority": 10,
      "isStackable": false,
      "createdAt": "2024-05-01T00:00:00Z",
      "updatedAt": "2024-06-01T00:00:00Z"
    },
    {
      "_id": "507f1f77bcf86cd799439012",
      "name": "Buy 2 Get 1 Free",
      "nameAr": "اشتر 2 واحصل على 1 مجاناً",
      "code": "BUY2GET1",
      "description": "Buy 2 items and get 1 free",
      "descriptionAr": "اشتر 2 واحصل على 1 مجاناً",
      "discountType": "buy_x_get_y",
      "buyQuantity": 2,
      "getQuantity": 1,
      "getDiscountPercentage": 100,
      "startDate": "2024-01-01T00:00:00Z",
      "endDate": "2024-12-31T23:59:59Z",
      "scope": "specific_categories",
      "usedCount": 456,
      "isActive": true,
      "isAutoApply": false,
      "priority": 5,
      "isStackable": true,
      "createdAt": "2024-01-01T00:00:00Z",
      "updatedAt": "2024-01-01T00:00:00Z"
    }
  ],
  "message": "Promotions retrieved",
  "messageAr": "تم استرجاع العروض"
}
```

**Flutter Code:**
```dart
class PromotionsService {
  final Dio _dio;
  
  PromotionsService(this._dio);
  
  /// جلب العروض النشطة
  Future<List<Promotion>> getActivePromotions() async {
    final response = await _dio.get('/promotions/active');
    
    if (response.data['success']) {
      return (response.data['data'] as List)
          .map((p) => Promotion.fromJson(p))
          .toList();
    }
    throw Exception(response.data['messageAr'] ?? response.data['message']);
  }
}
```

---

### 🎟️ Coupons

#### 2️⃣ جلب الكوبونات العامة

**Endpoint:** `GET /promotions/coupons/public` 🌐 (Public)

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "_id": "507f1f77bcf86cd799439021",
      "code": "WELCOME10",
      "name": "Welcome Discount",
      "nameAr": "خصم الترحيب",
      "description": "10% off on your first order",
      "discountType": "percentage",
      "discountValue": 10,
      "maxDiscountAmount": 100,
      "startDate": "2024-01-01T00:00:00Z",
      "expiryDate": "2024-12-31T23:59:59Z",
      "minOrderAmount": 100,
      "firstOrderOnly": true,
      "usageLimit": 1000,
      "usageLimitPerCustomer": 1,
      "usedCount": 234,
      "isActive": true,
      "isPublic": true,
      "createdAt": "2024-01-01T00:00:00Z",
      "updatedAt": "2024-01-15T10:30:00Z"
    },
    {
      "_id": "507f1f77bcf86cd799439022",
      "code": "FREESHIP",
      "name": "Free Shipping",
      "nameAr": "شحن مجاني",
      "description": "Free shipping on orders above 300",
      "discountType": "free_shipping",
      "startDate": "2024-01-01T00:00:00Z",
      "expiryDate": "2024-12-31T23:59:59Z",
      "minOrderAmount": 300,
      "firstOrderOnly": false,
      "usageLimitPerCustomer": 10,
      "usedCount": 567,
      "isActive": true,
      "isPublic": true,
      "createdAt": "2024-01-01T00:00:00Z",
      "updatedAt": "2024-01-01T00:00:00Z"
    }
  ],
  "message": "Coupons retrieved",
  "messageAr": "تم استرجاع الكوبونات"
}
```

**Flutter Code:**
```dart
/// جلب الكوبونات العامة المتاحة
Future<List<Coupon>> getPublicCoupons() async {
  final response = await _dio.get('/promotions/coupons/public');
  
  if (response.data['success']) {
    return (response.data['data'] as List)
        .map((c) => Coupon.fromJson(c))
        .toList();
  }
  throw Exception(response.data['messageAr'] ?? response.data['message']);
}
```

---

#### 3️⃣ التحقق من صلاحية كوبون

**Endpoint:** `POST /promotions/coupons/validate`

**Headers:** `Authorization: Bearer <accessToken>` 🔒

**Request Body:**
```json
{
  "code": "WELCOME10",
  "orderAmount": 500.00
}
```

**Parameters:**
- `code`: مطلوب، كود الكوبون (string)
- `orderAmount`: مطلوب، المبلغ الإجمالي للطلب (number)

**Success Response:**
```json
{
  "success": true,
  "data": {
    "coupon": {
      "_id": "507f1f77bcf86cd799439011",
      "code": "WELCOME10",
      "name": "Welcome Discount",
      "nameAr": "خصم الترحيب",
      "description": "10% off on your first order",
      "discountType": "percentage",
      "discountValue": 10,
      "maxDiscountAmount": 100,
      "startDate": "2024-01-01T00:00:00Z",
      "expiryDate": "2024-12-31T23:59:59Z",
      "minOrderAmount": 100,
      "firstOrderOnly": true,
      "usageLimit": 1000,
      "usageLimitPerCustomer": 1,
      "usedCount": 245,
      "isActive": true,
      "isPublic": true,
      "createdAt": "2024-01-01T00:00:00Z",
      "updatedAt": "2024-01-15T10:30:00Z"
    },
    "discountAmount": 50.00
  },
  "message": "Coupon is valid",
  "messageAr": "الكوبون صحيح"
}
```

**Error Response (Validation Failed):**
```json
{
  "success": false,
  "message": "Minimum order amount is 100",
  "messageAr": "الحد الأدنى للطلب هو 100 ر.س",
  "statusCode": 400
}
```

**Error Response (Coupon Not Found):**
```json
{
  "success": false,
  "message": "Coupon not found",
  "messageAr": "الكوبون غير موجود",
  "statusCode": 404
}
```

**Flutter Code:**
```dart
/// التحقق من صلاحية كوبون
Future<Map<String, dynamic>> validateCoupon({
  required String code,
  required double orderAmount,
}) async {
  try {
    final response = await _dio.post(
      '/promotions/coupons/validate',
      data: {
        'code': code,
        'orderAmount': orderAmount,
      },
    );
    
    if (response.data['success']) {
      return response.data['data'];
    }
    throw Exception(response.data['messageAr'] ?? response.data['message']);
  } on DioException catch (e) {
    if (e.response != null) {
      final data = e.response!.data;
      throw Exception(data['messageAr'] ?? data['message'] ?? 'فشل التحقق من الكوبون');
    }
    throw Exception('حدث خطأ في الاتصال');
  }
}
```

---

## 🧩 PromotionsService الكامل

```dart
import 'package:dio/dio.dart';

class PromotionsService {
  final Dio _dio;
  
  PromotionsService(this._dio);
  
  // ═════════════════════════════════════
  // Promotions
  // ═════════════════════════════════════
  
  Future<List<Promotion>> getActivePromotions() async {
    final response = await _dio.get('/promotions/active');
    
    if (response.data['success']) {
      return (response.data['data'] as List)
          .map((p) => Promotion.fromJson(p))
          .toList();
    }
    throw Exception(response.data['messageAr']);
  }
  
  // ═════════════════════════════════════
  // Coupons
  // ═════════════════════════════════════
  
  Future<List<Coupon>> getPublicCoupons() async {
    final response = await _dio.get('/promotions/coupons/public');
    
    if (response.data['success']) {
      return (response.data['data'] as List)
          .map((c) => Coupon.fromJson(c))
          .toList();
    }
    throw Exception(response.data['messageAr'] ?? response.data['message']);
  }
  
  Future<Map<String, dynamic>> validateCoupon({
    required String code,
    required double orderAmount,
  }) async {
    try {
      final response = await _dio.post(
        '/promotions/coupons/validate',
        data: {
          'code': code,
          'orderAmount': orderAmount,
        },
      );
      
      if (response.data['success']) {
        return response.data['data'];
      }
      throw Exception(response.data['messageAr'] ?? response.data['message']);
    } on DioException catch (e) {
      if (e.response != null) {
        final data = e.response!.data;
        throw Exception(data['messageAr'] ?? data['message'] ?? 'فشل التحقق من الكوبون');
      }
      throw Exception('حدث خطأ في الاتصال');
    }
  }
}
```

---

## 🎯 أمثلة الاستخدام

### عرض شريط العروض

```dart
class PromotionsBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Promotion>>(
      future: promotionsService.getActivePromotions(),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          return SizedBox(
            height: 180,
            child: PageView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final promo = snapshot.data![index];
                return _buildPromotionCard(promo);
              },
            ),
          );
        }
        return SizedBox.shrink();
      },
    );
  }
  
  Widget _buildPromotionCard(Promotion promo) {
    return Container(
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: promo.image != null
            ? DecorationImage(
                image: NetworkImage(promo.image!),
                fit: BoxFit.cover,
              )
            : null,
        gradient: promo.image == null
            ? LinearGradient(
                colors: [Colors.purple, Colors.deepPurple],
              )
            : null,
      ),
      child: Stack(
        children: [
          // Overlay
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.7),
                ],
              ),
            ),
          ),
          
          // Content
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Badge
                if (promo.badgeText != null)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: promo.getBadgeColor() ?? Colors.red,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      promo.badgeText!,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                
                SizedBox(height: 8),
                
                Text(
                  promo.getName('ar'),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                Text(
                  promo.discountText,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                if (promo.daysRemaining <= 7)
                  Text(
                    'متبقي ${promo.daysRemaining} أيام',
                    style: TextStyle(
                      color: Colors.orange[300],
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

### حقل إدخال الكوبون في Checkout

```dart
class CouponInput extends StatefulWidget {
  final double orderTotal;
  final Function(CouponValidation) onCouponApplied;
  final VoidCallback onCouponRemoved;
  
  const CouponInput({
    required this.orderTotal,
    required this.onCouponApplied,
    required this.onCouponRemoved,
  });
  
  @override
  State<CouponInput> createState() => _CouponInputState();
}

class _CouponInputState extends State<CouponInput> {
  final controller = TextEditingController();
  bool isLoading = false;
  CouponValidation? appliedCoupon;
  String? errorMessage;
  
  Future<void> _applyCoupon() async {
    if (controller.text.isEmpty) return;
    
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    
    try {
      final result = await promotionsService.validateCoupon(
        code: controller.text.toUpperCase(),
        orderTotal: widget.orderTotal,
      );
      
      if (result.isValid) {
        setState(() => appliedCoupon = result);
        widget.onCouponApplied(result);
      } else {
        setState(() => errorMessage = result.getMessage('ar'));
      }
    } catch (e) {
      setState(() => errorMessage = 'حدث خطأ، حاول مرة أخرى');
    } finally {
      setState(() => isLoading = false);
    }
  }
  
  void _removeCoupon() {
    setState(() {
      appliedCoupon = null;
      controller.clear();
    });
    widget.onCouponRemoved();
  }
  
  @override
  Widget build(BuildContext context) {
    // كوبون مطبق
    if (appliedCoupon != null) {
      return Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.green[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.green),
        ),
        child: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    appliedCoupon!.coupon!.code,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'خصم: ${appliedCoupon!.discountAmount?.toStringAsFixed(2)} ر.س',
                    style: TextStyle(color: Colors.green[700]),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.close, color: Colors.red),
              onPressed: _removeCoupon,
            ),
          ],
        ),
      );
    }
    
    // حقل الإدخال
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: 'أدخل كود الكوبون',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.local_offer),
                  errorText: errorMessage,
                ),
                textCapitalization: TextCapitalization.characters,
              ),
            ),
            SizedBox(width: 12),
            ElevatedButton(
              onPressed: isLoading ? null : _applyCoupon,
              child: isLoading 
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text('تطبيق'),
            ),
          ],
        ),
        
        // الكوبونات المتاحة
        SizedBox(height: 8),
        TextButton(
          onPressed: () => _showAvailableCoupons(context),
          child: Text('عرض الكوبونات المتاحة'),
        ),
      ],
    );
  }
  
  void _showAvailableCoupons(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => FutureBuilder<List<Coupon>>(
        future: promotionsService.getPublicCoupons(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final coupon = snapshot.data![index];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(coupon.discountText),
                    ),
                    title: Text(coupon.code),
                    subtitle: Text(coupon.getName('ar')),
                    trailing: TextButton(
                      onPressed: () {
                        controller.text = coupon.code;
                        Navigator.pop(context);
                        _applyCoupon();
                      },
                      child: Text('استخدام'),
                    ),
                  ),
                );
              },
            );
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
```

### عرض بطاقة عرض "اشتر X واحصل على Y"

```dart
class BuyXGetYCard extends StatelessWidget {
  final Promotion promotion;
  
  const BuyXGetYCard({required this.promotion});
  
  @override
  Widget build(BuildContext context) {
    if (promotion.discountType != DiscountType.buyXGetY) {
      return SizedBox.shrink();
    }
    
    return Card(
      color: Colors.amber[50],
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            // Icon
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.card_giftcard, color: Colors.white, size: 32),
            ),
            
            SizedBox(width: 16),
            
            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    promotion.getName('ar'),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 4),
                  RichText(
                    text: TextSpan(
                      style: TextStyle(color: Colors.black87),
                      children: [
                        TextSpan(text: 'اشتر '),
                        TextSpan(
                          text: '${promotion.buyQuantity}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.amber[800],
                          ),
                        ),
                        TextSpan(text: ' واحصل على '),
                        TextSpan(
                          text: '${promotion.getQuantity}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.amber[800],
                          ),
                        ),
                        if (promotion.getDiscountPercentage == 100)
                          TextSpan(
                            text: ' مجاناً!',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          )
                        else
                          TextSpan(
                            text: ' بخصم ${promotion.getDiscountPercentage?.toInt()}%',
                          ),
                      ],
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
}
```

---

## ⚠️ الأخطاء المحتملة

### Validation Errors

| HTTP Code | Message | الوصف |
|-----------|---------|-------|
| `404` | Coupon not found | الكوبون غير موجود |
| `400` | Coupon is not active | الكوبون غير نشط |
| `400` | Coupon has expired or not yet valid | الكوبون منتهي الصلاحية أو لم يبدأ بعد |
| `400` | Minimum order amount is X | الحد الأدنى للطلب غير مستوفى |
| `400` | Coupon is for first orders only | الكوبون للطلب الأول فقط |
| `400` | Coupon usage limit reached | تم استنفاد الكوبون |
| `400` | You have already used this coupon | استخدمت هذا الكوبون من قبل |

### معالجة الأخطاء

```dart
try {
  final result = await promotionsService.validateCoupon(
    code: couponCode,
    orderAmount: cartTotal,
  );
  
  // Success - apply discount
  final coupon = Coupon.fromJson(result['coupon']);
  final discountAmount = result['discountAmount'] as double;
  
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('تم تطبيق الكوبون! خصم ${discountAmount.toStringAsFixed(2)} ر.س'),
      backgroundColor: Colors.green,
    ),
  );
  
} on DioException catch (e) {
  String errorMessage = 'حدث خطأ غير متوقع';
  
  if (e.response != null) {
    final statusCode = e.response!.statusCode;
    final data = e.response!.data;
    
    switch (statusCode) {
      case 400:
        errorMessage = data['messageAr'] ?? data['message'] ?? 'الكوبون غير صالح';
        break;
      case 404:
        errorMessage = 'الكوبون غير موجود';
        break;
      default:
        errorMessage = data['messageAr'] ?? data['message'] ?? 'حدث خطأ في السيرفر';
    }
  }
  
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(errorMessage),
      backgroundColor: Colors.red,
    ),
  );
} catch (e) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('حدث خطأ: ${e.toString()}'),
      backgroundColor: Colors.red,
    ),
  );
}
```

---

## 📝 ملخص الـ Endpoints

### Customer Endpoints

| Method | Endpoint | Auth | الوصف |
|--------|----------|------|-------|
| GET | `/promotions/active` | ❌ | العروض النشطة (Public) |
| GET | `/promotions/coupons/public` | ❌ | الكوبونات العامة (Public) |
| POST | `/promotions/coupons/validate` | ✅ | التحقق من صلاحية كوبون |

### Admin Endpoints (للتوثيق فقط)

| Method | Endpoint | Auth | الوصف |
|--------|----------|------|-------|
| GET | `/promotions` | Admin | جميع العروض |
| GET | `/promotions/:id` | Admin | تفاصيل عرض |
| POST | `/promotions` | Admin | إنشاء عرض |
| PUT | `/promotions/:id` | Admin | تحديث عرض |
| DELETE | `/promotions/:id` | Super Admin | حذف عرض |
| GET | `/promotions/coupons` | Admin | جميع الكوبونات |
| POST | `/promotions/coupons` | Admin | إنشاء كوبون |
| PUT | `/promotions/coupons/:id` | Admin | تحديث كوبون |
| DELETE | `/promotions/coupons/:id` | Super Admin | حذف كوبون |
| GET | `/promotions/coupons/:id/statistics` | Admin | إحصائيات كوبون |

---

> 🔗 **السابق:** [returns.md](./returns.md) - دليل المرتجعات  
> 🔗 **التالي:** [support.md](./support.md) - دليل الدعم الفني
