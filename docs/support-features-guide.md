# 🎯 دليل الميزات الجديدة لنظام الدعم الفني

## المحتويات

1. [WebSocket - التحديثات الفورية](#websocket)
2. [نظام الإشعارات](#notifications)
3. [رفع الملفات](#file-upload)
4. [التقارير والإحصائيات](#reports)
5. [مراقبة SLA](#sla-monitoring)
6. [البحث المتقدم](#advanced-search)
7. [البوت الذكي](#chatbot)
8. [السجلات](#audit-log)
9. [التصدير](#export)
10. [الأذونات](#permissions)

---

## 🔌 WebSocket - التحديثات الفورية {#websocket}

### Backend Setup

تم إضافة WebSocket Gateway في:
`backend/src/modules/support/gateways/support.gateway.ts`

### الاتصال من Frontend

#### React (Admin Panel)

```typescript
import { socketService } from '@/services/socket.service';

// Connect
socketService.connect(token);

// Join ticket room
socketService.joinTicket(ticketId);

// Listen to events
socketService.on('ticket:message', (message) => {
    console.log('New message:', message);
});

// Leave room
socketService.leaveTicket(ticketId);
```

#### Flutter (Mobile App)

```dart
import 'package:socket_io_client/socket_io_client.dart';

final socket = SocketService();

// Connect
socket.connect(token, baseUrl);

// Join chat room
socket.joinChat(sessionId);

// Listen to events
socket.on('chat:message', (data) {
    print('New message: $data');
});

// Send typing indicator
socket.sendTyping(sessionId, true);
```

### الأحداث المتاحة

| Event | Description | Data |
|-------|-------------|------|
| `ticket:created` | تذكرة جديدة | Ticket object |
| `ticket:updated` | تحديث تذكرة | Ticket object |
| `ticket:message` | رسالة جديدة | Message object |
| `ticket:assigned` | تعيين تذكرة | Ticket object |
| `chat:message` | رسالة محادثة | Message object |
| `chat:session:updated` | تحديث جلسة | Session object |
| `chat:session:waiting` | جلسة في الانتظار | Session object |
| `chat:session:accepted` | قبول جلسة | Session object |
| `typing:start` | بدء الكتابة | { userId, userType } |
| `typing:stop` | إيقاف الكتابة | { userId, userType } |

---

## 🔔 نظام الإشعارات {#notifications}

### الإشعارات التلقائية

#### للتذاكر:
1. **عند الإنشاء** → إشعار للوكيل المعين (Push + Email)
2. **عند الرد** → إشعار للعميل/الوكيل (Push + Email)
3. **عند تغيير الحالة** → إشعار للعميل (Push + Email)
4. **عند الحل** → إشعار للعميل مع طلب التقييم (Push + Email)

#### للمحادثات:
1. **عند القبول** → إشعار للعميل (Push)
2. **عند الرسالة** → إشعار للطرف الآخر (Push)

### تخصيص الإشعارات

يمكن تخصيص الإشعارات من خلال:
`backend/src/modules/support/services/support-notifications.service.ts`

---

## 📤 رفع الملفات {#file-upload}

### Endpoints

#### للتذاكر
```http
POST /tickets/upload
Content-Type: application/json

{
    "files": [
        {
            "base64": "data:image/jpeg;base64,...",
            "filename": "image.jpg"
        }
    ]
}

Response: {
    "success": true,
    "data": {
        "urls": ["https://..."]
    }
}
```

#### للمحادثات
```http
POST /chat/upload
```

### القيود

- الحد الأقصى لحجم الملف: 10MB
- الأنواع المدعومة: صور (jpg, png, gif), PDF, مستندات (doc, docx)

---

## 📊 التقارير والإحصائيات {#reports}

### التقارير المتاحة

#### 1. تقرير التذاكر حسب الوقت
```http
GET /support/reports/tickets/overview?startDate=2024-01-01&endDate=2024-12-31&groupBy=day
```

**البيانات المرجعة:**
- عدد التذاكر حسب اليوم/الأسبوع/الشهر
- توزيع حسب الحالة
- إجمالي التذاكر

#### 2. تقرير التذاكر حسب الفئة
```http
GET /support/reports/tickets/by-category?startDate=...&endDate=...
```

**البيانات المرجعة:**
- إجمالي التذاكر لكل فئة
- التذاكر المفتوحة
- التذاكر المحلولة
- معدل الحل
- متوسط وقت الحل

#### 3. تقرير أداء الوكلاء
```http
GET /support/reports/tickets/agent-performance?startDate=...&endDate=...
```

**البيانات المرجعة:**
- إجمالي التذاكر المعينة
- التذاكر المحلولة
- معدل الحل
- متوسط وقت الرد الأول
- متوسط وقت الحل
- متوسط التقييم
- تجاوزات SLA

#### 4. تقرير امتثال SLA
```http
GET /support/reports/tickets/sla-compliance?startDate=...&endDate=...
```

**البيانات المرجعة:**
- معدل امتثال الرد الأول
- معدل امتثال الحل
- متوسط أوقات الاستجابة

#### 5. تقرير رضا العملاء
```http
GET /support/reports/tickets/satisfaction?startDate=...&endDate=...
```

**البيانات المرجعة:**
- توزيع التقييمات (1-5 نجوم)
- عدد التذاكر المقيّمة

#### 6. تقرير أوقات الذروة
```http
GET /support/reports/tickets/peak-hours?startDate=...&endDate=...
```

**البيانات المرجعة:**
- عدد التذاكر حسب الساعة (0-23)

---

## ⏰ مراقبة SLA {#sla-monitoring}

### Cron Job

يعمل كل 10 دقائق ويفحص:

1. **SLA الرد الأول**
   - تحذير عند 80% من الوقت
   - تنبيه عند التجاوز

2. **SLA الحل**
   - تحذير عند 80% من الوقت
   - تنبيه عند التجاوز

3. **التذاكر العاجلة**
   - تنبيه للتذاكر العاجلة بدون تعيين

4. **التذاكر المعلقة**
   - تذكير للتذاكر بدون نشاط لمدة 24 ساعة

### التنبيهات

- **Push Notification** - للوكيل المعين
- **Email** - للتجاوزات الحرجة

---

## 🔍 البحث المتقدم {#advanced-search}

### Endpoint

```http
POST /tickets/admin/search
Content-Type: application/json

{
    "query": "search text",
    "status": "open",
    "priority": "high",
    "categoryId": "...",
    "assignedTo": "...",
    "customerId": "...",
    "customerName": "أحمد",
    "customerEmail": "ahmed@example.com",
    "orderId": "...",
    "productId": "...",
    "tags": ["urgent", "vip"],
    "fromDate": "2024-01-01",
    "toDate": "2024-12-31",
    "hasAttachments": true,
    "slaBreached": true,
    "hasRating": false,
    "messageContent": "search in messages",
    "page": 1,
    "limit": 20,
    "sortBy": "createdAt",
    "sortOrder": "desc"
}
```

### الميزات

- بحث نصي في جميع الحقول
- فلترة متعددة المعايير
- بحث في محتوى الرسائل
- ترتيب مخصص
- pagination

---

## 🤖 البوت الذكي {#chatbot}

### كيفية العمل

عندما يرسل العميل رسالة في محادثة في حالة "waiting":
1. يتم فحص الرسالة مقابل قواعد البوت
2. إذا تطابقت، يرسل البوت رداً تلقائياً
3. يمكن إرفاق ردود سريعة (Quick Replies)

### إضافة قاعدة جديدة

```typescript
await chatBotService.createRule({
    nameAr: "استفسار عن الأسعار",
    nameEn: "Price Inquiry",
    triggerPatterns: ["سعر", "كم", "price", "cost"],
    responseAr: "يمكنك الاطلاع على الأسعار من خلال صفحة المنتجات في التطبيق.",
    responseEn: "You can view prices on the products page in the app.",
    priority: 8,
    quickReplies: [
        {
            labelAr: "عرض المنتجات",
            labelEn: "View Products",
            value: "view_products",
            action: "reply"
        }
    ]
});
```

### إدارة القواعد

- `GET /chat/bot/rules` - عرض جميع القواعد
- `POST /chat/bot/rules` - إضافة قاعدة
- `PUT /chat/bot/rules/:id` - تحديث قاعدة
- `DELETE /chat/bot/rules/:id` - حذف قاعدة

---

## 📝 السجلات (Audit Log) {#audit-log}

### الأحداث المسجلة

جميع العمليات على التذاكر والمحادثات يتم تسجيلها تلقائياً:

- إنشاء/تحديث/حذف
- تغيير الحالة
- التعيين
- التصعيد
- الدمج
- الرسائل

### عرض السجلات

```typescript
// Get logs for a ticket
const logs = await auditLogService.getEntityLogs('ticket', ticketId);

// Get logs for an agent
const logs = await auditLogService.getActorLogs(agentId);

// Get logs by action
const logs = await auditLogService.getLogsByAction(AuditAction.TICKET_ASSIGNED);

// Get logs by date range
const logs = await auditLogService.getLogsByDateRange(startDate, endDate, {
    entityType: 'ticket',
    action: AuditAction.TICKET_STATUS_CHANGED
});
```

---

## 📤 التصدير {#export}

### تصدير التذاكر

#### Excel
```http
GET /support/reports/tickets/export/excel?startDate=2024-01-01&endDate=2024-12-31&status=open
```

**الأعمدة:**
- Ticket Number
- Customer (Name + Email)
- Subject
- Status
- Priority
- Category
- Assigned To
- Created At
- Rating

#### PDF
```http
GET /support/reports/tickets/export/pdf?startDate=2024-01-01&endDate=2024-12-31
```

**التنسيق:**
- جدول منسق
- عناوين واضحة
- تاريخ التقرير

### تصدير المحادثات

```http
GET /support/reports/chat/export/excel?startDate=...&endDate=...
```

**الأعمدة:**
- Session ID
- Customer
- Status
- Agent
- Wait Time
- Duration
- Messages Count
- Rating

---

## 🔒 الأذونات {#permissions}

### الأذونات الجديدة

```typescript
// Tickets
support.tickets.view          // عرض التذاكر
support.tickets.create        // إنشاء تذاكر
support.tickets.update        // تحديث تذاكر
support.tickets.reply         // الرد على تذاكر
support.tickets.assign        // تعيين تذاكر
support.tickets.escalate      // تصعيد تذاكر
support.tickets.close         // إغلاق تذاكر
support.tickets.merge         // دمج تذاكر

// Chat
support.chat.view             // عرض المحادثات
support.chat.accept           // قبول محادثات
support.chat.transfer         // نقل محادثات

// Management
support.categories.manage     // إدارة الفئات
support.canned.manage         // إدارة الردود الجاهزة
support.reports.view          // عرض التقارير
support.export                // تصدير البيانات
```

### استخدام الأذونات

```typescript
import { SupportPermissionsGuard, RequirePermission } from '@/guards/support-permissions.guard';
import { PERMISSIONS } from '@/constants/permissions.constant';

@UseGuards(SupportPermissionsGuard)
@RequirePermission(PERMISSIONS.SUPPORT.ASSIGN_TICKETS)
async assignTicket(@Param('id') id: string) {
    // Only users with assign permission can access
}
```

---

## 📈 الإحصائيات المتقدمة

### إحصائيات الوكيل

```http
GET /tickets/admin/my-stats
```

**البيانات:**
- التذاكر المعينة (الحالية)
- التذاكر المحلولة (الإجمالي)
- معدل الحل (%)
- متوسط وقت الرد الأول (دقائق)
- متوسط التقييم (1-5)
- إجمالي الرسائل المرسلة

### إحصائيات الفئات

```typescript
const stats = await ticketsService.getCategoryStats();
```

**البيانات لكل فئة:**
- إجمالي التذاكر
- التذاكر المفتوحة
- التذاكر المحلولة
- معدل الحل (%)
- متوسط وقت الحل
- متوسط التقييم

### مؤشرات الأداء

#### معدل الحل من المحاولة الأولى
```typescript
const rate = await ticketsService.getFirstContactResolutionRate();
// Returns: percentage of tickets resolved with ≤2 messages
```

#### متوسط عدد الرسائل لكل تذكرة
```typescript
const avg = await ticketsService.getAvgMessagesPerTicket();
```

---

## 🎯 أفضل الممارسات

### 1. WebSocket

- اتصل عند تسجيل الدخول
- افصل عند تسجيل الخروج
- انضم للغرف عند فتح التذكرة/المحادثة
- اترك الغرف عند الإغلاق

### 2. الإشعارات

- تأكد من تفعيل الإشعارات في الإعدادات
- استخدم قوالب مخصصة للعلامة التجارية
- اختبر الإشعارات قبل الإنتاج

### 3. التقارير

- استخدم نطاقات زمنية معقولة
- قم بالتصدير في أوقات منخفضة الحمل
- احفظ التقارير المهمة

### 4. SLA

- راجع إعدادات SLA بانتظام
- تابع التنبيهات فوراً
- حلل أسباب التجاوزات

### 5. البوت

- أضف قواعد للأسئلة الشائعة
- راجع استخدام القواعد
- حدّث الردود بانتظام

---

## 🔧 استكشاف الأخطاء

### WebSocket لا يتصل

1. تحقق من أن الـ Backend يعمل
2. تحقق من صحة الـ Token
3. تحقق من إعدادات CORS
4. راجع console للأخطاء

### الإشعارات لا تصل

1. تحقق من إعدادات FCM
2. تحقق من إعدادات Email (SMTP)
3. راجع logs في Backend
4. تأكد من تفعيل الإشعارات في الإعدادات

### التقارير بطيئة

1. استخدم نطاقات زمنية أصغر
2. أضف indexes للـ Database
3. استخدم caching للتقارير المتكررة

### البوت لا يرد

1. تحقق من أن القواعد مفعّلة
2. راجع الأنماط (Patterns)
3. تحقق من أولويات القواعد
4. راجع logs للأخطاء

---

## 📚 موارد إضافية

- [Socket.IO Documentation](https://socket.io/docs/)
- [ExcelJS Documentation](https://github.com/exceljs/exceljs)
- [PDFKit Documentation](http://pdfkit.org/)
- [NestJS WebSockets](https://docs.nestjs.com/websockets/gateways)

---

## ✅ قائمة التحقق للإنتاج

- [ ] اختبار WebSocket في بيئة الإنتاج
- [ ] إعداد FCM للإشعارات
- [ ] إعداد SMTP للإيميل
- [ ] إعداد Unifonic للـ SMS (اختياري)
- [ ] اختبار رفع الملفات
- [ ] مراجعة قواعد البوت
- [ ] اختبار التقارير والتصدير
- [ ] إعداد Cron Job للـ SLA
- [ ] مراجعة الأذونات
- [ ] اختبار السجلات
- [ ] تحسين الأداء
- [ ] إعداد Monitoring

---

© 2024 TRAS Phone - جميع الحقوق محفوظة
