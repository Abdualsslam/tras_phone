# 📂 Categories API - دليل ربط الأقسام

## 📋 نظرة عامة

هذا الملف يحتوي على جميع API endpoints المتعلقة بالأقسام والتصنيفات (Categories).

> **ملاحظة**: جميع الـ endpoints هنا عامة (Public) ولا تحتاج Token.

---

## 📞 API Endpoints

### 4️⃣ جلب الأقسام الرئيسية

**Endpoint:** `GET /catalog/categories`

**Response:**
```dart
{
  "success": true,
  "data": [
    {
      "_id": "...",
      "name": "Screens",
      "nameAr": "شاشات",
      "slug": "screens",
      "image": "https://...",
      "level": 0,
      "parentId": null,
      "childrenCount": 5,
      "productsCount": 350,
      ...
    }
  ],
  "message": "Categories retrieved",
  "messageAr": "تم استرجاع الأقسام"
}
```

**Flutter Code:**
```dart
/// جلب الأقسام الرئيسية (Root)
Future<List<Category>> getRootCategories() async {
  final response = await _dio.get('/catalog/categories');
  
  if (response.data['success']) {
    return (response.data['data'] as List)
        .map((c) => Category.fromJson(c))
        .toList();
  }
  throw Exception(response.data['messageAr']);
}
```

---

### 5️⃣ جلب شجرة الأقسام كاملة

**Endpoint:** `GET /catalog/categories/tree`

**Response:**
```dart
{
  "success": true,
  "data": [
    {
      "_id": "...",
      "name": "Screens",
      "nameAr": "شاشات",
      "slug": "screens",
      "level": 0,
      "children": [
        {
          "_id": "...",
          "name": "LCD Screens",
          "nameAr": "شاشات LCD",
          "slug": "lcd-screens",
          "level": 1,
          "children": [
            // المزيد من التداخل...
          ]
        }
      ]
    }
  ],
  "message": "Category tree retrieved",
  "messageAr": "تم استرجاع شجرة الأقسام"
}
```

**Flutter Code:**
```dart
/// جلب شجرة الأقسام كاملة
Future<List<Category>> getCategoryTree() async {
  final response = await _dio.get('/catalog/categories/tree');
  
  if (response.data['success']) {
    return (response.data['data'] as List)
        .map((c) => Category.fromJson(c))
        .toList();
  }
  throw Exception(response.data['messageAr']);
}
```

---

### 6️⃣ جلب قسم مع Breadcrumb

**Endpoint:** `GET /catalog/categories/:id`

**Response:**
```dart
{
  "success": true,
  "data": {
    "category": {
      "_id": "...",
      "name": "LCD Screens",
      "nameAr": "شاشات LCD",
      ...
    },
    "breadcrumb": [
      { "_id": "...", "name": "Screens", "nameAr": "شاشات", "slug": "screens" },
      { "_id": "...", "name": "LCD Screens", "nameAr": "شاشات LCD", "slug": "lcd-screens" }
    ]
  },
  "message": "Category retrieved",
  "messageAr": "تم استرجاع القسم"
}
```

**Flutter Code:**
```dart
/// جلب قسم مع مسار التنقل (Breadcrumb)
Future<CategoryWithBreadcrumb> getCategoryById(String id) async {
  final response = await _dio.get('/catalog/categories/$id');
  
  if (response.data['success']) {
    return CategoryWithBreadcrumb.fromJson(response.data['data']);
  }
  throw Exception(response.data['messageAr']);
}
```

---

### 7️⃣ جلب الأقسام الفرعية

**Endpoint:** `GET /catalog/categories/:id/children`

**Response:**
```dart
{
  "success": true,
  "data": [
    {
      "_id": "...",
      "name": "OLED Screens",
      "nameAr": "شاشات OLED",
      "slug": "oled-screens",
      "parentId": "parent_id_here",
      "level": 1,
      ...
    }
  ],
  "message": "Children retrieved",
  "messageAr": "تم استرجاع الأقسام الفرعية"
}
```

**Flutter Code:**
```dart
/// جلب الأقسام الفرعية لقسم معين
Future<List<Category>> getCategoryChildren(String parentId) async {
  final response = await _dio.get('/catalog/categories/$parentId/children');
  
  if (response.data['success']) {
    return (response.data['data'] as List)
        .map((c) => Category.fromJson(c))
        .toList();
  }
  throw Exception(response.data['messageAr']);
}
```

---

### 8️⃣ جلب المنتجات حسب الفئة

**Endpoint:** `GET /catalog/categories/:identifier/products`

**ملاحظات:**
- `identifier` يمكن أن يكون `id` أو `slug`
- إذا كانت الفئة لديها فئات فرعية، سيتم جلب المنتجات من جميع الفئات الفرعية (بما في ذلك الفئات الفرعية للفئات الفرعية)
- إذا لم يكن للفئة فئات فرعية، سيتم جلب المنتجات مباشرة من الفئة الرئيسية

**Query Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `page` | number | ❌ | رقم الصفحة (افتراضي: 1) |
| `limit` | number | ❌ | عدد المنتجات في الصفحة (افتراضي: 20) |
| `minPrice` | number | ❌ | أدنى سعر |
| `maxPrice` | number | ❌ | أعلى سعر |
| `sortBy` | string | ❌ | حقل الترتيب (`price`, `name`, `createdAt`, إلخ) |
| `sortOrder` | string | ❌ | اتجاه الترتيب (`asc`, `desc`) |
| `brandId` | string | ❌ | فلترة حسب البراند |
| `qualityTypeId` | string | ❌ | فلترة حسب نوع الجودة |

**Response:**
```dart
{
  "success": true,
  "data": [
    {
      "_id": "...",
      "name": "iPhone 15 Pro Max Screen",
      "nameAr": "شاشة آيفون 15 برو ماكس",
      "basePrice": 150.00,
      "mainImage": "https://...",
      "brandId": {
        "_id": "507f1f77bcf86cd799439011",
        "name": "Apple",
        "nameAr": "أبل",
        "slug": "apple"
      },
      "categoryId": { ... },
      "qualityTypeId": { ... },
      ...
    }
  ],
  "message": "Category products retrieved",
  "messageAr": "تم استرجاع منتجات القسم",
  "meta": {
    "page": 1,
    "limit": 20,
    "total": 45,
    "pages": 3
  }
}
```

**Flutter Code:**
```dart
/// جلب المنتجات حسب الفئة
Future<Map<String, dynamic>> getCategoryProducts(
  String categoryIdentifier, {
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
    '/catalog/categories/$categoryIdentifier/products',
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

**مثال الاستخدام:**
```dart
// جلب منتجات فئة رئيسية (إذا كانت لديها فئات فرعية، سيجلب من جميعها)
final result = await catalogService.getCategoryProducts(
  'screens', // slug أو id
  page: 1,
  limit: 20,
);

// جلب منتجات فئة فرعية (سيجلب منتجات هذه الفئة فقط)
final result = await catalogService.getCategoryProducts(
  'lcd-screens',
  page: 1,
  limit: 20,
);
```

---

## 🧩 CatalogService للـ Categories

```dart
import 'package:dio/dio.dart';

class CatalogService {
  final Dio _dio;
  
  CatalogService(this._dio);
  
  // ═════════════════════════════════════
  // Categories
  // ═════════════════════════════════════
  
  Future<List<Category>> getRootCategories() async {
    final response = await _dio.get('/catalog/categories');
    
    if (response.data['success']) {
      return (response.data['data'] as List)
          .map((c) => Category.fromJson(c))
          .toList();
    }
    throw Exception(response.data['messageAr']);
  }
  
  Future<List<Category>> getCategoryTree() async {
    final response = await _dio.get('/catalog/categories/tree');
    
    if (response.data['success']) {
      return (response.data['data'] as List)
          .map((c) => Category.fromJson(c))
          .toList();
    }
    throw Exception(response.data['messageAr']);
  }
  
  Future<CategoryWithBreadcrumb> getCategoryById(String id) async {
    final response = await _dio.get('/catalog/categories/$id');
    
    if (response.data['success']) {
      return CategoryWithBreadcrumb.fromJson(response.data['data']);
    }
    throw Exception(response.data['messageAr']);
  }
  
  Future<List<Category>> getCategoryChildren(String parentId) async {
    final response = await _dio.get('/catalog/categories/$parentId/children');
    
    if (response.data['success']) {
      return (response.data['data'] as List)
          .map((c) => Category.fromJson(c))
          .toList();
    }
    throw Exception(response.data['messageAr']);
  }
  
  Future<Map<String, dynamic>> getCategoryProducts(
    String categoryIdentifier, {
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
      '/catalog/categories/$categoryIdentifier/products',
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
}
```

---

## 🎯 أمثلة الاستخدام

### عرض شجرة الأقسام

```dart
class CategoryTreeView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Category>>(
      future: catalogService.getCategoryTree(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              return _buildCategoryTile(snapshot.data![index], 0);
            },
          );
        }
        return CircularProgressIndicator();
      },
    );
  }
  
  Widget _buildCategoryTile(Category category, int depth) {
    return ExpansionTile(
      leading: category.icon != null 
          ? Icon(IconData(int.parse(category.icon!)))
          : null,
      title: Text(category.getName(locale)),
      subtitle: Text('${category.productsCount} منتج'),
      initiallyExpanded: depth == 0,
      children: category.children?.map((child) {
        return _buildCategoryTile(child, depth + 1);
      }).toList() ?? [],
    );
  }
}
```

---

## 📝 ملخص الـ Endpoints

| Method | Endpoint | الوصف |
|--------|----------|-------|
| GET | `/catalog/categories` | الأقسام الرئيسية |
| GET | `/catalog/categories/tree` | شجرة الأقسام كاملة |
| GET | `/catalog/categories/:id` | قسم مع breadcrumb |
| GET | `/catalog/categories/:id/children` | الأقسام الفرعية |
| GET | `/catalog/categories/:identifier/products` | منتجات حسب الفئة |

---

> 🔗 **السابق:** [Brands API](./2-catalog-brands.md) - دليل ربط العلامات التجارية  
> 🔗 **التالي:** [Devices & Quality Types](./2-catalog-devices-quality.md) - دليل ربط الأجهزة وأنواع الجودة
