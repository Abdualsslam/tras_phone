# 📋 نظام الدعم الفني - التوثيق الشامل

## نظرة عامة

تم إكمال نظام الدعم الفني بجميع الميزات المتقدمة المطلوبة. النظام يشمل:

### المكونات الرئيسية

1. **نظام التذاكر (Support Tickets)**
2. **المحادثة المباشرة (Live Chat)**
3. **WebSocket للتحديثات الفورية**
4. **نظام الإشعارات (Push + Email + SMS)**
5. **نظام التقارير والإحصائيات المتقدمة**
6. **نظام مراقبة SLA والتذكيرات**
7. **البحث والفلترة المتقدمة**
8. **البوت الذكي للمحادثات**
9. **نظام السجلات (Audit Log)**
10. **نظام التصدير (Excel + PDF)**
11. **نظام الأذونات المتقدم**
12. **قوالب الإيميل**

---

## 🔌 WebSocket - التحديثات الفورية

### الملفات المضافة

- `backend/src/modules/support/gateways/support.gateway.ts`

### الميزات

#### للتذاكر:
- `ticket:created` - عند إنشاء تذكرة جديدة
- `ticket:updated` - عند تحديث التذكرة
- `ticket:message` - عند إضافة رسالة
- `ticket:assigned` - عند تعيين تذكرة

#### للمحادثات:
- `chat:message` - عند إرسال رسالة
- `chat:session:updated` - عند تحديث جلسة
- `chat:session:waiting` - عند انتظار جلسة
- `chat:session:accepted` - عند قبول جلسة
- `typing:start` / `typing:stop` - مؤشر الكتابة

### Authentication

يتم المصادقة باستخدام JWT Token في handshake:

```typescript
const socket = io('http://localhost:3000/support', {
    auth: { token: 'your-jwt-token' }
});
```

### Room Management

- `user:{userId}` - غرفة المستخدم
- `ticket:{ticketId}` - غرفة التذكرة
- `chat:{sessionId}` - غرفة المحادثة

---

## 🔔 نظام الإشعارات

### الملفات المضافة

- `backend/src/modules/support/services/support-notifications.service.ts`

### أنواع الإشعارات

#### للتذاكر:
1. **إنشاء تذكرة** - إشعار للوكيل المعين
2. **تغيير الحالة** - إشعار للعميل
3. **تعيين تذكرة** - إشعار للوكيل الجديد
4. **رسالة جديدة** - إشعار للعميل/الوكيل
5. **حل التذكرة** - إشعار للعميل مع طلب التقييم

#### للمحادثات:
1. **قبول المحادثة** - إشعار للعميل
2. **رسالة جديدة** - إشعار للعميل/الوكيل
3. **جلسة في الانتظار** - إشعار للوكلاء المتاحين

### القنوات المدعومة

- **Push Notifications** - عبر FCM
- **Email** - عبر Nodemailer
- **SMS** - عبر Unifonic (اختياري)

---

## 📤 رفع الملفات

### Endpoints المضافة

- `POST /tickets/upload` - رفع مرفقات التذاكر
- `POST /chat/upload` - رفع ملفات المحادثة

### الميزات

- دعم رفع ملفات متعددة
- التحقق من نوع الملف
- التحقق من حجم الملف (حد أقصى 10MB)
- حفظ في S3 أو local storage
- إرجاع URLs للملفات

### مثال الاستخدام

```typescript
POST /tickets/upload
Body: {
    files: [
        { base64: "data:image/jpeg;base64,...", filename: "image.jpg" },
        { base64: "data:application/pdf;base64,...", filename: "doc.pdf" }
    ]
}

Response: {
    success: true,
    data: {
        urls: ["https://...", "https://..."]
    }
}
```

---

## ⭐ نظام التقييم للمحادثات

### الميزات المضافة

- `findLastEndedSession()` - إيجاد آخر جلسة منتهية
- تحديث endpoint `POST /chat/my-session/rate`
- حفظ التقييم والملاحظات

### الاستخدام

```typescript
POST /chat/my-session/rate
Body: {
    rating: 5,
    feedback: "خدمة ممتازة!"
}
```

---

## 📊 التقارير والإحصائيات المتقدمة

### الملفات المضافة

- `backend/src/modules/support/services/support-reports.service.ts`
- `backend/src/modules/support/controllers/reports.controller.ts`

### التقارير المتاحة

#### 1. تقرير التذاكر حسب الوقت
`GET /support/reports/tickets/overview?startDate=...&endDate=...&groupBy=day`

#### 2. تقرير التذاكر حسب الفئة
`GET /support/reports/tickets/by-category?startDate=...&endDate=...`

#### 3. تقرير أداء الوكلاء
`GET /support/reports/tickets/agent-performance?startDate=...&endDate=...`

#### 4. تقرير امتثال SLA
`GET /support/reports/tickets/sla-compliance?startDate=...&endDate=...`

#### 5. تقرير رضا العملاء
`GET /support/reports/tickets/satisfaction?startDate=...&endDate=...`

#### 6. تقرير أوقات الذروة
`GET /support/reports/tickets/peak-hours?startDate=...&endDate=...`

#### 7. تقرير جلسات المحادثة
`GET /support/reports/chat/overview?startDate=...&endDate=...`

### التصدير

#### Excel
`GET /support/reports/tickets/export/excel?startDate=...&endDate=...&status=...`

#### PDF
`GET /support/reports/tickets/export/pdf?startDate=...&endDate=...&status=...`

---

## ⏰ نظام مراقبة SLA

### الملفات المضافة

- `backend/src/modules/support/services/sla-monitor.service.ts`

### الميزات

#### Cron Job (كل 10 دقائق)
- فحص SLA للرد الأول
- فحص SLA للحل
- فحص التذاكر العاجلة
- فحص التذاكر المعلقة (24 ساعة بدون نشاط)

#### التنبيهات
- تحذير عند 80% من الوقت المحدد
- تنبيه عند تجاوز SLA
- تنبيه للتذاكر العاجلة بدون تعيين
- تذكير للتذاكر المعلقة

---

## 🔍 البحث المتقدم

### الملفات المضافة

- `backend/src/modules/support/dto/advanced-search.dto.ts`

### معايير البحث

- **نص البحث** - في رقم التذكرة، الموضوع، الوصف، اسم/بريد العميل
- **الحالة** - فلترة حسب الحالة
- **الأولوية** - فلترة حسب الأولوية
- **الفئة** - فلترة حسب الفئة
- **الوكيل** - فلترة حسب الوكيل المعين
- **العميل** - فلترة حسب العميل
- **الطلب/المنتج** - فلترة حسب Order ID أو Product ID
- **التاريخ** - نطاق زمني
- **المرفقات** - التذاكر التي تحتوي على مرفقات
- **SLA** - التذاكر التي تجاوزت SLA
- **التقييم** - التذاكر المقيّمة
- **محتوى الرسائل** - البحث في محتوى الرسائل

### Endpoint

```typescript
POST /tickets/admin/search
Body: {
    query: "search text",
    status: "open",
    priority: "high",
    categoryId: "...",
    fromDate: "2024-01-01",
    toDate: "2024-12-31",
    hasAttachments: true,
    slaBreached: true,
    messageContent: "search in messages",
    page: 1,
    limit: 20,
    sortBy: "createdAt",
    sortOrder: "desc"
}
```

---

## 🤖 البوت الذكي للمحادثات

### الملفات المضافة

- `backend/src/modules/support/schemas/chat-bot-rule.schema.ts`
- `backend/src/modules/support/services/chat-bot.service.ts`

### الميزات

- قاعدة بيانات للقواعد (Rules)
- مطابقة الأنماط (Regex أو Keywords)
- إجابات تلقائية بالعربية والإنجليزية
- ردود سريعة (Quick Replies)
- تتبع الاستخدام
- أولويات للقواعد

### القواعد الافتراضية

1. **ترحيب** - مرحبا، السلام عليكم، hello, hi
2. **تتبع الطلب** - تتبع، طلبي، track, my order
3. **ساعات العمل** - ساعات العمل، متى تفتحون
4. **شكر** - شكرا، thank you

### إضافة قاعدة جديدة

```typescript
{
    nameAr: "اسم القاعدة",
    nameEn: "Rule Name",
    triggerPatterns: ["pattern1", "pattern2"],
    responseAr: "الرد بالعربية",
    responseEn: "Response in English",
    priority: 10,
    quickReplies: [
        {
            labelAr: "خيار 1",
            labelEn: "Option 1",
            value: "option1",
            action: "reply"
        }
    ]
}
```

---

## 📝 نظام السجلات (Audit Log)

### الملفات المضافة

- `backend/src/modules/support/schemas/support-audit.schema.ts`
- `backend/src/modules/support/services/audit-log.service.ts`

### الأحداث المسجلة

#### للتذاكر:
- إنشاء تذكرة
- تحديث تذكرة
- تغيير الحالة
- تعيين تذكرة
- تصعيد تذكرة
- دمج تذاكر
- إضافة رسالة
- تقييم تذكرة

#### للمحادثات:
- إنشاء جلسة
- قبول جلسة
- نقل جلسة
- إنهاء جلسة
- إرسال رسالة

### البيانات المسجلة

- الإجراء (Action)
- نوع الكيان (Entity Type)
- معرف الكيان (Entity ID)
- الفاعل (Actor)
- القيم القديمة (Old Values)
- القيم الجديدة (New Values)
- البيانات الإضافية (Metadata)
- IP Address & User Agent

### الاستخدام

```typescript
await auditLogService.log({
    action: AuditAction.TICKET_CREATED,
    entityType: 'ticket',
    entityId: ticket._id.toString(),
    entityName: ticket.ticketNumber,
    actorId: customerId,
    actorModel: 'Customer',
    actorName: customerName,
    newValues: { subject, category, priority, status }
});
```

---

## 📤 نظام التصدير

### Endpoints

- `GET /support/reports/tickets/export/excel` - تصدير التذاكر إلى Excel
- `GET /support/reports/tickets/export/pdf` - تصدير التذاكر إلى PDF

### الميزات

- تصدير مع فلترة (حسب التاريخ، الحالة، إلخ)
- تنسيق احترافي
- عناوين بالعربية والإنجليزية
- تصميم جذاب

---

## 🔒 نظام الأذونات المتقدم

### الأذونات المضافة

```typescript
SUPPORT: {
    // Tickets
    VIEW_TICKETS: 'support.tickets.view',
    CREATE_TICKETS: 'support.tickets.create',
    UPDATE_TICKETS: 'support.tickets.update',
    REPLY_TICKETS: 'support.tickets.reply',
    ASSIGN_TICKETS: 'support.tickets.assign',
    ESCALATE_TICKETS: 'support.tickets.escalate',
    CLOSE_TICKETS: 'support.tickets.close',
    MERGE_TICKETS: 'support.tickets.merge',
    // Chat
    VIEW_CHAT: 'support.chat.view',
    ACCEPT_CHAT: 'support.chat.accept',
    TRANSFER_CHAT: 'support.chat.transfer',
    // Management
    MANAGE_CATEGORIES: 'support.categories.manage',
    MANAGE_CANNED: 'support.canned.manage',
    VIEW_REPORTS: 'support.reports.view',
    EXPORT_DATA: 'support.export',
}
```

### الاستخدام

```typescript
@UseGuards(SupportPermissionsGuard)
@RequirePermission(PERMISSIONS.SUPPORT.ASSIGN_TICKETS)
async assignTicket() { ... }
```

---

## 📧 قوالب الإيميل

### القوالب المضافة

1. `ticket-created.template.hbs` - عند إنشاء تذكرة
2. `ticket-replied.template.hbs` - عند الرد على تذكرة
3. `ticket-status-changed.template.hbs` - عند تغيير الحالة
4. `chat-accepted.template.hbs` - عند قبول محادثة

### الميزات

- تصميم احترافي responsive
- دعم RTL للعربية
- متغيرات ديناميكية
- أزرار Call-to-Action
- ألوان مخصصة حسب النوع

---

## 📊 الإحصائيات المتقدمة

### دوال جديدة في `tickets.service.ts`

#### 1. إحصائيات الوكيل المحسّنة
```typescript
{
    assignedTickets: number,
    resolvedTickets: number,
    resolutionRate: number,
    avgFirstResponseMinutes: number,
    avgRating: number,
    totalMessages: number
}
```

#### 2. إحصائيات الفئات
```typescript
getCategoryStats() => {
    categoryName,
    totalTickets,
    openTickets,
    resolvedTickets,
    resolutionRate,
    avgResolutionTimeMinutes,
    avgRating
}
```

#### 3. معدل الحل من المحاولة الأولى
```typescript
getFirstContactResolutionRate() => number
```

#### 4. متوسط عدد الرسائل لكل تذكرة
```typescript
getAvgMessagesPerTicket() => number
```

---

## 🎨 لوحة التحكم - التحسينات

### الملفات المضافة

- `admin/src/services/socket.service.ts` - خدمة WebSocket
- `admin/src/hooks/useSocket.ts` - Hook للـ WebSocket

### الميزات

1. **تحديثات فورية** - عبر WebSocket
2. **إشعارات فورية** - للتذاكر والمحادثات الجديدة
3. **مؤشر الكتابة** - في المحادثات
4. **تحديث تلقائي** - للقوائم والتفاصيل

### الاستخدام في React

```typescript
import { useSocket } from '@/hooks/useSocket';

function SupportPage() {
    const { on, joinTicket, leaveTicket } = useSocket();

    useEffect(() => {
        const unsubscribe = on('ticket:message', (message) => {
            // Handle new message
        });

        return unsubscribe;
    }, []);
}
```

---

## 📱 التطبيق - التحسينات

### الملفات المضافة

- `mobile/lib/core/services/socket_service.dart` - خدمة WebSocket

### الميزات

1. **تحديثات فورية** - عبر WebSocket
2. **إشعارات فورية** - Push notifications
3. **مؤشر الكتابة** - في المحادثات
4. **تحديث تلقائي** - للتذاكر والمحادثات

### الاستخدام في Flutter

```dart
final socketService = SocketService();

// Connect
socketService.connect(token, baseUrl);

// Join room
socketService.joinChat(sessionId);

// Listen to events
socketService.on('chat:message', (data) {
    // Handle new message
});

// Send typing
socketService.sendTyping(sessionId, true);
```

---

## 🚀 كيفية التشغيل

### 1. Backend

```bash
cd backend
npm install
npm run start:dev
```

### 2. Admin Panel

```bash
cd admin
npm install
npm run dev
```

### 3. Mobile App

```bash
cd mobile
flutter pub get
flutter run
```

---

## 🧪 الاختبار

### اختبار WebSocket

```bash
# في متصفح أو Postman
wscat -c ws://localhost:3000/support -H "Authorization: Bearer YOUR_TOKEN"
```

### اختبار الإشعارات

```bash
# إنشاء تذكرة وتحقق من وصول الإشعار
POST /tickets
```

### اختبار التقارير

```bash
# تصدير تقرير
GET /support/reports/tickets/export/excel?startDate=2024-01-01&endDate=2024-12-31
```

---

## 📝 ملاحظات مهمة

### الأداء

- WebSocket يستخدم Rooms لتقليل الحمل
- التقارير تستخدم Aggregation Pipeline للأداء
- الإشعارات تُرسل بشكل غير متزامن

### الأمان

- WebSocket يتطلب JWT Authentication
- جميع Endpoints محمية بـ Guards
- الأذونات تُفحص على مستوى الـ Controller

### التوسع

- يمكن إضافة قواعد بوت جديدة بسهولة
- يمكن إضافة قوالب إيميل جديدة
- يمكن إضافة تقارير جديدة
- يمكن إضافة أذونات جديدة

---

## 🎯 الخلاصة

تم إكمال نظام الدعم الفني بجميع الميزات المطلوبة:

✅ WebSocket للتحديثات الفورية
✅ نظام إشعارات شامل (Push + Email + SMS)
✅ رفع الملفات للتذاكر والمحادثات
✅ نظام التقييم الكامل للمحادثات
✅ تقارير وإحصائيات متقدمة
✅ مراقبة SLA وتذكيرات تلقائية
✅ بحث وفلترة متقدمة
✅ بوت ذكي للمحادثات
✅ نظام سجلات شامل
✅ تصدير Excel و PDF
✅ نظام أذونات متقدم
✅ قوالب إيميل احترافية
✅ إحصائيات متقدمة
✅ تحسينات لوحة التحكم
✅ تحسينات التطبيق

**النظام جاهز للإنتاج!** 🚀

---

© 2024 TRAS Phone - جميع الحقوق محفوظة
