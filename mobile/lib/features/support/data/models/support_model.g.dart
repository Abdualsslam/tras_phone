// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'support_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SupportTicketModel _$SupportTicketModelFromJson(Map<String, dynamic> json) =>
    SupportTicketModel(
      id: (json['id'] as num).toInt(),
      ticketNumber: json['ticket_number'] as String,
      subject: json['subject'] as String,
      categoryId: (json['category_id'] as num?)?.toInt(),
      category: json['category'] as String?,
      status: json['status'] as String,
      priority: json['priority'] as String? ?? 'medium',
      orderId: (json['order_id'] as num?)?.toInt(),
      lastReplyAt: json['last_reply_at'] as String?,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String?,
    );

Map<String, dynamic> _$SupportTicketModelToJson(SupportTicketModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'ticket_number': instance.ticketNumber,
      'subject': instance.subject,
      'category_id': instance.categoryId,
      'category': instance.category,
      'status': instance.status,
      'priority': instance.priority,
      'order_id': instance.orderId,
      'last_reply_at': instance.lastReplyAt,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };

TicketMessageModel _$TicketMessageModelFromJson(Map<String, dynamic> json) =>
    TicketMessageModel(
      id: (json['id'] as num).toInt(),
      ticketId: (json['ticket_id'] as num).toInt(),
      message: json['message'] as String,
      senderType: json['sender_type'] as String,
      senderName: json['sender_name'] as String?,
      attachments: (json['attachments'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      createdAt: json['created_at'] as String,
    );

Map<String, dynamic> _$TicketMessageModelToJson(TicketMessageModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'ticket_id': instance.ticketId,
      'message': instance.message,
      'sender_type': instance.senderType,
      'sender_name': instance.senderName,
      'attachments': instance.attachments,
      'created_at': instance.createdAt,
    };

SupportCategoryModel _$SupportCategoryModelFromJson(
  Map<String, dynamic> json,
) => SupportCategoryModel(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  nameAr: json['name_ar'] as String?,
  icon: json['icon'] as String?,
  description: json['description'] as String?,
);

Map<String, dynamic> _$SupportCategoryModelToJson(
  SupportCategoryModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'name_ar': instance.nameAr,
  'icon': instance.icon,
  'description': instance.description,
};

CreateTicketRequest _$CreateTicketRequestFromJson(Map<String, dynamic> json) =>
    CreateTicketRequest(
      subject: json['subject'] as String,
      categoryId: (json['category_id'] as num).toInt(),
      message: json['message'] as String,
      orderId: (json['order_id'] as num?)?.toInt(),
      priority: json['priority'] as String? ?? 'medium',
      attachments: (json['attachments'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$CreateTicketRequestToJson(
  CreateTicketRequest instance,
) => <String, dynamic>{
  'subject': instance.subject,
  'category_id': instance.categoryId,
  'message': instance.message,
  'order_id': instance.orderId,
  'priority': instance.priority,
  'attachments': instance.attachments,
};
