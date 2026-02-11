# إصلاح المفضلة في صفحة تفاصيل المنتج (للمطور Flutter)

## المشكلة

- عند فتح تفاصيل منتج **موجود أصلاً في المفضلة** يظهر القلب **فارغاً** (غير مفضّل).
- عند الضغط على القلب يُرسل التطبيق طلب "إضافة" فيرجع السيرفر **409 Conflict - Product already in wishlist**.
- المطلوب: أن يظهر القلب **مملوءاً** عند فتح الصفحة، وعند الضغط مرة ثانية يُزال من المفضلة.

---

## التغييرات في الـ Backend (تمت)

تم إضافة endpoint جديد للتحقق من وجود منتج في المفضلة **بدون** جلب قائمة المفضلة كاملة:

| Method | Endpoint | الوصف |
|--------|----------|--------|
| **GET** | `/api/v1/products/:id/wishlist/check` | التحقق من وجود المنتج في المفضلة |

**Headers:** `Authorization: Bearer <accessToken>`

**Response (200):**
```json
{
  "success": true,
  "data": {
    "inWishlist": true
  },
  "message": "Wishlist status checked",
  "messageAr": "تم التحقق من حالة المفضلة"
}
```

استخدم هذا الـ endpoint في صفحة تفاصيل المنتج لمعرفة حالة المفضلة عند فتح الصفحة.

---

## المطلوب تنفيذه في التطبيق (Flutter)

### 1) إضافة الـ endpoint في الثوابت

في `lib/core/constants/api_endpoints.dart` داخل قسم WISHLIST:

```dart
static const String wishlistMy = '/products/wishlist/my';
static String productWishlist(String id) => '/products/$id/wishlist';
/// التحقق من وجود منتج في المفضلة (بدون جلب القائمة كاملة)
static String productWishlistCheck(String id) => '/products/$id/wishlist/check';
```

---

### 2) تعديل WishlistRemoteDataSource

في `lib/features/wishlist/data/datasources/wishlist_remote_datasource.dart`:

**أ) إضافة استدعاء الـ endpoint الجديد في `isInWishlist`:**

- استدعاء **أولاً** `GET /products/:productId/wishlist/check` وقراءة `data.inWishlist`.
- إذا نجح الطلب، إرجاع القيمة مباشرة.
- إذا فشل (شبكة، أو 404 إن كان الـ backend قديماً)، استخدام الطريقة الحالية كـ fallback: جلب المفضلة كاملة ثم `wishlist.any((item) => ...)`.

**مثال تنفيذ مقترح:**

```dart
@override
Future<bool> isInWishlist(String productId) async {
  developer.log('Checking wishlist: $productId', name: 'WishlistDataSource');

  try {
    // 1) استخدم endpoint التحقق إن وُجد (أسرع وأدق)
    final response = await _apiClient.get(ApiEndpoints.productWishlistCheck(productId));
    final data = response.data['data'] ?? response.data;
    if (data is Map && data.containsKey('inWishlist')) {
      return data['inWishlist'] == true;
    }
  } catch (e) {
    developer.log(
      'Check wishlist endpoint failed, falling back to full list: $e',
      name: 'WishlistDataSource',
    );
  }

  // 2) Fallback: جلب القائمة والتحقق
  try {
    final wishlist = await getWishlist();
    return wishlist.any((item) =>
        (item.productId.toString().trim()) == productId.toString().trim());
  } catch (e) {
    developer.log('Error checking wishlist status: $e', name: 'WishlistDataSource', error: e);
    return false;
  }
}
```

**ملاحظة:** استخدم مقارنة مع `.toString().trim()` لتفادي اختلافات بسيطة في الـ id.

---

### 3) التعامل الصريح مع 409 في صفحة تفاصيل المنتج

في `lib/features/catalog/presentation/screens/product_details_screen.dart` داخل `_toggleWishlist`:

عند حدوث خطأ **409** (المنتج مضاف مسبقاً) يجب:

- اعتبار الحالة الحالية **مفضّل**: `_isFavorite = true`.
- إيقاف حالة التحميل: `_isLoadingWishlist = false`.
- إظهار رسالة واضحة للمستخدم، مثلاً: **"المنتج موجود في المفضلة"** (أو "المنتج موجود بالفعل في المفضلة") حتى لا يظن أن شيئاً لم يحدث.

**مثال في الـ catch:**

```dart
} catch (e) {
  if (mounted) {
    setState(() {
      _isLoadingWishlist = false;
    });

    // 409 = المنتج موجود فعلاً في المفضلة → نحدّث الواجهة ولا نعتبره خطأ
    if (e is DioException && e.response?.statusCode == 409) {
      setState(() => _isFavorite = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('المنتج موجود في المفضلة'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() => _isFavorite = wasFavorite);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${AppLocalizations.of(context)!.error}: ${e.toString()}',
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
```

تأكد من استيراد `DioException` من `package:dio/dio.dart` في نفس الملف إن لم يكن مستخدماً.

---

### 4) (اختياري) تقوية المقارنة عند استخدام getWishlist

إذا استمرت الطريقة الحالية (جلب القائمة كاملة) كـ fallback أو في أماكن أخرى، استخدم مقارنة موحّدة لتجنب اختلاف الصيغ:

```dart
final normalizedProductId = productId.toString().trim();
wishlist.any((item) => (item.productId ?? '').toString().trim() == normalizedProductId);
```

---

## ملخص السلوك المتوقع بعد التعديلات

| الحالة عند فتح الصفحة | عرض القلب | عند الضغط |
|------------------------|-----------|-----------|
| المنتج في المفضلة (السيرفر) | مملوء | إزالة من المفضلة + رسالة "تم الإزالة من المفضلة" |
| المنتج غير في المفضلة | فارغ | إضافة للمفضلة + رسالة "تم الإضافة للمفضلة" |
| المنتج في المفضلة لكن التطبيق ظنّه غير مضاف وضغط "إضافة" | — | السيرفر يرد 409 → تحديث القلب إلى مملوء + رسالة "المنتج موجود في المفضلة" |

---

## التحقق بعد التعديل

1. تسجيل الدخول ثم إضافة منتج للمفضلة من شاشة أخرى (مثلاً قائمة المنتجات أو شاشة المفضلة).
2. فتح **تفاصيل نفس المنتج**: يجب أن يظهر القلب **مملوءاً** فوراً.
3. الضغط على القلب: يجب أن يُزال من المفضلة ويظهر القلب فارغاً مع رسالة "تم الإزالة من المفضلة".
4. الضغط مرة ثانية: يُضاف للمفضلة مع رسالة "تم الإضافة للمفضلة".
5. إن ظهر 409 في أي سيناريو (مثلاً تأخر تحديث الحالة): يجب أن تُحدَّث الواجهة إلى "مفضّل" وتظهر رسالة "المنتج موجود في المفضلة".

---

**تاريخ المستند:** 2026-02-12
