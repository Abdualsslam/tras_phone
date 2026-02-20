# 🛠️ خطة إصلاح مشروع TRAS Phone - خطوة بخطوة

---

## المرحلة 1: توحيد صيغة الاستجابة (Response Format) 🔴 حرج

> هذه المرحلة أساسية - كل شيء يعتمد عليها

### 1.1 حذف `response.builder.ts` القديم وتوحيد الاستخدام

**الملف المطلوب حذفه:**

- `backend/src/common/response.builder.ts`

**الملفات التي تستخدمه وتحتاج تعديل (4 ملفات):**

```
backend/src/modules/support/support.controller.ts     → import من response.interface.ts
backend/src/modules/audit/audit.controller.ts          → import من response.interface.ts
backend/src/modules/content/educational.controller.ts  → import من response.interface.ts
backend/src/modules/content/banners.controller.ts      → import من response.interface.ts
```

**التغيير في كل ملف:**

```typescript
// ❌ قبل
import { ResponseBuilder } from "../../common/response.builder";

// ✅ بعد
import { ResponseBuilder } from "@common/interfaces/response.interface";
```

### 1.2 إصلاح `GlobalExceptionFilter`

**الملف:** `backend/src/common/filters/global-exception.filter.ts`

**التغيير:** توحيد صيغة الخطأ لتتوافق مع `ApiResponse`:

```typescript
// ❌ قبل
const errorResponse = {
  success: false,
  statusCode: status,
  message,
  errors: errors.length > 0 ? errors : undefined,
  path: request.url,
  timestamp: new Date().toISOString(),
};

// ✅ بعد
const errorResponse = {
  status: "error" as const,
  statusCode: status,
  message,
  messageAr: ResponseBuilder["translateMessage"](message), // استخدام الترجمة
  errors: errors.length > 0 ? errors : undefined,
  path: request.url,
  timestamp: new Date().toISOString(),
};
```

### 1.3 إصلاح `ResponseBuilder.paginated` في `response.interface.ts`

**الملف:** `backend/src/common/interfaces/response.interface.ts`

**المطلوب:** إضافة method `paginated` لأنها مستخدمة في `educational.controller.ts` لكنها غير موجودة في الملف الرسمي:

```typescript
static paginated<T>(
    data: T[],
    total: number,
    page: number,
    limit: number,
    message?: string,
): ApiResponse<T[]> {
    return {
        status: 'success',
        statusCode: 200,
        message: message || 'Success',
        messageAr: this.translateMessage(message || 'Success'),
        data,
        meta: {
            pagination: {
                total,
                page,
                limit,
                totalPages: Math.ceil(total / limit),
                hasNextPage: page * limit < total,
                hasPreviousPage: page > 1,
            },
        },
        timestamp: new Date().toISOString(),
    };
}
```

---

## المرحلة 2: إصلاح نظام الأخطاء (Error Handling) 🔴 حرج

### 2.1 إضافة Error Interceptor موحد في الفرونت إند

**الملف:** `admin/src/api/client.ts`

**التغييرات:**

1. نقل `API_BASE_URL` لـ environment variable
2. إضافة معالجة أخطاء شاملة
3. إضافة دعم رسائل الخطأ العربية

```typescript
// ✅ التغيير
const API_BASE_URL =
  import.meta.env.VITE_API_URL || "http://localhost:3000/api/v1";
```

إضافة في response interceptor:

```typescript
// بعد معالجة 401
// معالجة باقي الأخطاء مع استخراج الرسالة العربية
const errorMessage =
  error.response?.data?.messageAr || error.response?.data?.message || "حدث خطأ";
// يمكن استخدامها في toast notification
```

### 2.2 إنشاء ملف `.env` للفرونت إند

**ملف جديد:** `admin/.env`

```env
VITE_API_URL=http://localhost:3000/api/v1
```

**ملف جديد:** `admin/.env.example`

```env
VITE_API_URL=http://localhost:3000/api/v1
```

**ملف جديد:** `admin/.env.production`

```env
VITE_API_URL=https://api-trasphone.smartagency-ye.com/api/v1
```

### 2.3 إضافة Error Boundary

**ملف جديد:** `admin/src/components/ErrorBoundary.tsx`

- يلتقط أخطاء React runtime
- يعرض صفحة خطأ ودية مع زر إعادة المحاولة

### 2.4 إضافة Toast/Notification System

**ملف جديد:** `admin/src/hooks/useToast.ts`

- نظام إشعارات موحد للأخطاء والنجاح
- يدعم العربية والإنجليزية

---

## المرحلة 3: إصلاح مسارات API المختلفة 🟠 مهم

### 3.1 Notifications - campaigns send vs launch

**الخيار الأسهل:** تعديل الفرونت إند

**الملف:** `admin/src/api/notifications.api.ts`

```typescript
// ❌ قبل
sendCampaign: `/notifications/campaigns/${id}/send`;

// ✅ بعد
sendCampaign: `/notifications/campaigns/${id}/launch`;
```

### 3.2 Returns - inspect item path

**الخيار:** تعديل الفرونت إند ليتوافق مع الباك إند

**الملف:** `admin/src/api/returns.api.ts`

```typescript
// ❌ قبل
inspectItem: `/returns/items/${itemId}/inspect`;

// ✅ بعد - يحتاج returnId كمعامل إضافي
inspectItem: (returnId: string, itemId: string, data) =>
  `/returns/${returnId}/items/${itemId}/inspect`;
```

**ملاحظة:** هذا يتطلب تعديل `ReturnsPage.tsx` أيضاً لتمرير `returnId`.

### 3.3 Returns - complete refund path

**الملف:** `admin/src/api/returns.api.ts`

```typescript
// ❌ قبل
completeRefund: `/returns/refunds/${refundId}/complete`;

// ✅ بعد
completeRefund: (returnId: string) => `/returns/${returnId}/refund/complete`;
```

### 3.4 Inventory - locations path

**الخيار:** إضافة endpoint جديد في الباك إند

**الملف:** `backend/src/modules/inventory/inventory.controller.ts`

```typescript
// إضافة endpoint جديد
@Get('locations')
async getAllLocations(@Query('warehouseId') warehouseId?: string) {
    // إذا تم تمرير warehouseId، فلتر بناءً عليه
    // وإلا أرجع كل المواقع
}
```

### 3.5 Roles - permissions field name

**الملف:** `admin/src/api/roles.api.ts`

```typescript
// ❌ قبل
setPermissions: {
  permissions;
}

// ✅ بعد
setPermissions: {
  permissionIds: permissions;
}
```

### 3.6 Support - canned responses paths

**الخيار:** إضافة endpoints في `support.controller.ts` بالباك إند

**الملف:** `backend/src/modules/support/support.controller.ts`

```typescript
// إضافة CRUD endpoints لـ canned-responses
@Post('canned-responses')
@Put('canned-responses/:id')
@Delete('canned-responses/:id')
@Post('canned-responses/:id/use')
```

### 3.7 Support - categories CRUD

**الملف:** `backend/src/modules/support/support.controller.ts`

```typescript
// إضافة
@Post('categories')
@Put('categories/:id')
@Delete('categories/:id')
```

### 3.8 Support - ticket priority & close

**الملف:** `backend/src/modules/support/tickets.controller.ts`

```typescript
// إضافة
@Put(':id/priority')
@Put(':id/close')  // أو تعديل الفرونت ليستخدم updateStatus مع status='closed'
```

---

## المرحلة 4: إضافة Endpoints ناقصة في الباك إند 🟠 مهم

### 4.1 Orders Module

**الملف:** `backend/src/modules/orders/orders.controller.ts`

إضافة:

```typescript
// 1. استرداد المبلغ
@Post(':id/refund')
async refundOrder(@Param('id') id: string, @Body() data: { amount: number; reason?: string }) { }

// 2. تصدير الطلبات
@Get('export')
async exportOrders(@Query() query: OrderFilterQueryDto, @Res() res: Response) { }

// 3. حذف ملاحظة
@Delete(':id/notes/:noteId')
async deleteNote(@Param('id') id: string, @Param('noteId') noteId: string) { }
```

**الملف:** `backend/src/modules/orders/orders.service.ts`

- إضافة methods: `refundOrder`, `exportOrders`, `deleteNote`

### 4.2 Analytics Module

**الملف:** `backend/src/modules/analytics/analytics.controller.ts`

إضافة:

```typescript
@Get('customers-chart')
async getCustomersChart(@Query('startDate') startDate: string, @Query('endDate') endDate: string) { }

@Get('categories')
async getCategoryStats(@Query('startDate') startDate: string, @Query('endDate') endDate: string) { }

@Get('comparison')
async getComparison(@Query() query: ComparisonQueryDto) { }

@Get('customer-report')
async getCustomerReport(@Query('startDate') startDate: string, @Query('endDate') endDate: string) { }

@Get('inventory-report')
async getInventoryReport() { }

@Get('export')
async exportReport(@Query() query: ExportQueryDto, @Res() res: Response) { }

@Delete('reports/:id')
async deleteReport(@Param('id') id: string) { }

@Get('reports/:id/run')
async runReport(@Param('id') id: string) { }
```

**الملف:** `backend/src/modules/analytics/analytics.service.ts` أو `dashboard.service.ts`

- إضافة methods المقابلة

### 4.3 Inventory Module

**الملف:** `backend/src/modules/inventory/inventory.controller.ts`

إضافة:

```typescript
// تحديث مستويات المخزون
@Put('stock/:productId/levels')
async updateStockLevels(@Param('productId') productId: string, @Body() data: any) { }

// تأكيد التنبيه
@Put('alerts/:id/acknowledge')
async acknowledgeAlert(@Param('id') id: string) { }

// حل التنبيه
@Put('alerts/:id/resolve')
async resolveAlert(@Param('id') id: string) { }

// حذف مستودع
@Delete('warehouses/:id')
async deleteWarehouse(@Param('id') id: string) { }

// تحديث موقع
@Put('locations/:id')
async updateLocation(@Param('id') id: string, @Body() data: any) { }

// الحصول على كل المواقع
@Get('locations')
async getAllLocations(@Query('warehouseId') warehouseId?: string) { }

// تحويل مخزون بسيط
@Post('stock/transfer')
async transferStock(@Body() data: StockTransferDto) { }
```

### 4.4 Settings Module

**الملف:** `backend/src/modules/settings/settings.controller.ts`

إضافة Delete endpoints:

```typescript
@Delete('admin/countries/:id')
@Delete('admin/cities/:id')
@Delete('admin/currencies/:id')
@Delete('admin/tax-rates/:id')
@Delete('admin/shipping-zones/:id')
@Delete('admin/payment-methods/:id')
```

### 4.5 Catalog Module

**الملف:** `backend/src/modules/catalog/catalog.controller.ts`

إضافة:

```typescript
@Delete('categories/:id')
async deleteCategory(@Param('id') id: string) { }
```

### 4.6 Content Module

**الملف:** `backend/src/modules/content/content.controller.ts`

إضافة:

```typescript
@Delete('admin/faqs/:id')
async deleteFaq(@Param('id') id: string) { }

@Delete('admin/faq-categories/:id')
async deleteFaqCategory(@Param('id') id: string) { }
```

---

## المرحلة 5: تحسينات الفرونت إند 🟡 متوسط

### 5.1 إضافة Lazy Loading للصفحات

**الملف:** `admin/src/App.tsx`

```typescript
// ❌ قبل
import { DashboardPage } from "@/pages/dashboard/DashboardPage";

// ✅ بعد
const DashboardPage = lazy(() => import("@/pages/dashboard/DashboardPage"));
// + Suspense wrapper
```

### 5.2 توحيد `extractData` helper

**ملف جديد:** `admin/src/api/helpers.ts`

```typescript
export function extractData<T>(responseData: any): T { ... }
export function extractArrayData<T>(responseData: any): T[] { ... }
```

حذف النسخ المكررة من:

- `admin/src/api/catalog.api.ts`
- `admin/src/api/audit.api.ts`
- `admin/src/api/content.api.ts`
- `admin/src/api/settings.api.ts`
- `admin/src/api/chat.api.ts`
- `admin/src/api/analytics.api.ts`

### 5.3 إضافة Health Check

**الملف:** `backend/src/app.module.ts` أو controller جديد

```typescript
@Get('health')
async healthCheck() {
    return { status: 'ok', timestamp: new Date().toISOString() };
}
```

---

## المرحلة 6: تحسينات الأمان والأداء 🟢 قبل الإنتاج

### 6.1 أمان

- [ ] التأكد من قوة `JWT_SECRET` في الإنتاج
- [ ] إضافة rate limiting headers في الفرونت إند
- [ ] مراجعة CORS settings للإنتاج

### 6.2 أداء

- [ ] إضافة compression في nginx config
- [ ] مراجعة React Query invalidation strategy
- [ ] إضافة image lazy loading

### 6.3 Docker

- [ ] مراجعة `admin/Dockerfile` و `admin/nginx.conf`
- [ ] مراجعة `backend/Dockerfile` و `backend/docker-compose.yml`
- [ ] التأكد من environment variables في Docker

---

## ترتيب التنفيذ المقترح

```
المرحلة 1 (يوم 1-2):
  ├── 1.1 توحيد ResponseBuilder
  ├── 1.2 إصلاح GlobalExceptionFilter
  └── 1.3 إضافة paginated method

المرحلة 2 (يوم 2-3):
  ├── 2.1 إصلاح client.ts + env vars
  ├── 2.2 إنشاء .env files
  ├── 2.3 ErrorBoundary
  └── 2.4 Toast system

المرحلة 3 (يوم 3-4):
  ├── 3.1-3.3 إصلاح paths في الفرونت إند
  ├── 3.4-3.5 إصلاح paths في الباك إند
  └── 3.6-3.8 إصلاح Support paths

المرحلة 4 (يوم 4-7):
  ├── 4.1 Orders endpoints
  ├── 4.2 Analytics endpoints (الأكبر)
  ├── 4.3 Inventory endpoints
  ├── 4.4 Settings delete endpoints
  ├── 4.5 Catalog delete
  └── 4.6 Content delete

المرحلة 5 (يوم 7-8):
  ├── 5.1 Lazy loading
  ├── 5.2 توحيد helpers
  └── 5.3 Health check

المرحلة 6 (يوم 8-9):
  ├── 6.1 أمان
  ├── 6.2 أداء
  └── 6.3 Docker review
```

**الوقت المقدر: 7-9 أيام عمل**
