# تصحيح مشكلة تحديث الـ Token

## ما تم إضافته

### 1. Logging مفصل في TokenManager
- يطبع `expiresAt` عند استخراجه من JWT
- يطبع الوقت المتبقي بالدقائق
- يطبع `expiresAt` عند حفظ الـ tokens

### 2. Logging مفصل في AuthInterceptor
- يطبع حالة الـ token قبل كل طلب:
  - `expiresAt`: متى ينتهي الـ token
  - `isExpired`: هل انتهى الـ token؟
  - `willExpireSoon`: هل سينتهي قريباً؟

## الخطوات التالية للتشخيص

### 1. أعد تشغيل التطبيق
```bash
cd mobile
flutter run
```

### 2. حاول إضافة منتج للمفضلة أو زيارة منتج

### 3. أرسل الـ Logs الكاملة

ابحث عن هذه السطور في الـ logs:
```
[TokenManager] Token expires at: ...
[TokenManager] Tokens cached with expiresAt: ...
[AuthInterceptor] Token check: expiresAt=..., isExpired=..., willExpireSoon=...
```

## المشاكل المحتملة

### احتمال 1: JWT لا يحتوي على `exp`
إذا رأيت:
```
[TokenManager] Failed to decode JWT expiration: ...
```
معناها أن الـ JWT من الباك إند لا يحتوي على حقل `exp`.

**الحل**: يجب على الباك إند إضافة `exp` إلى JWT.

### احتمال 2: فرق التوقيت بين الجهاز والسيرفر
إذا كان `expiresAt` موجود لكن الـ token يُعتبر expired بسرعة، قد يكون هناك فرق في التوقيت.

**الحل**: زيادة buffer time من 5 دقائق إلى 10 أو 15 دقيقة.

### احتمال 3: الـ cache لا يُحدَّث
إذا كان `expiresAt` يظهر `null` في كل مرة، معناها أن الـ cache لا يُحدَّث بشكل صحيح.

**الحل**: تم إضافة `_cachedTokens = null` قبل حفظ tokens جديدة.

## ما نحتاجه منك

أرسل الـ logs الكاملة التي تحتوي على:
1. `[TokenManager] Token expires at: ...`
2. `[TokenManager] Tokens cached with expiresAt: ...`
3. `[AuthInterceptor] Token check: ...`
4. `[API] → GET /products/wishlist/my`
5. أي رسائل أخرى بين هذه السطور

هذا سيساعدنا على فهم السبب الحقيقي للمشكلة.
