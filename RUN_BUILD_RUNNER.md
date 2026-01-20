# 🔧 تشغيل Build Runner

## الخطوة الوحيدة المتبقية!

لإكمال نظام المحتوى التعليمي، يجب تشغيل build_runner لإنشاء ملفات JSON serialization.

---

## الأوامر

### Windows (PowerShell):
```powershell
cd mobile
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### Mac/Linux:
```bash
cd mobile
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## ما سيحدث؟

سيتم إنشاء الملفات التالية:
- `mobile/lib/features/education/data/models/educational_category_model.g.dart`
- `mobile/lib/features/education/data/models/educational_content_model.g.dart`

هذه الملفات تحتوي على كود JSON serialization المطلوب للـ Models.

---

## الوقت المتوقع

- **flutter pub get:** 10-30 ثانية
- **build_runner:** 30-60 ثانية

**الإجمالي:** ~1 دقيقة

---

## بعد الانتهاء

بعد تشغيل build_runner، يمكنك:

1. **تشغيل التطبيق:**
```bash
flutter run
```

2. **اختبار الميزات:**
   - افتح شاشة المحتوى التعليمي من القائمة
   - تصفح الفئات
   - افتح قائمة المحتوى
   - شاهد تفاصيل المقالات والفيديوهات

---

## في حالة حدوث أخطاء

إذا ظهرت أخطاء أثناء build_runner:

1. **تنظيف المشروع:**
```bash
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

2. **حذف الملفات القديمة:**
```bash
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## ملاحظات

- ✅ جميع الأكواد جاهزة
- ✅ جميع الـ dependencies مثبتة
- ✅ جميع الشاشات محدثة
- ⚠️ فقط build_runner متبقي

**بعد تشغيل build_runner، النظام سيكون جاهزاً 100%!** 🎉
