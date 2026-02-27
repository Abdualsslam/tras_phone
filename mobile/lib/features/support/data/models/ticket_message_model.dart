import 'package:json_annotation/json_annotation.dart';
import 'support_enums.dart';

part 'ticket_message_model.g.dart';

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
