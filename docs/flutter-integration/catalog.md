# 📚 Catalog Module - دليل ربط الكتالوج

## 📋 نظرة عامة

هذا الموديول يتعامل مع:
- ✅ العلامات التجارية (Brands)
- ✅ الأقسام والتصنيفات (Categories)
- ✅ الأجهزة/الموديلات (Devices)
- ✅ أنواع الجودة (Quality Types)

> **ملاحظة**: جميع الـ endpoints هنا عامة (Public) ولا تحتاج Token.

---

## 📁 Flutter Models

### Brand Model

```dart
class Brand {
  final String id;
  final String name;
  final String nameAr;
  final String slug;
  final String? description;
  final String? descriptionAr;
  final String? logo;
  final String? website;
  final bool isActive;
  final bool isFeatured;
  final int displayOrder;
  final int productsCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  Brand({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.slug,
    this.description,
    this.descriptionAr,
    this.logo,
    this.website,
    required this.isActive,
    required this.isFeatured,
    required this.displayOrder,
    required this.productsCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Brand.fromJson(Map<String, dynamic> json) {
    return Brand(
      id: json['_id'] ?? json['id'],
      name: json['name'],
      nameAr: json['nameAr'],
      slug: json['slug'],
      description: json['description'],
      descriptionAr: json['descriptionAr'],
      logo: json['logo'],
      website: json['website'],
      isActive: json['isActive'] ?? true,
      isFeatured: json['isFeatured'] ?? false,
      displayOrder: json['displayOrder'] ?? 0,
      productsCount: json['productsCount'] ?? 0,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  /// الحصول على الاسم حسب اللغة
  String getName(String locale) => locale == 'ar' ? nameAr : name;
  
  /// الحصول على الوصف حسب اللغة
  String? getDescription(String locale) => 
      locale == 'ar' ? descriptionAr : description;
}
```

### Category Model

```dart
class Category {
  final String id;
  final String name;
  final String nameAr;
  final String slug;
  final String? description;
  final String? descriptionAr;
  final String? image;
  final String? icon;
  final String? parentId;
  final List<String> ancestors;
  final int level;
  final String? path;
  final bool isActive;
  final bool isFeatured;
  final int displayOrder;
  final int productsCount;
  final int childrenCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // للـ Tree structure
  List<Category>? children;

  Category({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.slug,
    this.description,
    this.descriptionAr,
    this.image,
    this.icon,
    this.parentId,
    required this.ancestors,
    required this.level,
    this.path,
    required this.isActive,
    required this.isFeatured,
    required this.displayOrder,
    required this.productsCount,
    required this.childrenCount,
    required this.createdAt,
    required this.updatedAt,
    this.children,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['_id'] ?? json['id'],
      name: json['name'],
      nameAr: json['nameAr'],
      slug: json['slug'],
      description: json['description'],
      descriptionAr: json['descriptionAr'],
      image: json['image'],
      icon: json['icon'],
      parentId: json['parentId'],
      ancestors: List<String>.from(json['ancestors'] ?? []),
      level: json['level'] ?? 0,
      path: json['path'],
      isActive: json['isActive'] ?? true,
      isFeatured: json['isFeatured'] ?? false,
      displayOrder: json['displayOrder'] ?? 0,
      productsCount: json['productsCount'] ?? 0,
      childrenCount: json['childrenCount'] ?? 0,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      children: json['children'] != null
          ? (json['children'] as List)
              .map((c) => Category.fromJson(c))
              .toList()
          : null,
    );
  }

  /// هل هذا قسم رئيسي؟
  bool get isRoot => parentId == null && level == 0;
  
  /// هل لديه أقسام فرعية؟
  bool get hasChildren => childrenCount > 0;
  
  /// الحصول على الاسم حسب اللغة
  String getName(String locale) => locale == 'ar' ? nameAr : name;
}
```

### Device Model

```dart
class Device {
  final String id;
  final String brandId;
  final String name;
  final String nameAr;
  final String slug;
  final String? modelNumber;
  final String? image;
  final String? screenSize;
  final int? releaseYear;
  final List<String>? colors;
  final List<String>? storageOptions;
  final bool isActive;
  final bool isPopular;
  final int displayOrder;
  final int productsCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // يمكن تعبئتها إذا تم populate
  Brand? brand;

  Device({
    required this.id,
    required this.brandId,
    required this.name,
    required this.nameAr,
    required this.slug,
    this.modelNumber,
    this.image,
    this.screenSize,
    this.releaseYear,
    this.colors,
    this.storageOptions,
    required this.isActive,
    required this.isPopular,
    required this.displayOrder,
    required this.productsCount,
    required this.createdAt,
    required this.updatedAt,
    this.brand,
  });

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      id: json['_id'] ?? json['id'],
      brandId: json['brandId'] is String 
          ? json['brandId'] 
          : json['brandId']['_id'],
      name: json['name'],
      nameAr: json['nameAr'],
      slug: json['slug'],
      modelNumber: json['modelNumber'],
      image: json['image'],
      screenSize: json['screenSize'],
      releaseYear: json['releaseYear'],
      colors: json['colors'] != null 
          ? List<String>.from(json['colors']) 
          : null,
      storageOptions: json['storageOptions'] != null 
          ? List<String>.from(json['storageOptions']) 
          : null,
      isActive: json['isActive'] ?? true,
      isPopular: json['isPopular'] ?? false,
      displayOrder: json['displayOrder'] ?? 0,
      productsCount: json['productsCount'] ?? 0,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      brand: json['brandId'] is Map 
          ? Brand.fromJson(json['brandId']) 
          : null,
    );
  }

  /// الحصول على الاسم حسب اللغة
  String getName(String locale) => locale == 'ar' ? nameAr : name;
}
```

### QualityType Model

```dart
class QualityType {
  final String id;
  final String name;
  final String nameAr;
  final String code;  // "original", "oem", "aaa", "copy"
  final String? description;
  final String? descriptionAr;
  final String? color;  // Badge color (hex)
  final String? icon;
  final int displayOrder;
  final bool isActive;
  final int? defaultWarrantyDays;
  final DateTime createdAt;
  final DateTime updatedAt;

  QualityType({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.code,
    this.description,
    this.descriptionAr,
    this.color,
    this.icon,
    required this.displayOrder,
    required this.isActive,
    this.defaultWarrantyDays,
    required this.createdAt,
    required this.updatedAt,
  });

  factory QualityType.fromJson(Map<String, dynamic> json) {
    return QualityType(
      id: json['_id'] ?? json['id'],
      name: json['name'],
      nameAr: json['nameAr'],
      code: json['code'],
      description: json['description'],
      descriptionAr: json['descriptionAr'],
      color: json['color'],
      icon: json['icon'],
      displayOrder: json['displayOrder'] ?? 0,
      isActive: json['isActive'] ?? true,
      defaultWarrantyDays: json['defaultWarrantyDays'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  /// الحصول على الاسم حسب اللغة
  String getName(String locale) => locale == 'ar' ? nameAr : name;
  
  /// تحويل اللون hex إلى Color
  Color? getColor() {
    if (color == null) return null;
    final hex = color!.replaceFirst('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }
}
```

### CategoryWithBreadcrumb Model

```dart
class CategoryWithBreadcrumb {
  final Category category;
  final List<BreadcrumbItem> breadcrumb;

  CategoryWithBreadcrumb({
    required this.category,
    required this.breadcrumb,
  });

  factory CategoryWithBreadcrumb.fromJson(Map<String, dynamic> json) {
    return CategoryWithBreadcrumb(
      category: Category.fromJson(json['category']),
      breadcrumb: (json['breadcrumb'] as List)
          .map((b) => BreadcrumbItem.fromJson(b))
          .toList(),
    );
  }
}

class BreadcrumbItem {
  final String id;
  final String name;
  final String nameAr;
  final String slug;

  BreadcrumbItem({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.slug,
  });

  factory BreadcrumbItem.fromJson(Map<String, dynamic> json) {
    return BreadcrumbItem(
      id: json['_id'] ?? json['id'],
      name: json['name'],
      nameAr: json['nameAr'],
      slug: json['slug'],
    );
  }
}
```

---

## 📞 API Endpoints

### 🏷️ Brands

#### 1️⃣ جلب جميع العلامات التجارية

**Endpoint:** `GET /catalog/brands`

**Query Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `featured` | boolean | ❌ | فلترة المميزة فقط |

**Response:**
```dart
{
  "success": true,
  "data": [
    {
      "_id": "507f1f77bcf86cd799439011",
      "name": "Apple",
      "nameAr": "أبل",
      "slug": "apple",
      "logo": "https://cdn.example.com/brands/apple.png",
      "isFeatured": true,
      "productsCount": 150,
      ...
    }
  ],
  "message": "Brands retrieved",
  "messageAr": "تم استرجاع العلامات التجارية"
}
```

**Flutter Code:**
```dart
class CatalogService {
  final Dio _dio;
  
  CatalogService(this._dio);
  
  /// جلب جميع الماركات
  Future<List<Brand>> getBrands({bool? featured}) async {
    final response = await _dio.get('/catalog/brands', queryParameters: {
      if (featured != null) 'featured': featured,
    });
    
    if (response.data['success']) {
      return (response.data['data'] as List)
          .map((b) => Brand.fromJson(b))
          .toList();
    }
    throw Exception(response.data['messageAr']);
  }
}
```

---

#### 2️⃣ جلب علامة تجارية بالـ Slug

**Endpoint:** `GET /catalog/brands/:slug`

**Response:**
```dart
{
  "success": true,
  "data": {
    "_id": "507f1f77bcf86cd799439011",
    "name": "Apple",
    "nameAr": "أبل",
    "slug": "apple",
    "description": "Apple Inc. is an American...",
    "descriptionAr": "شركة أبل هي شركة أمريكية...",
    "logo": "https://cdn.example.com/brands/apple.png",
    "website": "https://www.apple.com",
    "productsCount": 150,
    ...
  },
  "message": "Brand retrieved",
  "messageAr": "تم استرجاع العلامة التجارية"
}
```

**Flutter Code:**
```dart
/// جلب ماركة بالـ slug
Future<Brand> getBrandBySlug(String slug) async {
  final response = await _dio.get('/catalog/brands/$slug');
  
  if (response.data['success']) {
    return Brand.fromJson(response.data['data']);
  }
  throw Exception(response.data['messageAr']);
}
```

---

### 📂 Categories

#### 3️⃣ جلب الأقسام الرئيسية

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

#### 4️⃣ جلب شجرة الأقسام كاملة

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

#### 5️⃣ جلب قسم مع Breadcrumb

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

#### 6️⃣ جلب الأقسام الفرعية

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

### 📱 Devices

#### 7️⃣ جلب الأجهزة الشائعة

**Endpoint:** `GET /catalog/devices`

**Query Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `limit` | number | ❌ | الحد الأقصى للنتائج |

**Response:**
```dart
{
  "success": true,
  "data": [
    {
      "_id": "...",
      "brandId": "...",
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
      "productsCount": 45,
      ...
    }
  ],
  "message": "Devices retrieved",
  "messageAr": "تم استرجاع الأجهزة"
}
```

**Flutter Code:**
```dart
/// جلب الأجهزة الشائعة
Future<List<Device>> getPopularDevices({int? limit}) async {
  final response = await _dio.get('/catalog/devices', queryParameters: {
    if (limit != null) 'limit': limit,
  });
  
  if (response.data['success']) {
    return (response.data['data'] as List)
        .map((d) => Device.fromJson(d))
        .toList();
  }
  throw Exception(response.data['messageAr']);
}
```

---

#### 8️⃣ جلب أجهزة ماركة معينة

**Endpoint:** `GET /catalog/devices/brand/:brandId`

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

#### 9️⃣ جلب جهاز بالـ Slug

**Endpoint:** `GET /catalog/devices/:slug`

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

### ⭐ Quality Types

#### 🔟 جلب أنواع الجودة

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

## 🧩 CatalogService الكامل

```dart
import 'package:dio/dio.dart';

class CatalogService {
  final Dio _dio;
  
  CatalogService(this._dio);
  
  // ═════════════════════════════════════
  // Brands
  // ═════════════════════════════════════
  
  Future<List<Brand>> getBrands({bool? featured}) async {
    final response = await _dio.get('/catalog/brands', queryParameters: {
      if (featured != null) 'featured': featured,
    });
    
    if (response.data['success']) {
      return (response.data['data'] as List)
          .map((b) => Brand.fromJson(b))
          .toList();
    }
    throw Exception(response.data['messageAr']);
  }
  
  Future<Brand> getBrandBySlug(String slug) async {
    final response = await _dio.get('/catalog/brands/$slug');
    
    if (response.data['success']) {
      return Brand.fromJson(response.data['data']);
    }
    throw Exception(response.data['messageAr']);
  }
  
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
  
  // ═════════════════════════════════════
  // Devices
  // ═════════════════════════════════════
  
  Future<List<Device>> getPopularDevices({int? limit}) async {
    final response = await _dio.get('/catalog/devices', queryParameters: {
      if (limit != null) 'limit': limit,
    });
    
    if (response.data['success']) {
      return (response.data['data'] as List)
          .map((d) => Device.fromJson(d))
          .toList();
    }
    throw Exception(response.data['messageAr']);
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

## 🎯 أمثلة الاستخدام

### عرض شريط الماركات

```dart
class BrandsBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Brand>>(
      future: catalogService.getBrands(featured: true),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final brand = snapshot.data![index];
                return GestureDetector(
                  onTap: () => Navigator.pushNamed(
                    context, 
                    '/brand/${brand.slug}',
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(8),
                    child: Column(
                      children: [
                        CircleAvatar(
                          backgroundImage: NetworkImage(brand.logo ?? ''),
                          radius: 24,
                        ),
                        Text(brand.getName(locale)),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        }
        return CircularProgressIndicator();
      },
    );
  }
}
```

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
| GET | `/catalog/brands` | جميع الماركات |
| GET | `/catalog/brands/:slug` | ماركة بالـ slug |
| GET | `/catalog/categories` | الأقسام الرئيسية |
| GET | `/catalog/categories/tree` | شجرة الأقسام كاملة |
| GET | `/catalog/categories/:id` | قسم مع breadcrumb |
| GET | `/catalog/categories/:id/children` | الأقسام الفرعية |
| GET | `/catalog/devices` | الأجهزة الشائعة |
| GET | `/catalog/devices/brand/:brandId` | أجهزة ماركة معينة |
| GET | `/catalog/devices/:slug` | جهاز بالـ slug |
| GET | `/catalog/quality-types` | أنواع الجودة |

---

> 🔗 **السابق:** [auth.md](./auth.md) - دليل المصادقة  
> 🔗 **التالي:** [products.md](./products.md) - دليل المنتجات (قريباً)
