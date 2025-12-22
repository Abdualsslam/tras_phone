# 📋 متطلبات الحسابات والخدمات - Tras Phone

هذا الملف يوضح جميع الحسابات والخدمات الخارجية التي تحتاج إلى إنشائها لتشغيل مشروع Tras Phone بشكل كامل.

---

## 📱 1. خدمات الرسائل النصية (SMS)

### 🔹 Unifonic (الخيار الأساسي - للسوق السعودي)

**الوصف:** منصة اتصالات سحابية متخصصة في الشرق الأوسط، مثالية للرسائل النصية في السعودية.

**الخطوات:**
1. زيارة الموقع: [https://www.unifonic.com](https://www.unifonic.com)
2. إنشاء حساب جديد (Business Account)
3. التوجه إلى لوحة التحكم > API Settings
4. الحصول على:
   - `App SID` (معرف التطبيق)
   - اختيار `Sender ID` (اسم المرسل - يمكن أن يكون "TrasPhone")

**المتغيرات المطلوبة في .env:**
```env
SMS_PROVIDER=unifonic
UNIFONIC_APP_SID=your-unifonic-app-sid
UNIFONIC_SENDER_ID=TrasPhone
```

**ملاحظات:**
- يتطلب التحقق من الهوية للحسابات التجارية
- الأسعار تنافسية في السوق السعودي
- دعم فني بالعربية

---

### 🔹 Twilio (خيار بديل - عالمي)

**الوصف:** منصة اتصالات عالمية، خيار جيد للتوسع الدولي.

**الخطوات:**
1. زيارة الموقع: [https://www.twilio.com](https://www.twilio.com)
2. إنشاء حساب جديد (Trial أو Paid)
3. من Console:
   - نسخ `Account SID`
   - نسخ `Auth Token`
4. شراء أو تسجيل رقم هاتف من Phone Numbers > Buy a Number

**المتغيرات المطلوبة في .env:**
```env
TWILIO_ACCOUNT_SID=your-twilio-sid
TWILIO_AUTH_TOKEN=your-twilio-token
TWILIO_PHONE_NUMBER=+1234567890
```

---

## 📧 2. خدمات البريد الإلكتروني (Email)

### 🔹 Gmail SMTP (الخيار الأساسي)

**الوصف:** استخدام Gmail كمزود SMTP للرسائل البريدية.

**الخطوات:**
1. تسجيل الدخول إلى حساب Gmail
2. تفعيل التحقق بخطوتين (2FA):
   - الذهاب إلى [Google Account Security](https://myaccount.google.com/security)
   - تفعيل "2-Step Verification"
3. إنشاء App Password:
   - الذهاب إلى Security > App Passwords
   - اختيار "Mail" و "Other (Custom name)"
   - كتابة اسم التطبيق (مثل: Tras Phone Backend)
   - نسخ كلمة المرور المُنشأة (16 حرف)

**المتغيرات المطلوبة في .env:**
```env
MAIL_PROVIDER=smtp
MAIL_HOST=smtp.gmail.com
MAIL_PORT=587
MAIL_SECURE=false
MAIL_USER=your-email@gmail.com
MAIL_PASSWORD=your-app-password   # كلمة المرور المُنشأة
MAIL_FROM=noreply@trasphone.com
MAIL_FROM_NAME=Tras Phone
```

**ملاحظات:**
- لا تستخدم كلمة مرور Gmail العادية
- الحد اليومي: 500 رسالة (للحسابات المجانية)

---

### 🔹 SendGrid (خيار بديل - احترافي)

**الوصف:** منصة بريد إلكتروني احترافية مع إمكانيات تحليل متقدمة.

**الخطوات:**
1. زيارة الموقع: [https://sendgrid.com](https://sendgrid.com)
2. إنشاء حساب جديد (Free tier يوفر 100 email/day)
3. من Dashboard > Settings > API Keys
4. إنشاء API Key جديد مع صلاحيات "Full Access"

**المتغيرات المطلوبة في .env:**
```env
MAIL_PROVIDER=sendgrid
SENDGRID_API_KEY=your-sendgrid-api-key
```

---

## 💳 3. بوابات الدفع (Payment Gateways)

### 🔹 HyperPay (الخيار الأساسي - للسوق السعودي)

**الوصف:** بوابة دفع إلكتروني متخصصة في الشرق الأوسط، تدعم مدى وVisa/Mastercard.

**الخطوات:**
1. زيارة الموقع: [https://www.hyperpay.com](https://www.hyperpay.com)
2. التواصل مع فريق المبيعات لإنشاء حساب تجاري
3. بعد الموافقة، الحصول على:
   - `Entity ID` (للمعاملات العادية Visa/Mastercard)
   - `Entity ID MADA` (للمعاملات من خلال مدى)
   - `Access Token` (للتفويض)
4. طلب تفعيل Test Mode للتجربة

**المتغيرات المطلوبة في .env:**
```env
PAYMENT_PROVIDER=hyperpay
HYPERPAY_ENTITY_ID=your-entity-id
HYPERPAY_ENTITY_ID_MADA=your-mada-entity-id
HYPERPAY_ACCESS_TOKEN=your-access-token
HYPERPAY_TEST_MODE=true   # غيّر إلى false في الإنتاج
```

**المستندات المطلوبة:**
- السجل التجاري
- بطاقة الهوية الوطنية/الإقامة
- معلومات الحساب البنكي

---

### 🔹 Moyasar (خيار بديل - سعودي)

**الوصف:** بوابة دفع سعودية سهلة التكامل.

**الخطوات:**
1. زيارة الموقع: [https://moyasar.com](https://moyasar.com)
2. إنشاء حساب تجاري
3. من Dashboard > API Keys
4. نسخ Secret API Key

**المتغيرات المطلوبة في .env:**
```env
PAYMENT_PROVIDER=moyasar
MOYASAR_API_KEY=your-moyasar-api-key
```

---

## 📦 4. خدمات الشحن (Shipping)

### 🔹 SMSA Express (الخيار الأساسي - سعودي)

**الوصف:** شركة شحن رائدة في السعودية.

**الخطوات:**
1. زيارة الموقع: [https://www.smsaexpress.com](https://www.smsaexpress.com)
2. التواصل مع قسم الشركات لفتح حساب تجاري
3. الحصول على:
   - `Pass Key` (مفتاح API)
   - `Account Number` (رقم الحساب)

**المتغيرات المطلوبة في .env:**
```env
SHIPPING_PROVIDER=smsa
SMSA_PASS_KEY=your-smsa-pass-key
SMSA_ACCOUNT_NUMBER=your-account-number
```

---

### 🔹 Aramex (خيار بديل - عالمي)

**الوصف:** شركة شحن عالمية مع تواجد قوي في المنطقة.

**الخطوات:**
1. زيارة الموقع: [https://www.aramex.com](https://www.aramex.com)
2. فتح حساب تجاري
3. طلب API Credentials:
   - Account Number
   - Account PIN
   - Account Entity
   - Username & Password

**المتغيرات المطلوبة في .env:**
```env
SHIPPING_PROVIDER=aramex
ARAMEX_ACCOUNT_NUMBER=your-account
ARAMEX_ACCOUNT_PIN=your-pin
ARAMEX_ACCOUNT_ENTITY=your-entity
ARAMEX_USERNAME=your-username
ARAMEX_PASSWORD=your-password
```

---

## ☁️ 5. تخزين الملفات (AWS S3)

**الوصف:** خدمة تخزين سحابية من Amazon لتخزين الصور والملفات.

**الخطوات:**
1. إنشاء حساب AWS: [https://aws.amazon.com](https://aws.amazon.com)
2. تسجيل الدخول إلى AWS Console
3. إنشاء S3 Bucket:
   - الذهاب إلى S3 Service
   - Create Bucket
   - اختيار Region: `me-south-1` (البحرين - الأقرب للسعودية)
   - تسمية Bucket (مثل: trasphone-media)
   - تكوين Permissions حسب الحاجة
4. إنشاء IAM User:
   - الذهاب إلى IAM > Users > Add User
   - تفعيل "Programmatic access"
   - إرفاق Policy: `AmazonS3FullAccess` (أو سياسة مخصصة)
5. حفظ Credentials:
   - `Access Key ID`
   - `Secret Access Key`

**المتغيرات المطلوبة في .env:**
```env
STORAGE_PROVIDER=s3
AWS_REGION=me-south-1
AWS_S3_BUCKET=your-bucket-name
AWS_ACCESS_KEY_ID=your-access-key
AWS_SECRET_ACCESS_KEY=your-secret-key
CDN_URL=https://cdn.trasphone.com  # أو رابط CloudFront
```

**اختياري - تكوين CloudFront للـ CDN:**
1. من AWS Console > CloudFront
2. Create Distribution
3. ربطه بـ S3 Bucket
4. استخدام رابط Distribution كـ CDN_URL

---

## 🔔 6. إشعارات الدفع (Firebase Cloud Messaging)

**الوصف:** خدمة من Google لإرسال الإشعارات للهواتف (Android & iOS).

**الخطوات:**
1. زيارة [Firebase Console](https://console.firebase.google.com)
2. إنشاء مشروع جديد أو استخدام مشروع موجود
3. من Project Settings > Service Accounts
4. اختيار Node.js
5. الضغط على "Generate new private key"
6. تحميل ملف JSON
7. من الملف، استخراج:
   - `project_id`
   - `client_email`
   - `private_key` (يبدأ بـ -----BEGIN PRIVATE KEY-----)

**المتغيرات المطلوبة في .env:**
```env
FCM_PROJECT_ID=your-firebase-project-id
FCM_CLIENT_EMAIL=firebase-admin@your-project.iam.gserviceaccount.com
FCM_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n"
```

**ملاحظة:** 
- احفظ ملف JSON الكامل في مكان آمن
- لا تشارك المفتاح الخاص أبداً

---

## 🗺️ 7. خدمة الخرائط (Google Maps)

**الوصف:** للعرض على الخرائط وتحديد المواقع.

**الخطوات:**
1. الذهاب إلى [Google Cloud Console](https://console.cloud.google.com)
2. إنشاء مشروع جديد أو اختيار مشروع موجود
3. تفعيل APIs المطلوبة:
   - Maps JavaScript API
   - Places API
   - Geocoding API
4. الذهاب إلى APIs & Services > Credentials
5. Create Credentials > API Key
6. (اختياري) تقييد الـ API Key:
   - HTTP referrers للمواقع
   - IP addresses للـ Backend

**المتغيرات المطلوبة في .env:**
```env
GOOGLE_MAPS_API_KEY=your-google-maps-api-key
```

**الأسعار:**
- تقدم Google $200 رصيد مجاني شهرياً
- كافي لأغلب التطبيقات الصغيرة والمتوسطة

---

## 🗄️ 8. قاعدة البيانات (MongoDB)

### Development (محلي):
```env
MONGODB_URI=mongodb://localhost:27017/trasphone
```

### Production (سحابي):

**خيار 1: MongoDB Atlas (مُوصى به)**
1. زيارة [MongoDB Atlas](https://www.mongodb.com/cloud/atlas)
2. إنشاء حساب مجاني
3. إنشاء Cluster جديد (Free tier متاح)
4. إنشاء Database User
5. إضافة IP Address إلى Whitelist
6. الحصول على Connection String

**خيار 2: تثبيت محلي**
1. تحميل MongoDB Community Server
2. تثبيته على السيرفر
3. تكوين Authentication

---

## 🔴 9. Redis (Cache & Session Storage)

### Development (محلي):
```env
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_PASSWORD=
```

### Production (سحابي):

**خيار 1: Redis Cloud**
1. زيارة [Redis Cloud](https://redis.com/try-free/)
2. إنشاء حساب مجاني (30MB متاح)
3. إنشاء Database
4. الحصول على:
   - Endpoint (Host + Port)
   - Password

**خيار 2: تثبيت محلي**
1. تثبيت Redis على السيرفر
2. تكوين Authentication

---

## 📊 ملخص التكاليف التقريبية

| الخدمة | الباقة المجانية | التكلفة الشهرية المتوقعة |
|--------|-----------------|---------------------------|
| Unifonic | ❌ | 100-500 ريال |
| Gmail SMTP | ✅ (500/يوم) | مجاني |
| SendGrid | ✅ (100/يوم) | مجاني - $15 |
| HyperPay | ❌ | عمولة على المعاملات |
| SMSA | ❌ | حسب الشحنات |
| AWS S3 | ✅ (5GB) | $1-10 |
| Firebase FCM | ✅ | مجاني (غالباً) |
| Google Maps | ✅ ($200/شهر) | مجاني - $50 |
| MongoDB Atlas | ✅ (512MB) | مجاني - $10 |
| Redis Cloud | ✅ (30MB) | مجاني - $5 |

---

## ✅ قائمة التحقق (Checklist)

قبل بدء الإنتاج، تأكد من:

- [ ] إنشاء حساب SMS (Unifonic أو Twilio)
- [ ] تكوين البريد الإلكتروني (Gmail أو SendGrid)
- [ ] فتح حساب بوابة الدفع (HyperPay - يحتاج وقت للموافقة)
- [ ] التعاقد مع شركة شحن (SMSA أو Aramex)
- [ ] إنشاء AWS S3 Bucket وIAM User
- [ ] تكوين Firebase للإشعارات
- [ ] الحصول على Google Maps API Key
- [ ] إعداد MongoDB (Atlas أو محلي)
- [ ] تثبيت Redis (Cloud أو محلي)
- [ ] نسخ جميع الـ Credentials إلى ملف .env
- [ ] تأمين ملف .env (إضافته لـ .gitignore)
- [ ] اختبار كل خدمة على حدة

---

## 🔒 تنبيهات أمنية

1. **لا تشارك ملف .env أبداً** - أضفه إلى `.gitignore`
2. **استخدم متغيرات بيئية في Production** - لا تضع Secrets في الكود
3. **قيّد API Keys** - حدد النطاقات والـ IPs المسموح بها
4. **فعّل 2FA** - على جميع الحسابات الحساسة
5. **راجع الفواتير دورياً** - لتجنب المفاجآت

---

## 📞 للدعم الفني

إذا واجهت مشاكل في إنشاء أي حساب:
- راجع التوثيق الرسمي لكل خدمة
- تواصل مع الدعم الفني للخدمة
- ابحث في Stack Overflow عن مشاكل مشابهة

---

**آخر تحديث:** 2025-12-22
**نسخة المشروع:** Tras Phone Backend v1.0
