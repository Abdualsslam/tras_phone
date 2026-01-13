# 🎧 Support Module - دليل ربط الدعم الفني

## 📋 نظرة عامة

هذا الموديول يتعامل مع:
- ✅ تذاكر الدعم (Support Tickets)
- ✅ رسائل التذاكر (Ticket Messages)
- ✅ المحادثة المباشرة (Live Chat)
- ✅ فئات التذاكر (Ticket Categories)
- ✅ تقييم الخدمة

> **ملاحظة**: جميع الـ endpoints تحتاج **Token** 🔒 باستثناء `GET /tickets/categories`

---

## 📁 Flutter Models

### Ticket Model

```dart
class Ticket {
  final String id;
  final String ticketNumber;
  final TicketCustomerInfo customer;
  final String categoryId;
  final TicketCategory? category;
  final String subject;
  final String description;
  final TicketStatus status;
  final TicketPriority priority;
  final TicketSource source;
  final String? assignedTo;
  final String? orderId;
  final String? productId;
  final List<String> attachments;
  final List<String> tags;
  final TicketSLA sla;
  final TicketResolution? resolution;
  final int messageCount;
  final DateTime? lastCustomerReplyAt;
  final DateTime? lastAgentReplyAt;
  final int? satisfactionRating;
  final String? satisfactionFeedback;
  final DateTime createdAt;
  final DateTime updatedAt;

  Ticket({
    required this.id,
    required this.ticketNumber,
    required this.customer,
    required this.categoryId,
    this.category,
    required this.subject,
    required this.description,
    required this.status,
    required this.priority,
    required this.source,
    this.assignedTo,
    this.orderId,
    this.productId,
    required this.attachments,
    required this.tags,
    required this.sla,
    this.resolution,
    required this.messageCount,
    this.lastCustomerReplyAt,
    this.lastAgentReplyAt,
    this.satisfactionRating,
    this.satisfactionFeedback,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      id: json['_id'] ?? json['id'],
      ticketNumber: json['ticketNumber'],
      customer: TicketCustomerInfo.fromJson(json['customer']),
      categoryId: json['category'] is String 
          ? json['category'] 
          : json['category']?['_id'] ?? '',
      category: json['category'] is Map 
          ? TicketCategory.fromJson(json['category']) 
          : null,
      subject: json['subject'],
      description: json['description'],
      status: TicketStatus.fromString(json['status']),
      priority: TicketPriority.fromString(json['priority']),
      source: TicketSource.fromString(json['source']),
      assignedTo: json['assignedTo'],
      orderId: json['orderId'],
      productId: json['productId'],
      attachments: List<String>.from(json['attachments'] ?? []),
      tags: List<String>.from(json['tags'] ?? []),
      sla: TicketSLA.fromJson(json['sla'] ?? {}),
      resolution: json['resolution'] != null 
          ? TicketResolution.fromJson(json['resolution']) 
          : null,
      messageCount: json['messageCount'] ?? 0,
      lastCustomerReplyAt: json['lastCustomerReplyAt'] != null 
          ? DateTime.parse(json['lastCustomerReplyAt']) 
          : null,
      lastAgentReplyAt: json['lastAgentReplyAt'] != null 
          ? DateTime.parse(json['lastAgentReplyAt']) 
          : null,
      satisfactionRating: json['satisfactionRating'],
      satisfactionFeedback: json['satisfactionFeedback'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  /// هل التذكرة مفتوحة؟
  bool get isOpen => ![
    TicketStatus.closed,
    TicketStatus.resolved,
  ].contains(status);
  
  /// هل يمكن التقييم؟
  bool get canRate => 
      status == TicketStatus.resolved && 
      satisfactionRating == null;
  
  /// هل تم تجاوز SLA؟
  bool get isSlaBreached => 
      sla.firstResponseBreached || sla.resolutionBreached;
}
```

### TicketCustomerInfo Model

```dart
class TicketCustomerInfo {
  final String? customerId;
  final String name;
  final String email;
  final String? phone;

  TicketCustomerInfo({
    this.customerId,
    required this.name,
    required this.email,
    this.phone,
  });

  factory TicketCustomerInfo.fromJson(Map<String, dynamic> json) {
    return TicketCustomerInfo(
      customerId: json['customerId'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
    );
  }
}
```

### TicketSLA Model

```dart
class TicketSLA {
  final DateTime? firstResponseDue;
  final DateTime? resolutionDue;
  final DateTime? firstRespondedAt;
  final DateTime? resolvedAt;
  final bool firstResponseBreached;
  final bool resolutionBreached;

  TicketSLA({
    this.firstResponseDue,
    this.resolutionDue,
    this.firstRespondedAt,
    this.resolvedAt,
    required this.firstResponseBreached,
    required this.resolutionBreached,
  });

  factory TicketSLA.fromJson(Map<String, dynamic> json) {
    return TicketSLA(
      firstResponseDue: json['firstResponseDue'] != null 
          ? DateTime.parse(json['firstResponseDue']) 
          : null,
      resolutionDue: json['resolutionDue'] != null 
          ? DateTime.parse(json['resolutionDue']) 
          : null,
      firstRespondedAt: json['firstRespondedAt'] != null 
          ? DateTime.parse(json['firstRespondedAt']) 
          : null,
      resolvedAt: json['resolvedAt'] != null 
          ? DateTime.parse(json['resolvedAt']) 
          : null,
      firstResponseBreached: json['firstResponseBreached'] ?? false,
      resolutionBreached: json['resolutionBreached'] ?? false,
    );
  }
}
```

### TicketResolution Model

```dart
class TicketResolution {
  final String? summary;
  final ResolutionType? type;
  final String? resolvedBy;
  final DateTime? resolvedAt;

  TicketResolution({
    this.summary,
    this.type,
    this.resolvedBy,
    this.resolvedAt,
  });

  factory TicketResolution.fromJson(Map<String, dynamic> json) {
    return TicketResolution(
      summary: json['summary'],
      type: json['type'] != null 
          ? ResolutionType.fromString(json['type']) 
          : null,
      resolvedBy: json['resolvedBy'],
      resolvedAt: json['resolvedAt'] != null 
          ? DateTime.parse(json['resolvedAt']) 
          : null,
    );
  }
}
```

### TicketMessage Model

```dart
class TicketMessage {
  final String id;
  final String ticketId;
  final MessageSenderType senderType;
  final String? senderId;
  final String senderName;
  final MessageType messageType;
  final String content;
  final String? htmlContent;
  final List<String> attachments;
  final bool isInternal;
  final bool isRead;
  final DateTime? readAt;
  final DateTime createdAt;

  TicketMessage({
    required this.id,
    required this.ticketId,
    required this.senderType,
    this.senderId,
    required this.senderName,
    required this.messageType,
    required this.content,
    this.htmlContent,
    required this.attachments,
    required this.isInternal,
    required this.isRead,
    this.readAt,
    required this.createdAt,
  });

  factory TicketMessage.fromJson(Map<String, dynamic> json) {
    return TicketMessage(
      id: json['_id'] ?? json['id'],
      ticketId: json['ticket'] is String 
          ? json['ticket'] 
          : json['ticket']?['_id'] ?? '',
      senderType: MessageSenderType.fromString(json['senderType']),
      senderId: json['senderId'],
      senderName: json['senderName'] ?? '',
      messageType: MessageType.fromString(json['messageType']),
      content: json['content'],
      htmlContent: json['htmlContent'],
      attachments: List<String>.from(json['attachments'] ?? []),
      isInternal: json['isInternal'] ?? false,
      isRead: json['isRead'] ?? false,
      readAt: json['readAt'] != null 
          ? DateTime.parse(json['readAt']) 
          : null,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  /// هل الرسالة من العميل؟
  bool get isFromCustomer => senderType == MessageSenderType.customer;
  
  /// هل الرسالة من الدعم؟
  bool get isFromAgent => senderType == MessageSenderType.agent;
}
```

### TicketCategory Model

```dart
class TicketCategory {
  final String id;
  final String nameAr;
  final String nameEn;
  final String? descriptionAr;
  final String? descriptionEn;
  final String? icon;
  final String? parentId;
  final int sortOrder;
  final bool isActive;
  final bool requiresOrderId;
  final bool requiresProductId;

  TicketCategory({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    this.descriptionAr,
    this.descriptionEn,
    this.icon,
    this.parentId,
    required this.sortOrder,
    required this.isActive,
    required this.requiresOrderId,
    required this.requiresProductId,
  });

  factory TicketCategory.fromJson(Map<String, dynamic> json) {
    return TicketCategory(
      id: json['_id'] ?? json['id'],
      nameAr: json['nameAr'],
      nameEn: json['nameEn'],
      descriptionAr: json['descriptionAr'],
      descriptionEn: json['descriptionEn'],
      icon: json['icon'],
      parentId: json['parent'],
      sortOrder: json['sortOrder'] ?? 0,
      isActive: json['isActive'] ?? true,
      requiresOrderId: json['requiresOrderId'] ?? false,
      requiresProductId: json['requiresProductId'] ?? false,
    );
  }

  /// الحصول على الاسم حسب اللغة
  String getName(String locale) => locale == 'ar' ? nameAr : nameEn;
  
  /// الحصول على الوصف حسب اللغة
  String? getDescription(String locale) => 
      locale == 'ar' ? descriptionAr : descriptionEn;
}
```

### ChatSession Model

```dart
class ChatSession {
  final String id;
  final String sessionId;
  final ChatVisitorInfo visitor;
  final ChatSessionStatus status;
  final String? assignedAgentId;
  final DateTime? assignedAt;
  final int queuePosition;
  final String? department;
  final DateTime? startedAt;
  final DateTime? endedAt;
  final DateTime? lastActivityAt;
  final String? initialMessage;
  final ChatMetrics metrics;
  final int? rating;
  final String? ratingFeedback;
  final DateTime createdAt;

  ChatSession({
    required this.id,
    required this.sessionId,
    required this.visitor,
    required this.status,
    this.assignedAgentId,
    this.assignedAt,
    required this.queuePosition,
    this.department,
    this.startedAt,
    this.endedAt,
    this.lastActivityAt,
    this.initialMessage,
    required this.metrics,
    this.rating,
    this.ratingFeedback,
    required this.createdAt,
  });

  factory ChatSession.fromJson(Map<String, dynamic> json) {
    return ChatSession(
      id: json['_id'] ?? json['id'],
      sessionId: json['sessionId'],
      visitor: ChatVisitorInfo.fromJson(json['visitor']),
      status: ChatSessionStatus.fromString(json['status']),
      assignedAgentId: json['assignedAgent'],
      assignedAt: json['assignedAt'] != null 
          ? DateTime.parse(json['assignedAt']) 
          : null,
      queuePosition: json['queuePosition'] ?? 0,
      department: json['department'],
      startedAt: json['startedAt'] != null 
          ? DateTime.parse(json['startedAt']) 
          : null,
      endedAt: json['endedAt'] != null 
          ? DateTime.parse(json['endedAt']) 
          : null,
      lastActivityAt: json['lastActivityAt'] != null 
          ? DateTime.parse(json['lastActivityAt']) 
          : null,
      initialMessage: json['initialMessage'],
      metrics: ChatMetrics.fromJson(json['metrics'] ?? {}),
      rating: json['rating'],
      ratingFeedback: json['ratingFeedback'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  /// هل المحادثة نشطة؟
  bool get isActive => status == ChatSessionStatus.active;
  
  /// هل في الانتظار؟
  bool get isWaiting => status == ChatSessionStatus.waiting;
  
  /// هل يمكن التقييم؟
  bool get canRate => status == ChatSessionStatus.ended && rating == null;
}
```

### ChatVisitorInfo Model

```dart
class ChatVisitorInfo {
  final String? customerId;
  final String? name;
  final String? email;
  final String? phone;

  ChatVisitorInfo({
    this.customerId,
    this.name,
    this.email,
    this.phone,
  });

  factory ChatVisitorInfo.fromJson(Map<String, dynamic> json) {
    return ChatVisitorInfo(
      customerId: json['customerId'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
    );
  }
}
```

### ChatMetrics Model

```dart
class ChatMetrics {
  final int waitTime;
  final int chatDuration;
  final int messageCount;
  final int agentMessageCount;
  final int visitorMessageCount;
  final int avgResponseTime;

  ChatMetrics({
    required this.waitTime,
    required this.chatDuration,
    required this.messageCount,
    required this.agentMessageCount,
    required this.visitorMessageCount,
    required this.avgResponseTime,
  });

  factory ChatMetrics.fromJson(Map<String, dynamic> json) {
    return ChatMetrics(
      waitTime: json['waitTime'] ?? 0,
      chatDuration: json['chatDuration'] ?? 0,
      messageCount: json['messageCount'] ?? 0,
      agentMessageCount: json['agentMessageCount'] ?? 0,
      visitorMessageCount: json['visitorMessageCount'] ?? 0,
      avgResponseTime: json['avgResponseTime'] ?? 0,
    );
  }

  /// وقت الانتظار بالدقائق
  String get waitTimeFormatted {
    if (waitTime < 60) return '$waitTime ثانية';
    return '${(waitTime / 60).floor()} دقيقة';
  }
  
  /// مدة المحادثة بالدقائق
  String get durationFormatted {
    if (chatDuration < 60) return '$chatDuration ثانية';
    return '${(chatDuration / 60).floor()} دقيقة';
  }
}
```

### ChatMessage Model

```dart
class ChatMessage {
  final String id;
  final String sessionId;
  final ChatSenderType senderType;
  final String? senderId;
  final String? senderName;
  final ChatMessageType messageType;
  final String content;
  final String? fileUrl;
  final String? fileName;
  final List<QuickReply>? quickReplies;
  final bool isDelivered;
  final bool isRead;
  final DateTime createdAt;

  ChatMessage({
    required this.id,
    required this.sessionId,
    required this.senderType,
    this.senderId,
    this.senderName,
    required this.messageType,
    required this.content,
    this.fileUrl,
    this.fileName,
    this.quickReplies,
    required this.isDelivered,
    required this.isRead,
    required this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['_id'] ?? json['id'],
      sessionId: json['session'] is String 
          ? json['session'] 
          : json['session']?['_id'] ?? '',
      senderType: ChatSenderType.fromString(json['senderType']),
      senderId: json['senderId'],
      senderName: json['senderName'],
      messageType: ChatMessageType.fromString(json['messageType']),
      content: json['content'],
      fileUrl: json['fileUrl'],
      fileName: json['fileName'],
      quickReplies: json['quickReplies'] != null
          ? (json['quickReplies'] as List)
              .map((q) => QuickReply.fromJson(q))
              .toList()
          : null,
      isDelivered: json['isDelivered'] ?? false,
      isRead: json['isRead'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  /// هل من الزائر؟
  bool get isFromVisitor => senderType == ChatSenderType.visitor;
  
  /// هل من الوكيل؟
  bool get isFromAgent => senderType == ChatSenderType.agent;
}

class QuickReply {
  final String label;
  final String value;

  QuickReply({required this.label, required this.value});

  factory QuickReply.fromJson(Map<String, dynamic> json) {
    return QuickReply(
      label: json['label'],
      value: json['value'],
    );
  }
}
```

### Enums

```dart
/// حالة التذكرة
enum TicketStatus {
  open,             // مفتوحة
  awaitingResponse, // بانتظار الرد
  inProgress,       // قيد المعالجة
  onHold,           // معلقة
  escalated,        // مُصعّدة
  resolved,         // تم الحل
  closed,           // مغلقة
  reopened;         // أعيد فتحها

  static TicketStatus fromString(String value) {
    switch (value) {
      case 'open': return TicketStatus.open;
      case 'awaiting_response': return TicketStatus.awaitingResponse;
      case 'in_progress': return TicketStatus.inProgress;
      case 'on_hold': return TicketStatus.onHold;
      case 'escalated': return TicketStatus.escalated;
      case 'resolved': return TicketStatus.resolved;
      case 'closed': return TicketStatus.closed;
      case 'reopened': return TicketStatus.reopened;
      default: return TicketStatus.open;
    }
  }

  String get displayNameAr {
    switch (this) {
      case TicketStatus.open: return 'مفتوحة';
      case TicketStatus.awaitingResponse: return 'بانتظار الرد';
      case TicketStatus.inProgress: return 'قيد المعالجة';
      case TicketStatus.onHold: return 'معلقة';
      case TicketStatus.escalated: return 'مُصعّدة';
      case TicketStatus.resolved: return 'تم الحل';
      case TicketStatus.closed: return 'مغلقة';
      case TicketStatus.reopened: return 'أعيد فتحها';
    }
  }

  Color get color {
    switch (this) {
      case TicketStatus.open: return Colors.blue;
      case TicketStatus.awaitingResponse: return Colors.orange;
      case TicketStatus.inProgress: return Colors.purple;
      case TicketStatus.onHold: return Colors.grey;
      case TicketStatus.escalated: return Colors.red;
      case TicketStatus.resolved: return Colors.green;
      case TicketStatus.closed: return Colors.grey[700]!;
      case TicketStatus.reopened: return Colors.amber;
    }
  }
}

/// أولوية التذكرة
enum TicketPriority {
  low,
  medium,
  high,
  urgent;

  static TicketPriority fromString(String value) {
    return TicketPriority.values.firstWhere(
      (e) => e.name == value,
      orElse: () => TicketPriority.medium,
    );
  }

  String get displayNameAr {
    switch (this) {
      case TicketPriority.low: return 'منخفضة';
      case TicketPriority.medium: return 'متوسطة';
      case TicketPriority.high: return 'عالية';
      case TicketPriority.urgent: return 'عاجلة';
    }
  }

  Color get color {
    switch (this) {
      case TicketPriority.low: return Colors.green;
      case TicketPriority.medium: return Colors.blue;
      case TicketPriority.high: return Colors.orange;
      case TicketPriority.urgent: return Colors.red;
    }
  }
}

/// مصدر التذكرة
enum TicketSource {
  web,
  mobileApp,
  email,
  phone,
  liveChat,
  socialMedia;

  static TicketSource fromString(String value) {
    switch (value) {
      case 'web': return TicketSource.web;
      case 'mobile_app': return TicketSource.mobileApp;
      case 'email': return TicketSource.email;
      case 'phone': return TicketSource.phone;
      case 'live_chat': return TicketSource.liveChat;
      case 'social_media': return TicketSource.socialMedia;
      default: return TicketSource.mobileApp;
    }
  }
}

/// نوع الحل
enum ResolutionType {
  solved,
  wontFix,
  duplicate,
  invalid,
  customerAbandoned;

  static ResolutionType fromString(String value) {
    switch (value) {
      case 'solved': return ResolutionType.solved;
      case 'wont_fix': return ResolutionType.wontFix;
      case 'duplicate': return ResolutionType.duplicate;
      case 'invalid': return ResolutionType.invalid;
      case 'customer_abandoned': return ResolutionType.customerAbandoned;
      default: return ResolutionType.solved;
    }
  }
}

/// نوع مرسل الرسالة
enum MessageSenderType {
  customer,
  agent,
  system;

  static MessageSenderType fromString(String value) {
    return MessageSenderType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => MessageSenderType.system,
    );
  }
}

/// نوع الرسالة
enum MessageType {
  text,
  internalNote,
  statusChange,
  assignment,
  escalation,
  cannedResponse;

  static MessageType fromString(String value) {
    switch (value) {
      case 'text': return MessageType.text;
      case 'internal_note': return MessageType.internalNote;
      case 'status_change': return MessageType.statusChange;
      case 'assignment': return MessageType.assignment;
      case 'escalation': return MessageType.escalation;
      case 'canned_response': return MessageType.cannedResponse;
      default: return MessageType.text;
    }
  }
}

/// حالة جلسة المحادثة
enum ChatSessionStatus {
  waiting,
  active,
  onHold,
  ended,
  abandoned;

  static ChatSessionStatus fromString(String value) {
    return ChatSessionStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ChatSessionStatus.waiting,
    );
  }

  String get displayNameAr {
    switch (this) {
      case ChatSessionStatus.waiting: return 'في الانتظار';
      case ChatSessionStatus.active: return 'نشطة';
      case ChatSessionStatus.onHold: return 'معلقة';
      case ChatSessionStatus.ended: return 'منتهية';
      case ChatSessionStatus.abandoned: return 'مهجورة';
    }
  }
}

/// نوع مرسل رسالة المحادثة
enum ChatSenderType {
  visitor,
  agent,
  system,
  bot;

  static ChatSenderType fromString(String value) {
    return ChatSenderType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ChatSenderType.system,
    );
  }
}

/// نوع رسالة المحادثة
enum ChatMessageType {
  text,
  image,
  file,
  system,
  bot,
  quickReply;

  static ChatMessageType fromString(String value) {
    switch (value) {
      case 'text': return ChatMessageType.text;
      case 'image': return ChatMessageType.image;
      case 'file': return ChatMessageType.file;
      case 'system': return ChatMessageType.system;
      case 'bot': return ChatMessageType.bot;
      case 'quick_reply': return ChatMessageType.quickReply;
      default: return ChatMessageType.text;
    }
  }
}
```

---

## 📞 API Endpoints

### 🎫 Tickets

#### 1️⃣ جلب فئات التذاكر

**Endpoint:** `GET /tickets/categories` 🌐 (Public)

**Response:**
```dart
{
  "success": true,
  "data": [
    {
      "_id": "...",
      "nameAr": "مشاكل الطلبات",
      "nameEn": "Order Issues",
      "descriptionAr": "مشاكل متعلقة بالطلبات والتوصيل",
      "icon": "shopping_cart",
      "sortOrder": 1,
      "isActive": true,
      "requiresOrderId": true
    },
    {
      "_id": "...",
      "nameAr": "الدفع والفواتير",
      "nameEn": "Payment & Billing",
      "icon": "credit_card",
      "sortOrder": 2,
      "isActive": true
    },
    {
      "_id": "...",
      "nameAr": "استفسارات عامة",
      "nameEn": "General Inquiries",
      "icon": "help",
      "sortOrder": 3,
      "isActive": true
    }
  ],
  "message": "Categories retrieved",
  "messageAr": "تم استرجاع الفئات"
}
```

**Flutter Code:**
```dart
class SupportService {
  final Dio _dio;
  
  SupportService(this._dio);
  
  /// جلب فئات التذاكر
  Future<List<TicketCategory>> getCategories() async {
    final response = await _dio.get('/tickets/categories');
    
    if (response.data['success']) {
      return (response.data['data'] as List)
          .map((c) => TicketCategory.fromJson(c))
          .toList();
    }
    throw Exception(response.data['messageAr']);
  }
}
```

---

#### 2️⃣ جلب تذاكري

**Endpoint:** `GET /tickets/my`

**Headers:** `Authorization: Bearer <accessToken>` 🔒

**Query Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `page` | number | ❌ | رقم الصفحة |
| `limit` | number | ❌ | عدد النتائج |
| `status` | string | ❌ | فلترة بالحالة |

**Response:**
```dart
{
  "success": true,
  "data": [
    {
      "_id": "...",
      "ticketNumber": "TKT-2024-001234",
      "category": {
        "_id": "...",
        "nameAr": "مشاكل الطلبات",
        "nameEn": "Order Issues"
      },
      "subject": "لم يصل طلبي",
      "description": "طلبت منذ أسبوع ولم يصل حتى الآن",
      "status": "in_progress",
      "priority": "high",
      "source": "mobile_app",
      "messageCount": 5,
      "lastAgentReplyAt": "2024-01-16T14:30:00Z",
      "createdAt": "2024-01-15T10:00:00Z",
      ...
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 10,
    "total": 3
  },
  "message": "Tickets retrieved",
  "messageAr": "تم استرجاع التذاكر"
}
```

**Flutter Code:**
```dart
/// جلب تذاكري
Future<List<Ticket>> getMyTickets({
  int page = 1,
  int limit = 10,
  TicketStatus? status,
}) async {
  final response = await _dio.get('/tickets/my', queryParameters: {
    'page': page,
    'limit': limit,
    if (status != null) 'status': status.name,
  });
  
  if (response.data['success']) {
    return (response.data['data'] as List)
        .map((t) => Ticket.fromJson(t))
        .toList();
  }
  throw Exception(response.data['messageAr']);
}
```

---

#### 3️⃣ إنشاء تذكرة جديدة

**Endpoint:** `POST /tickets`

**Headers:** `Authorization: Bearer <accessToken>` 🔒

**Request Body:**
```dart
{
  "category": "category_id",
  "subject": "موضوع التذكرة",
  "description": "وصف المشكلة بالتفصيل...",
  "priority": "medium",  // اختياري (low, medium, high, urgent)
  "orderId": "order_id",  // اختياري
  "productId": "product_id",  // اختياري
  "attachments": ["url1", "url2"]  // اختياري
}
```

**Response:**
```dart
{
  "success": true,
  "data": {
    "_id": "...",
    "ticketNumber": "TKT-2024-001235",
    "status": "open",
    "priority": "medium",
    "createdAt": "2024-01-16T15:00:00Z",
    ...
  },
  "message": "Ticket created successfully",
  "messageAr": "تم إنشاء التذكرة بنجاح"
}
```

**Flutter Code:**
```dart
/// إنشاء تذكرة جديدة
Future<Ticket> createTicket({
  required String categoryId,
  required String subject,
  required String description,
  TicketPriority? priority,
  String? orderId,
  String? productId,
  List<String>? attachments,
}) async {
  final response = await _dio.post('/tickets', data: {
    'category': categoryId,
    'subject': subject,
    'description': description,
    if (priority != null) 'priority': priority.name,
    if (orderId != null) 'orderId': orderId,
    if (productId != null) 'productId': productId,
    if (attachments != null) 'attachments': attachments,
  });
  
  if (response.data['success']) {
    return Ticket.fromJson(response.data['data']);
  }
  throw Exception(response.data['messageAr']);
}
```

---

#### 4️⃣ جلب تفاصيل تذكرتي

**Endpoint:** `GET /tickets/my/:id`

**Headers:** `Authorization: Bearer <accessToken>` 🔒

**Response:**
```dart
{
  "success": true,
  "data": {
    "_id": "...",
    "ticketNumber": "TKT-2024-001234",
    "customer": {
      "customerId": "...",
      "name": "أحمد محمد",
      "email": "ahmed@example.com"
    },
    "category": {
      "_id": "...",
      "nameAr": "مشاكل الطلبات"
    },
    "subject": "لم يصل طلبي",
    "description": "طلبت منذ أسبوع...",
    "status": "in_progress",
    "priority": "high",
    "orderId": {
      "_id": "...",
      "orderNumber": "ORD-2024-001234"
    },
    "messageCount": 5,
    "sla": {
      "firstResponseDue": "2024-01-15T22:00:00Z",
      "firstRespondedAt": "2024-01-15T14:00:00Z",
      "firstResponseBreached": false
    },
    "messages": [
      {
        "_id": "...",
        "senderType": "customer",
        "senderName": "أحمد محمد",
        "content": "طلبت منذ أسبوع ولم يصل حتى الآن",
        "createdAt": "2024-01-15T10:00:00Z"
      },
      {
        "_id": "...",
        "senderType": "agent",
        "senderName": "محمد - فريق الدعم",
        "content": "شكراً لتواصلك، سنتحقق من حالة طلبك",
        "createdAt": "2024-01-15T14:00:00Z"
      }
    ],
    "createdAt": "2024-01-15T10:00:00Z",
    ...
  },
  "message": "Ticket retrieved",
  "messageAr": "تم استرجاع التذكرة"
}
```

**Flutter Code:**
```dart
/// جلب تفاصيل تذكرة مع الرسائل
Future<Ticket> getMyTicketById(String ticketId) async {
  final response = await _dio.get('/tickets/my/$ticketId');
  
  if (response.data['success']) {
    return Ticket.fromJson(response.data['data']);
  }
  throw Exception(response.data['messageAr']);
}
```

---

#### 5️⃣ إضافة رسالة لتذكرتي

**Endpoint:** `POST /tickets/my/:id/messages`

**Headers:** `Authorization: Bearer <accessToken>` 🔒

**Request Body:**
```dart
{
  "content": "نص الرسالة",
  "attachments": ["url1"]  // اختياري
}
```

**Response:**
```dart
{
  "success": true,
  "data": {
    "_id": "...",
    "senderType": "customer",
    "senderName": "أحمد محمد",
    "content": "نص الرسالة",
    "attachments": [],
    "createdAt": "2024-01-16T16:00:00Z"
  },
  "message": "Message sent",
  "messageAr": "تم إرسال الرسالة"
}
```

**Flutter Code:**
```dart
/// إضافة رسالة لتذكرة
Future<TicketMessage> addMessageToTicket({
  required String ticketId,
  required String content,
  List<String>? attachments,
}) async {
  final response = await _dio.post('/tickets/my/$ticketId/messages', data: {
    'content': content,
    if (attachments != null) 'attachments': attachments,
  });
  
  if (response.data['success']) {
    return TicketMessage.fromJson(response.data['data']);
  }
  throw Exception(response.data['messageAr']);
}
```

---

#### 6️⃣ تقييم التذكرة

**Endpoint:** `POST /tickets/my/:id/rate`

**Headers:** `Authorization: Bearer <accessToken>` 🔒

**Request Body:**
```dart
{
  "rating": 5,  // من 1 إلى 5
  "feedback": "خدمة ممتازة!"  // اختياري
}
```

**Response:**
```dart
{
  "success": true,
  "message": "Thank you for your feedback",
  "messageAr": "شكراً لتقييمك"
}
```

**Flutter Code:**
```dart
/// تقييم التذكرة
Future<void> rateTicket({
  required String ticketId,
  required int rating,
  String? feedback,
}) async {
  final response = await _dio.post('/tickets/my/$ticketId/rate', data: {
    'rating': rating,
    if (feedback != null) 'feedback': feedback,
  });
  
  if (!response.data['success']) {
    throw Exception(response.data['messageAr']);
  }
}
```

---

### 💬 Live Chat

#### 7️⃣ بدء محادثة جديدة

**Endpoint:** `POST /chat/start`

**Headers:** `Authorization: Bearer <accessToken>` 🔒

**Request Body:**
```dart
{
  "initialMessage": "مرحباً، أحتاج مساعدة",  // اختياري
  "department": "support",  // اختياري: general, sales, support, billing
  "categoryId": "category_id"  // اختياري
}
```

**Response:**
```dart
{
  "success": true,
  "data": {
    "_id": "...",
    "sessionId": "CHAT-2024-001234",
    "status": "waiting",
    "queuePosition": 3,
    "visitor": {
      "customerId": "...",
      "name": "أحمد محمد",
      "email": "ahmed@example.com"
    },
    "initialMessage": "مرحباً، أحتاج مساعدة",
    "createdAt": "2024-01-16T16:00:00Z"
  },
  "message": "Chat session started",
  "messageAr": "تم بدء المحادثة"
}
```

**Flutter Code:**
```dart
/// بدء محادثة جديدة
Future<ChatSession> startChat({
  String? initialMessage,
  String? department,
  String? categoryId,
}) async {
  final response = await _dio.post('/chat/start', data: {
    if (initialMessage != null) 'initialMessage': initialMessage,
    if (department != null) 'department': department,
    if (categoryId != null) 'categoryId': categoryId,
  });
  
  if (response.data['success']) {
    return ChatSession.fromJson(response.data['data']);
  }
  throw Exception(response.data['messageAr']);
}
```

---

#### 8️⃣ جلب جلستي النشطة

**Endpoint:** `GET /chat/my-session`

**Headers:** `Authorization: Bearer <accessToken>` 🔒

**Response:**
```dart
{
  "success": true,
  "data": {
    "_id": "...",
    "sessionId": "CHAT-2024-001234",
    "status": "active",
    "queuePosition": 0,
    "assignedAgent": {
      "_id": "...",
      "name": "محمد"
    },
    "startedAt": "2024-01-16T16:05:00Z",
    "metrics": {
      "waitTime": 300,
      "messageCount": 10
    },
    "messages": [
      {
        "_id": "...",
        "senderType": "visitor",
        "content": "مرحباً",
        "createdAt": "2024-01-16T16:00:00Z"
      },
      {
        "_id": "...",
        "senderType": "agent",
        "senderName": "محمد",
        "content": "أهلاً بك، كيف يمكنني مساعدتك؟",
        "createdAt": "2024-01-16T16:05:00Z"
      }
    ]
  },
  "message": "Session retrieved",
  "messageAr": "تم استرجاع الجلسة"
}
```

**Flutter Code:**
```dart
/// جلب الجلسة النشطة
Future<ChatSession?> getMySession() async {
  final response = await _dio.get('/chat/my-session');
  
  if (response.data['success']) {
    if (response.data['data'] == null) return null;
    return ChatSession.fromJson(response.data['data']);
  }
  throw Exception(response.data['messageAr']);
}
```

---

#### 9️⃣ إرسال رسالة في المحادثة

**Endpoint:** `POST /chat/my-session/messages`

**Headers:** `Authorization: Bearer <accessToken>` 🔒

**Request Body:**
```dart
{
  "content": "نص الرسالة",
  "messageType": "text"  // text, image, file
}
```

**Response:**
```dart
{
  "success": true,
  "data": {
    "_id": "...",
    "senderType": "visitor",
    "content": "نص الرسالة",
    "messageType": "text",
    "createdAt": "2024-01-16T16:10:00Z"
  },
  "message": "Message sent",
  "messageAr": "تم إرسال الرسالة"
}
```

**Flutter Code:**
```dart
/// إرسال رسالة في المحادثة
Future<ChatMessage> sendChatMessage({
  required String content,
  ChatMessageType messageType = ChatMessageType.text,
}) async {
  final response = await _dio.post('/chat/my-session/messages', data: {
    'content': content,
    'messageType': messageType.name,
  });
  
  if (response.data['success']) {
    return ChatMessage.fromJson(response.data['data']);
  }
  throw Exception(response.data['messageAr']);
}
```

---

#### 🔟 إنهاء المحادثة

**Endpoint:** `POST /chat/my-session/end`

**Headers:** `Authorization: Bearer <accessToken>` 🔒

**Request Body:**
```dart
{
  "rating": 5,  // اختياري: من 1 إلى 5
  "feedback": "خدمة رائعة!"  // اختياري
}
```

**Response:**
```dart
{
  "success": true,
  "message": "Chat ended",
  "messageAr": "تم إنهاء المحادثة"
}
```

**Flutter Code:**
```dart
/// إنهاء المحادثة
Future<void> endChat({int? rating, String? feedback}) async {
  final response = await _dio.post('/chat/my-session/end', data: {
    if (rating != null) 'rating': rating,
    if (feedback != null) 'feedback': feedback,
  });
  
  if (!response.data['success']) {
    throw Exception(response.data['messageAr']);
  }
}
```

---

## 🧩 SupportService الكامل

```dart
import 'package:dio/dio.dart';

class SupportService {
  final Dio _dio;
  
  SupportService(this._dio);
  
  // ═════════════════════════════════════
  // Ticket Categories (Public)
  // ═════════════════════════════════════
  
  Future<List<TicketCategory>> getCategories() async {
    final response = await _dio.get('/tickets/categories');
    
    if (response.data['success']) {
      return (response.data['data'] as List)
          .map((c) => TicketCategory.fromJson(c))
          .toList();
    }
    throw Exception(response.data['messageAr']);
  }
  
  // ═════════════════════════════════════
  // My Tickets
  // ═════════════════════════════════════
  
  Future<List<Ticket>> getMyTickets({
    int page = 1,
    int limit = 10,
    TicketStatus? status,
  }) async {
    final response = await _dio.get('/tickets/my', queryParameters: {
      'page': page,
      'limit': limit,
      if (status != null) 'status': status.name,
    });
    
    if (response.data['success']) {
      return (response.data['data'] as List)
          .map((t) => Ticket.fromJson(t))
          .toList();
    }
    throw Exception(response.data['messageAr']);
  }
  
  Future<Ticket> createTicket({
    required String categoryId,
    required String subject,
    required String description,
    TicketPriority? priority,
    String? orderId,
    String? productId,
    List<String>? attachments,
  }) async {
    final response = await _dio.post('/tickets', data: {
      'category': categoryId,
      'subject': subject,
      'description': description,
      if (priority != null) 'priority': priority.name,
      if (orderId != null) 'orderId': orderId,
      if (productId != null) 'productId': productId,
      if (attachments != null) 'attachments': attachments,
    });
    
    if (response.data['success']) {
      return Ticket.fromJson(response.data['data']);
    }
    throw Exception(response.data['messageAr']);
  }
  
  Future<Ticket> getMyTicketById(String ticketId) async {
    final response = await _dio.get('/tickets/my/$ticketId');
    
    if (response.data['success']) {
      return Ticket.fromJson(response.data['data']);
    }
    throw Exception(response.data['messageAr']);
  }
  
  Future<TicketMessage> addMessageToTicket({
    required String ticketId,
    required String content,
    List<String>? attachments,
  }) async {
    final response = await _dio.post('/tickets/my/$ticketId/messages', data: {
      'content': content,
      if (attachments != null) 'attachments': attachments,
    });
    
    if (response.data['success']) {
      return TicketMessage.fromJson(response.data['data']);
    }
    throw Exception(response.data['messageAr']);
  }
  
  Future<void> rateTicket({
    required String ticketId,
    required int rating,
    String? feedback,
  }) async {
    final response = await _dio.post('/tickets/my/$ticketId/rate', data: {
      'rating': rating,
      if (feedback != null) 'feedback': feedback,
    });
    
    if (!response.data['success']) {
      throw Exception(response.data['messageAr']);
    }
  }
  
  // ═════════════════════════════════════
  // Live Chat
  // ═════════════════════════════════════
  
  Future<ChatSession> startChat({
    String? initialMessage,
    String? department,
    String? categoryId,
  }) async {
    final response = await _dio.post('/chat/start', data: {
      if (initialMessage != null) 'initialMessage': initialMessage,
      if (department != null) 'department': department,
      if (categoryId != null) 'categoryId': categoryId,
    });
    
    if (response.data['success']) {
      return ChatSession.fromJson(response.data['data']);
    }
    throw Exception(response.data['messageAr']);
  }
  
  Future<ChatSession?> getMySession() async {
    final response = await _dio.get('/chat/my-session');
    
    if (response.data['success']) {
      if (response.data['data'] == null) return null;
      return ChatSession.fromJson(response.data['data']);
    }
    throw Exception(response.data['messageAr']);
  }
  
  Future<ChatMessage> sendChatMessage({
    required String content,
    ChatMessageType messageType = ChatMessageType.text,
  }) async {
    final response = await _dio.post('/chat/my-session/messages', data: {
      'content': content,
      'messageType': messageType.name,
    });
    
    if (response.data['success']) {
      return ChatMessage.fromJson(response.data['data']);
    }
    throw Exception(response.data['messageAr']);
  }
  
  Future<void> endChat({int? rating, String? feedback}) async {
    final response = await _dio.post('/chat/my-session/end', data: {
      if (rating != null) 'rating': rating,
      if (feedback != null) 'feedback': feedback,
    });
    
    if (!response.data['success']) {
      throw Exception(response.data['messageAr']);
    }
  }
}
```

---

## 🎯 أمثلة الاستخدام

### شاشة إنشاء تذكرة

```dart
class CreateTicketScreen extends StatefulWidget {
  @override
  State<CreateTicketScreen> createState() => _CreateTicketScreenState();
}

class _CreateTicketScreenState extends State<CreateTicketScreen> {
  final subjectController = TextEditingController();
  final descriptionController = TextEditingController();
  TicketCategory? selectedCategory;
  List<TicketCategory> categories = [];
  List<String> attachments = [];
  bool isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _loadCategories();
  }
  
  Future<void> _loadCategories() async {
    categories = await supportService.getCategories();
    setState(() {});
  }
  
  Future<void> _submitTicket() async {
    if (selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('اختر فئة التذكرة')),
      );
      return;
    }
    
    if (subjectController.text.isEmpty || descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('أدخل الموضوع والوصف')),
      );
      return;
    }
    
    setState(() => isLoading = true);
    
    try {
      final ticket = await supportService.createTicket(
        categoryId: selectedCategory!.id,
        subject: subjectController.text,
        description: descriptionController.text,
        attachments: attachments.isNotEmpty ? attachments : null,
      );
      
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => TicketDetailScreen(ticketId: ticket.id),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('تذكرة جديدة')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // اختيار الفئة
            Text('الفئة', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: categories.map((cat) {
                final isSelected = selectedCategory?.id == cat.id;
                return ChoiceChip(
                  avatar: cat.icon != null 
                      ? Icon(IconData(int.parse(cat.icon!))) 
                      : null,
                  label: Text(cat.getName('ar')),
                  selected: isSelected,
                  onSelected: (_) => setState(() => selectedCategory = cat),
                );
              }).toList(),
            ),
            
            SizedBox(height: 16),
            
            // الموضوع
            TextField(
              controller: subjectController,
              decoration: InputDecoration(
                labelText: 'الموضوع',
                border: OutlineInputBorder(),
              ),
            ),
            
            SizedBox(height: 16),
            
            // الوصف
            TextField(
              controller: descriptionController,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: 'وصف المشكلة',
                border: OutlineInputBorder(),
                hintText: 'اشرح مشكلتك بالتفصيل...',
              ),
            ),
            
            SizedBox(height: 16),
            
            // المرفقات
            Text('المرفقات (اختياري)', 
                style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            AttachmentPicker(
              attachments: attachments,
              onChanged: (files) => setState(() => attachments = files),
            ),
            
            SizedBox(height: 24),
            
            // زر الإرسال
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : _submitTicket,
                child: isLoading 
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('إرسال التذكرة'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

### شاشة المحادثة المباشرة

```dart
class LiveChatScreen extends StatefulWidget {
  @override
  State<LiveChatScreen> createState() => _LiveChatScreenState();
}

class _LiveChatScreenState extends State<LiveChatScreen> {
  final messageController = TextEditingController();
  final scrollController = ScrollController();
  ChatSession? session;
  List<ChatMessage> messages = [];
  bool isLoading = true;
  bool isSending = false;
  
  @override
  void initState() {
    super.initState();
    _initChat();
  }
  
  Future<void> _initChat() async {
    try {
      // تحقق من وجود جلسة نشطة
      session = await supportService.getMySession();
      
      // إذا لم توجد، ابدأ جلسة جديدة
      if (session == null) {
        session = await supportService.startChat();
      }
      
      setState(() => isLoading = false);
      
      // TODO: اتصل بـ WebSocket لاستلام الرسائل الجديدة
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }
  
  Future<void> _sendMessage() async {
    if (messageController.text.isEmpty) return;
    
    final content = messageController.text;
    messageController.clear();
    
    setState(() => isSending = true);
    
    try {
      final message = await supportService.sendChatMessage(content: content);
      setState(() {
        messages.add(message);
      });
      
      _scrollToBottom();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      setState(() => isSending = false);
    }
  }
  
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
  
  Future<void> _endChat() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('إنهاء المحادثة'),
        content: Text('هل تريد إنهاء المحادثة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('إنهاء'),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      // عرض نافذة التقييم
      final rating = await _showRatingDialog();
      await supportService.endChat(rating: rating);
      Navigator.pop(context);
    }
  }
  
  Future<int?> _showRatingDialog() async {
    int selectedRating = 5;
    
    return showDialog<int>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text('قيم المحادثة'),
            content: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < selectedRating 
                        ? Icons.star 
                        : Icons.star_border,
                    color: Colors.amber,
                    size: 32,
                  ),
                  onPressed: () {
                    setDialogState(() => selectedRating = index + 1);
                  },
                );
              }),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('تخطي'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, selectedRating),
                child: Text('إرسال'),
              ),
            ],
          );
        },
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('المحادثة المباشرة')),
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('المحادثة المباشرة'),
            if (session?.isWaiting == true)
              Text(
                'في الانتظار... الموقع: ${session!.queuePosition}',
                style: TextStyle(fontSize: 12),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.close),
            onPressed: _endChat,
          ),
        ],
      ),
      body: Column(
        children: [
          // رسالة الانتظار
          if (session?.isWaiting == true)
            Container(
              padding: EdgeInsets.all(16),
              color: Colors.blue[50],
              child: Row(
                children: [
                  CircularProgressIndicator(strokeWidth: 2),
                  SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'جاري توصيلك بأحد ممثلي الدعم...',
                      style: TextStyle(color: Colors.blue[800]),
                    ),
                  ),
                ],
              ),
            ),
          
          // الرسائل
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              padding: EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return _buildMessageBubble(message);
              },
            ),
          ),
          
          // حقل الإدخال
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: InputDecoration(
                      hintText: 'اكتب رسالتك...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor,
                  child: IconButton(
                    icon: isSending 
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Icon(Icons.send, color: Colors.white),
                    onPressed: isSending ? null : _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMessageBubble(ChatMessage message) {
    final isMe = message.isFromVisitor;
    
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          bottom: 8,
          left: isMe ? 50 : 0,
          right: isMe ? 0 : 50,
        ),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe ? Theme.of(context).primaryColor : Colors.grey[200],
          borderRadius: BorderRadius.circular(16).copyWith(
            bottomRight: isMe ? Radius.zero : null,
            bottomLeft: isMe ? null : Radius.zero,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isMe && message.senderName != null)
              Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Text(
                  message.senderName!,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            Text(
              message.content,
              style: TextStyle(
                color: isMe ? Colors.white : Colors.black87,
              ),
            ),
            SizedBox(height: 4),
            Text(
              _formatTime(message.createdAt),
              style: TextStyle(
                fontSize: 10,
                color: isMe ? Colors.white70 : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
```

---

## ⚠️ الأخطاء المحتملة

| Error Code | Message | الوصف |
|------------|---------|-------|
| `TICKET_NOT_FOUND` | Ticket not found | التذكرة غير موجودة |
| `TICKET_CLOSED` | Ticket is closed | التذكرة مغلقة |
| `CATEGORY_NOT_FOUND` | Category not found | الفئة غير موجودة |
| `ORDER_REQUIRED` | Order ID is required | معرف الطلب مطلوب |
| `CHAT_SESSION_NOT_FOUND` | No active chat session | لا توجد جلسة محادثة نشطة |
| `CHAT_SESSION_ENDED` | Chat session has ended | انتهت جلسة المحادثة |
| `ALREADY_RATED` | Already rated | تم التقييم مسبقاً |

---

## 📝 ملخص الـ Endpoints

### Tickets

| Method | Endpoint | Auth | الوصف |
|--------|----------|------|-------|
| GET | `/tickets/categories` | ❌ | فئات التذاكر (Public) |
| GET | `/tickets/my` | ✅ | تذاكري |
| POST | `/tickets` | ✅ | إنشاء تذكرة جديدة |
| GET | `/tickets/my/:id` | ✅ | تفاصيل تذكرتي |
| POST | `/tickets/my/:id/messages` | ✅ | إضافة رسالة لتذكرتي |
| POST | `/tickets/my/:id/rate` | ✅ | تقييم التذكرة |

### Live Chat

| Method | Endpoint | Auth | الوصف |
|--------|----------|------|-------|
| POST | `/chat/start` | ✅ | بدء محادثة |
| GET | `/chat/my-session` | ✅ | جلستي النشطة |
| POST | `/chat/my-session/messages` | ✅ | إرسال رسالة |
| POST | `/chat/my-session/end` | ✅ | إنهاء المحادثة |

---

> 🔗 **السابق:** [promotions.md](./promotions.md) - دليل العروض والكوبونات  
> 🔗 **الصفحة الرئيسية:** [README.md](./README.md)
