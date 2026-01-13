---
name: Backend Completion Plan
overview: خطة شاملة لإكمال الباك إند بناءً على مقارنة ما تم تنفيذه مع المواصفات النهائية (TRAS_PHONE_FINAL_SPECIFICATIONS.md). تشمل الخطة تحديد الفجوات في الـ Schemas والـ API Endpoints والميزات الناقصة.
todos: []
---

# خطة إكمال TRAS Phone Backend

## ملخص المقارنة

### ما تم تنفيذه (NestJS + MongoDB)

| الوحدة | الحالة | الملاحظات |

|--------|--------|----------|

| Auth | 70% | ينقص: Social login, Sessions management, FCM |

| Customers | 80% | ينقص: Referrals endpoints, Wallet adjustment |

| Admins | 85% | مكتمل تقريباً |

| Products | 75% | ينقص: Device compatibility, Tags, Bulk ops |

| Catalog | 80% | ينقص: Delete endpoints |

| Orders | 70% | ينقص: Bank accounts, Payment verification |

| Returns | 60% | ينقص: Supplier returns batches |

| Inventory | 70% | ينقص: Inventory counts completion |

| Promotions | 75% | ينقص: Usage tracking endpoints |

| Wallet | 65% | ينقص: Points redemption, Expiry handling |

| Support | 70% | ينقص: SLA tracking, Internal notes |

| Notifications | 60% | ينقص: Campaigns, Templates CRUD |

| Content | 55% | ينقص: Educational content, Testimonials |

| Settings | 70% | ينقص: App versions, Bank accounts |

| Analytics | 30% | ينقص: معظم التقارير |

| Locations | 80% | ينقص: Markets CRUD |

---

## الفجوات الرئيسية

### 1. Schemas الناقصة (قاعدة البيانات)

#### الأمان والمصادقة

- `login-attempts.schema.ts` - تتبع محاولات تسجيل الدخول
- `ip-blacklist.schema.ts` - قائمة IP المحظورة
- `security-events.schema.ts` - أحداث الأمان
- `api-tokens.schema.ts` - توكنات API للتكاملات

#### المنتجات

- `product-device-compatibility.schema.ts` - توافق المنتجات مع الأجهزة
- `tag.schema.ts` - الوسوم
- `product-tag.schema.ts` - ربط المنتجات بالوسوم
- `stock-alert.schema.ts` - تنبيهات المخزون للعملاء

#### الطلبات والمدفوعات

- `bank-account.schema.ts` - الحسابات البنكية
- `order-payment.schema.ts` - مدفوعات الطلبات
- `abandoned-cart-notification.schema.ts` - إشعارات السلات المتروكة

#### المشتريات والموردين

- `goods-received-note.schema.ts` - إذن استلام البضائع
- `supplier-return-batch.schema.ts` - دفعات إرجاع الموردين

#### المحتوى

- `educational-category.schema.ts` - تصنيفات المحتوى التعليمي
- `educational-content.schema.ts` - المحتوى التعليمي

#### النظام

- `search-log.schema.ts` - سجل البحث
- `popular-search.schema.ts` - البحث الشائع
- `recently-viewed.schema.ts` - المشاهدات الأخيرة
- `app-version.schema.ts` - إصدارات التطبيق
- `integration-log.schema.ts` - سجل التكاملات

---

### 2. API Endpoints الناقصة (~80 endpoint)

#### Customer APIs (~35 endpoint)

```yaml
# Auth (5)
POST   /auth/fcm-token
GET    /auth/sessions
DELETE /auth/sessions/:id
POST   /auth/social/:provider

# Profile (2)
POST   /customer/profile/avatar
DELETE /customer/profile/avatar

# Wishlist (2)
POST   /wishlist/move-to-cart
PUT    /wishlist/:productId/notify

# Reviews (4)
POST   /reviews/:id/vote
GET    /customer/pending-reviews
GET    /recently-viewed
DELETE /recently-viewed

# Stock Alerts (4)
GET    /stock-alerts
POST   /stock-alerts
PUT    /stock-alerts/:id
DELETE /stock-alerts/:id

# Orders (3)
POST   /orders/:number/upload-receipt
GET    /orders/pending-payment
POST   /orders/:number/rate

# Content (6)
GET    /education/categories
GET    /education/content
GET    /education/content/:slug
GET    /education/featured
POST   /faqs/:id/feedback
POST   /banners/:id/click

# General (4)
GET    /app/version
GET    /app/config
POST   /app/feedback
GET    /search/suggestions
```

#### Admin APIs (~45 endpoint)

```yaml
# Dashboard (8)
GET    /admin/dashboard/stats
GET    /admin/dashboard/sales
GET    /admin/dashboard/orders
GET    /admin/dashboard/top-products
GET    /admin/dashboard/top-customers
GET    /admin/dashboard/low-stock
GET    /admin/dashboard/recent-orders
GET    /admin/dashboard/pending-actions

# Customers (5)
POST   /admin/customers/:id/suspend
POST   /admin/customers/:id/activate
POST   /admin/customers/:id/wallet/adjust
GET    /admin/customers/export
PUT    /admin/customers/:id/price-level

# Products (8)
POST   /admin/products/:id/images
DELETE /admin/products/:id/images/:imageId
PUT    /admin/products/:id/images/reorder
POST   /admin/products/:id/devices
POST   /admin/products/:id/duplicate
GET    /admin/products/export
POST   /admin/products/import
PUT    /admin/products/bulk-update

# Orders (4)
POST   /admin/orders/:id/verify-payment
POST   /admin/orders/:id/ship
POST   /admin/orders/:id/deliver
GET    /admin/orders/export

# Inventory (6)
GET    /admin/inventory-counts
POST   /admin/inventory-counts
PUT    /admin/inventory-counts/:id/complete
POST   /admin/stock-transfers/:id/approve
POST   /admin/stock-transfers/:id/ship
POST   /admin/stock-transfers/:id/receive

# Reports (10)
GET    /admin/reports/sales
GET    /admin/reports/orders
GET    /admin/reports/products
GET    /admin/reports/customers
GET    /admin/reports/inventory
GET    /admin/reports/returns
GET    /admin/reports/financial
GET    /admin/search/analytics
GET    /admin/search/popular
GET    /admin/search/no-results

# Settings (4)
GET    /admin/bank-accounts
POST   /admin/bank-accounts
PUT    /admin/bank-accounts/:id
GET    /admin/app-versions
```

---

## خطة التنفيذ (4 مراحل)

### المرحلة 1: الأساسيات الناقصة (أسبوعين)

**الأولوية: عالية**

1. **إكمال Auth Module**

   - إضافة FCM token management
   - إضافة Sessions management
   - إضافة Login attempts tracking
   - إضافة Social login (Google, Apple)

2. **إكمال Orders Module**

   - إضافة Bank accounts schema و service
   - إضافة Payment verification
   - إضافة Upload receipt endpoint
   - إضافة Order rating

3. **إكمال Products Module**

   - إضافة Device compatibility
   - إضافة Tags system
   - إضافة Stock alerts for customers

### المرحلة 2: التجارة والمخزون (أسبوعين)

**الأولوية: عالية**

1. **إكمال Inventory Module**

   - إضافة Inventory counts completion flow
   - إضافة Stock transfers approval flow
   - تحسين Stock reservations

2. **إكمال Returns Module**

   - إضافة Supplier return batches
   - إضافة Complete return workflow

3. **إكمال Suppliers Module**

   - إضافة Goods received notes
   - إضافة Purchase orders completion

### المرحلة 3: التحليلات والتقارير (أسبوع)

**الأولوية: متوسطة**

1. **Dashboard APIs**

   - Sales statistics
   - Orders statistics
   - Top products/customers
   - Pending actions

2. **Reports Module**

   - Sales report
   - Orders report
   - Inventory report
   - Financial report

3. **Search Analytics**

   - Search logs
   - Popular searches
   - No-results tracking

### المرحلة 4: المحتوى والإضافات (أسبوع)

**الأولوية: متوسطة**

1. **Content Module**

   - Educational categories
   - Educational content CRUD
   - Testimonials

2. **Notifications Module**

   - Campaign management
   - Template CRUD
   - Scheduled notifications

3. **Settings Module**

   - App versions management
   - Bank accounts management

---

## الملفات الرئيسية للتعديل

### Schemas جديدة

```
backend/src/modules/
├── auth/schemas/
│   ├── login-attempt.schema.ts
│   └── api-token.schema.ts
├── orders/schemas/
│   ├── bank-account.schema.ts
│   └── order-payment.schema.ts
├── products/schemas/
│   ├── product-device.schema.ts
│   ├── tag.schema.ts
│   └── stock-alert.schema.ts
├── content/schemas/
│   ├── educational-category.schema.ts
│   └── educational-content.schema.ts
├── settings/schemas/
│   └── app-version.schema.ts
└── analytics/schemas/
    ├── search-log.schema.ts
    └── recently-viewed.schema.ts
```

### Controllers للتحديث

- [`auth.controller.ts`](backend/src/modules/auth/auth.controller.ts) - إضافة 5 endpoints
- [`orders.controller.ts`](backend/src/modules/orders/orders.controller.ts) - إضافة 6 endpoints
- [`products.controller.ts`](backend/src/modules/products/products.controller.ts) - إضافة 8 endpoints
- [`inventory.controller.ts`](backend/src/modules/inventory/inventory.controller.ts) - إضافة 6 endpoints

### Services جديدة

- `dashboard.service.ts` - خدمة لوحة التحكم
- `reports.service.ts` - خدمة التقارير
- `search-analytics.service.ts` - خدمة تحليلات البحث

---

## التقدير الزمني

| المرحلة | المدة | الأولوية |

|---------|-------|----------|

| المرحلة 1 | 2 أسابيع | عالية |

| المرحلة 2 | 2 أسابيع | عالية |

| المرحلة 3 | 1 أسبوع | متوسطة |

| المرحلة 4 | 1 أسبوع | متوسطة |

| **الإجمالي** | **6 أسابيع** | - |

---

## ملاحظات تقنية

1. **MongoDB vs MySQL**: التحويل من MySQL (المواصفات) إلى MongoDB (التنفيذ) صحيح ومناسب لـ NestJS
2. **الـ Relations**: استخدم `populate` في Mongoose بدلاً من Foreign Keys
3. **الـ Indexes**: تأكد من إضافة Indexes للحقول المستخدمة في البحث والفلترة
4. **الـ Soft Delete**: استخدم `deletedAt` بدلاً من الحذف الفعلي
