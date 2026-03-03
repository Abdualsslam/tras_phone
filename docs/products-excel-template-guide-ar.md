# دليل قالب Excel للمنتجات

هذا الدليل يشرح طريقة استخدام قالب استيراد/تصدير المنتجات، معنى كل حقل، وكيف يتم الربط بين المنتج والكيانات المرجعية (الفئات، البراندات، الأنواع، الأجهزة).

## الفكرة الأساسية

- **داخل قاعدة البيانات**: العلاقات تُخزن كـ `ObjectId`.
- **داخل ملف Excel**: الإدخال يكون بقيم مرجعية سهلة (مثل `slug` و `code`) ثم النظام يحولها داخليًا إلى `ObjectId`.

## مكونات ملف القالب

ملف القالب يحتوي هذه الشيتات:

- `Products`: الشيت الرئيسي لإضافة/تحديث المنتجات.
- `Brands`: مرجع البراندات (تأخذ منه قيمة `slug`).
- `Categories`: مرجع الفئات (تأخذ منه قيمة `slug`).
- `QualityTypes`: مرجع الأنواع/الجودة (تأخذ منه قيمة `code`).
- `Devices`: مرجع الأجهزة (تأخذ منه قيمة `slug`).
- `DeviceCompatibility`: ربط إضافي بين `productSku` و `deviceSlug`.

## قواعد مهمة قبل التعبئة

- لا تغيّر أسماء الشيتات.
- لا تغيّر أسماء الأعمدة في الصف الأول.
- لا تحذف الأعمدة حتى لو لم تستخدمها.
- للحقول متعددة القيم استخدم فاصلة `,` بدون أسطر جديدة.
- يفضّل تعبئة القيم المرجعية بالنقل المباشر من شيتات المرجع لتجنب أخطاء الكتابة.

## كيف يتم الربط بين المنتج والفئة/البراند/النوع/الأجهزة

في شيت `Products`:

- `brandSlug`: اكتب **slug** البراند من شيت `Brands`.
- `categorySlug`: اكتب **slug** الفئة من شيت `Categories`.
- `qualityTypeSlug`: اكتب **code** النوع من شيت `QualityTypes`.
- `compatibleDevices`: اكتب `slug` الأجهزة من شيت `Devices` مفصولة بفواصل.

### مثال ربط صحيح

- `brandSlug = apple`
- `categorySlug = phone-accessories`
- `qualityTypeSlug = original`
- `compatibleDevices = iphone-14,iphone-15-pro`

## شرح حقول شيت Products

### حقول مطلوبة

- `sku`: كود المنتج (فريد). أحرف/أرقام/`-`/`_`.
- `name`: اسم المنتج (إنجليزي أو رئيسي).
- `nameAr`: اسم المنتج بالعربية.
- `slug`: رابط المنتج النصي (فريد، أحرف صغيرة وأرقام و`-` فقط).
- `brandSlug`: ربط البراند عبر `slug`.
- `categorySlug`: ربط الفئة عبر `slug`.
- `qualityTypeSlug`: ربط النوع عبر `code`.
- `basePrice`: السعر الأساسي (رقم موجب).

### حقول تعريف وربط إضافي

- `id`: اختياري. يستخدم غالبًا في التحديث والتحقق المزدوج.
- `additionalCategorySlugs`: فئات إضافية عبر `slug` مفصولة بفواصل.
- `compatibleDevices`: أجهزة متوافقة عبر `slug` مفصولة بفواصل.

### حقول الأسعار والمخزون

- `compareAtPrice`: سعر قبل الخصم (اختياري).
- `costPrice`: سعر التكلفة (اختياري).
- `stockQuantity`: كمية المخزون.
- `lowStockThreshold`: حد التنبيه للمخزون المنخفض.
- `trackInventory`: تتبع المخزون (`true/false`).
- `allowBackorder`: السماح بالطلب عند نفاد المخزون (`true/false`).

### حقول الحالة والظهور

- `status`: واحدة من القيم:
  - `draft`
  - `active`
  - `inactive`
  - `out_of_stock`
  - `discontinued`
- `isActive`: نشط (`true/false`).
- `isFeatured`: منتج مميز (`true/false`).
- `isNewArrival`: وصول جديد (`true/false`).
- `isBestSeller`: الأكثر مبيعًا (`true/false`).

### حقول المحتوى

- `description`: وصف.
- `descriptionAr`: وصف عربي.
- `shortDescription`: وصف مختصر.
- `shortDescriptionAr`: وصف مختصر عربي.

### حقول الوسائط

- `mainImage`: رابط صورة رئيسية (URL).
- `images`: روابط صور إضافية مفصولة بفواصل.
- `video`: رابط فيديو (URL).

### حقول تقنية وتسويقية

- `specifications`: JSON صحيح، مثال: `{"ram":"8GB","color":"Black"}`.
- `weight`: الوزن.
- `dimensions`: الأبعاد نصيًا.
- `color`: اللون.
- `tags`: وسوم مفصولة بفواصل.
- `warrantyDays`: مدة الضمان بالأيام.
- `warrantyDescription`: وصف الضمان.
- `metaTitle`: عنوان SEO.
- `metaTitleAr`: عنوان SEO عربي.
- `metaDescription`: وصف SEO.
- `metaDescriptionAr`: وصف SEO عربي.
- `metaKeywords`: كلمات مفتاحية مفصولة بفواصل.

## شرح شيت DeviceCompatibility

هذا الشيت اختياري ويستخدم لربط إضافي لكل جهاز مع المنتج:

- `productSku`: كود المنتج (`sku`) من شيت `Products`.
- `deviceSlug`: `slug` الجهاز من شيت `Devices`.
- `isVerified`: هل التوافق موثّق (`true/false`).
- `compatibilityNotes`: ملاحظات توافق.

مثال:

- `productSku = SKU-IP15-CASE`
- `deviceSlug = iphone-15-pro`
- `isVerified = true`
- `compatibilityNotes = Tested on iOS 17`

## القيم الافتراضية عند ترك بعض الحقول فارغة

في الاستيراد الكامل (`import`):

- `stockQuantity` الافتراضي `0`.
- `lowStockThreshold` الافتراضي `5`.
- `trackInventory` الافتراضي `true`.
- `allowBackorder` الافتراضي `false`.
- `status` الافتراضي `draft`.
- `isActive` الافتراضي `true`.
- `isFeatured` و `isNewArrival` و `isBestSeller` الافتراضي `false`.

## الفرق بين الإضافة اليدوية و Excel

- **الإضافة اليدوية (واجهة الأدمن/API)**: ترسل `brandId/categoryId/qualityTypeId` كـ IDs.
- **Excel**: تكتب `brandSlug/categorySlug/qualityTypeSlug` والنظام يحولها إلى IDs تلقائيًا.

## خطوات العمل الموصى بها

1. نزّل القالب الجديد من شاشة الاستيراد/التصدير.
2. افتح شيتات المرجع وخذ القيم (`slug`/`code`) كما هي.
3. عبّئ شيت `Products`.
4. (اختياري) عبّئ `DeviceCompatibility`.
5. نفّذ `Validate` قبل `Import`.
6. أصلح الأخطاء ثم أعد الاستيراد.

## أكثر الأخطاء شيوعًا

- كتابة اسم الفئة بدل `slug` في `categorySlug`.
- كتابة اسم النوع بدل `code` في `qualityTypeSlug`.
- نسيان الفواصل في الحقول متعددة القيم.
- `slug` المنتج يحتوي أحرف كبيرة أو مسافات.
- `basePrice` صفر أو قيمة غير رقمية.
- JSON غير صالح في `specifications`.
