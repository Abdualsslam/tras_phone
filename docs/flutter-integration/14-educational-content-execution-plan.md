# خطة تنفيذ المحتوى التعليمي في تطبيق Flutter

## الهدف
تنفيذ رحلة محتوى تعليمي متكاملة داخل التطبيق بحيث:
- يظهر المحتوى المرتبط داخل صفحة تفاصيل المنتج.
- يمكن للمستخدم فتح صفحة التفاصيل التعليمية مباشرة من المنتج.
- يتوفر قسم مستقل للمحتوى التعليمي يمكن الوصول له من التطبيق.
- تكون الرحلة مستقرة وسريعة وقابلة للاختبار.

---

## الوضع الحالي (ملخص سريع)
- قسم "المحتوى التعليمي الخاص بالمنتج" موجود داخل `mobile/lib/features/catalog/presentation/screens/product_details_screen.dart`.
- عند الضغط على العنصر يتم فتح صفحة التفاصيل التعليمية عبر route: `/education/details/:id`.
- يوجد مركز تعليمي كامل بالمسارات التالية:
  - `/education`
  - `/education/list/:id`
  - `/education/details/:id`
- الربط بين المنتج والمحتوى التعليمي موجود في لوحة التحكم داخل:
  - `admin/src/pages/products/ProductsPage.tsx`
  - الحقل: `relatedEducationalContent`

---

## ملاحظة مهمة قبل التنفيذ
حاليا صفحة المنتج تحمل المحتوى التعليمي عبر استدعاء كل ID بشكل منفصل باستخدام `getContentById`.

يفضل عدم الاعتماد على هذا المسار، واستخدام endpoint واحد مخصص للمنتج:
- `GET /products/:id/educational-content`

السبب:
- أداء أفضل (طلب واحد بدل عدة طلبات).
- تقليل احتمالية فشل التحميل عند عدم تطابق slug/id.
- Pagination جاهز من الخلفية.

---

## نطاق التنفيذ المطلوب من مطور Flutter

### 1) تحسين تحميل المحتوى المرتبط داخل صفحة المنتج
**الملف:**
- `mobile/lib/features/catalog/presentation/screens/product_details_screen.dart`

**المطلوب:**
- استبدال آلية `Future.wait` على IDs بآلية جلب واحدة من endpoint المنتج التعليمي.
- عرض 3 عناصر فقط بشكل افتراضي داخل الصفحة.
- إضافة زر واضح: `عرض كل المحتوى التعليمي`.
- عند الضغط على الزر:
  - الانتقال إلى شاشة قائمة مفلترة حسب المنتج (تفاصيلها في الخطوة 2).

**حالات العرض:**
- Loading: skeleton أو spinner داخل الكارد.
- Error: رسالة + زر إعادة المحاولة.
- Empty: إخفاء القسم أو عرض CTA: `استكشف المركز التعليمي`.

---

### 2) إضافة قائمة محتوى تعليمي خاصة بالمنتج
**الملفات المقترح إضافتها:**
- `mobile/lib/features/education/presentation/screens/product_education_list_screen.dart`
- (اختياري) Cubit مخصص: `product_education_content_cubit.dart`

**المطلوب:**
- شاشة تعرض كل المحتوى المرتبط بمنتج محدد.
- تعتمد على endpoint:
  - `GET /products/:id/educational-content?page=1&limit=20`
- تدعم:
  - Pagination (load more)
  - Pull to refresh
  - Empty/Error states
- عند الضغط على أي عنصر:
  - `context.push('/education/details/${content.slug}')`

---

### 3) إضافة route جديد لقائمة محتوى المنتج
**الملف:**
- `mobile/lib/routes/app_router.dart`

**المطلوب:**
- إضافة route جديد مثلا:
  - `/product/:id/education`
- تمرير `productId` و(اختياري) `productName` عبر path أو extra.

---

### 4) تحسين الوصول إلى القسم المستقل "المركز التعليمي"
**المطلوب UX:**
- إضافة مدخل واضح للمركز التعليمي من التطبيق (Home أو Profile).
- النص المقترح: `المركز التعليمي`.

**مهم:**
- لا تعتمد فقط على الوصول من صفحة المنتج.
- يجب وجود مسار مستقل دائم للمستخدم.

---

### 5) تحسين تفاصيل المحتوى التعليمي
**الملف:**
- `mobile/lib/features/education/presentation/screens/education_details_screen.dart`

**المطلوب:**
- الحفاظ على العرض الحالي (فيديو/HTML).
- إضافة قسم `منتجات مرتبطة` (إن كانت البيانات متاحة في الاستجابة).
- كل منتج مرتبط قابل للنقر وينتقل لتفاصيل المنتج.
- الحفاظ على like/share/favorite كما هو مع تحسين رسائل النجاح/الفشل.

---

## طبقة البيانات (Data Layer) المطلوبة

### A) إضافة endpoint جديد في الثوابت
**الملف:**
- `mobile/lib/core/constants/api_endpoints.dart`

**أضف دالة مثل:**
- `static String productEducationalContent(String id) => '/products/$id/educational-content';`

### B) DataSource
**الملف:**
- `mobile/lib/features/education/data/datasources/education_remote_datasource.dart`

**أضف method مثل:**
- `Future<Map<String, dynamic>> getProductEducationalContent({required String productId, int page = 1, int limit = 20});`

### C) Repository Interface + Impl
**الملفات:**
- `mobile/lib/features/education/domain/repositories/education_repository.dart`
- `mobile/lib/features/education/data/repositories/education_repository_impl.dart`

**أضف method موافقة للـ DataSource.**

---

## معايير القبول (Acceptance Criteria)
- عند فتح منتج مرتبط بمحتوى تعليمي، يظهر القسم خلال أقل من 2 ثانية (حسب الشبكة).
- الضغط على عنصر تعليمي من صفحة المنتج يفتح تفاصيل المحتوى بدون أخطاء.
- زر `عرض كل المحتوى التعليمي` يفتح شاشة قائمة كاملة مرتبطة بالمنتج.
- عند عدم وجود محتوى مرتبط، لا تظهر أخطاء للمستخدم.
- المركز التعليمي يمكن الوصول له مباشرة من التطبيق بدون المرور بصفحة منتج.

---

## سيناريوهات الاختبار اليدوي
1. **منتج يحتوي 1-3 عناصر تعليمية**
   - تحقق من الظهور + التنقل للتفاصيل.
2. **منتج يحتوي عدد كبير من العناصر**
   - تحقق من `عرض كل المحتوى` + pagination.
3. **منتج بدون محتوى تعليمي**
   - لا crash، وCTA مناسب.
4. **انقطاع الشبكة**
   - error state واضح + retry يعمل.
5. **الدخول المباشر للمركز التعليمي**
   - الصفحة تعمل والتصنيفات/القوائم سليمة.

---

## ترتيب التنفيذ المقترح (عملي)
1. تنفيذ DataSource/Repository للـ endpoint الجديد.
2. تعديل صفحة المنتج لاستخدام endpoint الواحد.
3. إضافة شاشة "كل محتوى المنتج" + route.
4. إضافة مدخل واضح للمركز التعليمي من التطبيق.
5. تحسين صفحة تفاصيل المحتوى (قسم المنتجات المرتبطة).
6. اختبار يدوي شامل للحالات السابقة.

---

## مخرجات التسليم المطلوبة من مطور Flutter
- Pull Request يحتوي التعديلات على الملفات المذكورة.
- فيديو قصير يوضح السيناريوهين:
  - Product-first
  - Learning-first
- checklist اختبار يدوي مكتمل قبل الدمج.
