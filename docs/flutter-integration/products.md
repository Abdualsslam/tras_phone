# 📦 Products Module - دليل ربط المنتجات

## 📋 نظرة عامة

هذا الموديول يتعامل مع:
- ✅ جلب المنتجات مع الفلترة (Public)
- ✅ تفاصيل المنتج (Public)
- ✅ تقييمات المنتج (Public)
- ✅ المفضلة (Wishlist)
- ✅ إضافة تقييم

---

## 📁 Flutter Models

### Product Model

```dart
class Product {
  final String id;
  final String sku;
  final String name;
  final String nameAr;
  final String slug;
  final String? description;
  final String? descriptionAr;
  final String? shortDescription;
  final String? shortDescriptionAr;
  
  // العلاقات
  final String brandId;
  final String categoryId;
  final List<String> additionalCategories;
  final String qualityTypeId;
  final List<String> compatibleDevices;
  
  // الصور
  final String? mainImage;
  final List<String> images;
  final String? video;
  
  // التسعير
  final double basePrice;
  final double? compareAtPrice;
  
  // المخزون
  final int stockQuantity;
  final int lowStockThreshold;
  final bool trackInventory;
  final bool allowBackorder;
  
  // الطلب
  final int minOrderQuantity;
  final int? maxOrderQuantity;
  final int quantityStep;
  
  // الحالة
  final ProductStatus status;
  final bool isActive;
  final bool isFeatured;
  final bool isNewArrival;
  final bool isBestSeller;
  
  // المواصفات
  final Map<String, dynamic>? specifications;
  final double? weight;
  final String? dimensions;
  final String? color;
  
  // الضمان
  final int? warrantyDays;
  final String? warrantyDescription;
  
  // الإحصائيات
  final int viewsCount;
  final int ordersCount;
  final int reviewsCount;
  final double averageRating;
  final int wishlistCount;
  
  // العلامات
  final List<String> tags;
  
  final DateTime? publishedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // يمكن تعبئتها إذا تم populate
  Brand? brand;
  Category? category;
  QualityType? qualityType;

  Product({
    required this.id,
    required this.sku,
    required this.name,
    required this.nameAr,
    required this.slug,
    this.description,
    this.descriptionAr,
    this.shortDescription,
    this.shortDescriptionAr,
    required this.brandId,
    required this.categoryId,
    required this.additionalCategories,
    required this.qualityTypeId,
    required this.compatibleDevices,
    this.mainImage,
    required this.images,
    this.video,
    required this.basePrice,
    this.compareAtPrice,
    required this.stockQuantity,
    required this.lowStockThreshold,
    required this.trackInventory,
    required this.allowBackorder,
    required this.minOrderQuantity,
    this.maxOrderQuantity,
    required this.quantityStep,
    required this.status,
    required this.isActive,
    required this.isFeatured,
    required this.isNewArrival,
    required this.isBestSeller,
    this.specifications,
    this.weight,
    this.dimensions,
    this.color,
    this.warrantyDays,
    this.warrantyDescription,
    required this.viewsCount,
    required this.ordersCount,
    required this.reviewsCount,
    required this.averageRating,
    required this.wishlistCount,
    required this.tags,
    this.publishedAt,
    required this.createdAt,
    required this.updatedAt,
    this.brand,
    this.category,
    this.qualityType,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id'] ?? json['id'],
      sku: json['sku'],
      name: json['name'],
      nameAr: json['nameAr'],
      slug: json['slug'],
      description: json['description'],
      descriptionAr: json['descriptionAr'],
      shortDescription: json['shortDescription'],
      shortDescriptionAr: json['shortDescriptionAr'],
      brandId: json['brandId'] is String 
          ? json['brandId'] 
          : json['brandId']['_id'],
      categoryId: json['categoryId'] is String 
          ? json['categoryId'] 
          : json['categoryId']['_id'],
      additionalCategories: List<String>.from(json['additionalCategories'] ?? []),
      qualityTypeId: json['qualityTypeId'] is String 
          ? json['qualityTypeId'] 
          : json['qualityTypeId']['_id'],
      compatibleDevices: List<String>.from(json['compatibleDevices'] ?? []),
      mainImage: json['mainImage'],
      images: List<String>.from(json['images'] ?? []),
      video: json['video'],
      basePrice: (json['basePrice'] ?? 0).toDouble(),
      compareAtPrice: json['compareAtPrice']?.toDouble(),
      stockQuantity: json['stockQuantity'] ?? 0,
      lowStockThreshold: json['lowStockThreshold'] ?? 5,
      trackInventory: json['trackInventory'] ?? true,
      allowBackorder: json['allowBackorder'] ?? false,
      minOrderQuantity: json['minOrderQuantity'] ?? 1,
      maxOrderQuantity: json['maxOrderQuantity'],
      quantityStep: json['quantityStep'] ?? 1,
      status: ProductStatus.fromString(json['status']),
      isActive: json['isActive'] ?? true,
      isFeatured: json['isFeatured'] ?? false,
      isNewArrival: json['isNewArrival'] ?? false,
      isBestSeller: json['isBestSeller'] ?? false,
      specifications: json['specifications'],
      weight: json['weight']?.toDouble(),
      dimensions: json['dimensions'],
      color: json['color'],
      warrantyDays: json['warrantyDays'],
      warrantyDescription: json['warrantyDescription'],
      viewsCount: json['viewsCount'] ?? 0,
      ordersCount: json['ordersCount'] ?? 0,
      reviewsCount: json['reviewsCount'] ?? 0,
      averageRating: (json['averageRating'] ?? 0).toDouble(),
      wishlistCount: json['wishlistCount'] ?? 0,
      tags: List<String>.from(json['tags'] ?? []),
      publishedAt: json['publishedAt'] != null 
          ? DateTime.parse(json['publishedAt']) 
          : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      brand: json['brandId'] is Map ? Brand.fromJson(json['brandId']) : null,
      category: json['categoryId'] is Map ? Category.fromJson(json['categoryId']) : null,
      qualityType: json['qualityTypeId'] is Map 
          ? QualityType.fromJson(json['qualityTypeId']) 
          : null,
    );
  }

  /// الاسم حسب اللغة
  String getName(String locale) => locale == 'ar' ? nameAr : name;
  
  /// الوصف حسب اللغة
  String? getDescription(String locale) => 
      locale == 'ar' ? descriptionAr : description;
  
  /// هل يوجد خصم؟
  bool get hasDiscount => 
      compareAtPrice != null && compareAtPrice! > basePrice;
  
  /// نسبة الخصم
  int get discountPercentage {
    if (!hasDiscount) return 0;
    return ((compareAtPrice! - basePrice) / compareAtPrice! * 100).round();
  }
  
  /// هل المخزون منخفض؟
  bool get isLowStock => stockQuantity <= lowStockThreshold;
  
  /// هل نفدت الكمية؟
  bool get isOutOfStock => stockQuantity == 0;
  
  /// هل يمكن الطلب؟
  bool get canOrder => isActive && (stockQuantity > 0 || allowBackorder);
}
```

### Enums

```dart
enum ProductStatus {
  draft,
  active,
  inactive,
  outOfStock,
  discontinued;
  
  static ProductStatus fromString(String value) {
    switch (value) {
      case 'draft': return ProductStatus.draft;
      case 'active': return ProductStatus.active;
      case 'inactive': return ProductStatus.inactive;
      case 'out_of_stock': return ProductStatus.outOfStock;
      case 'discontinued': return ProductStatus.discontinued;
      default: return ProductStatus.draft;
    }
  }
  
  String get displayNameAr {
    switch (this) {
      case ProductStatus.draft: return 'مسودة';
      case ProductStatus.active: return 'نشط';
      case ProductStatus.inactive: return 'غير نشط';
      case ProductStatus.outOfStock: return 'نفد المخزون';
      case ProductStatus.discontinued: return 'متوقف';
    }
  }
}

enum ProductSortBy {
  price,
  name,
  createdAt,
  viewsCount,
  ordersCount,
  averageRating;
  
  String get value => name;
}

enum SortOrder {
  asc,
  desc;
}
```

### ProductReview Model

```dart
class ProductReview {
  final String id;
  final String productId;
  final String customerId;
  final String? orderId;
  final int rating;
  final String? title;
  final String? comment;
  final List<String> images;
  final ReviewStatus status;
  final int helpfulCount;
  final bool isVerifiedPurchase;
  final DateTime createdAt;
  
  // يمكن تعبئتها
  Customer? customer;

  ProductReview({
    required this.id,
    required this.productId,
    required this.customerId,
    this.orderId,
    required this.rating,
    this.title,
    this.comment,
    required this.images,
    required this.status,
    required this.helpfulCount,
    required this.isVerifiedPurchase,
    required this.createdAt,
    this.customer,
  });

  factory ProductReview.fromJson(Map<String, dynamic> json) {
    return ProductReview(
      id: json['_id'] ?? json['id'],
      productId: json['productId'] is String 
          ? json['productId'] 
          : json['productId']['_id'],
      customerId: json['customerId'] is String 
          ? json['customerId'] 
          : json['customerId']['_id'],
      orderId: json['orderId'],
      rating: json['rating'],
      title: json['title'],
      comment: json['comment'],
      images: List<String>.from(json['images'] ?? []),
      status: ReviewStatus.fromString(json['status']),
      helpfulCount: json['helpfulCount'] ?? 0,
      isVerifiedPurchase: json['isVerifiedPurchase'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      customer: json['customerId'] is Map 
          ? Customer.fromJson(json['customerId']) 
          : null,
    );
  }
}

enum ReviewStatus {
  pending,
  approved,
  rejected;
  
  static ReviewStatus fromString(String value) {
    return ReviewStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ReviewStatus.pending,
    );
  }
}
```

### Filter & Response Models

```dart
class ProductFilterQuery {
  final String? search;
  final String? brandId;
  final String? categoryId;
  final String? qualityTypeId;
  final double? minPrice;
  final double? maxPrice;
  final String? status;
  final bool? isActive;
  final bool? isFeatured;
  final ProductSortBy? sortBy;
  final SortOrder? sortOrder;
  final int page;
  final int limit;

  ProductFilterQuery({
    this.search,
    this.brandId,
    this.categoryId,
    this.qualityTypeId,
    this.minPrice,
    this.maxPrice,
    this.status,
    this.isActive,
    this.isFeatured,
    this.sortBy,
    this.sortOrder,
    this.page = 1,
    this.limit = 20,
  });

  Map<String, dynamic> toQueryParameters() {
    return {
      if (search != null) 'search': search,
      if (brandId != null) 'brandId': brandId,
      if (categoryId != null) 'categoryId': categoryId,
      if (qualityTypeId != null) 'qualityTypeId': qualityTypeId,
      if (minPrice != null) 'minPrice': minPrice,
      if (maxPrice != null) 'maxPrice': maxPrice,
      if (status != null) 'status': status,
      if (isActive != null) 'isActive': isActive,
      if (isFeatured != null) 'isFeatured': isFeatured,
      if (sortBy != null) 'sortBy': sortBy!.value,
      if (sortOrder != null) 'sortOrder': sortOrder!.name,
      'page': page,
      'limit': limit,
    };
  }
}

class ProductsResponse {
  final List<Product> products;
  final int total;
  final int page;
  final int pages;

  ProductsResponse({
    required this.products,
    required this.total,
    required this.page,
    required this.pages,
  });

  factory ProductsResponse.fromJson(Map<String, dynamic> json) {
    return ProductsResponse(
      products: (json['data'] as List)
          .map((p) => Product.fromJson(p))
          .toList(),
      total: json['meta']?['total'] ?? 0,
      page: json['meta']?['page'] ?? 1,
      pages: json['meta']?['pages'] ?? 1,
    );
  }
}
```

---

## 📞 API Endpoints

### 🌐 Public Endpoints

#### 1️⃣ جلب المنتجات مع الفلترة

**Endpoint:** `GET /products` 🌐 (Public)

**Query Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `search` | string | ❌ | البحث في الاسم والوصف |
| `brandId` | string | ❌ | فلترة بالماركة |
| `categoryId` | string | ❌ | فلترة بالقسم |
| `qualityTypeId` | string | ❌ | فلترة بنوع الجودة |
| `minPrice` | number | ❌ | الحد الأدنى للسعر |
| `maxPrice` | number | ❌ | الحد الأعلى للسعر |
| `status` | string | ❌ | حالة المنتج |
| `isActive` | boolean | ❌ | المنتجات النشطة فقط |
| `isFeatured` | boolean | ❌ | المنتجات المميزة فقط |
| `sortBy` | string | ❌ | ترتيب حسب (price, name, createdAt, averageRating) |
| `sortOrder` | string | ❌ | اتجاه الترتيب (asc, desc) |
| `page` | number | ❌ | رقم الصفحة |
| `limit` | number | ❌ | عدد النتائج |

**Response:**
```dart
{
  "success": true,
  "data": [
    {
      "_id": "...",
      "sku": "SCRN-IP15-PRO",
      "name": "iPhone 15 Pro Screen",
      "nameAr": "شاشة ايفون 15 برو",
      "slug": "iphone-15-pro-screen",
      "mainImage": "https://...",
      "basePrice": 450,
      "compareAtPrice": 550,
      "stockQuantity": 25,
      "averageRating": 4.5,
      "reviewsCount": 12,
      "brandId": { "_id": "...", "name": "Apple", "nameAr": "آبل" },
      "categoryId": { "_id": "...", "name": "Screens", "nameAr": "شاشات" },
      ...
    }
  ],
  "message": "Products retrieved",
  "messageAr": "تم استرجاع المنتجات",
  "meta": {
    "total": 150,
    "page": 1,
    "pages": 8,
    "limit": 20
  }
}
```

**Flutter Code:**
```dart
class ProductsService {
  final Dio _dio;
  
  ProductsService(this._dio);
  
  /// جلب المنتجات مع الفلترة
  Future<ProductsResponse> getProducts(ProductFilterQuery filter) async {
    final response = await _dio.get(
      '/products',
      queryParameters: filter.toQueryParameters(),
    );
    
    if (response.data['success']) {
      return ProductsResponse(
        products: (response.data['data'] as List)
            .map((p) => Product.fromJson(p))
            .toList(),
        total: response.data['meta']?['total'] ?? 0,
        page: response.data['meta']?['page'] ?? 1,
        pages: response.data['meta']?['pages'] ?? 1,
      );
    }
    throw Exception(response.data['messageAr']);
  }
}
```

---

#### 2️⃣ جلب تفاصيل منتج

**Endpoint:** `GET /products/:identifier` 🌐 (Public)

> **ملاحظة:** يمكن استخدام الـ ID أو الـ slug

**Response:**
```dart
{
  "success": true,
  "data": {
    "_id": "...",
    "sku": "SCRN-IP15-PRO",
    "name": "iPhone 15 Pro Screen",
    "nameAr": "شاشة ايفون 15 برو",
    "slug": "iphone-15-pro-screen",
    "description": "Premium quality OLED screen...",
    "descriptionAr": "شاشة OLED عالية الجودة...",
    "mainImage": "https://...",
    "images": ["https://...", "https://..."],
    "video": "https://youtube.com/...",
    "basePrice": 450,
    "compareAtPrice": 550,
    "stockQuantity": 25,
    "specifications": {
      "displayType": "OLED",
      "resolution": "2556x1179",
      "brightness": "2000 nits"
    },
    "warrantyDays": 90,
    "averageRating": 4.5,
    "reviewsCount": 12,
    "brandId": { "_id": "...", "name": "Apple", ... },
    "categoryId": { "_id": "...", "name": "Screens", ... },
    "qualityTypeId": { "_id": "...", "name": "Original", ... },
    ...
  },
  "message": "Product retrieved",
  "messageAr": "تم استرجاع المنتج"
}
```

**Flutter Code:**
```dart
/// جلب تفاصيل منتج (بالـ ID أو slug)
Future<Product> getProduct(String identifier) async {
  final response = await _dio.get('/products/$identifier');
  
  if (response.data['success']) {
    return Product.fromJson(response.data['data']);
  }
  throw Exception(response.data['messageAr']);
}
```

---

#### 3️⃣ جلب تقييمات منتج

**Endpoint:** `GET /products/:id/reviews` 🌐 (Public)

**Response:**
```dart
{
  "success": true,
  "data": [
    {
      "_id": "...",
      "customerId": { 
        "_id": "...", 
        "shopName": "Tech Mobile" 
      },
      "rating": 5,
      "title": "ممتاز!",
      "comment": "جودة عالية، أنصح به بشدة",
      "images": [],
      "isVerifiedPurchase": true,
      "helpfulCount": 8,
      "createdAt": "2024-01-10T..."
    }
  ],
  "message": "Reviews retrieved",
  "messageAr": "تم استرجاع التقييمات"
}
```

**Flutter Code:**
```dart
/// جلب تقييمات منتج
Future<List<ProductReview>> getProductReviews(String productId) async {
  final response = await _dio.get('/products/$productId/reviews');
  
  if (response.data['success']) {
    return (response.data['data'] as List)
        .map((r) => ProductReview.fromJson(r))
        .toList();
  }
  throw Exception(response.data['messageAr']);
}
```

---

### 🔐 Customer Endpoints (تحتاج Token)

#### 4️⃣ جلب المفضلة

**Endpoint:** `GET /products/wishlist/my`

**Headers:** `Authorization: Bearer <accessToken>` 🔒

**Response:**
```dart
{
  "success": true,
  "data": [
    { /* Product objects */ }
  ],
  "message": "Wishlist retrieved",
  "messageAr": "تم استرجاع المفضلة"
}
```

**Flutter Code:**
```dart
/// جلب المفضلة
Future<List<Product>> getWishlist() async {
  final response = await _dio.get('/products/wishlist/my');
  
  if (response.data['success']) {
    return (response.data['data'] as List)
        .map((p) => Product.fromJson(p))
        .toList();
  }
  throw Exception(response.data['messageAr']);
}
```

---

#### 5️⃣ إضافة للمفضلة

**Endpoint:** `POST /products/:id/wishlist`

**Headers:** `Authorization: Bearer <accessToken>` 🔒

**Flutter Code:**
```dart
/// إضافة للمفضلة
Future<void> addToWishlist(String productId) async {
  final response = await _dio.post('/products/$productId/wishlist');
  
  if (!response.data['success']) {
    throw Exception(response.data['messageAr']);
  }
}
```

---

#### 6️⃣ إزالة من المفضلة

**Endpoint:** `DELETE /products/:id/wishlist`

**Headers:** `Authorization: Bearer <accessToken>` 🔒

**Flutter Code:**
```dart
/// إزالة من المفضلة
Future<void> removeFromWishlist(String productId) async {
  final response = await _dio.delete('/products/$productId/wishlist');
  
  if (!response.data['success']) {
    throw Exception(response.data['messageAr']);
  }
}
```

---

#### 7️⃣ إضافة تقييم

**Endpoint:** `POST /products/:id/reviews`

**Headers:** `Authorization: Bearer <accessToken>` 🔒

**Request Body:**
```dart
{
  "rating": 5,                              // مطلوب (1-5)
  "title": "ممتاز!",                        // اختياري
  "comment": "جودة عالية، أنصح به بشدة",    // اختياري
  "images": ["https://..."]                 // اختياري (max 5)
}
```

**Response (201 Created):**
```dart
{
  "success": true,
  "data": { /* ProductReview object */ },
  "message": "Review added",
  "messageAr": "تم إضافة التقييم"
}
```

**Flutter Code:**
```dart
/// إضافة تقييم
Future<ProductReview> addReview({
  required String productId,
  required int rating,
  String? title,
  String? comment,
  List<String>? images,
}) async {
  final response = await _dio.post('/products/$productId/reviews', data: {
    'rating': rating,
    if (title != null) 'title': title,
    if (comment != null) 'comment': comment,
    if (images != null && images.isNotEmpty) 'images': images,
  });
  
  if (response.data['success']) {
    return ProductReview.fromJson(response.data['data']);
  }
  throw Exception(response.data['messageAr']);
}
```

---

## 🧩 ProductsService الكامل

```dart
import 'package:dio/dio.dart';

class ProductsService {
  final Dio _dio;
  
  ProductsService(this._dio);
  
  // ═════════════════════════════════════
  // Public
  // ═════════════════════════════════════
  
  Future<ProductsResponse> getProducts(ProductFilterQuery filter) async {
    final response = await _dio.get(
      '/products',
      queryParameters: filter.toQueryParameters(),
    );
    
    if (response.data['success']) {
      return ProductsResponse(
        products: (response.data['data'] as List)
            .map((p) => Product.fromJson(p))
            .toList(),
        total: response.data['meta']?['total'] ?? 0,
        page: response.data['meta']?['page'] ?? 1,
        pages: response.data['meta']?['pages'] ?? 1,
      );
    }
    throw Exception(response.data['messageAr']);
  }
  
  Future<Product> getProduct(String identifier) async {
    final response = await _dio.get('/products/$identifier');
    
    if (response.data['success']) {
      return Product.fromJson(response.data['data']);
    }
    throw Exception(response.data['messageAr']);
  }
  
  Future<List<ProductReview>> getProductReviews(String productId) async {
    final response = await _dio.get('/products/$productId/reviews');
    
    if (response.data['success']) {
      return (response.data['data'] as List)
          .map((r) => ProductReview.fromJson(r))
          .toList();
    }
    throw Exception(response.data['messageAr']);
  }
  
  // ═════════════════════════════════════
  // Wishlist (Auth Required)
  // ═════════════════════════════════════
  
  Future<List<Product>> getWishlist() async {
    final response = await _dio.get('/products/wishlist/my');
    
    if (response.data['success']) {
      return (response.data['data'] as List)
          .map((p) => Product.fromJson(p))
          .toList();
    }
    throw Exception(response.data['messageAr']);
  }
  
  Future<void> addToWishlist(String productId) async {
    final response = await _dio.post('/products/$productId/wishlist');
    
    if (!response.data['success']) {
      throw Exception(response.data['messageAr']);
    }
  }
  
  Future<void> removeFromWishlist(String productId) async {
    final response = await _dio.delete('/products/$productId/wishlist');
    
    if (!response.data['success']) {
      throw Exception(response.data['messageAr']);
    }
  }
  
  /// تبديل حالة المفضلة
  Future<bool> toggleWishlist(String productId, bool isInWishlist) async {
    if (isInWishlist) {
      await removeFromWishlist(productId);
      return false;
    } else {
      await addToWishlist(productId);
      return true;
    }
  }
  
  // ═════════════════════════════════════
  // Reviews (Auth Required)
  // ═════════════════════════════════════
  
  Future<ProductReview> addReview({
    required String productId,
    required int rating,
    String? title,
    String? comment,
    List<String>? images,
  }) async {
    final response = await _dio.post('/products/$productId/reviews', data: {
      'rating': rating,
      if (title != null) 'title': title,
      if (comment != null) 'comment': comment,
      if (images != null && images.isNotEmpty) 'images': images,
    });
    
    if (response.data['success']) {
      return ProductReview.fromJson(response.data['data']);
    }
    throw Exception(response.data['messageAr']);
  }
}
```

---

## 🎯 أمثلة الاستخدام

### شبكة المنتجات مع الفلترة

```dart
class ProductsGridScreen extends StatefulWidget {
  final String? categoryId;
  final String? brandId;
  
  @override
  _ProductsGridScreenState createState() => _ProductsGridScreenState();
}

class _ProductsGridScreenState extends State<ProductsGridScreen> {
  List<Product> _products = [];
  bool _isLoading = true;
  int _currentPage = 1;
  int _totalPages = 1;
  ProductSortBy _sortBy = ProductSortBy.createdAt;
  SortOrder _sortOrder = SortOrder.desc;
  
  @override
  void initState() {
    super.initState();
    _loadProducts();
  }
  
  Future<void> _loadProducts({bool refresh = false}) async {
    if (refresh) _currentPage = 1;
    
    setState(() => _isLoading = true);
    
    try {
      final response = await productsService.getProducts(ProductFilterQuery(
        categoryId: widget.categoryId,
        brandId: widget.brandId,
        sortBy: _sortBy,
        sortOrder: _sortOrder,
        page: _currentPage,
      ));
      
      setState(() {
        _products = response.products;
        _totalPages = response.pages;
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('المنتجات'),
        actions: [
          PopupMenuButton<ProductSortBy>(
            icon: Icon(Icons.sort),
            onSelected: (sortBy) {
              _sortBy = sortBy;
              _loadProducts(refresh: true);
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: ProductSortBy.createdAt, child: Text('الأحدث')),
              PopupMenuItem(value: ProductSortBy.price, child: Text('السعر')),
              PopupMenuItem(value: ProductSortBy.averageRating, child: Text('التقييم')),
              PopupMenuItem(value: ProductSortBy.ordersCount, child: Text('الأكثر مبيعاً')),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? LoadingIndicator()
          : RefreshIndicator(
              onRefresh: () => _loadProducts(refresh: true),
              child: GridView.builder(
                padding: EdgeInsets.all(16),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.7,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: _products.length,
                itemBuilder: (context, index) {
                  return ProductCard(
                    product: _products[index],
                    onTap: () => _openProduct(_products[index]),
                  );
                },
              ),
            ),
    );
  }
}
```

### بطاقة المنتج مع زر المفضلة

```dart
class ProductCard extends StatefulWidget {
  final Product product;
  final VoidCallback onTap;
  
  @override
  _ProductCardState createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool _isInWishlist = false;
  
  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    
    return GestureDetector(
      onTap: widget.onTap,
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // الصورة + زر المفضلة
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 1,
                  child: Image.network(
                    product.mainImage ?? '',
                    fit: BoxFit.cover,
                  ),
                ),
                
                // شارة الخصم
                if (product.hasDiscount)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${product.discountPercentage}%-',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ),
                
                // زر المفضلة
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    icon: Icon(
                      _isInWishlist ? Icons.favorite : Icons.favorite_border,
                      color: _isInWishlist ? Colors.red : Colors.grey,
                    ),
                    onPressed: _toggleWishlist,
                  ),
                ),
              ],
            ),
            
            Padding(
              padding: EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.getName('ar'),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  
                  // التقييم
                  Row(
                    children: [
                      Icon(Icons.star, size: 16, color: Colors.amber),
                      Text(' ${product.averageRating}'),
                      Text(' (${product.reviewsCount})', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                  SizedBox(height: 4),
                  
                  // السعر
                  Row(
                    children: [
                      Text(
                        '${product.basePrice} ر.س',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      if (product.hasDiscount) ...[
                        SizedBox(width: 8),
                        Text(
                          '${product.compareAtPrice}',
                          style: TextStyle(
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Future<void> _toggleWishlist() async {
    final newState = await productsService.toggleWishlist(
      widget.product.id, 
      _isInWishlist,
    );
    setState(() => _isInWishlist = newState);
  }
}
```

---

## 📝 ملخص الـ Endpoints

| Method | Endpoint | Auth | الوصف |
|--------|----------|------|-------|
| GET | `/products` | ❌ | جلب المنتجات مع الفلترة |
| GET | `/products/:identifier` | ❌ | تفاصيل منتج |
| GET | `/products/:id/reviews` | ❌ | تقييمات منتج |
| GET | `/products/wishlist/my` | ✅ | جلب المفضلة |
| POST | `/products/:id/wishlist` | ✅ | إضافة للمفضلة |
| DELETE | `/products/:id/wishlist` | ✅ | إزالة من المفضلة |
| POST | `/products/:id/reviews` | ✅ | إضافة تقييم |

---

> 🔗 **السابق:** [notifications.md](./notifications.md) - دليل الإشعارات  
> 🔗 **التالي:** [locations.md](./locations.md) - دليل المواقع (قريباً)
