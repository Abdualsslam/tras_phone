// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ticket_message_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

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
