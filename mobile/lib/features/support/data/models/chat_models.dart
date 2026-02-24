import 'package:json_annotation/json_annotation.dart';
import 'support_enums.dart';

part 'chat_models.g.dart';

/// قراءة الـ ID من الـ JSON
Object? _readId(Map<dynamic, dynamic> json, String key) =>
    json['_id'] ?? json['id'];

/// قراءة session ID
Object? _readSessionId(Map<dynamic, dynamic> json, String key) {
  final session = json['session'];
  if (session is String) return session;
  if (session is Map) return session['_id'] ?? session['id'] ?? '';
  return '';
}

/// معلومات زائر المحادثة
@JsonSerializable()
class ChatVisitorInfo {
  final String? customerId;
  final String? name;
  final String? email;
  final String? phone;

  const ChatVisitorInfo({this.customerId, this.name, this.email, this.phone});

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
      final messages = messagesJson
          .map((m) => ChatMessageModel.fromJson(m))
          .toList();
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
