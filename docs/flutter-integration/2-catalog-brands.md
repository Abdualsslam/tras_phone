# 🏷️ Brands API - دليل ربط العلامات التجارية

## 📋 نظرة عامة

هذا الملف يحتوي على جميع API endpoints المتعلقة بالعلامات التجارية (Brands).

> **ملاحظة**: جميع الـ endpoints هنا عامة (Public) ولا تحتاج Token.

---

## 📞 API Endpoints

### 1️⃣ جلب جميع العلامات التجارية

**Endpoint:** `GET /catalog/brands`

> **ملاحظة**: هذا الـ endpoint يرجع فقط البراندات النشطة (`isActive: true`). للادمن، استخدم `/catalog/brands/all` (يتطلب مصادقة).

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

### 2️⃣ جلب منتجات البراند

**Endpoint:** `GET /catalog/brands/:id/products`

> **استخدام**: عند الضغط على براند معين، استخدم هذا الـ endpoint لجلب جميع المنتجات المرتبطة بهذا البراند. يجب استخدام ID البراند وليس slug.

**Query Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `page` | number | ❌ | رقم الصفحة (افتراضي: 1) |
| `limit` | number | ❌ | عدد المنتجات في الصفحة (افتراضي: 20) |
| `minPrice` | number | ❌ | أدنى سعر |
| `maxPrice` | number | ❌ | أعلى سعر |
| `sortBy` | string | ❌ | حقل الترتيب (`price`, `name`, `createdAt`, إلخ) |
| `sortOrder` | string | ❌ | اتجاه الترتيب (`asc`, `desc`) |

**Response:**
```dart
{
  "success": true,
  "data": [
    {
      "_id": "...",
      "name": "iPhone 15 Pro Max Screen",
      "nameAr": "شاشة آيفون 15 برو ماكس",
      "slug": "iphone-15-pro-max-screen",
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
  "message": "Brand products retrieved",
  "messageAr": "تم استرجاع منتجات العلامة التجارية",
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
/// جلب منتجات براند معين
Future<Map<String, dynamic>> getBrandProducts(
  String brandId, {
  int page = 1,
  int limit = 20,
  double? minPrice,
  double? maxPrice,
  String? sortBy,
  String? sortOrder,
}) async {
  final queryParams = <String, dynamic>{
    'page': page,
    'limit': limit,
  };
  
  if (minPrice != null) queryParams['minPrice'] = minPrice;
  if (maxPrice != null) queryParams['maxPrice'] = maxPrice;
  if (sortBy != null) queryParams['sortBy'] = sortBy;
  if (sortOrder != null) queryParams['sortOrder'] = sortOrder;
  
  final response = await _dio.get(
    '/catalog/brands/$brandId/products',
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

### 3️⃣ جلب علامة تجارية بالـ Slug

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

## 🧩 CatalogService للـ Brands

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
  
  Future<Map<String, dynamic>> getBrandProducts(
    String brandId, {
    int page = 1,
    int limit = 20,
    double? minPrice,
    double? maxPrice,
    String? sortBy,
    String? sortOrder,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
    };
    
    if (minPrice != null) queryParams['minPrice'] = minPrice;
    if (maxPrice != null) queryParams['maxPrice'] = maxPrice;
    if (sortBy != null) queryParams['sortBy'] = sortBy;
    if (sortOrder != null) queryParams['sortOrder'] = sortOrder;
    
    final response = await _dio.get(
      '/catalog/brands/$brandId/products',
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
                    '/brand/${brand.id}',
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

### عرض منتجات البراند

```dart
class BrandProductsScreen extends StatefulWidget {
  final String brandId;
  
  const BrandProductsScreen({required this.brandId});
  
  @override
  _BrandProductsScreenState createState() => _BrandProductsScreenState();
}

class _BrandProductsScreenState extends State<BrandProductsScreen> {
  int _page = 1;
  final int _limit = 20;
  List<Product> _products = [];
  bool _isLoading = false;
  bool _hasMore = true;
  
  @override
  void initState() {
    super.initState();
    _loadProducts();
  }
  
  Future<void> _loadProducts() async {
    if (_isLoading || !_hasMore) return;
    
    setState(() => _isLoading = true);
    
    try {
      final result = await catalogService.getBrandProducts(
        widget.brandId,
        page: _page,
        limit: _limit,
      );
      
      setState(() {
        _products.addAll(result['products']);
        final pagination = result['pagination'];
        _hasMore = _page < pagination['pages'];
        _page++;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Brand Products')),
      body: RefreshIndicator(
        onRefresh: () async {
          _page = 1;
          _products.clear();
          _hasMore = true;
          await _loadProducts();
        },
        child: ListView.builder(
          itemCount: _products.length + (_hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index < _products.length) {
              final product = _products[index];
              return ProductCard(product: product);
            } else {
              _loadProducts(); // Load more
              return Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }
}
```

---

## 📝 ملخص الـ Endpoints

| Method | Endpoint | الوصف |
|--------|----------|-------|
| GET | `/catalog/brands` | جميع الماركات النشطة |
| GET | `/catalog/brands/:slug` | ماركة بالـ slug |
| GET | `/catalog/brands/:id/products` | منتجات براند معين (يستخدم ID) |

---

> 🔗 **السابق:** [Models](./2-catalog-models.md) - نماذج الكتالوج  
> 🔗 **التالي:** [Categories API](./2-catalog-categories.md) - دليل ربط الأقسام
