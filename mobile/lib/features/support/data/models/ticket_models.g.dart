// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ticket_models.dart';

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
  category: _categoryFromJson(json['category']),
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
