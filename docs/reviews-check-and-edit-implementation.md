# تنفيذ التحقق من التقييم السابق وتعديل التقييم

## نظرة عامة

هذا الملف يوثق التعديلات المطلوبة لتمكين التطبيق من:
1. **التحقق إذا كان العميل قد قيّم المنتج مسبقاً** — لمنع التقييم المكرر وعرض زر "تعديل" بدل "إضافة"
2. **تعديل التقييم** — السماح للعميل بتحديث تقييمه السابق

---

## 1. Backend (تم تنفيذه)

### Endpoints الجديدة

| Method | Endpoint | الوصف |
|--------|----------|--------|
| GET | `/products/:id/reviews/mine` | جلب تقييم العميل الحالي للمنتج (يتطلب تسجيل دخول) |
| PUT | `/products/:id/reviews/:reviewId` | تحديث التقييم (للمالك فقط) |

### منطق addReview

تم تعديل `addReview` للتحقق قبل الإضافة، وإرجاع رسالة واضحة عند التقييم المكرر:
```
"You have already reviewed this product"
```

---

## 2. تطبيق Flutter — التعديلات المطلوبة

### 2.1 إضافة Endpoints جديدة

**الملف:** `mobile/lib/core/constants/api_endpoints.dart`

أضف:
```dart
static String productReviewsMine(String id) => '/products/$id/reviews/mine';
static String productReviewUpdate(String productId, String reviewId) =>
    '/products/$productId/reviews/$reviewId';
```

---

### 2.2 الـ Data Source

**الملف:** `mobile/lib/features/catalog/data/datasources/catalog_remote_datasource.dart`

#### أ. إضافة في الـ Abstract Interface:
```dart
Future<ProductReviewModel?> getMyReview(String productId);
Future<ProductReviewModel> updateReview({
  required String productId,
  required String reviewId,
  required int rating,
  String? title,
  String? comment,
  List<String>? images,
});
```

#### ب. تنفيذ `getMyReview`:
```dart
@override
Future<ProductReviewModel?> getMyReview(String productId) async {
  try {
    final response = await _apiClient.get(
      ApiEndpoints.productReviewsMine(productId),
    );
    final success = response.data['success'] == true ||
        response.data['statusCode'] == 200;
    if (success) {
      final data = response.data['data'];
      if (data == null) return null;
      return ProductReviewModel.fromJson(data);
    }
    return null;
  } catch (_) {
    return null; // عند 401 أو غيره نعتبر أن المستخدم لم يقم بالتقييم
  }
}
```

#### ج. تنفيذ `updateReview`:
```dart
@override
Future<ProductReviewModel> updateReview({
  required String productId,
  required String reviewId,
  required int rating,
  String? title,
  String? comment,
  List<String>? images,
}) async {
  final response = await _apiClient.put(
    ApiEndpoints.productReviewUpdate(productId, reviewId),
    data: {
      'rating': rating,
      if (title != null) 'title': title,
      if (comment != null) 'comment': comment,
      if (images != null && images.isNotEmpty) 'images': images,
    },
  );
  final success = response.data['success'] == true ||
      response.data['statusCode'] == 200;
  if (success) {
    return ProductReviewModel.fromJson(response.data['data']);
  }
  throw Exception(response.data['messageAr'] ?? 'Failed to update review');
}
```

---

### 2.3 الـ Repository

**الملف:** `mobile/lib/features/catalog/domain/repositories/catalog_repository.dart`

أضف في الـ interface:
```dart
Future<Either<Failure, ProductReviewModel?>> getMyReview(String productId);
Future<Either<Failure, ProductReviewModel>> updateReview({
  required String productId,
  required String reviewId,
  required int rating,
  String? title,
  String? comment,
  List<String>? images,
});
```

**الملف:** `mobile/lib/features/catalog/data/repositories/catalog_repository_impl.dart`

نفّذ الدالتين باستدعاء `_remoteDataSource.getMyReview` و `_remoteDataSource.updateReview`.

---

### 2.4 شاشة التقييمات `ProductReviewsScreen`

**الملف:** `mobile/lib/features/reviews/presentation/screens/product_reviews_screen.dart`

#### أ. متغير جديد:
```dart
ProductReviewModel? _myReview;
```

#### ب. تحميل التقييمات وتقييمي معاً:
استبدل `_loadReviews()` بجلب متوازي:
```dart
final results = await Future.wait([
  _catalogRepository.getProductReviews(widget.productId),
  _catalogRepository.getMyReview(widget.productId),
]);
```
ثم استخدم النتائج لتعبئة `_reviews` و `_myReview`.

#### ج. زر الإضافة/التعديل (FAB):
- إذا `_myReview != null` → عرض "تعديل التقييم"
- إذا `_myReview == null` → عرض "أضف تقييم"

#### د. تمرير `myReview` لصندوق إدخال التقييم:
```dart
builder: (context) => _AddReviewBottomSheet(
  productId: widget.productId,
  productName: widget.productName ?? 'المنتج',
  existingReview: _myReview, // جديد
),
```

---

### 2.5 Bottom Sheet إضافة/تعديل التقييم

**في نفس الملف:** `_AddReviewBottomSheet`

#### أ. إضافة parameter:
```dart
final ProductReviewModel? existingReview;
```

#### ب. تهيئة القيم عند تعديل:
```dart
@override
void initState() {
  super.initState();
  if (widget.existingReview != null) {
    _rating = widget.existingReview!.rating;
    _titleController.text = widget.existingReview!.title ?? '';
    _commentController.text = widget.existingReview!.comment ?? '';
  }
}
```

#### ج. عند الإرسال:
- إذا `existingReview != null` → استدعاء `updateReview` مع `productId`, `reviewId`, `rating`, `title`, `comment`
- إذا `existingReview == null` → استدعاء `addReview` كالمعتاد

#### د. العنوان:
- عند تعديل: "تعديل التقييم"
- عند إضافة: "أضف تقييم"

---

## 3. ملخص مسار الاستخدام

1. فتح صفحة تقييمات المنتج.
2. استدعاء `getProductReviews` و `getMyReview`.
3. إذا وجد `myReview`:
   - إظهار زر "تعديل التقييم".
   - عند الضغط، فتح الـ bottom sheet بالقيم الحالية.
   - عند الحفظ، استدعاء `updateReview`.
4. إذا لم يوجد `myReview`:
   - إظهار زر "أضف تقييم".
   - عند الضغط، فتح الـ bottom sheet فارغ.
   - عند الحفظ، استدعاء `addReview`.

---

## 4. ملاحظات

- `getMyReview` يتطلب تسجيل دخول (JWT). عند 401 يمكن اعتبار أن المستخدم لم يقم بالتقييم.
- Backend يمنع التقييم المكرر في `addReview` ويرجع رسالة واضحة.
- `updateReview` يتحقق أن التقييم يخص العميل الحالي قبل التحديث.
