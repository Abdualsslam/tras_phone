# دليل استخدام API الكتالوج والمنتجات

## نظرة عامة

هذا الدليل مخصص لمطوري Flutter لفهم كيفية التعامل مع endpoints الخاصة بالمنتجات والكتالوج بشكل صحيح.

---

## 1. جلب جميع المنتجات مع الفلترة

### Endpoint
```
GET /products
```

### الوصف
جلب قائمة المنتجات مع إمكانية الفلترة بطرق متعددة. هذا الـ endpoint يدعم pagination و sorting.

### Query Parameters المتاحة

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `page` | number | No | رقم الصفحة (default: 1) |
| `limit` | number | No | عدد العناصر في الصفحة (default: 20) |
| `search` | string | No | البحث في اسم المنتج ووصفه |
| `brandId` | string (ObjectId) | No | فلترة حسب معرف العلامة التجارية |
| `categoryId` | string (ObjectId) | No | فلترة حسب معرف الفئة |
| `qualityTypeId` | string (ObjectId) | No | فلترة حسب نوع الجودة |
| `deviceId` | string (ObjectId) | No | فلترة حسب الجهاز المتوافق |
| `tags` | string[] | No | فلترة حسب الوسوم (comma-separated) |
| `minPrice` | number | No | الحد الأدنى للسعر |
| `maxPrice` | number | No | الحد الأقصى للسعر |
| `minRating` | number (1-5) | No | الحد الأدنى للتقييم |
| `maxRating` | number (1-5) | No | الحد الأقصى للتقييم |
| `inStock` | boolean | No | المنتجات المتوفرة فقط |
| `color` | string | No | فلترة حسب اللون |
| `hasOffer` | boolean | No | المنتجات التي لها عروض فقط |
| `status` | string | No | الحالة (draft, active, inactive, out_of_stock, discontinued) |
| `isActive` | boolean | No | المنتجات النشطة فقط |
| `isFeatured` | boolean | No | المنتجات المميزة فقط |
| `isNewArrival` | boolean | No | المنتجات الجديدة فقط |
| `isBestSeller` | boolean | No | الأكثر مبيعاً فقط |
| `sortBy` | string | No | حقل الترتيب (price, name, createdAt, viewsCount, ordersCount, averageRating) |
| `sortOrder` | string | No | اتجاه الترتيب (asc, desc) |

### مثال في Dart/Flutter

```dart
// جلب جميع المنتجات بدون فلترة
final response = await _dio.get('/products');

// جلب المنتجات مع فلترة
final response = await _dio.get('/products', queryParameters: {
  'page': 1,
  'limit': 20,
  'brandId': '507f1f77bcf86cd799439011',
  'categoryId': '507f1f77bcf86cd799439012',
  'minPrice': 100,
  'maxPrice': 1000,
  'inStock': true,
  'sortBy': 'price',
  'sortOrder': 'asc',
});

// البحث في المنتجات
final response = await _dio.get('/products', queryParameters: {
  'search': 'iPhone',
  'page': 1,
  'limit': 20,
});

// فلترة بالوسوم
final response = await _dio.get('/products', queryParameters: {
  'tags': 'screen,original',
});
```

### شكل الاستجابة (Response)

```json
{
  "success": true,
  "message": "Products retrieved",
  "messageAr": "تم استرجاع المنتجات",
  "data": [
    {
      "_id": "507f1f77bcf86cd799439011",
      "name": "iPhone 15 Pro Screen",
      "nameAr": "شاشة آيفون 15 برو",
      "slug": "iphone-15-pro-screen",
      "basePrice": 299.99,
      "compareAtPrice": 349.99,
      "stockQuantity": 50,
      "brand": {
        "_id": "507f1f77bcf86cd799439020",
        "name": "Apple",
        "nameAr": "آبل",
        "slug": "apple"
      },
      "category": {
        "_id": "507f1f77bcf86cd799439021",
        "name": "Screens",
        "nameAr": "الشاشات"
      },
      "images": ["url1", "url2"],
      "averageRating": 4.5,
      "isFeatured": true,
      "hasOffer": true
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 100,
    "totalPages": 5
  }
}
```

---

## 2. جلب الفئات (Categories)

### 2.1 جلب الفئات الرئيسية (Root Categories)

```
GET /catalog/categories
```

**الوصف**: جلب الفئات الرئيسية فقط (بدون أب).

**مثال في Dart:**
```dart
final response = await _dio.get('/catalog/categories');
```

### 2.2 جلب شجرة الفئات الكاملة

```
GET /catalog/categories/tree
```

**الوصف**: جلب جميع الفئات بشكل هرمي (شجرة).

**مثال في Dart:**
```dart
final response = await _dio.get('/catalog/categories/tree');
```

### 2.3 جلب فئة معينة مع مسار التنقل (Breadcrumb)

```
GET /catalog/categories/:id
```

**Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | string (ObjectId) | Yes | معرف الفئة |

**مثال في Dart:**
```dart
final response = await _dio.get('/catalog/categories/507f1f77bcf86cd799439011');
```

### 2.4 جلب الفئات الفرعية لفئة معينة

```
GET /catalog/categories/:id/children
```

**مثال في Dart:**
```dart
final response = await _dio.get('/catalog/categories/507f1f77bcf86cd799439011/children');
```

### 2.5 جلب منتجات فئة معينة

```
GET /catalog/categories/:identifier/products
```

**Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `identifier` | string | Yes | معرف الفئة أو الـ slug |

**Query Parameters:** نفس فلاتر المنتجات (page, limit, minPrice, maxPrice, sortBy, sortOrder, brandId, qualityTypeId)

**ملاحظة مهمة**: إذا كانت الفئة لها فئات فرعية، سيتم جلب المنتجات من جميع الفئات الفرعية أيضاً.

**مثال في Dart:**
```dart
// بالـ ID
final response = await _dio.get('/catalog/categories/507f1f77bcf86cd799439011/products', queryParameters: {
  'page': 1,
  'limit': 20,
  'minPrice': 100,
  'maxPrice': 500,
});

// بالـ slug
final response = await _dio.get('/catalog/categories/screens/products');
```

### شكل بيانات الفئة (Category Response)

```json
{
  "_id": "507f1f77bcf86cd799439011",
  "name": "Screens",
  "nameAr": "الشاشات",
  "slug": "screens",
  "description": "Phone screens and displays",
  "parentId": null,
  "level": 0,
  "isActive": true,
  "isFeatured": true,
  "productsCount": 150,
  "childrenCount": 3,
  "children": [
    {
      "_id": "507f1f77bcf86cd799439012",
      "name": "iPhone Screens",
      "nameAr": "شاشات آيفون",
      "slug": "iphone-screens",
      "parentId": "507f1f77bcf86cd799439011",
      "level": 1
    }
  ]
}
```

---

## 3. جلب العلامات التجارية (Brands)

### 3.1 جلب جميع العلامات التجارية النشطة

```
GET /catalog/brands
```

**Query Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `featured` | boolean | No | جلب العلامات التجارية المميزة فقط |

**مثال في Dart:**
```dart
// جلب جميع البراندات النشطة
final response = await _dio.get('/catalog/brands');

// جلب البراندات المميزة فقط
final response = await _dio.get('/catalog/brands', queryParameters: {
  'featured': true,
});
```

### 3.2 جلب علامة تجارية بالـ slug

```
GET /catalog/brands/:slug
```

**مثال في Dart:**
```dart
final response = await _dio.get('/catalog/brands/apple');
```

### 3.3 جلب منتجات علامة تجارية معينة

```
GET /catalog/brands/:id/products
```

**Query Parameters:** نفس فلاتر المنتجات (page, limit, minPrice, maxPrice, sortBy, sortOrder)

**مثال في Dart:**
```dart
final response = await _dio.get('/catalog/brands/507f1f77bcf86cd799439011/products', queryParameters: {
  'page': 1,
  'limit': 20,
  'minPrice': 50,
  'maxPrice': 300,
  'sortBy': 'price',
  'sortOrder': 'asc',
});
```

### شكل بيانات العلامة التجارية (Brand Response)

```json
{
  "_id": "507f1f77bcf86cd799439011",
  "name": "Apple",
  "nameAr": "آبل",
  "slug": "apple",
  "description": "Apple Inc.",
  "logo": "https://example.com/apple-logo.png",
  "website": "https://apple.com",
  "isActive": true,
  "isFeatured": true,
  "productsCount": 200,
  "displayOrder": 1
}
```

---

## 4. جلب الأجهزة الخاصة بالعلامة التجارية

### 4.1 جلب جميع الأجهزة النشطة

```
GET /catalog/devices
```

**Query Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `limit` | number | No | الحد الأقصى لعدد الأجهزة |
| `popular` | boolean | No | جلب الأجهزة الشائعة فقط |

**مثال في Dart:**
```dart
// جلب جميع الأجهزة
final response = await _dio.get('/catalog/devices');

// جلب الأجهزة الشائعة
final response = await _dio.get('/catalog/devices', queryParameters: {
  'popular': true,
  'limit': 10,
});
```

### 4.2 جلب أجهزة علامة تجارية معينة (مهم!)

```
GET /catalog/devices/brand/:brandId
```

**الوصف**: هذا هو الـ endpoint الصحيح لجلب الأجهزة المرتبطة بعلامة تجارية محددة.

**Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `brandId` | string (ObjectId) | Yes | معرف العلامة التجارية |

**مثال في Dart:**
```dart
// جلب أجهزة Apple
final brandId = '507f1f77bcf86cd799439011'; // Apple brand ID
final response = await _dio.get('/catalog/devices/brand/$brandId');
```

### 4.3 جلب جهاز بالـ slug

```
GET /catalog/devices/:slug
```

**مثال في Dart:**
```dart
final response = await _dio.get('/catalog/devices/iphone-15-pro-max');
```

### 4.4 جلب منتجات متوافقة مع جهاز معين

```
GET /catalog/devices/:identifier/products
```

**Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `identifier` | string | Yes | معرف الجهاز أو الـ slug |

**Query Parameters:** نفس فلاتر المنتجات

**مثال في Dart:**
```dart
// بالـ ID
final response = await _dio.get('/catalog/devices/507f1f77bcf86cd799439011/products', queryParameters: {
  'page': 1,
  'limit': 20,
});

// بالـ slug
final response = await _dio.get('/catalog/devices/iphone-15-pro-max/products');
```

### شكل بيانات الجهاز (Device Response)

```json
{
  "_id": "507f1f77bcf86cd799439011",
  "name": "iPhone 15 Pro Max",
  "nameAr": "آيفون 15 برو ماكس",
  "slug": "iphone-15-pro-max",
  "brandId": "507f1f77bcf86cd799439020",
  "brand": {
    "_id": "507f1f77bcf86cd799439020",
    "name": "Apple",
    "nameAr": "آبل",
    "slug": "apple"
  },
  "modelNumber": "A2849",
  "screenSize": "6.7 inch",
  "releaseYear": 2023,
  "colors": ["Black", "White", "Blue", "Natural"],
  "storageOptions": ["128GB", "256GB", "512GB", "1TB"],
  "image": "https://example.com/iphone-15-pro-max.png",
  "isActive": true,
  "isPopular": true,
  "productsCount": 45
}
```

---

## 5. أنواع الجودة (Quality Types)

```
GET /catalog/quality-types
```

**الوصف**: جلب جميع أنواع الجودة المتاحة (جديد، مستعمل، مجدد...).

**مثال في Dart:**
```dart
final response = await _dio.get('/catalog/quality-types');
```

---

## 6. Endpoints إضافية مهمة

### 6.1 المنتجات المميزة
```
GET /products/featured
```
**Query Parameters:** `limit` (default: 10)

### 6.2 المنتجات الجديدة
```
GET /products/new-arrivals
```
**Query Parameters:** `limit` (default: 10)

### 6.3 الأكثر مبيعاً
```
GET /products/best-sellers
```
**Query Parameters:** `limit` (default: 10)

### 6.4 المنتجات ذات العروض
```
GET /products/on-offer
```
**Query Parameters:** نفس فلاتر المنتجات + pagination

### 6.5 منتج واحد بالـ ID أو slug
```
GET /products/:identifier
```

---

## 7. تدفق العمل الصحيح (Workflow)

### سيناريو: عرض المنتجات حسب العلامة التجارية ثم الجهاز

```dart
// 1. جلب جميع البراندات
final brandsResponse = await _dio.get('/catalog/brands');
final brands = brandsResponse.data['data'] as List;

// 2. المستخدم يختار براند (مثلاً Apple)
final selectedBrand = brands.firstWhere((b) => b['slug'] == 'apple');
final brandId = selectedBrand['_id'];

// 3. جلب أجهزة البراند المختار
final devicesResponse = await _dio.get('/catalog/devices/brand/$brandId');
final devices = devicesResponse.data['data'] as List;

// 4. المستخدم يختار جهاز (مثلاً iPhone 15 Pro Max)
final selectedDevice = devices.firstWhere((d) => d['slug'] == 'iphone-15-pro-max');
final deviceId = selectedDevice['_id'];

// 5. جلب المنتجات المتوافقة مع الجهاز
final productsResponse = await _dio.get('/catalog/devices/$deviceId/products', queryParameters: {
  'page': 1,
  'limit': 20,
  'sortBy': 'price',
  'sortOrder': 'asc',
});
```

---

## 8. ملاحظات مهمة

1. **كل الأجهزة مربوطة ببراند**: كل جهاز له `brandId` إلزامي، لذا يجب أولاً اختيار البراند ثم جلب أجهزته.

2. **الترقيم الصفحي (Pagination)**: جميع endpoints التي ترجع قوائم تدعم pagination. استخدم `page` و `limit` للتحكم.

3. **الفلترة المتعددة**: يمكن دمج عدة فلاتر معاً في طلب واحد.

4. **الترتيب**: استخدم `sortBy` مع `sortOrder` لترتيب النتائج.

5. **البحث**: استخدم `search` للبحث في اسم المنتج ووصفه.

6. **ObjectId**: جميع المعرفات هي MongoDB ObjectId (24 حرف hex).

---

## 9. ملخص Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/products` | GET | جلب المنتجات مع الفلترة |
| `/products/:identifier` | GET | جلب منتج واحد |
| `/products/featured` | GET | المنتجات المميزة |
| `/products/new-arrivals` | GET | المنتجات الجديدة |
| `/products/best-sellers` | GET | الأكثر مبيعاً |
| `/products/on-offer` | GET | المنتجات ذات العروض |
| `/catalog/categories` | GET | الفئات الرئيسية |
| `/catalog/categories/tree` | GET | شجرة الفئات |
| `/catalog/categories/:id` | GET | فئة معينة |
| `/catalog/categories/:id/children` | GET | الفئات الفرعية |
| `/catalog/categories/:identifier/products` | GET | منتجات فئة |
| `/catalog/brands` | GET | العلامات التجارية |
| `/catalog/brands/:slug` | GET | علامة تجارية بالـ slug |
| `/catalog/brands/:id/products` | GET | منتجات علامة تجارية |
| `/catalog/devices` | GET | جميع الأجهزة |
| `/catalog/devices/brand/:brandId` | GET | أجهزة علامة تجارية |
| `/catalog/devices/:slug` | GET | جهاز بالـ slug |
| `/catalog/devices/:identifier/products` | GET | منتجات متوافقة مع جهاز |
| `/catalog/quality-types` | GET | أنواع الجودة |
