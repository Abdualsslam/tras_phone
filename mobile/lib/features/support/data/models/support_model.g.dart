// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'support_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TicketCustomerInfo _$TicketCustomerInfoFromJson(Map<String, dynamic> json) =>
    TicketCustomerInfo(
      customerId: json['customerId'] as String?,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
    );

Map<String, dynamic> _$TicketCustomerInfoToJson(TicketCustomerInfo instance) =>
    <String, dynamic>{
      'customerId': instance.customerId,
      'name': instance.name,
      'email': instance.email,
      'phone': instance.phone,
    };

TicketSLA _$TicketSLAFromJson(Map<String, dynamic> json) => TicketSLA(
  firstResponseDue: json['firstResponseDue'] == null
      ? null
      : DateTime.parse(json['firstResponseDue'] as String),
  resolutionDue: json['resolutionDue'] == null
      ? null
      : DateTime.parse(json['resolutionDue'] as String),
  firstRespondedAt: json['firstRespondedAt'] == null
      ? null
      : DateTime.parse(json['firstRespondedAt'] as String),
  resolvedAt: json['resolvedAt'] == null
      ? null
      : DateTime.parse(json['resolvedAt'] as String),
  firstResponseBreached: json['firstResponseBreached'] as bool? ?? false,
  resolutionBreached: json['resolutionBreached'] as bool? ?? false,
);

Map<String, dynamic> _$TicketSLAToJson(TicketSLA instance) => <String, dynamic>{
  'firstResponseDue': instance.firstResponseDue?.toIso8601String(),
  'resolutionDue': instance.resolutionDue?.toIso8601String(),
  'firstRespondedAt': instance.firstRespondedAt?.toIso8601String(),
  'resolvedAt': instance.resolvedAt?.toIso8601String(),
  'firstResponseBreached': instance.firstResponseBreached,
  'resolutionBreached': instance.resolutionBreached,
};

TicketResolution _$TicketResolutionFromJson(Map<String, dynamic> json) =>
    TicketResolution(
      summary: json['summary'] as String?,
      type: TicketResolution._resolutionTypeFromJson(json['type'] as String?),
      resolvedBy: json['resolvedBy'] as String?,
      resolvedAt: json['resolvedAt'] == null
          ? null
          : DateTime.parse(json['resolvedAt'] as String),
    );

Map<String, dynamic> _$TicketResolutionToJson(TicketResolution instance) =>
    <String, dynamic>{
      'summary': instance.summary,
      'type': _$ResolutionTypeEnumMap[instance.type],
      'resolvedBy': instance.resolvedBy,
      'resolvedAt': instance.resolvedAt?.toIso8601String(),
    };

const _$ResolutionTypeEnumMap = {
  ResolutionType.solved: 'solved',
  ResolutionType.wontFix: 'wontFix',
  ResolutionType.duplicate: 'duplicate',
  ResolutionType.invalid: 'invalid',
  ResolutionType.customerAbandoned: 'customerAbandoned',
};

TicketCategoryModel _$TicketCategoryModelFromJson(Map<String, dynamic> json) =>
    TicketCategoryModel(
      id: _readId(json, '_id') as String,
      nameAr: json['nameAr'] as String,
      nameEn: json['nameEn'] as String,
      descriptionAr: json['descriptionAr'] as String?,
      descriptionEn: json['descriptionEn'] as String?,
      icon: json['icon'] as String?,
      parentId: json['parent'] as String?,
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
      isActive: json['isActive'] as bool? ?? true,
      requiresOrderId: json['requiresOrderId'] as bool? ?? false,
      requiresProductId: json['requiresProductId'] as bool? ?? false,
    );

Map<String, dynamic> _$TicketCategoryModelToJson(
  TicketCategoryModel instance,
) => <String, dynamic>{
  '_id': instance.id,
  'nameAr': instance.nameAr,
  'nameEn': instance.nameEn,
  'descriptionAr': instance.descriptionAr,
  'descriptionEn': instance.descriptionEn,
  'icon': instance.icon,
  'parent': instance.parentId,
  'sortOrder': instance.sortOrder,
  'isActive': instance.isActive,
  'requiresOrderId': instance.requiresOrderId,
  'requiresProductId': instance.requiresProductId,
};

TicketModel _$TicketModelFromJson(Map<String, dynamic> json) => TicketModel(
  id: _readId(json, '_id') as String,
  ticketNumber: json['ticketNumber'] as String,
  customer: TicketCustomerInfo.fromJson(
    json['customer'] as Map<String, dynamic>,
  ),
  category: json['category'] == null
      ? null
      : TicketCategoryModel.fromJson(json['category'] as Map<String, dynamic>),
  subject: json['subject'] as String,
  description: json['description'] as String,
  status: TicketModel._statusFromJson(json['status'] as String),
  priority: TicketModel._priorityFromJson(json['priority'] as String),
  source: TicketModel._sourceFromJson(json['source'] as String),
  assignedTo: json['assignedTo'] as String?,
  orderId: json['orderId'] as String?,
  productId: json['productId'] as String?,
  attachments:
      (json['attachments'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      [],
  tags:
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
  sla: TicketSLA.fromJson(json['sla'] as Map<String, dynamic>),
  resolution: json['resolution'] == null
      ? null
      : TicketResolution.fromJson(json['resolution'] as Map<String, dynamic>),
  messageCount: (json['messageCount'] as num?)?.toInt() ?? 0,
  lastCustomerReplyAt: json['lastCustomerReplyAt'] == null
      ? null
      : DateTime.parse(json['lastCustomerReplyAt'] as String),
  lastAgentReplyAt: json['lastAgentReplyAt'] == null
      ? null
      : DateTime.parse(json['lastAgentReplyAt'] as String),
  satisfactionRating: (json['satisfactionRating'] as num?)?.toInt(),
  satisfactionFeedback: json['satisfactionFeedback'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$TicketModelToJson(TicketModel instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'ticketNumber': instance.ticketNumber,
      'customer': instance.customer,
      'category': instance.category,
      'subject': instance.subject,
      'description': instance.description,
      'status': _$TicketStatusEnumMap[instance.status]!,
      'priority': _$TicketPriorityEnumMap[instance.priority]!,
      'source': _$TicketSourceEnumMap[instance.source]!,
      'assignedTo': instance.assignedTo,
      'orderId': instance.orderId,
      'productId': instance.productId,
      'attachments': instance.attachments,
      'tags': instance.tags,
      'sla': instance.sla,
      'resolution': instance.resolution,
      'messageCount': instance.messageCount,
      'lastCustomerReplyAt': instance.lastCustomerReplyAt?.toIso8601String(),
      'lastAgentReplyAt': instance.lastAgentReplyAt?.toIso8601String(),
      'satisfactionRating': instance.satisfactionRating,
      'satisfactionFeedback': instance.satisfactionFeedback,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$TicketStatusEnumMap = {
  TicketStatus.open: 'open',
  TicketStatus.awaitingResponse: 'awaitingResponse',
  TicketStatus.inProgress: 'inProgress',
  TicketStatus.onHold: 'onHold',
  TicketStatus.escalated: 'escalated',
  TicketStatus.resolved: 'resolved',
  TicketStatus.closed: 'closed',
  TicketStatus.reopened: 'reopened',
};

const _$TicketPriorityEnumMap = {
  TicketPriority.low: 'low',
  TicketPriority.medium: 'medium',
  TicketPriority.high: 'high',
  TicketPriority.urgent: 'urgent',
};

const _$TicketSourceEnumMap = {
  TicketSource.web: 'web',
  TicketSource.mobileApp: 'mobileApp',
  TicketSource.email: 'email',
  TicketSource.phone: 'phone',
  TicketSource.liveChat: 'liveChat',
  TicketSource.socialMedia: 'socialMedia',
};

TicketMessageModel _$TicketMessageModelFromJson(Map<String, dynamic> json) =>
    TicketMessageModel(
      id: _readId(json, '_id') as String,
      ticketId: _readTicketId(json, 'ticket') as String,
      senderType: TicketMessageModel._senderTypeFromJson(
        json['senderType'] as String,
      ),
      senderId: json['senderId'] as String?,
      senderName: json['senderName'] as String? ?? '',
      messageType: TicketMessageModel._messageTypeFromJson(
        json['messageType'] as String,
      ),
      content: json['content'] as String,
      htmlContent: json['htmlContent'] as String?,
      attachments:
          (json['attachments'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      isInternal: json['isInternal'] as bool? ?? false,
      isRead: json['isRead'] as bool? ?? false,
      readAt: json['readAt'] == null
          ? null
          : DateTime.parse(json['readAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$TicketMessageModelToJson(TicketMessageModel instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'ticket': instance.ticketId,
      'senderType': _$MessageSenderTypeEnumMap[instance.senderType]!,
      'senderId': instance.senderId,
      'senderName': instance.senderName,
      'messageType': _$MessageTypeEnumMap[instance.messageType]!,
      'content': instance.content,
      'htmlContent': instance.htmlContent,
      'attachments': instance.attachments,
      'isInternal': instance.isInternal,
      'isRead': instance.isRead,
      'readAt': instance.readAt?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$MessageSenderTypeEnumMap = {
  MessageSenderType.customer: 'customer',
  MessageSenderType.agent: 'agent',
  MessageSenderType.system: 'system',
};

const _$MessageTypeEnumMap = {
  MessageType.text: 'text',
  MessageType.internalNote: 'internalNote',
  MessageType.statusChange: 'statusChange',
  MessageType.assignment: 'assignment',
  MessageType.escalation: 'escalation',
  MessageType.cannedResponse: 'cannedResponse',
};

ChatVisitorInfo _$ChatVisitorInfoFromJson(Map<String, dynamic> json) =>
    ChatVisitorInfo(
      customerId: json['customerId'] as String?,
      name: json['name'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
    );

Map<String, dynamic> _$ChatVisitorInfoToJson(ChatVisitorInfo instance) =>
    <String, dynamic>{
      'customerId': instance.customerId,
      'name': instance.name,
      'email': instance.email,
      'phone': instance.phone,
    };

ChatMetrics _$ChatMetricsFromJson(Map<String, dynamic> json) => ChatMetrics(
  waitTime: (json['waitTime'] as num?)?.toInt() ?? 0,
  chatDuration: (json['chatDuration'] as num?)?.toInt() ?? 0,
  messageCount: (json['messageCount'] as num?)?.toInt() ?? 0,
  agentMessageCount: (json['agentMessageCount'] as num?)?.toInt() ?? 0,
  visitorMessageCount: (json['visitorMessageCount'] as num?)?.toInt() ?? 0,
  avgResponseTime: (json['avgResponseTime'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$ChatMetricsToJson(ChatMetrics instance) =>
    <String, dynamic>{
      'waitTime': instance.waitTime,
      'chatDuration': instance.chatDuration,
      'messageCount': instance.messageCount,
      'agentMessageCount': instance.agentMessageCount,
      'visitorMessageCount': instance.visitorMessageCount,
      'avgResponseTime': instance.avgResponseTime,
    };

ChatSessionModel _$ChatSessionModelFromJson(Map<String, dynamic> json) =>
    ChatSessionModel(
      id: _readId(json, '_id') as String,
      sessionId: json['sessionId'] as String,
      visitor: ChatVisitorInfo.fromJson(
        json['visitor'] as Map<String, dynamic>,
      ),
      status: ChatSessionModel._chatStatusFromJson(json['status'] as String),
      assignedAgentId: json['assignedAgent'] as String?,
      assignedAt: json['assignedAt'] == null
          ? null
          : DateTime.parse(json['assignedAt'] as String),
      queuePosition: (json['queuePosition'] as num?)?.toInt() ?? 0,
      department: json['department'] as String?,
      startedAt: json['startedAt'] == null
          ? null
          : DateTime.parse(json['startedAt'] as String),
      endedAt: json['endedAt'] == null
          ? null
          : DateTime.parse(json['endedAt'] as String),
      lastActivityAt: json['lastActivityAt'] == null
          ? null
          : DateTime.parse(json['lastActivityAt'] as String),
      initialMessage: json['initialMessage'] as String?,
      metrics: ChatMetrics.fromJson(json['metrics'] as Map<String, dynamic>),
      rating: (json['rating'] as num?)?.toInt(),
      ratingFeedback: json['ratingFeedback'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$ChatSessionModelToJson(ChatSessionModel instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'sessionId': instance.sessionId,
      'visitor': instance.visitor,
      'status': _$ChatSessionStatusEnumMap[instance.status]!,
      'assignedAgent': instance.assignedAgentId,
      'assignedAt': instance.assignedAt?.toIso8601String(),
      'queuePosition': instance.queuePosition,
      'department': instance.department,
      'startedAt': instance.startedAt?.toIso8601String(),
      'endedAt': instance.endedAt?.toIso8601String(),
      'lastActivityAt': instance.lastActivityAt?.toIso8601String(),
      'initialMessage': instance.initialMessage,
      'metrics': instance.metrics,
      'rating': instance.rating,
      'ratingFeedback': instance.ratingFeedback,
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$ChatSessionStatusEnumMap = {
  ChatSessionStatus.waiting: 'waiting',
  ChatSessionStatus.active: 'active',
  ChatSessionStatus.onHold: 'onHold',
  ChatSessionStatus.ended: 'ended',
  ChatSessionStatus.abandoned: 'abandoned',
};

QuickReply _$QuickReplyFromJson(Map<String, dynamic> json) =>
    QuickReply(label: json['label'] as String, value: json['value'] as String);

Map<String, dynamic> _$QuickReplyToJson(QuickReply instance) =>
    <String, dynamic>{'label': instance.label, 'value': instance.value};

ChatMessageModel _$ChatMessageModelFromJson(Map<String, dynamic> json) =>
    ChatMessageModel(
      id: _readId(json, '_id') as String,
      sessionId: _readSessionId(json, 'session') as String,
      senderType: ChatMessageModel._chatSenderTypeFromJson(
        json['senderType'] as String,
      ),
      senderId: json['senderId'] as String?,
      senderName: json['senderName'] as String?,
      messageType: ChatMessageModel._chatMessageTypeFromJson(
        json['messageType'] as String,
      ),
      content: json['content'] as String,
      fileUrl: json['fileUrl'] as String?,
      fileName: json['fileName'] as String?,
      quickReplies: (json['quickReplies'] as List<dynamic>?)
          ?.map((e) => QuickReply.fromJson(e as Map<String, dynamic>))
          .toList(),
      isDelivered: json['isDelivered'] as bool? ?? false,
      isRead: json['isRead'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$ChatMessageModelToJson(ChatMessageModel instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'session': instance.sessionId,
      'senderType': _$ChatSenderTypeEnumMap[instance.senderType]!,
      'senderId': instance.senderId,
      'senderName': instance.senderName,
      'messageType': _$ChatMessageTypeEnumMap[instance.messageType]!,
      'content': instance.content,
      'fileUrl': instance.fileUrl,
      'fileName': instance.fileName,
      'quickReplies': instance.quickReplies,
      'isDelivered': instance.isDelivered,
      'isRead': instance.isRead,
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$ChatSenderTypeEnumMap = {
  ChatSenderType.visitor: 'visitor',
  ChatSenderType.agent: 'agent',
  ChatSenderType.system: 'system',
  ChatSenderType.bot: 'bot',
};

const _$ChatMessageTypeEnumMap = {
  ChatMessageType.text: 'text',
  ChatMessageType.image: 'image',
  ChatMessageType.file: 'file',
  ChatMessageType.system: 'system',
  ChatMessageType.bot: 'bot',
  ChatMessageType.quickReply: 'quickReply',
};

CreateTicketRequest _$CreateTicketRequestFromJson(Map<String, dynamic> json) =>
    CreateTicketRequest(
      categoryId: json['categoryId'] as String,
      subject: json['subject'] as String,
      description: json['description'] as String,
      priority: json['priority'] as String?,
      orderId: json['orderId'] as String?,
      productId: json['productId'] as String?,
      attachments: (json['attachments'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      source: json['source'] as String?,
    );

Map<String, dynamic> _$CreateTicketRequestToJson(
  CreateTicketRequest instance,
) => <String, dynamic>{
  'categoryId': instance.categoryId,
  'subject': instance.subject,
  'description': instance.description,
  'priority': instance.priority,
  'orderId': instance.orderId,
  'productId': instance.productId,
  'attachments': instance.attachments,
  'source': instance.source,
};

StartChatRequest _$StartChatRequestFromJson(Map<String, dynamic> json) =>
    StartChatRequest(
      initialMessage: json['initialMessage'] as String?,
      department: json['department'] as String?,
      categoryId: json['categoryId'] as String?,
    );

Map<String, dynamic> _$StartChatRequestToJson(StartChatRequest instance) =>
    <String, dynamic>{
      'initialMessage': instance.initialMessage,
      'department': instance.department,
      'categoryId': instance.categoryId,
    };
