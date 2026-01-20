# 📱 Devices & Quality Types - دليل ربط الأجهزة وأنواع الجودة

## 📋 نظرة عامة

هذا الملف يحتوي على جميع API endpoints المتعلقة بالأجهزة/الموديلات (Devices) وأنواع الجودة (Quality Types).

> **ملاحظة**: جميع الـ endpoints هنا عامة (Public) ولا تحتاج Token.

---

## 📞 API Endpoints

### 📱 Devices

#### 9️⃣ جلب الأجهزة النشطة

**Endpoint:** `GET /catalog/devices`

**Query Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `limit` | number | ❌ | الحد الأقصى للنتائج |
| `popular` | boolean | ❌ | فلترة الأجهزة الشائعة فقط |

**Response:**
```dart
{
  "success": true,
  "data": [
    {
      "_id": "...",
      "brandId": {
        "_id": "...",
        "name": "Apple",
        "nameAr": "أبل",
        "slug": "apple",
        "logo": "https://..."
      },
      "name": "iPhone 15 Pro Max",
      "nameAr": "ايفون 15 برو ماكس",
      "slug": "iphone-15-pro-max",
      "modelNumber": "A2849",
      "image": "https://...",
      "screenSize": "6.7 inch",
      "releaseYear": 2023,
      "colors": ["Black", "White", "Blue", "Natural"],
      "storageOptions": ["256GB", "512GB", "1TB"],
      "isPopular": true,
      "isActive": true,
      "displayOrder": 1,
      "productsCount": 45,
      "createdAt": "2024-01-01T00:00:00.000Z",
      "updatedAt": "2024-01-01T00:00:00.000Z"
    }
  ],
  "message": "Devices retrieved",
  "messageAr": "تم استرجاع الأجهزة"
}
```

**ملاحظات:**
- إذا تم إرسال `popular=true`، سيتم جلب الأجهزة الشائعة فقط (isPopular: true)
- إذا لم يتم إرسال `popular` أو تم إرسال `popular=false`، سيتم جلب جميع الأجهزة النشطة
- البيانات تأتي مع populate للـ `brandId` (معلومات البراند كاملة)

**Flutter Code:**
```dart
/// جلب الأجهزة النشطة مع فلترة الشائعة اختيارياً
Future<List<Device>> getDevices({
  int? limit, 
  bool? popular,
}) async {
  final queryParams = <String, dynamic>{};
  if (limit != null) queryParams['limit'] = limit;
  if (popular != null) queryParams['popular'] = popular;
  
  final response = await _dio.get('/catalog/devices', queryParameters: queryParams);
  
  if (response.data['success']) {
    return (response.data['data'] as List)
        .map((d) => Device.fromJson(d))
        .toList();
  }
  throw Exception(response.data['messageAr']);
}

/// جلب الأجهزة الشائعة فقط
Future<List<Device>> getPopularDevices({int? limit}) async {
  return getDevices(limit: limit, popular: true);
}
```

---

#### 🔟 جلب أجهزة ماركة معينة

**Endpoint:** `GET /catalog/devices/brand/:brandId`

**Response:**
```dart
{
  "success": true,
  "data": [
    {
      "_id": "...",
      "brandId": {
        "_id": "...",
        "name": "Apple",
        "nameAr": "أبل",
        "slug": "apple",
        "logo": "https://..."
      },
      "name": "iPhone 15 Pro Max",
      "nameAr": "ايفون 15 برو ماكس",
      "slug": "iphone-15-pro-max",
      "modelNumber": "A2849",
      "image": "https://...",
      "screenSize": "6.7 inch",
      "releaseYear": 2023,
      "colors": ["Black", "White", "Blue", "Natural"],
      "storageOptions": ["256GB", "512GB", "1TB"],
      "isPopular": true,
      "isActive": true,
      "displayOrder": 1,
      "productsCount": 45,
      "createdAt": "2024-01-01T00:00:00.000Z",
      "updatedAt": "2024-01-01T00:00:00.000Z"
    }
  ],
  "message": "Devices retrieved",
  "messageAr": "تم استرجاع الأجهزة"
}
```

**ملاحظات:**
- البيانات تأتي مع populate للـ `brandId` (معلومات البراند: name, nameAr, slug, logo)
- يتم ترتيب النتائج حسب `releaseYear` (تنازلي) ثم `displayOrder` (تصاعدي)

**Flutter Code:**
```dart
/// جلب أجهزة ماركة معينة
Future<List<Device>> getDevicesByBrand(String brandId) async {
  final response = await _dio.get('/catalog/devices/brand/$brandId');
  
  if (response.data['success']) {
    return (response.data['data'] as List)
        .map((d) => Device.fromJson(d))
        .toList();
  }
  throw Exception(response.data['messageAr']);
}
```

---

#### 1️⃣1️⃣ جلب جهاز بالـ Slug

**Endpoint:** `GET /catalog/devices/:slug`

**Response:**
```dart
{
  "success": true,
  "data": {
    "_id": "...",
    "brandId": {
      "_id": "...",
      "name": "Apple",
      "nameAr": "أبل",
      "slug": "apple",
      "logo": "https://...",
      "website": "https://www.apple.com",
      "description": "...",
      "descriptionAr": "..."
    },
    "name": "iPhone 15 Pro Max",
    "nameAr": "ايفون 15 برو ماكس",
    "slug": "iphone-15-pro-max",
    "modelNumber": "A2849",
    "image": "https://...",
    "screenSize": "6.7 inch",
    "releaseYear": 2023,
    "colors": ["Black", "White", "Blue", "Natural"],
    "storageOptions": ["256GB", "512GB", "1TB"],
    "isPopular": true,
    "isActive": true,
    "displayOrder": 1,
    "productsCount": 45,
    "createdAt": "2024-01-01T00:00:00.000Z",
    "updatedAt": "2024-01-01T00:00:00.000Z"
  },
  "message": "Device retrieved",
  "messageAr": "تم استرجاع الجهاز"
}
```

**ملاحظات:**
- البيانات تأتي مع populate كامل للـ `brandId` (جميع معلومات البراند)

**Flutter Code:**
```dart
/// جلب جهاز بالـ slug
Future<Device> getDeviceBySlug(String slug) async {
  final response = await _dio.get('/catalog/devices/$slug');
  
  if (response.data['success']) {
    return Device.fromJson(response.data['data']);
  }
  throw Exception(response.data['messageAr']);
}
```

---

#### 1️⃣2️⃣ جلب منتجات جهاز معين

**Endpoint:** `GET /catalog/devices/:identifier/products`

**Query Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `page` | number | ❌ | رقم الصفحة (افتراضي: 1) |
| `limit` | number | ❌ | عدد العناصر (افتراضي: 20) |
| `minPrice` | number | ❌ | الحد الأدنى للسعر |
| `maxPrice` | number | ❌ | الحد الأقصى للسعر |
| `sortBy` | string | ❌ | ترتيب حسب (price, name, createdAt) |
| `sortOrder` | string | ❌ | ترتيب (asc, desc) |
| `brandId` | string | ❌ | فلترة حسب العلامة التجارية |
| `qualityTypeId` | string | ❌ | فلترة حسب نوع الجودة |

**Response:**
```dart
{
  "success": true,
  "data": [
    {
      "_id": "...",
      "name": "شاشة iPhone 15 Pro Max",
      "nameAr": "شاشة آيفون 15 برو ماكس",
      "slug": "screen-iphone-15-pro-max",
      "basePrice": 500.00,
      ...
    }
  ],
  "meta": {
    "page": 1,
    "limit": 20,
    "total": 45,
    "pages": 3
  },
  "message": "Device products retrieved",
  "messageAr": "تم استرجاع منتجات الجهاز"
}
```

**Flutter Code:**
```dart
/// جلب منتجات جهاز معين
Future<Map<String, dynamic>> getDeviceProducts(
  String deviceIdentifier, {
  int page = 1,
  int limit = 20,
  double? minPrice,
  double? maxPrice,
  String? sortBy,
  String? sortOrder,
  String? brandId,
  String? qualityTypeId,
}) async {
  final queryParams = <String, dynamic>{
    'page': page,
    'limit': limit,
  };
  
  if (minPrice != null) queryParams['minPrice'] = minPrice;
  if (maxPrice != null) queryParams['maxPrice'] = maxPrice;
  if (sortBy != null) queryParams['sortBy'] = sortBy;
  if (sortOrder != null) queryParams['sortOrder'] = sortOrder;
  if (brandId != null) queryParams['brandId'] = brandId;
  if (qualityTypeId != null) queryParams['qualityTypeId'] = qualityTypeId;
  
  final response = await _dio.get(
    '/catalog/devices/$deviceIdentifier/products',
    queryParameters: queryParams,
  );
  
  if (response.data['success']) {
    return {
      'products': (response.data['data'] as List)
          .map((p) => Product.fromJson(p))
          .toList(),
      'pagination': response.data['meta'],
    };
  }
  throw Exception(response.data['messageAr']);
}
```

---

### ⭐ Quality Types

#### 1️⃣3️⃣ جلب أنواع الجودة

**Endpoint:** `GET /catalog/quality-types`

**Response:**
```dart
{
  "success": true,
  "data": [
    {
      "_id": "...",
      "name": "Original",
      "nameAr": "أصلي",
      "code": "original",
      "description": "Official parts from manufacturer",
      "descriptionAr": "قطع أصلية من الشركة المصنعة",
      "color": "#00AA00",
      "defaultWarrantyDays": 365,
      ...
    },
    {
      "_id": "...",
      "name": "OEM",
      "nameAr": "OEM",
      "code": "oem",
      "color": "#0066CC",
      "defaultWarrantyDays": 180,
      ...
    },
    {
      "_id": "...",
      "name": "AAA Copy",
      "nameAr": "نسخة AAA",
      "code": "aaa",
      "color": "#FF9900",
      "defaultWarrantyDays": 90,
      ...
    },
    {
      "_id": "...",
      "name": "Copy",
      "nameAr": "نسخة",
      "code": "copy",
      "color": "#999999",
      "defaultWarrantyDays": 30,
      ...
    }
  ],
  "message": "Quality types retrieved",
  "messageAr": "تم استرجاع أنواع الجودة"
}
```

**Flutter Code:**
```dart
/// جلب جميع أنواع الجودة
Future<List<QualityType>> getQualityTypes() async {
  final response = await _dio.get('/catalog/quality-types');
  
  if (response.data['success']) {
    return (response.data['data'] as List)
        .map((q) => QualityType.fromJson(q))
        .toList();
  }
  throw Exception(response.data['messageAr']);
}
```

---

## 🧩 CatalogService للـ Devices و Quality Types

```dart
import 'package:dio/dio.dart';

class CatalogService {
  final Dio _dio;
  
  CatalogService(this._dio);
  
  // ═════════════════════════════════════
  // Devices
  // ═════════════════════════════════════
  
  Future<List<Device>> getDevices({
    int? limit, 
    bool? popular,
  }) async {
    final queryParams = <String, dynamic>{};
    if (limit != null) queryParams['limit'] = limit;
    if (popular != null) queryParams['popular'] = popular;
    
    final response = await _dio.get('/catalog/devices', queryParameters: queryParams);
    
    if (response.data['success']) {
      return (response.data['data'] as List)
          .map((d) => Device.fromJson(d))
          .toList();
    }
    throw Exception(response.data['messageAr']);
  }
  
  Future<List<Device>> getPopularDevices({int? limit}) async {
    return getDevices(limit: limit, popular: true);
  }
  
  Future<List<Device>> getDevicesByBrand(String brandId) async {
    final response = await _dio.get('/catalog/devices/brand/$brandId');
    
    if (response.data['success']) {
      return (response.data['data'] as List)
          .map((d) => Device.fromJson(d))
          .toList();
    }
    throw Exception(response.data['messageAr']);
  }
  
  Future<Device> getDeviceBySlug(String slug) async {
    final response = await _dio.get('/catalog/devices/$slug');
    
    if (response.data['success']) {
      return Device.fromJson(response.data['data']);
    }
    throw Exception(response.data['messageAr']);
  }
  
  Future<Map<String, dynamic>> getDeviceProducts(
    String deviceIdentifier, {
    int page = 1,
    int limit = 20,
    double? minPrice,
    double? maxPrice,
    String? sortBy,
    String? sortOrder,
    String? brandId,
    String? qualityTypeId,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
    };
    
    if (minPrice != null) queryParams['minPrice'] = minPrice;
    if (maxPrice != null) queryParams['maxPrice'] = maxPrice;
    if (sortBy != null) queryParams['sortBy'] = sortBy;
    if (sortOrder != null) queryParams['sortOrder'] = sortOrder;
    if (brandId != null) queryParams['brandId'] = brandId;
    if (qualityTypeId != null) queryParams['qualityTypeId'] = qualityTypeId;
    
    final response = await _dio.get(
      '/catalog/devices/$deviceIdentifier/products',
      queryParameters: queryParams,
    );
    
    if (response.data['success']) {
      return {
        'products': (response.data['data'] as List)
            .map((p) => Product.fromJson(p))
            .toList(),
        'pagination': response.data['meta'],
      };
    }
    throw Exception(response.data['messageAr']);
  }
  
  // ═════════════════════════════════════
  // Quality Types
  // ═════════════════════════════════════
  
  Future<List<QualityType>> getQualityTypes() async {
    final response = await _dio.get('/catalog/quality-types');
    
    if (response.data['success']) {
      return (response.data['data'] as List)
          .map((q) => QualityType.fromJson(q))
          .toList();
    }
    throw Exception(response.data['messageAr']);
  }
}
```

---

## 📝 ملخص الـ Endpoints

| Method | Endpoint | الوصف |
|--------|----------|-------|
| GET | `/catalog/devices` | الأجهزة النشطة (مع فلتر `popular` اختياري) |
| GET | `/catalog/devices/brand/:brandId` | أجهزة ماركة معينة |
| GET | `/catalog/devices/:slug` | جهاز بالـ slug |
| GET | `/catalog/devices/:identifier/products` | منتجات جهاز معين |
| GET | `/catalog/quality-types` | أنواع الجودة |

---

> 🔗 **السابق:** [Categories API](./2-catalog-categories.md) - دليل ربط الأقسام  
> 🔗 **التالي:** [Products API](./3-products.md) - دليل المنتجات (قريباً)
