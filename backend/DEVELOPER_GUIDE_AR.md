# ═══════════════════════════════════════════════════════════════
# 📘 دليل المطور الشامل - TRAS Phone Backend
# ═══════════════════════════════════════════════════════════════

## 🎯 نظرة عامة

تم إنشاء **TRAS Phone Backend** باستخدام أحدث التقنيات والممارسات البرمجية الاحترافية:

- ✅ **NestJS + TypeScript** - بنية احترافية type-safe
- ✅ **MongoDB + Mongoose** - قاعدة بيانات مرنة وقابلة للتوسع
- ✅ **Redis Caching** - نظام تخزين مؤقت للأداء العالي
- ✅ **JWT Authentication** - مصادقة آمنة مع refresh tokens
- ✅ **Role-Based Access Control** - صلاحيات متقدمة
- ✅ **Unified Response System** - ردود موحدة ومنظمة
- ✅ **Global Error Handling** - معالجة أخطاء شاملة
- ✅ **Professional Logging** - سجلات احترافية مع Winston
- ✅ **Swagger Documentation** - توثيق تلقائي للـ API
- ✅ **Rate Limiting & Security** - حماية من الهجمات

---

## 📁 الهيكل المعماري

### 1️⃣ **Unified Response System** (نظام الردود الموحد)

**الموقع:** `src/common/interfaces/response.interface.ts`

جميع استجابات API تتبع هذا الهيكل الموحد:

```typescript
{
  "status": "success",           // success أو error
  "statusCode": 200,              // HTTP status code
  "message": "Success",           // رسالة بالإنجليزية
  "messageAr": "نجح",            // رسالة بالعربية
  "data": { ... },               // البيانات المطلوبة
  "meta": {                       // معلومات إضافية
    "pagination": { ... }
  },
  "timestamp": "2024-12-20...",   // وقت الطلب
  "path": "/api/v1/users"        // المسار المطلوب
}
```

**مثال على الاستخدام:**

```typescript
return ResponseBuilder.success(
  userData,
  'User retrieved successfully',
  'تم استرجاع المستخدم بنجاح'
);
```

### 2️⃣ **Global Error Handling** (معالجة الأخطاء الشاملة)

**الموقع:** `src/common/filters/http-exception.filter.ts`

يقوم بالتقاط جميع الأخطاء وتحويلها لصيغة موحدة:

- ✅ أخطاء HTTP من NestJS
- ✅ أخطاء Mongoose (validation, cast, duplicate)
- ✅ أخطاء MongoDB
- ✅ أخطاء غير متوقعة

**مثال على رد الخطأ:**

```json
{
  "status": "error",
  "statusCode": 400,
  "message": "Validation failed",
  "messageAr": "فشل التحقق من صحة البيانات",
  "errors": [
    {
      "field": "phone",
      "message": "Phone number is required"
    }
  ],
  "timestamp": "2024-12-20T18:30:00.000Z",
  "path": "/api/v1/auth/register"
}
```

### 3️⃣ **JWT Authentication** (المصادقة بـ JWT)

**الملفات الرئيسية:**
- `src/modules/auth/auth.service.ts` - منطق المصادقة
- `src/modules/auth/strategies/jwt.strategy.ts` - استراتيجية JWT
- `src/common/guards/jwt-auth.guard.ts` - حارس JWT

**كيف يعمل:**

1. **التسجيل/تسجيل الدخول:**
   ```typescript
   POST /api/v1/auth/register
   POST /api/v1/auth/login
   ```
   يرجع: `accessToken` و `refreshToken`

2. **استخدام Token:**
   ```http
   Authorization: Bearer <accessToken>
   ```

3. **تحديث Token:**
   ```typescript
   POST /api/v1/auth/refresh
   Body: { "refreshToken": "..." }
   ```

4. **Routes العامة:**  
   استخدم decorator `@Public()` للمسارات التي لا تحتاج مصادقة:
   ```typescript
   @Public()
   @Post('login')
   ```

### 4️⃣ **Guards & Decorators** (الحراس والديكوراتورات)

#### **JwtAuthGuard** - حارس JWT
```typescript
@UseGuards(JwtAuthGuard)
@Get('profile')
async getProfile() { ... }
```

#### **RolesGuard** - حارس الصلاحيات
```typescript
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(UserRole.ADMIN)
@Delete(':id')
async deleteUser() { ... }
```

#### **Decorators المفيدة:**

```typescript
// الحصول على المستخدم الحالي
@CurrentUser() user: any

// جعل المسار عام (بدون مصادقة)
@Public()

// تحديد الصلاحيات المطلوبة
@Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
```

### 5️⃣ **Logging System** (نظام السجلات)

**الموقع:** `src/common/logger/logger.service.ts`

يستخدم **Winston** مع تدوير يومي للملفات:

```typescript
// الحقن في أي service
constructor(private logger: Logger) {}

// الاستخدام
this.logger.log('Info message', 'ContextName');
this.logger.error('Error message', stackTrace, 'ContextName');
this.logger.warn('Warning message');
this.logger.debug('Debug message');
```

**ملفات السجلات:**
- `logs/combined-YYYY-MM-DD.log` - جميع السجلات
- `logs/error-YYYY-MM-DD.log` - الأخطاء فقط
- `logs/http-YYYY-MM-DD.log` - طلبات HTTP
- `logs/exceptions-YYYY-MM-DD.log` - الاستثناءات
- `logs/rejections-YYYY-MM-DD.log` - Promise rejections

### 6️⃣ **Interceptors** (الاعتراضات)

#### **TransformInterceptor**
**الموقع:** `src/common/interceptors/transform.interceptor.ts`

يحول جميع الردود تلقائياً إلى الصيغة الموحدة.

#### **LoggingInterceptor**
**الموقع:** `src/common/interceptors/logging.interceptor.ts`

يسجل جميع الطلبات والردود مع:
- وقت التنفيذ
- معلومات الطلب (IP, User Agent)
- إخفاء البيانات الحساسة (passwords, tokens)

### 7️⃣ **Validation** (التحقق من البيانات)

يستخدم **class-validator** و **class-transformer**:

```typescript
// DTO مثال
export class RegisterDto {
  @IsString()
  @IsNotEmpty()
  @Matches(/^\+?[1-9]\d{1,14}$/)
  phone: string;

  @IsEmail()
  @IsOptional()
  email?: string;

  @IsString()
  @MinLength(8)
  @Matches(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])/)
  password: string;
}
```

التحقق يتم تلقائياً عبر `ValidationPipe` في `main.ts`.

### 8️⃣ **Caching مع Redis**

**التكوين:** `src/config/cache.config.ts`

```typescript
// استخدام Cache في أي service
import { CACHE_MANAGER } from '@nestjs/cache-manager';
import { Cache } from 'cache-manager';

constructor(@Inject(CACHE_MANAGER) private cacheManager: Cache) {}

// حفظ بيانات
await this.cacheManager.set('key', value, 3600); // TTL: 1 hour

// استرجاع بيانات
const data = await this.cacheManager.get('key');

// حذف بيانات
await this.cacheManager.del('key');

// حذف جميع البيانات
await this.cacheManager.reset();
```

### 9️⃣ **Rate Limiting** (تحديد المعدل)

**التكوين:** في `app.module.ts`

```typescript
@UseGuards(ThrottlerGuard)
@Post('login')
```

الإعدادات الافتراضية:
- **100 طلب** لكل دقيقة
- قابل للتخصيص في `.env`

---

## 🔐 نظام المصادقة والأمان

### خطوات التسجيل وتسجيل الدخول:

#### 1. **التسجيل:**

```http
POST /api/v1/auth/register
Content-Type: application/json

{
  "phone": "+966501234567",
  "email": "user@example.com",
  "password": "StrongP@ss123",
  "userType": "customer"
}
```

**الرد:**
```json
{
  "status": "success",
  "data": {
    "user": { ... },
    "accessToken": "eyJhbGc...",
    "refreshToken": "eyJhbGc...",
    "expiresIn": "15m"
  }
}
```

#### 2. **تسجيل الدخول:**

```http
POST /api/v1/auth/login
Content-Type: application/json

{
  "phone": "+966501234567",
  "password": "StrongP@ss123"
}
```

#### 3. **استخدام Token:**

```http
GET /api/v1/auth/me
Authorization: Bearer eyJhbGc...
```

#### 4. **تحديث Token:**

```http
POST /api/v1/auth/refresh
Content-Type: application/json

{
  "refreshToken": "eyJhbGc..."
}
```

### ميزات الأمان:

✅ **تشفير كلمات المرور** - bcrypt مع 12 جولة  
✅ **قفل الحساب** - بعد 5 محاولات فاشلة (30 دقيقة)  
✅ **تتبع تسجيل الدخول** - IP, User Agent, الوقت  
✅ **Helmet.js** - حماية HTTP headers  
✅ **CORS** - تحكم في الأصول المسموحة  
✅ **Input Validation** - التحقق من جميع المدخلات  
✅ **Rate Limiting** - حماية من هجمات DDoS  

---

## 🗄️ قاعدة البيانات MongoDB

### User Schema

**الموقع:** `src/modules/users/schemas/user.schema.ts`

```typescript
{
  uuid: String,              // UUID فريد
  phone: String,            // رقم الهاتف (فريد)
  email: String,            // البريد (فريد، اختياري)
  password: String,         // كلمة مرور مشفرة
  userType: Enum,          // customer أو admin
  status: Enum,            // pending, active, suspended, deleted
  
  // Profile
  avatar: String,
  
  // Verification
  phoneVerifiedAt: Date,
  emailVerifiedAt: Date,
  
  // 2FA
  twoFactorEnabled: Boolean,
  twoFactorSecret: String,
  
  // Social Login
  googleId: String,
  appleId: String,
  
  // Tracking
  lastLoginAt: Date,
  lastLoginIp: String,
  failedLoginAttempts: Number,
  lockedUntil: Date,
  
  // Device
  fcmToken: String,
  deviceInfo: Object,
  
  // Preferences
  language: String,
  timezone: String,
  notificationPreferences: Object,
  
  // Marketing
  acceptsMarketing: Boolean,
  marketingConsentAt: Date,
  
  // Referral
  referralCode: String,
  referredBy: ObjectId,
  
  // Timestamps
  createdAt: Date,
  updatedAt: Date,
  deletedAt: Date
}
```

### الفهارس (Indexes):

```typescript
phone: 1          // فريد
email: 1          // فريد
uuid: 1           // فريد
{userType, status}: 1
referralCode: 1   // فريد
createdAt: -1
```

---

## 🚀 التشغيل والاستخدام

### 1. **التثبيت:**

```bash
cd backend
npm install
```

### 2. **إعداد البيئة:**

```bash
cp .env.example .env
# ثم قم بتعديل .env
```

### 3. **تشغيل MongoDB و Redis:**

```bash
# باستخدام Docker
docker-compose up -d mongo redis

# أو يدوياً
mongod
redis-server
```

### 4. **تشغيل التطبيق:**

```bash
# Development
npm run start:dev

# Production
npm run build
npm run start:prod

# Debug
npm run start:debug
```

### 5. **الوصول للتطبيق:**

- **API:** http://localhost:3000
- **Swagger Docs:** http://localhost:3000/api/docs

---

## 📊 اختبار API

### باستخدام cURL:

```bash
# Register
curl -X POST http://localhost:3000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "phone": "+966501234567",
    "password": "StrongP@ss123",
    "userType": "customer"
  }'

# Login
curl -X POST http://localhost:3000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "phone": "+966501234567",
    "password": "StrongP@ss123"
  }'

# Get Profile (with token)
curl -X GET http://localhost:3000/api/v1/auth/me \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

### باستخدام Postman/Insomnia:

1. استورد collection من Swagger: http://localhost:3000/api/docs-json
2. أو استخدم Swagger UI مباشرة

---

## 🔧 التخصيص والتطوير

### إضافة Module جديد:

```bash
nest g module modules/MODULE_NAME
nest g service modules/MODULE_NAME
nest g controller modules/MODULE_NAME
```

### إضافة Schema جديد:

```typescript
// modules/MODULE_NAME/schemas/entity.schema.ts
import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document } from 'mongoose';

@Schema({ timestamps: true })
export class Entity {
  @Prop({ required: true })
  name: string;
  
  // ... المزيد من الحقول
}

export const EntitySchema = SchemaFactory.createForClass(Entity);
```

### إضافة DTO جديد:

```typescript
// modules/MODULE_NAME/dto/create-entity.dto.ts
import { ApiProperty } from '@nestjs/swagger';
import { IsString, IsNotEmpty } from 'class-validator';

export class CreateEntityDto {
  @ApiProperty()
  @IsString()
  @IsNotEmpty()
  name: string;
}
```

---

## 📦 النشر (Deployment)

### باستخدام Docker:

```bash
# Build image
docker build -t tras-phone-api .

# Run container
docker run -d -p 3000:3000 \
  -e MONGODB_URI=mongodb://mongo:27017/tras_phone \
  -e REDIS_HOST=redis \
  --name tras-api \
  tras-phone-api
```

### باستخدام Docker Compose:

```bash
docker-compose up -d
```

### النشر على VPS:

1. رفع الكود للسيرفر
2. تثبيت Node.js, MongoDB, Redis
3. تشغيل `npm install` و `npm run build`
4. استخدام PM2 للتشغيل:

```bash
npm install -g pm2
pm2 start dist/main.js --name tras-api
pm2 save
pm2 startup
```

---

## 🎓 ملاحظات هامة

### Best Practices المطبقة:

1. ✅ **Type Safety** - TypeScript في كل مكان
2. ✅ **Error Handling** - معالجة شاملة للأخطاء
3. ✅ **Validation** - التحقق من جميع المدخلات
4. ✅ **Security** - أمان على مستوى enterprise
5. ✅ **Logging** - سجلات شاملة
6. ✅ **Documentation** - Swagger تلقائي
7. ✅ **Caching** - Redis للأداء
8. ✅ **Clean Code** - كود نظيف وقابل للصيانة
9. ✅ **Modular** - هيكل معماري واضح
10. ✅ **Scalable** - قابل للتوسع

### الخطوات التالية:

1. 📝 إضافة باقي Modules (Products, Orders, إلخ)
2. 📧 تكامل Email/SMS Services
3. 📁 إضافة File Upload مع S3
4. 🔔 نظام الإشعارات (FCM)
5. 💳 تكامل Payment Gateways
6. 📊 Monitoring & Analytics
7. 🧪 كتابة الـ Tests
8. 🚀 CI/CD Pipeline

---

## ✅ الخلاصة

تم إنشاء backend احترافي كامل يتضمن:

- ✅ NestJS + TypeScript + MongoDB
- ✅ JWT Authentication مع Refresh Tokens
- ✅ نظام ردود موحد باللغتين
- ✅ معالجة أخطاء شاملة
- ✅ Guards و Decorators متقدمة
- ✅ نظام سجلات احترافي مع Winston
- ✅ Redis Caching للأداء
- ✅ Rate Limiting للحماية
- ✅ Swagger Documentation
- ✅ Docker Support
- ✅ Clean Architecture

**Backend جاهز للتطوير والتوسع!** 🚀

---

© 2024 TRAS Phone - جميع الحقوق محفوظة
