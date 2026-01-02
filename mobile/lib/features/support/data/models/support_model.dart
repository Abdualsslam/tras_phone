/// Support Models - Data layer models with JSON serialization
library;

import 'package:json_annotation/json_annotation.dart';

part 'support_model.g.dart';

/// Ticket Status Enum
enum TicketStatus {
  open,
  pending,
  inProgress,
  resolved,
  closed;

  String get displayName {
    switch (this) {
      case TicketStatus.open:
        return 'مفتوحة';
      case TicketStatus.pending:
        return 'معلقة';
      case TicketStatus.inProgress:
        return 'قيد المعالجة';
      case TicketStatus.resolved:
        return 'تم الحل';
      case TicketStatus.closed:
        return 'مغلقة';
    }
  }
}

@JsonSerializable()
class SupportTicketModel {
  final int id;
  @JsonKey(name: 'ticket_number')
  final String ticketNumber;
  final String subject;
  @JsonKey(name: 'category_id')
  final int? categoryId;
  final String? category;
  final String status;
  final String priority; // 'low', 'medium', 'high', 'urgent'
  @JsonKey(name: 'order_id')
  final int? orderId;
  @JsonKey(name: 'last_reply_at')
  final String? lastReplyAt;
  @JsonKey(name: 'created_at')
  final String createdAt;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  const SupportTicketModel({
    required this.id,
    required this.ticketNumber,
    required this.subject,
    this.categoryId,
    this.category,
    required this.status,
    this.priority = 'medium',
    this.orderId,
    this.lastReplyAt,
    required this.createdAt,
    this.updatedAt,
  });

  factory SupportTicketModel.fromJson(Map<String, dynamic> json) =>
      _$SupportTicketModelFromJson(json);
  Map<String, dynamic> toJson() => _$SupportTicketModelToJson(this);

  TicketStatus get statusEnum {
    switch (status.toLowerCase()) {
      case 'open':
        return TicketStatus.open;
      case 'pending':
        return TicketStatus.pending;
      case 'in_progress':
        return TicketStatus.inProgress;
      case 'resolved':
        return TicketStatus.resolved;
      case 'closed':
        return TicketStatus.closed;
      default:
        return TicketStatus.open;
    }
  }
}

@JsonSerializable()
class TicketMessageModel {
  final int id;
  @JsonKey(name: 'ticket_id')
  final int ticketId;
  final String message;
  @JsonKey(name: 'sender_type')
  final String senderType; // 'customer', 'admin'
  @JsonKey(name: 'sender_name')
  final String? senderName;
  final List<String>? attachments;
  @JsonKey(name: 'created_at')
  final String createdAt;

  const TicketMessageModel({
    required this.id,
    required this.ticketId,
    required this.message,
    required this.senderType,
    this.senderName,
    this.attachments,
    required this.createdAt,
  });

  factory TicketMessageModel.fromJson(Map<String, dynamic> json) =>
      _$TicketMessageModelFromJson(json);
  Map<String, dynamic> toJson() => _$TicketMessageModelToJson(this);

  bool get isFromCustomer => senderType == 'customer';
  bool get isFromAdmin => senderType == 'admin';
}

@JsonSerializable()
class SupportCategoryModel {
  final int id;
  final String name;
  @JsonKey(name: 'name_ar')
  final String? nameAr;
  final String? icon;
  final String? description;

  const SupportCategoryModel({
    required this.id,
    required this.name,
    this.nameAr,
    this.icon,
    this.description,
  });

  factory SupportCategoryModel.fromJson(Map<String, dynamic> json) =>
      _$SupportCategoryModelFromJson(json);
  Map<String, dynamic> toJson() => _$SupportCategoryModelToJson(this);

  String get displayName => nameAr ?? name;
}

@JsonSerializable()
class CreateTicketRequest {
  final String subject;
  @JsonKey(name: 'category_id')
  final int categoryId;
  final String message;
  @JsonKey(name: 'order_id')
  final int? orderId;
  final String priority;
  final List<String>? attachments;

  const CreateTicketRequest({
    required this.subject,
    required this.categoryId,
    required this.message,
    this.orderId,
    this.priority = 'medium',
    this.attachments,
  });

  factory CreateTicketRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateTicketRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateTicketRequestToJson(this);
}
