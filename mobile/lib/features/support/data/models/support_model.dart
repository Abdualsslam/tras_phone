/// Support Models - Data layer models with JSON serialization
library;

import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'support_model.g.dart';

// ═══════════════════════════════════════════════════════════════════════════
// ENUMS
// ═══════════════════════════════════════════════════════════════════════════

/// حالة التذكرة
enum TicketStatus {
  open,
  awaitingResponse,
  inProgress,
  onHold,
  escalated,
  resolved,
  closed,
  reopened;

  static TicketStatus fromString(String value) {
    switch (value) {
      case 'open':
        return TicketStatus.open;
      case 'awaiting_response':
        return TicketStatus.awaitingResponse;
      case 'in_progress':
        return TicketStatus.inProgress;
      case 'on_hold':
        return TicketStatus.onHold;
      case 'escalated':
        return TicketStatus.escalated;
      case 'resolved':
        return TicketStatus.resolved;
      case 'closed':
        return TicketStatus.closed;
      case 'reopened':
        return TicketStatus.reopened;
      default:
        return TicketStatus.open;
    }
  }

  String get apiValue {
    switch (this) {
      case TicketStatus.awaitingResponse:
        return 'awaiting_response';
      case TicketStatus.inProgress:
        return 'in_progress';
      case TicketStatus.onHold:
        return 'on_hold';
      default:
        return name;
    }
  }

  String get displayNameAr {
    switch (this) {
      case TicketStatus.open:
        return 'مفتوحة';
      case TicketStatus.awaitingResponse:
        return 'بانتظار الرد';
      case TicketStatus.inProgress:
        return 'قيد المعالجة';
      case TicketStatus.onHold:
        return 'معلقة';
      case TicketStatus.escalated:
        return 'مُصعّدة';
      case TicketStatus.resolved:
        return 'تم الحل';
      case TicketStatus.closed:
        return 'مغلقة';
      case TicketStatus.reopened:
        return 'أعيد فتحها';
    }
  }

  Color get color {
    switch (this) {
      case TicketStatus.open:
        return Colors.blue;
      case TicketStatus.awaitingResponse:
        return Colors.orange;
      case TicketStatus.inProgress:
        return Colors.purple;
      case TicketStatus.onHold:
        return Colors.grey;
      case TicketStatus.escalated:
        return Colors.red;
      case TicketStatus.resolved:
        return Colors.green;
      case TicketStatus.closed:
        return Colors.grey.shade700;
      case TicketStatus.reopened:
        return Colors.amber;
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
      case TicketPriority.low:
        return 'منخفضة';
      case TicketPriority.medium:
        return 'متوسطة';
      case TicketPriority.high:
        return 'عالية';
      case TicketPriority.urgent:
        return 'عاجلة';
    }
  }

  Color get color {
    switch (this) {
      case TicketPriority.low:
        return Colors.green;
      case TicketPriority.medium:
        return Colors.blue;
      case TicketPriority.high:
        return Colors.orange;
      case TicketPriority.urgent:
        return Colors.red;
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
      case 'web':
        return TicketSource.web;
      case 'mobile_app':
        return TicketSource.mobileApp;
      case 'email':
        return TicketSource.email;
      case 'phone':
        return TicketSource.phone;
      case 'live_chat':
        return TicketSource.liveChat;
      case 'social_media':
        return TicketSource.socialMedia;
      default:
        return TicketSource.mobileApp;
    }
  }

  String get apiValue {
    switch (this) {
      case TicketSource.mobileApp:
        return 'mobile_app';
      case TicketSource.liveChat:
        return 'live_chat';
      case TicketSource.socialMedia:
        return 'social_media';
      default:
        return name;
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
      case 'solved':
        return ResolutionType.solved;
      case 'wont_fix':
        return ResolutionType.wontFix;
      case 'duplicate':
        return ResolutionType.duplicate;
      case 'invalid':
        return ResolutionType.invalid;
      case 'customer_abandoned':
        return ResolutionType.customerAbandoned;
      default:
        return ResolutionType.solved;
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
      case 'text':
        return MessageType.text;
      case 'internal_note':
        return MessageType.internalNote;
      case 'status_change':
        return MessageType.statusChange;
      case 'assignment':
        return MessageType.assignment;
      case 'escalation':
        return MessageType.escalation;
      case 'canned_response':
        return MessageType.cannedResponse;
      default:
        return MessageType.text;
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
      case ChatSessionStatus.waiting:
        return 'في الانتظار';
      case ChatSessionStatus.active:
        return 'نشطة';
      case ChatSessionStatus.onHold:
        return 'معلقة';
      case ChatSessionStatus.ended:
        return 'منتهية';
      case ChatSessionStatus.abandoned:
        return 'مهجورة';
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
      case 'text':
        return ChatMessageType.text;
      case 'image':
        return ChatMessageType.image;
      case 'file':
        return ChatMessageType.file;
      case 'system':
        return ChatMessageType.system;
      case 'bot':
        return ChatMessageType.bot;
      case 'quick_reply':
        return ChatMessageType.quickReply;
      default:
        return ChatMessageType.text;
    }
  }

  String get apiValue {
    switch (this) {
      case ChatMessageType.quickReply:
        return 'quick_reply';
      default:
        return name;
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// TICKET MODELS
// ═══════════════════════════════════════════════════════════════════════════

/// معلومات العميل في التذكرة
@JsonSerializable()
class TicketCustomerInfo {
  final String? customerId;
  final String name;
  final String email;
  final String? phone;

  const TicketCustomerInfo({
    this.customerId,
    required this.name,
    required this.email,
    this.phone,
  });

  factory TicketCustomerInfo.fromJson(Map<String, dynamic> json) =>
      _$TicketCustomerInfoFromJson(json);
  Map<String, dynamic> toJson() => _$TicketCustomerInfoToJson(this);
}

/// SLA التذكرة
@JsonSerializable()
class TicketSLA {
  final DateTime? firstResponseDue;
  final DateTime? resolutionDue;
  final DateTime? firstRespondedAt;
  final DateTime? resolvedAt;
  final bool firstResponseBreached;
  final bool resolutionBreached;

  const TicketSLA({
    this.firstResponseDue,
    this.resolutionDue,
    this.firstRespondedAt,
    this.resolvedAt,
    this.firstResponseBreached = false,
    this.resolutionBreached = false,
  });

  factory TicketSLA.fromJson(Map<String, dynamic> json) =>
      _$TicketSLAFromJson(json);
  Map<String, dynamic> toJson() => _$TicketSLAToJson(this);
}

/// حل التذكرة
@JsonSerializable()
class TicketResolution {
  final String? summary;
  @JsonKey(fromJson: _resolutionTypeFromJson)
  final ResolutionType? type;
  final String? resolvedBy;
  final DateTime? resolvedAt;

  const TicketResolution({
    this.summary,
    this.type,
    this.resolvedBy,
    this.resolvedAt,
  });

  factory TicketResolution.fromJson(Map<String, dynamic> json) =>
      _$TicketResolutionFromJson(json);
  Map<String, dynamic> toJson() => _$TicketResolutionToJson(this);

  static ResolutionType? _resolutionTypeFromJson(String? value) =>
      value != null ? ResolutionType.fromString(value) : null;
}

/// فئة التذكرة
@JsonSerializable()
class TicketCategoryModel {
  @JsonKey(name: '_id', readValue: _readId)
  final String id;
  final String nameAr;
  final String nameEn;
  final String? descriptionAr;
  final String? descriptionEn;
  final String? icon;
  @JsonKey(name: 'parent')
  final String? parentId;
  final int sortOrder;
  final bool isActive;
  final bool requiresOrderId;
  final bool requiresProductId;

  const TicketCategoryModel({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    this.descriptionAr,
    this.descriptionEn,
    this.icon,
    this.parentId,
    this.sortOrder = 0,
    this.isActive = true,
    this.requiresOrderId = false,
    this.requiresProductId = false,
  });

  factory TicketCategoryModel.fromJson(Map<String, dynamic> json) =>
      _$TicketCategoryModelFromJson(json);
  Map<String, dynamic> toJson() => _$TicketCategoryModelToJson(this);

  String getName(String locale) => locale == 'ar' ? nameAr : nameEn;
  String? getDescription(String locale) =>
      locale == 'ar' ? descriptionAr : descriptionEn;
}

/// التذكرة
@JsonSerializable()
class TicketModel {
  @JsonKey(name: '_id', readValue: _readId)
  final String id;
  final String ticketNumber;
  final TicketCustomerInfo customer;
  @JsonKey(includeFromJson: false, includeToJson: false)
  final String? categoryId;
  @JsonKey(name: 'category')
  final TicketCategoryModel? category;
  final String subject;
  final String description;
  @JsonKey(fromJson: _statusFromJson)
  final TicketStatus status;
  @JsonKey(fromJson: _priorityFromJson)
  final TicketPriority priority;
  @JsonKey(fromJson: _sourceFromJson)
  final TicketSource source;
  final String? assignedTo;
  final String? orderId;
  final String? productId;
  @JsonKey(defaultValue: [])
  final List<String> attachments;
  @JsonKey(defaultValue: [])
  final List<String> tags;
  final TicketSLA sla;
  final TicketResolution? resolution;
  @JsonKey(defaultValue: 0)
  final int messageCount;
  final DateTime? lastCustomerReplyAt;
  final DateTime? lastAgentReplyAt;
  final int? satisfactionRating;
  final String? satisfactionFeedback;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TicketModel({
    required this.id,
    required this.ticketNumber,
    required this.customer,
    this.categoryId,
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

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    final model = _$TicketModelFromJson(json);
    // Extract categoryId from category field
    final category = json['category'];
    String catId = '';
    if (category is String) {
      catId = category;
    } else if (category is Map) {
      catId = category['_id']?.toString() ?? category['id']?.toString() ?? '';
    }
    return TicketModel(
      id: model.id,
      ticketNumber: model.ticketNumber,
      customer: model.customer,
      categoryId: catId,
      category: model.category,
      subject: model.subject,
      description: model.description,
      status: model.status,
      priority: model.priority,
      source: model.source,
      assignedTo: model.assignedTo,
      orderId: model.orderId,
      productId: model.productId,
      attachments: model.attachments,
      tags: model.tags,
      sla: model.sla,
      resolution: model.resolution,
      messageCount: model.messageCount,
      lastCustomerReplyAt: model.lastCustomerReplyAt,
      lastAgentReplyAt: model.lastAgentReplyAt,
      satisfactionRating: model.satisfactionRating,
      satisfactionFeedback: model.satisfactionFeedback,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );
  }
  Map<String, dynamic> toJson() => _$TicketModelToJson(this);

  /// هل التذكرة مفتوحة؟
  bool get isOpen => ![
        TicketStatus.closed,
        TicketStatus.resolved,
      ].contains(status);

  /// هل يمكن التقييم؟
  bool get canRate =>
      status == TicketStatus.resolved && satisfactionRating == null;

  /// هل تم تجاوز SLA؟
  bool get isSlaBreached => sla.firstResponseBreached || sla.resolutionBreached;

  static TicketStatus _statusFromJson(String value) =>
      TicketStatus.fromString(value);
  static TicketPriority _priorityFromJson(String value) =>
      TicketPriority.fromString(value);
  static TicketSource _sourceFromJson(String value) =>
      TicketSource.fromString(value);
}

/// رسالة التذكرة
@JsonSerializable()
class TicketMessageModel {
  @JsonKey(name: '_id', readValue: _readId)
  final String id;
  @JsonKey(name: 'ticket', readValue: _readTicketId)
  final String ticketId;
  @JsonKey(fromJson: _senderTypeFromJson)
  final MessageSenderType senderType;
  final String? senderId;
  @JsonKey(defaultValue: '')
  final String senderName;
  @JsonKey(fromJson: _messageTypeFromJson)
  final MessageType messageType;
  final String content;
  final String? htmlContent;
  @JsonKey(defaultValue: [])
  final List<String> attachments;
  @JsonKey(defaultValue: false)
  final bool isInternal;
  @JsonKey(defaultValue: false)
  final bool isRead;
  final DateTime? readAt;
  final DateTime createdAt;

  const TicketMessageModel({
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

  factory TicketMessageModel.fromJson(Map<String, dynamic> json) =>
      _$TicketMessageModelFromJson(json);
  Map<String, dynamic> toJson() => _$TicketMessageModelToJson(this);

  /// هل الرسالة من العميل؟
  bool get isFromCustomer => senderType == MessageSenderType.customer;

  /// هل الرسالة من الدعم؟
  bool get isFromAgent => senderType == MessageSenderType.agent;

  static MessageSenderType _senderTypeFromJson(String value) =>
      MessageSenderType.fromString(value);
  static MessageType _messageTypeFromJson(String value) =>
      MessageType.fromString(value);
}

// ═══════════════════════════════════════════════════════════════════════════
// CHAT MODELS
// ═══════════════════════════════════════════════════════════════════════════

/// معلومات زائر المحادثة
@JsonSerializable()
class ChatVisitorInfo {
  final String? customerId;
  final String? name;
  final String? email;
  final String? phone;

  const ChatVisitorInfo({
    this.customerId,
    this.name,
    this.email,
    this.phone,
  });

  factory ChatVisitorInfo.fromJson(Map<String, dynamic> json) =>
      _$ChatVisitorInfoFromJson(json);
  Map<String, dynamic> toJson() => _$ChatVisitorInfoToJson(this);
}

/// مقاييس المحادثة
@JsonSerializable()
class ChatMetrics {
  @JsonKey(defaultValue: 0)
  final int waitTime;
  @JsonKey(defaultValue: 0)
  final int chatDuration;
  @JsonKey(defaultValue: 0)
  final int messageCount;
  @JsonKey(defaultValue: 0)
  final int agentMessageCount;
  @JsonKey(defaultValue: 0)
  final int visitorMessageCount;
  @JsonKey(defaultValue: 0)
  final int avgResponseTime;

  const ChatMetrics({
    this.waitTime = 0,
    this.chatDuration = 0,
    this.messageCount = 0,
    this.agentMessageCount = 0,
    this.visitorMessageCount = 0,
    this.avgResponseTime = 0,
  });

  factory ChatMetrics.fromJson(Map<String, dynamic> json) =>
      _$ChatMetricsFromJson(json);
  Map<String, dynamic> toJson() => _$ChatMetricsToJson(this);

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

/// جلسة المحادثة
@JsonSerializable()
class ChatSessionModel {
  @JsonKey(name: '_id', readValue: _readId)
  final String id;
  final String sessionId;
  final ChatVisitorInfo visitor;
  @JsonKey(fromJson: _chatStatusFromJson)
  final ChatSessionStatus status;
  @JsonKey(name: 'assignedAgent')
  final String? assignedAgentId;
  final DateTime? assignedAt;
  @JsonKey(defaultValue: 0)
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
  @JsonKey(includeFromJson: false, includeToJson: false)
  final List<ChatMessageModel> messages;

  const ChatSessionModel({
    required this.id,
    required this.sessionId,
    required this.visitor,
    required this.status,
    this.assignedAgentId,
    this.assignedAt,
    this.queuePosition = 0,
    this.department,
    this.startedAt,
    this.endedAt,
    this.lastActivityAt,
    this.initialMessage,
    required this.metrics,
    this.rating,
    this.ratingFeedback,
    required this.createdAt,
    this.messages = const [],
  });

  factory ChatSessionModel.fromJson(Map<String, dynamic> json) {
    final model = _$ChatSessionModelFromJson(json);
    // Parse messages if present
    final messagesJson = json['messages'] as List<dynamic>?;
    if (messagesJson != null) {
      final messages =
          messagesJson.map((m) => ChatMessageModel.fromJson(m)).toList();
      return ChatSessionModel(
        id: model.id,
        sessionId: model.sessionId,
        visitor: model.visitor,
        status: model.status,
        assignedAgentId: model.assignedAgentId,
        assignedAt: model.assignedAt,
        queuePosition: model.queuePosition,
        department: model.department,
        startedAt: model.startedAt,
        endedAt: model.endedAt,
        lastActivityAt: model.lastActivityAt,
        initialMessage: model.initialMessage,
        metrics: model.metrics,
        rating: model.rating,
        ratingFeedback: model.ratingFeedback,
        createdAt: model.createdAt,
        messages: messages,
      );
    }
    return model;
  }
  Map<String, dynamic> toJson() => _$ChatSessionModelToJson(this);

  /// هل المحادثة نشطة؟
  bool get isActive => status == ChatSessionStatus.active;

  /// هل في الانتظار؟
  bool get isWaiting => status == ChatSessionStatus.waiting;

  /// هل يمكن التقييم؟
  bool get canRate => status == ChatSessionStatus.ended && rating == null;

  static ChatSessionStatus _chatStatusFromJson(String value) =>
      ChatSessionStatus.fromString(value);
}

/// رد سريع
@JsonSerializable()
class QuickReply {
  final String label;
  final String value;

  const QuickReply({required this.label, required this.value});

  factory QuickReply.fromJson(Map<String, dynamic> json) =>
      _$QuickReplyFromJson(json);
  Map<String, dynamic> toJson() => _$QuickReplyToJson(this);
}

/// رسالة المحادثة
@JsonSerializable()
class ChatMessageModel {
  @JsonKey(name: '_id', readValue: _readId)
  final String id;
  @JsonKey(name: 'session', readValue: _readSessionId)
  final String sessionId;
  @JsonKey(fromJson: _chatSenderTypeFromJson)
  final ChatSenderType senderType;
  final String? senderId;
  final String? senderName;
  @JsonKey(fromJson: _chatMessageTypeFromJson)
  final ChatMessageType messageType;
  final String content;
  final String? fileUrl;
  final String? fileName;
  final List<QuickReply>? quickReplies;
  @JsonKey(defaultValue: false)
  final bool isDelivered;
  @JsonKey(defaultValue: false)
  final bool isRead;
  final DateTime createdAt;

  const ChatMessageModel({
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
    this.isDelivered = false,
    this.isRead = false,
    required this.createdAt,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageModelFromJson(json);
  Map<String, dynamic> toJson() => _$ChatMessageModelToJson(this);

  /// هل من الزائر؟
  bool get isFromVisitor => senderType == ChatSenderType.visitor;

  /// هل من الوكيل؟
  bool get isFromAgent => senderType == ChatSenderType.agent;

  static ChatSenderType _chatSenderTypeFromJson(String value) =>
      ChatSenderType.fromString(value);
  static ChatMessageType _chatMessageTypeFromJson(String value) =>
      ChatMessageType.fromString(value);
}

// ═══════════════════════════════════════════════════════════════════════════
// REQUEST MODELS
// ═══════════════════════════════════════════════════════════════════════════

/// طلب إنشاء تذكرة
@JsonSerializable()
class CreateTicketRequest {
  @JsonKey(name: 'categoryId')
  final String categoryId;
  final String subject;
  final String description;
  final String? priority;
  final String? orderId;
  final String? productId;
  final List<String>? attachments;
  final String? source;
  @JsonKey(includeFromJson: false, includeToJson: false)
  final String? customerName;
  @JsonKey(includeFromJson: false, includeToJson: false)
  final String? customerEmail;

  const CreateTicketRequest({
    required this.categoryId,
    required this.subject,
    required this.description,
    this.priority,
    this.orderId,
    this.productId,
    this.attachments,
    this.source,
    this.customerName,
    this.customerEmail,
  });

  factory CreateTicketRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateTicketRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateTicketRequestToJson(this);
}

/// طلب بدء محادثة
@JsonSerializable()
class StartChatRequest {
  final String? initialMessage;
  final String? department;
  final String? categoryId;

  const StartChatRequest({
    this.initialMessage,
    this.department,
    this.categoryId,
  });

  factory StartChatRequest.fromJson(Map<String, dynamic> json) =>
      _$StartChatRequestFromJson(json);
  Map<String, dynamic> toJson() => _$StartChatRequestToJson(this);
}

// ═══════════════════════════════════════════════════════════════════════════
// HELPER FUNCTIONS
// ═══════════════════════════════════════════════════════════════════════════

/// قراءة الـ ID من الـ JSON
Object? _readId(Map<dynamic, dynamic> json, String key) =>
    json['_id'] ?? json['id'];

/// قراءة ticket ID
Object? _readTicketId(Map<dynamic, dynamic> json, String key) {
  final ticket = json['ticket'];
  if (ticket is String) return ticket;
  if (ticket is Map) return ticket['_id'] ?? ticket['id'] ?? '';
  return '';
}

/// قراءة session ID
Object? _readSessionId(Map<dynamic, dynamic> json, String key) {
  final session = json['session'];
  if (session is String) return session;
  if (session is Map) return session['_id'] ?? session['id'] ?? '';
  return '';
}
