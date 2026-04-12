part of 'chat_models.dart';

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
    final messagesJson = json['messages'] as List<dynamic>?;
    if (messagesJson == null) {
      return model;
    }

    final messages = messagesJson
        .map((message) => ChatMessageModel.fromJson(message))
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

  Map<String, dynamic> toJson() => _$ChatSessionModelToJson(this);

  bool get isActive => status == ChatSessionStatus.active;
  bool get isWaiting => status == ChatSessionStatus.waiting;
  bool get canRate => status == ChatSessionStatus.ended && rating == null;

  static ChatSessionStatus _chatStatusFromJson(String value) =>
      ChatSessionStatus.fromString(value);
}
