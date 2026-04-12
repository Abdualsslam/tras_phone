part of 'chat_models.dart';

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

  bool get isFromVisitor => senderType == ChatSenderType.visitor;
  bool get isFromAgent => senderType == ChatSenderType.agent;

  static ChatSenderType _chatSenderTypeFromJson(String value) =>
      ChatSenderType.fromString(value);
  static ChatMessageType _chatMessageTypeFromJson(String value) =>
      ChatMessageType.fromString(value);
}
