# ❤️ Wishlist Module - دليل ربط المفضلة

## 📋 نظرة عامة

هذا الموديول يتعامل مع:
- ✅ إضافة المنتجات للمفضلة
- ✅ إزالة المنتجات من المفضلة
- ✅ جلب قائمة المفضلة
- ✅ التحقق من وجود منتج في المفضلة
- ✅ Toggle حالة المفضلة
- ✅ مسح المفضلة بالكامل
- ✅ جلب عدد المنتجات في المفضلة
- ✅ نقل منتج من المفضلة للسلة
- ✅ نقل جميع المنتجات للسلة
- ✅ المنتجات التي تم مشاهدتها مؤخراً
- ✅ تنبيهات المخزون

**ملاحظة:** جميع عمليات المفضلة تحتاج **مصادقة (Authentication)** 🔒

---

## 🗄️ Backend Schema

### Wishlist Schema

```typescript
@Schema({
  timestamps: true,
  collection: 'wishlists',
})
export class Wishlist {
  @Prop({ type: Types.ObjectId, ref: 'Customer', required: true, index: true })
  customerId: Types.ObjectId;

  @Prop({ type: Types.ObjectId, ref: 'Product', required: true, index: true })
  productId: Types.ObjectId;

  @Prop()
  note?: string;

  @Prop({ default: false })
  notifyOnPriceChange: boolean;

  @Prop({ default: false })
  notifyOnBackInStock: boolean;

  createdAt: Date;
}

// Unique index: customerId + productId
WishlistSchema.index({ customerId: 1, productId: 1 }, { unique: true });
```

---

## 📁 Flutter Models

### WishlistItemModel

```dart
import 'package:json_annotation/json_annotation.dart';
import '../../../catalog/data/models/product_model.dart';

part 'wishlist_item_model.g.dart';

@JsonSerializable()
class WishlistItemModel {
  final int id;
  @JsonKey(name: 'product_id')
  final int productId;
  final ProductModel? product;
  @JsonKey(name: 'added_at')
  final String? addedAt;
  @JsonKey(name: 'is_in_stock')
  final bool isInStock;
  @JsonKey(name: 'price_dropped')
  final bool priceDropped;
  @JsonKey(name: 'original_price')
  final double? originalPrice;
  @JsonKey(name: 'current_price')
  final double? currentPrice;

  const WishlistItemModel({
    required this.id,
    required this.productId,
    this.product,
    this.addedAt,
    this.isInStock = true,
    this.priceDropped = false,
    this.originalPrice,
    this.currentPrice,
  });

  factory WishlistItemModel.fromJson(Map<String, dynamic> json) =>
      _$WishlistItemModelFromJson(json);
  Map<String, dynamic> toJson() => _$WishlistItemModelToJson(this);

  /// حساب الفرق في السعر
  double? get priceDifference {
    if (originalPrice != null && currentPrice != null) {
      return originalPrice! - currentPrice!;
    }
    return null;
  }

  /// نسبة الخصم
  double? get discountPercentage {
    if (originalPrice != null && currentPrice != null && originalPrice! > 0) {
      return ((originalPrice! - currentPrice!) / originalPrice!) * 100;
    }
    return null;
  }
}
```

---

## 🔌 API Endpoints

### Base URLs

```dart
// في api_endpoints.dart
static const String wishlist = '/wishlist';
static const String wishlistMy = '/products/wishlist/my';
static String productWishlist(String id) => '/products/$id/wishlist';
static const String recentlyViewed = '/recently-viewed';
static const String stockAlerts = '/stock-alerts';
```

---

### 1️⃣ جلب المفضلة

**Endpoint:** `GET /products/wishlist/my`

**Headers:** `Authorization: Bearer <accessToken>` 🔒

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": "507f1f77bcf86cd799439011",
      "productId": "507f1f77bcf86cd799439012",
      "product": {
        "id": "507f1f77bcf86cd799439012",
        "name": "شاشة آيفون 14 برو ماكس",
        "nameAr": "شاشة آيفون 14 برو ماكس",
        "mainImage": "https://...",
        "basePrice": 450.0,
        "compareAtPrice": 500.0,
        "stockQuantity": 10,
        "wishlistCount": 25
      },
      "addedAt": "2024-01-15T10:30:00Z",
      "isInStock": true,
      "priceDropped": true,
      "originalPrice": 500.0,
      "currentPrice": 450.0
    }
  ],
  "message": "Wishlist retrieved",
  "messageAr": "تم استرجاع المفضلة"
}
```

**Flutter Code:**
```dart
/// جلب المفضلة
Future<List<WishlistItemModel>> getWishlist() async {
  final response = await _apiClient.get(ApiEndpoints.wishlistMy);
  final data = response.data['data'] ?? response.data;
  final List<dynamic> list = data is List ? data : [];
  
  return list.map((json) => WishlistItemModel.fromJson(json)).toList();
}
```

---

### 2️⃣ إضافة للمفضلة

**Endpoint:** `POST /products/:id/wishlist`

**Headers:** `Authorization: Bearer <accessToken>` 🔒

**Response:**
```json
{
  "success": true,
  "data": null,
  "message": "Added to wishlist",
  "messageAr": "تم الإضافة للمفضلة"
}
```

**Errors:**
- `409 Conflict`: المنتج موجود بالفعل في المفضلة
- `404 Not Found`: المنتج غير موجود

**Flutter Code:**
```dart
/// إضافة للمفضلة
Future<void> addToWishlist(String productId) async {
  final response = await _apiClient.post(
    ApiEndpoints.productWishlist(productId),
  );
  
  if (response.data['success'] != true) {
    throw Exception(response.data['messageAr'] ?? 'Failed to add to wishlist');
  }
}
```

---

### 3️⃣ إزالة من المفضلة

**Endpoint:** `DELETE /products/:id/wishlist`

**Headers:** `Authorization: Bearer <accessToken>` 🔒

**Response:**
```json
{
  "success": true,
  "data": null,
  "message": "Removed from wishlist",
  "messageAr": "تم الإزالة من المفضلة"
}
```

**Flutter Code:**
```dart
/// إزالة من المفضلة
Future<void> removeFromWishlist(String productId) async {
  final response = await _apiClient.delete(
    ApiEndpoints.productWishlist(productId),
  );
  
  if (response.data['success'] != true) {
    throw Exception(response.data['messageAr'] ?? 'Failed to remove from wishlist');
  }
}
```

---

### 4️⃣ Toggle المفضلة

**Flutter Code:**
```dart
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
```

---

### 5️⃣ التحقق من وجود منتج في المفضلة

**Endpoint:** `GET /wishlist/check/:productId`

**Headers:** `Authorization: Bearer <accessToken>` 🔒

**Response:**
```json
{
  "success": true,
  "data": {
    "in_wishlist": true
  },
  "message": "Wishlist status checked",
  "messageAr": "تم التحقق من حالة المفضلة"
}
```

**Flutter Code:**
```dart
/// التحقق من وجود منتج في المفضلة
Future<bool> isInWishlist(String productId) async {
  final response = await _apiClient.get(
    '${ApiEndpoints.wishlist}/check/$productId',
  );
  
  final data = response.data['data'] ?? response.data;
  return data['in_wishlist'] ?? false;
}
```

---

### 6️⃣ مسح المفضلة بالكامل

**Endpoint:** `DELETE /wishlist`

**Headers:** `Authorization: Bearer <accessToken>` 🔒

**Response:**
```json
{
  "success": true,
  "data": null,
  "message": "Wishlist cleared",
  "messageAr": "تم مسح المفضلة"
}
```

**Flutter Code:**
```dart
/// مسح المفضلة بالكامل
Future<bool> clearWishlist() async {
  final response = await _apiClient.delete(ApiEndpoints.wishlist);
  return response.statusCode == 200;
}
```

---

### 7️⃣ جلب عدد المنتجات في المفضلة

**Endpoint:** `GET /wishlist/count`

**Headers:** `Authorization: Bearer <accessToken>` 🔒

**Response:**
```json
{
  "success": true,
  "data": {
    "count": 15
  },
  "message": "Wishlist count retrieved",
  "messageAr": "تم جلب عدد المفضلة"
}
```

**Flutter Code:**
```dart
/// جلب عدد المنتجات في المفضلة
Future<int> getWishlistCount() async {
  final response = await _apiClient.get('${ApiEndpoints.wishlist}/count');
  final data = response.data['data'] ?? response.data;
  return data['count'] ?? 0;
}
```

---

### 8️⃣ نقل منتج من المفضلة للسلة

**Endpoint:** `POST /wishlist/:productId/move-to-cart`

**Headers:** `Authorization: Bearer <accessToken>` 🔒

**Request Body (Optional):**
```json
{
  "quantity": 1
}
```

**Response:**
```json
{
  "success": true,
  "data": null,
  "message": "Product moved to cart",
  "messageAr": "تم نقل المنتج للسلة"
}
```

**Flutter Code:**
```dart
/// نقل منتج من المفضلة للسلة
Future<bool> moveToCart(String productId, {int quantity = 1}) async {
  final response = await _apiClient.post(
    '${ApiEndpoints.wishlist}/$productId/move-to-cart',
    data: {'quantity': quantity},
  );
  
  return response.statusCode == 200;
}
```

---

### 9️⃣ نقل جميع المنتجات للسلة

**Endpoint:** `POST /wishlist/move-all-to-cart`

**Headers:** `Authorization: Bearer <accessToken>` 🔒

**Response:**
```json
{
  "success": true,
  "data": {
    "moved": 5,
    "failed": 0
  },
  "message": "Products moved to cart",
  "messageAr": "تم نقل المنتجات للسلة"
}
```

**Flutter Code:**
```dart
/// نقل جميع المنتجات للسلة
Future<bool> moveAllToCart() async {
  final response = await _apiClient.post(
    '${ApiEndpoints.wishlist}/move-all-to-cart',
  );
  
  return response.statusCode == 200;
}
```

---

### 🔟 المنتجات التي تم مشاهدتها مؤخراً

#### جلب المنتجات المشاهدة مؤخراً

**Endpoint:** `GET /recently-viewed`

**Headers:** `Authorization: Bearer <accessToken>` 🔒

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "productId": "507f1f77bcf86cd799439012",
      "product": { /* Product object */ },
      "viewedAt": "2024-01-15T10:30:00Z"
    }
  ],
  "message": "Recently viewed retrieved",
  "messageAr": "تم جلب المنتجات المشاهدة مؤخراً"
}
```

**Flutter Code:**
```dart
/// جلب المنتجات المشاهدة مؤخراً
Future<List<Map<String, dynamic>>> getRecentlyViewed() async {
  final response = await _apiClient.get(ApiEndpoints.recentlyViewed);
  final data = response.data['data'] ?? response.data;
  
  if (data is List) {
    return data.cast<Map<String, dynamic>>();
  }
  return [];
}
```

#### إضافة منتج للمشاهدة مؤخراً

**Endpoint:** `POST /recently-viewed`

**Headers:** `Authorization: Bearer <accessToken>` 🔒

**Request Body:**
```json
{
  "product_id": "507f1f77bcf86cd799439012"
}
```

**Flutter Code:**
```dart
/// إضافة منتج للمشاهدة مؤخراً
Future<bool> addToRecentlyViewed(String productId) async {
  final response = await _apiClient.post(
    ApiEndpoints.recentlyViewed,
    data: {'product_id': productId},
  );
  
  return response.statusCode == 200;
}
```

#### مسح المنتجات المشاهدة مؤخراً

**Endpoint:** `DELETE /recently-viewed`

**Headers:** `Authorization: Bearer <accessToken>` 🔒

**Flutter Code:**
```dart
/// مسح المنتجات المشاهدة مؤخراً
Future<bool> clearRecentlyViewed() async {
  final response = await _apiClient.delete(ApiEndpoints.recentlyViewed);
  return response.statusCode == 200;
}
```

---

### 1️⃣1️⃣ تنبيهات المخزون

#### إنشاء تنبيه مخزون

**Endpoint:** `POST /stock-alerts`

**Headers:** `Authorization: Bearer <accessToken>` 🔒

**Request Body:**
```json
{
  "product_id": "507f1f77bcf86cd799439012"
}
```

**Flutter Code:**
```dart
/// إنشاء تنبيه مخزون
Future<bool> createStockAlert(String productId) async {
  final response = await _apiClient.post(
    ApiEndpoints.stockAlerts,
    data: {'product_id': productId},
  );
  
  return response.statusCode == 200;
}
```

#### إزالة تنبيه مخزون

**Endpoint:** `DELETE /stock-alerts/:productId`

**Headers:** `Authorization: Bearer <accessToken>` 🔒

**Flutter Code:**
```dart
/// إزالة تنبيه مخزون
Future<bool> removeStockAlert(String productId) async {
  final response = await _apiClient.delete(
    '${ApiEndpoints.stockAlerts}/$productId',
  );
  
  return response.statusCode == 200;
}
```

#### جلب تنبيهات المخزون

**Endpoint:** `GET /stock-alerts`

**Headers:** `Authorization: Bearer <accessToken>` 🔒

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "productId": "507f1f77bcf86cd799439012",
      "product": { /* Product object */ },
      "createdAt": "2024-01-15T10:30:00Z"
    }
  ],
  "message": "Stock alerts retrieved",
  "messageAr": "تم جلب تنبيهات المخزون"
}
```

**Flutter Code:**
```dart
/// جلب تنبيهات المخزون
Future<List<Map<String, dynamic>>> getStockAlerts() async {
  final response = await _apiClient.get(ApiEndpoints.stockAlerts);
  final data = response.data['data'] ?? response.data;
  
  if (data is List) {
    return data.cast<Map<String, dynamic>>();
  }
  return [];
}
```

---

## 📦 Flutter Data Source

### WishlistRemoteDataSource

```dart
/// Abstract interface for wishlist data source
abstract class WishlistRemoteDataSource {
  /// Get all wishlist items
  Future<List<WishlistItemModel>> getWishlist();

  /// Add product to wishlist
  Future<void> addToWishlist(String productId);

  /// Remove product from wishlist
  Future<void> removeFromWishlist(String productId);

  /// Toggle wishlist status
  Future<bool> toggleWishlist(String productId, bool isInWishlist);

  /// Check if product is in wishlist
  Future<bool> isInWishlist(String productId);

  /// Clear entire wishlist
  Future<bool> clearWishlist();

  /// Get wishlist count
  Future<int> getWishlistCount();

  /// Move item to cart
  Future<bool> moveToCart(String productId);

  /// Move all items to cart
  Future<bool> moveAllToCart();

  /// Get recently viewed products
  Future<List<Map<String, dynamic>>> getRecentlyViewed();

  /// Add to recently viewed
  Future<bool> addToRecentlyViewed(String productId);

  /// Clear recently viewed
  Future<bool> clearRecentlyViewed();

  /// Create stock alert for product
  Future<bool> createStockAlert(String productId);

  /// Remove stock alert
  Future<bool> removeStockAlert(String productId);

  /// Get stock alerts
  Future<List<Map<String, dynamic>>> getStockAlerts();
}
```

### Implementation

```dart
/// Implementation of WishlistRemoteDataSource using API client
class WishlistRemoteDataSourceImpl implements WishlistRemoteDataSource {
  final ApiClient _apiClient;

  WishlistRemoteDataSourceImpl({required ApiClient apiClient})
    : _apiClient = apiClient;

  @override
  Future<List<WishlistItemModel>> getWishlist() async {
    final response = await _apiClient.get(ApiEndpoints.wishlistMy);
    final data = response.data['data'] ?? response.data;
    final List<dynamic> list = data is List ? data : [];

    return list.map((json) => WishlistItemModel.fromJson(json)).toList();
  }

  @override
  Future<void> addToWishlist(String productId) async {
    final response = await _apiClient.post(
      ApiEndpoints.productWishlist(productId),
    );

    if (response.data['success'] != true) {
      throw Exception(response.data['messageAr'] ?? 'Failed to add to wishlist');
    }
  }

  @override
  Future<void> removeFromWishlist(String productId) async {
    final response = await _apiClient.delete(
      ApiEndpoints.productWishlist(productId),
    );

    if (response.data['success'] != true) {
      throw Exception(response.data['messageAr'] ?? 'Failed to remove from wishlist');
    }
  }

  @override
  Future<bool> toggleWishlist(String productId, bool isInWishlist) async {
    if (isInWishlist) {
      await removeFromWishlist(productId);
      return false;
    } else {
      await addToWishlist(productId);
      return true;
    }
  }

  @override
  Future<bool> isInWishlist(String productId) async {
    final response = await _apiClient.get(
      '${ApiEndpoints.wishlist}/check/$productId',
    );

    final data = response.data['data'] ?? response.data;
    return data['in_wishlist'] ?? false;
  }

  @override
  Future<bool> clearWishlist() async {
    final response = await _apiClient.delete(ApiEndpoints.wishlist);
    return response.statusCode == 200;
  }

  @override
  Future<int> getWishlistCount() async {
    final response = await _apiClient.get('${ApiEndpoints.wishlist}/count');
    final data = response.data['data'] ?? response.data;
    return data['count'] ?? 0;
  }

  @override
  Future<bool> moveToCart(String productId) async {
    final response = await _apiClient.post(
      '${ApiEndpoints.wishlist}/$productId/move-to-cart',
    );
    return response.statusCode == 200;
  }

  @override
  Future<bool> moveAllToCart() async {
    final response = await _apiClient.post(
      '${ApiEndpoints.wishlist}/move-all-to-cart',
    );
    return response.statusCode == 200;
  }

  @override
  Future<List<Map<String, dynamic>>> getRecentlyViewed() async {
    final response = await _apiClient.get(ApiEndpoints.recentlyViewed);
    final data = response.data['data'] ?? response.data;

    if (data is List) {
      return data.cast<Map<String, dynamic>>();
    }
    return [];
  }

  @override
  Future<bool> addToRecentlyViewed(String productId) async {
    final response = await _apiClient.post(
      ApiEndpoints.recentlyViewed,
      data: {'product_id': productId},
    );
    return response.statusCode == 200;
  }

  @override
  Future<bool> clearRecentlyViewed() async {
    final response = await _apiClient.delete(ApiEndpoints.recentlyViewed);
    return response.statusCode == 200;
  }

  @override
  Future<bool> createStockAlert(String productId) async {
    final response = await _apiClient.post(
      ApiEndpoints.stockAlerts,
      data: {'product_id': productId},
    );
    return response.statusCode == 200;
  }

  @override
  Future<bool> removeStockAlert(String productId) async {
    final response = await _apiClient.delete(
      '${ApiEndpoints.stockAlerts}/$productId',
    );
    return response.statusCode == 200;
  }

  @override
  Future<List<Map<String, dynamic>>> getStockAlerts() async {
    final response = await _apiClient.get(ApiEndpoints.stockAlerts);
    final data = response.data['data'] ?? response.data;

    if (data is List) {
      return data.cast<Map<String, dynamic>>();
    }
    return [];
  }
}
```

---

## 🎨 Flutter Screens

### WishlistScreen

```dart
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/datasources/wishlist_remote_datasource.dart';
import '../../data/models/wishlist_item_model.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  final WishlistRemoteDataSource _dataSource = getIt<WishlistRemoteDataSource>();
  List<WishlistItemModel> _wishlistItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWishlist();
  }

  Future<void> _loadWishlist() async {
    setState(() => _isLoading = true);
    try {
      final items = await _dataSource.getWishlist();
      setState(() {
        _wishlistItems = items;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في جلب المفضلة: $e')),
        );
      }
    }
  }

  Future<void> _removeFromWishlist(String productId) async {
    try {
      await _dataSource.removeFromWishlist(productId);
      await _loadWishlist();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم الإزالة من المفضلة')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ: $e')),
        );
      }
    }
  }

  Future<void> _moveToCart(String productId) async {
    try {
      await _dataSource.moveToCart(productId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم نقل المنتج للسلة')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ: $e')),
        );
      }
    }
  }

  Future<void> _clearWishlist() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('مسح المفضلة'),
        content: const Text('هل أنت متأكد من مسح جميع المنتجات من المفضلة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('مسح', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _dataSource.clearWishlist();
        await _loadWishlist();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم مسح المفضلة')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('خطأ: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          '${AppLocalizations.of(context)!.favorites} (${_wishlistItems.length})',
        ),
        actions: [
          if (_wishlistItems.isNotEmpty)
            TextButton(
              onPressed: _clearWishlist,
              child: const Text('مسح الكل'),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _wishlistItems.isEmpty
              ? _buildEmptyState(theme)
              : RefreshIndicator(
                  onRefresh: _loadWishlist,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _wishlistItems.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return _buildWishlistCard(
                        context,
                        theme,
                        isDark,
                        _wishlistItems[index],
                      );
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Iconsax.heart,
            size: 80,
            color: AppColors.textTertiaryLight,
          ),
          const SizedBox(height: 24),
          Text(
            'قائمة المفضلة فارغة',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'أضف المنتجات التي تعجبك للوصول إليها لاحقاً',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textTertiaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWishlistCard(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    WishlistItemModel item,
  ) {
    final product = item.product;
    if (product == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Product Image
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: isDark ? AppColors.backgroundDark : Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: product.mainImage != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      product.mainImage!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(
                        Iconsax.image,
                        size: 32,
                        color: AppColors.textTertiaryLight,
                      ),
                    ),
                  )
                : Icon(
                    Iconsax.image,
                    size: 32,
                    color: AppColors.textTertiaryLight,
                  ),
          ),
          const SizedBox(width: 12),

          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.nameAr,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      '${item.currentPrice ?? product.basePrice} ${AppLocalizations.of(context)!.currency}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    if (item.originalPrice != null && item.priceDropped) ...[
                      const SizedBox(width: 8),
                      Text(
                        '${item.originalPrice} ${AppLocalizations.of(context)!.currency}',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textTertiaryLight,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      if (item.discountPercentage != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '-${item.discountPercentage!.toStringAsFixed(0)}%',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      item.isInStock ? Iconsax.tick_circle : Iconsax.close_circle,
                      size: 14,
                      color: item.isInStock ? AppColors.success : AppColors.error,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      item.isInStock
                          ? AppLocalizations.of(context)!.inStock
                          : AppLocalizations.of(context)!.outOfStock,
                      style: TextStyle(
                        fontSize: 12,
                        color: item.isInStock ? AppColors.success : AppColors.error,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Actions
          Column(
            children: [
              IconButton(
                icon: const Icon(Iconsax.trash, color: AppColors.error),
                onPressed: () => _removeFromWishlist(product.id),
              ),
              if (item.isInStock)
                IconButton(
                  icon: const Icon(
                    Iconsax.shopping_cart,
                    color: AppColors.primary,
                  ),
                  onPressed: () => _moveToCart(product.id),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
```

---

## 💡 أمثلة الاستخدام

### 1. إضافة منتج للمفضلة من صفحة المنتج

```dart
class ProductDetailsScreen extends StatefulWidget {
  final String productId;
  
  const ProductDetailsScreen({required this.productId, super.key});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  final WishlistRemoteDataSource _wishlistDataSource = getIt<WishlistRemoteDataSource>();
  bool _isInWishlist = false;
  bool _isLoadingWishlist = false;

  @override
  void initState() {
    super.initState();
    _checkWishlistStatus();
  }

  Future<void> _checkWishlistStatus() async {
    try {
      final isInWishlist = await _wishlistDataSource.isInWishlist(widget.productId);
      setState(() => _isInWishlist = isInWishlist);
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _toggleWishlist() async {
    setState(() => _isLoadingWishlist = true);
    try {
      final newState = await _wishlistDataSource.toggleWishlist(
        widget.productId,
        _isInWishlist,
      );
      setState(() {
        _isInWishlist = newState;
        _isLoadingWishlist = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isInWishlist ? 'تم الإضافة للمفضلة' : 'تم الإزالة من المفضلة',
            ),
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoadingWishlist = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل المنتج'),
        actions: [
          IconButton(
            icon: _isLoadingWishlist
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(
                    _isInWishlist ? Iconsax.heart5 : Iconsax.heart,
                    color: _isInWishlist ? Colors.red : null,
                  ),
            onPressed: _toggleWishlist,
          ),
        ],
      ),
      body: const Center(child: Text('Product Details')),
    );
  }
}
```

### 2. عرض عدد المفضلة في AppBar

```dart
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final WishlistRemoteDataSource _wishlistDataSource = getIt<WishlistRemoteDataSource>();
  int _wishlistCount = 0;

  @override
  void initState() {
    super.initState();
    _loadWishlistCount();
  }

  Future<void> _loadWishlistCount() async {
    try {
      final count = await _wishlistDataSource.getWishlistCount();
      setState(() => _wishlistCount = count);
    } catch (e) {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الرئيسية'),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Iconsax.heart),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const WishlistScreen(),
                    ),
                  ).then((_) => _loadWishlistCount());
                },
              ),
              if (_wishlistCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '$_wishlistCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: const Center(child: Text('Home')),
    );
  }
}
```

### 3. إضافة منتج للمشاهدة مؤخراً

```dart
class ProductDetailsScreen extends StatefulWidget {
  final String productId;
  
  const ProductDetailsScreen({required this.productId, super.key});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  final WishlistRemoteDataSource _wishlistDataSource = getIt<WishlistRemoteDataSource>();

  @override
  void initState() {
    super.initState();
    _addToRecentlyViewed();
  }

  Future<void> _addToRecentlyViewed() async {
    try {
      await _wishlistDataSource.addToRecentlyViewed(widget.productId);
    } catch (e) {
      // Handle error silently
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تفاصيل المنتج')),
      body: const Center(child: Text('Product Details')),
    );
  }
}
```

### 4. إنشاء تنبيه مخزون

```dart
Future<void> _createStockAlert(String productId) async {
  try {
    await _wishlistDataSource.createStockAlert(productId);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('سيتم إشعارك عند توفر المنتج'),
        ),
      );
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ: $e')),
      );
    }
  }
}
```

---

## 🔄 Dependency Injection

```dart
// في injection.dart
import '../../features/wishlist/data/datasources/wishlist_remote_datasource.dart';

// تسجيل WishlistRemoteDataSource
getIt.registerLazySingleton<WishlistRemoteDataSource>(
  () => WishlistRemoteDataSourceImpl(apiClient: getIt<ApiClient>()),
);
```

---

## 📊 ملخص الـ Endpoints

| Method | Endpoint | الوصف | Auth |
|--------|----------|-------|------|
| GET | `/products/wishlist/my` | جلب المفضلة | ✅ |
| POST | `/products/:id/wishlist` | إضافة للمفضلة | ✅ |
| DELETE | `/products/:id/wishlist` | إزالة من المفضلة | ✅ |
| GET | `/wishlist/check/:productId` | التحقق من المفضلة | ✅ |
| DELETE | `/wishlist` | مسح المفضلة | ✅ |
| GET | `/wishlist/count` | عدد المفضلة | ✅ |
| POST | `/wishlist/:productId/move-to-cart` | نقل للسلة | ✅ |
| POST | `/wishlist/move-all-to-cart` | نقل الكل للسلة | ✅ |
| GET | `/recently-viewed` | المشاهدة مؤخراً | ✅ |
| POST | `/recently-viewed` | إضافة للمشاهدة مؤخراً | ✅ |
| DELETE | `/recently-viewed` | مسح المشاهدة مؤخراً | ✅ |
| GET | `/stock-alerts` | تنبيهات المخزون | ✅ |
| POST | `/stock-alerts` | إنشاء تنبيه مخزون | ✅ |
| DELETE | `/stock-alerts/:productId` | إزالة تنبيه مخزون | ✅ |

---

## ⚠️ معالجة الأخطاء

### الأخطاء الشائعة

1. **409 Conflict**: المنتج موجود بالفعل في المفضلة
   ```dart
   try {
     await _dataSource.addToWishlist(productId);
   } on DioException catch (e) {
     if (e.response?.statusCode == 409) {
       // المنتج موجود بالفعل
     }
   }
   ```

2. **404 Not Found**: المنتج غير موجود
   ```dart
   try {
     await _dataSource.addToWishlist(productId);
   } on DioException catch (e) {
     if (e.response?.statusCode == 404) {
       // المنتج غير موجود
     }
   }
   ```

3. **401 Unauthorized**: غير مصرح
   ```dart
   try {
     await _dataSource.getWishlist();
   } on DioException catch (e) {
     if (e.response?.statusCode == 401) {
       // إعادة توجيه لتسجيل الدخول
       Navigator.pushNamed(context, '/login');
     }
   }
   ```

---

## 🎯 أفضل الممارسات

1. **Cache المفضلة محلياً**: احفظ قائمة المفضلة في `SharedPreferences` أو `Hive` للوصول السريع
2. **Optimistic Updates**: حدث الـ UI فوراً قبل تأكيد الطلب
3. **Error Handling**: تعامل مع جميع الأخطاء المحتملة
4. **Loading States**: أظهر حالات التحميل للمستخدم
5. **Pull to Refresh**: أضف إمكانية السحب للتحديث
6. **Empty States**: أظهر رسائل واضحة عندما تكون المفضلة فارغة

---

## 📝 ملاحظات إضافية

- جميع عمليات المفضلة تحتاج **مصادقة (JWT Token)**
- عند إضافة منتج للمفضلة، يتم زيادة `wishlistCount` في المنتج تلقائياً
- عند إزالة منتج من المفضلة، يتم تقليل `wishlistCount` تلقائياً
- يمكن للمستخدم إضافة نفس المنتج مرة واحدة فقط (Unique constraint)
- يمكن إضافة ملاحظات للمنتجات في المفضلة (حسب التصميم)
- يمكن تفعيل تنبيهات عند تغيير السعر أو عودة المخزون

---

> **ملاحظة**: هذا التوثيق مخصص للـ **تطبيق العميل (Customer App)** وليس للوحة الإدارة.
