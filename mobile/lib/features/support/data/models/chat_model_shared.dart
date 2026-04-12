part of 'chat_models.dart';

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

  String get waitTimeFormatted {
    if (waitTime < 60) return '$waitTime ثانية';
    return '${(waitTime / 60).floor()} دقيقة';
  }

  String get durationFormatted {
    if (chatDuration < 60) return '$chatDuration ثانية';
    return '${(chatDuration / 60).floor()} دقيقة';
  }
}

@JsonSerializable()
class QuickReply {
  final String label;
  final String value;

  const QuickReply({required this.label, required this.value});

  factory QuickReply.fromJson(Map<String, dynamic> json) =>
      _$QuickReplyFromJson(json);
  Map<String, dynamic> toJson() => _$QuickReplyToJson(this);
}

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
