# إصلاح مشكلة المفضلة (Wishlist)

## ملخص التغييرات

تم إصلاح مشكلة عدم التوافق بين بنية البيانات في التطبيق Flutter وبنية البيانات التي يرسلها الباك إند NestJS.

## المشكلة الأصلية

كان التطبيق يتوقع بنية بيانات مختلفة عن التي يرسلها الباك إند:

### ما كان يتوقعه التطبيق:
```json
{
  "id": 1,
  "product_id": 1,
  "product": { /* Product object */ },
  "added_at": "2024-01-01",
  "is_in_stock": true,
  "price_dropped": false
}
```

### ما يرسله الباك إند فعلياً:
```json
{
  "_id": "507f1f77bcf86cd799439011",
  "customerId": "507f1f77bcf86cd799439012",
  "productId": {
    "_id": "...",
    "name": "...",
    "basePrice": 100,
    // ... بقية حقول المنتج (populated)
  },
  "createdAt": "2024-01-01T00:00:00.000Z",
  "notifyOnPriceChange": false,
  "notifyOnBackInStock": false
}
```

## الملفات المعدلة

### 1. `lib/features/wishlist/data/models/wishlist_item_model.dart`

**التغييرات الرئيسية:**

- تغيير `id` من `int` إلى `String` وربطه بـ `_id` من MongoDB
- إضافة معالج custom للـ `productId` الذي يأتي كـ object populated
- ربط `addedAt` مع `createdAt` من الباك إند
- إضافة حقول جديدة: `notifyOnPriceChange`, `notifyOnBackInStock`, `note`
- تحويل الحقول المحسوبة إلى getters: `isInStock`, `priceDropped`, `originalPrice`, `currentPrice`, `discountPercentage`

**الحقول الجديدة:**
```dart
@JsonKey(name: '_id', readValue: _readId)
final String id;

@JsonKey(name: 'productId', readValue: _readProductData)
final dynamic productData;

@JsonKey(includeFromJson: false, includeToJson: false)
final String? productIdString;

@JsonKey(includeFromJson: false, includeToJson: false)
final ProductModel? product;
```

**Getters المحسوبة:**
```dart
String get productId => productIdString ?? product?.id ?? '';
bool get isInStock => product?.stockQuantity != null && product!.stockQuantity > 0;
bool get priceDropped => /* ... */;
double? get originalPrice => product?.compareAtPrice ?? product?.basePrice;
double? get currentPrice => product?.basePrice;
double? get discountPercentage => /* ... */;
```

### 2. `lib/features/wishlist/data/models/wishlist_item_model.g.dart`

تم إعادة توليد هذا الملف تلقائياً باستخدام `build_runner` بعد تعديل النموذج.

### 3. `lib/features/wishlist/data/datasources/wishlist_remote_datasource.dart`

**التغييرات:**

- تحسين معالجة الأخطاء في `getWishlist()`
- إضافة logging للمساعدة في debugging
- تحديث `isInWishlist()` لاستخدام `getWishlist()` بدلاً من endpoint منفصل

```dart
@override
Future<List<WishlistItemModel>> getWishlist() async {
  try {
    final response = await _apiClient.get(ApiEndpoints.wishlistMy);
    final data = response.data['data'] ?? response.data;
    final List<dynamic> list = data is List ? data : [];
    
    return list.map((json) {
      if (json is Map<String, dynamic>) {
        return WishlistItemModel.fromJson(json);
      }
      throw Exception('Invalid wishlist item format');
    }).toList();
  } catch (e) {
    developer.log('Error fetching wishlist: $e', name: 'WishlistDataSource', error: e);
    rethrow;
  }
}
```

## كيفية عمل الحل

1. **معالجة productId المرن**: يمكن للنموذج الآن التعامل مع `productId` سواء كان:
   - String (ID فقط)
   - Object (المنتج الكامل populated)

2. **استخراج البيانات**: في `fromJson()`, يتم:
   - فحص نوع `productData`
   - إذا كان String، يتم حفظه كـ `productIdString`
   - إذا كان Object، يتم parse-ه كـ `ProductModel` واستخراج الـ ID منه

3. **Getters المحسوبة**: بدلاً من حفظ القيم مباشرة، يتم حسابها من بيانات المنتج:
   - `isInStock`: يفحص `product.stockQuantity > 0`
   - `priceDropped`: يقارن `compareAtPrice` مع `basePrice`
   - `discountPercentage`: يحسب نسبة الخصم

## التوافق مع MongoDB

النموذج يدعم الآن:
- MongoDB ObjectIds (سواء كـ String أو كـ `{$oid: "..."}`)
- Populated references (عندما يكون الحقل object بدلاً من ID)
- التعامل مع `_id` بدلاً من `id`

## API Endpoints المستخدمة

لم يتم تغيير الـ endpoints:
- `GET /products/wishlist/my` - جلب المفضلة
- `POST /products/:id/wishlist` - إضافة للمفضلة
- `DELETE /products/:id/wishlist` - إزالة من المفضلة

## الاختبار

تم التحقق من:
- ✅ عدم وجود أخطاء في Linter
- ✅ توليد ملفات `.g.dart` بنجاح
- ✅ توافق مع `WishlistScreen`
- ✅ توافق مع `ProductDetailsScreen`
- ✅ توافق مع `WishlistCubit`

## ملاحظات مهمة

1. **لم يتم تعديل الباك إند**: جميع التغييرات على جانب التطبيق فقط
2. **التوافق العكسي**: النموذج الجديد يمكنه التعامل مع كلا الصيغتين (القديمة والجديدة)
3. **معالجة الأخطاء**: تم تحسين معالجة الأخطاء مع logging مفصل

## خطوات إعادة البناء

إذا احتجت لإعادة توليد الملفات:

```bash
cd mobile
dart run build_runner build --delete-conflicting-outputs
```

## التاريخ

- **التاريخ**: 2026-01-21
- **الإصدار**: 1.0.0
- **المطور**: AI Assistant
