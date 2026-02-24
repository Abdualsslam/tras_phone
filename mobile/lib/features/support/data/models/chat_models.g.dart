// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

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
