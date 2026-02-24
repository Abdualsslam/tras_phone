import 'package:json_annotation/json_annotation.dart';
import 'support_enums.dart';

part 'ticket_models.g.dart';

/// تحويل category من String أو Map إلى TicketCategoryModel
TicketCategoryModel? _categoryFromJson(dynamic value) {
  if (value == null) return null;
  if (value is String) return null;
  if (value is Map<String, dynamic>) {
    return TicketCategoryModel.fromJson(value);
  }
  if (value is Map) {
    return TicketCategoryModel.fromJson(Map<String, dynamic>.from(value));
  }
  return null;
}

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

/// معلومات العميل في التذكرة
@JsonSerializable()
class TicketCustomerInfo {
  final String? customerId;
  final String name;
  final String email;
  final String? phone;

  const TicketCustomerInfo({
    this.customerId,
    required this.name,
    required this.email,
    this.phone,
  });

  factory TicketCustomerInfo.fromJson(Map<String, dynamic> json) =>
      _$TicketCustomerInfoFromJson(json);
  Map<String, dynamic> toJson() => _$TicketCustomerInfoToJson(this);
}

/// SLA التذكرة
@JsonSerializable()
class TicketSLA {
  final DateTime? firstResponseDue;
  final DateTime? resolutionDue;
  final DateTime? firstRespondedAt;
  final DateTime? resolvedAt;
  final bool firstResponseBreached;
  final bool resolutionBreached;

  const TicketSLA({
    this.firstResponseDue,
    this.resolutionDue,
    this.firstRespondedAt,
    this.resolvedAt,
    this.firstResponseBreached = false,
    this.resolutionBreached = false,
  });

  factory TicketSLA.fromJson(Map<String, dynamic> json) =>
      _$TicketSLAFromJson(json);
  Map<String, dynamic> toJson() => _$TicketSLAToJson(this);
}

/// حل التذكرة
@JsonSerializable()
class TicketResolution {
  final String? summary;
  @JsonKey(fromJson: _resolutionTypeFromJson)
  final ResolutionType? type;
  final String? resolvedBy;
  final DateTime? resolvedAt;

  const TicketResolution({
    this.summary,
    this.type,
    this.resolvedBy,
    this.resolvedAt,
  });

  factory TicketResolution.fromJson(Map<String, dynamic> json) =>
      _$TicketResolutionFromJson(json);
  Map<String, dynamic> toJson() => _$TicketResolutionToJson(this);

  static ResolutionType? _resolutionTypeFromJson(String? value) =>
      value != null ? ResolutionType.fromString(value) : null;
}

/// فئة التذكرة
@JsonSerializable()
class TicketCategoryModel {
  @JsonKey(name: '_id', readValue: _readId)
  final String id;
  final String nameAr;
  final String nameEn;
  final String? descriptionAr;
  final String? descriptionEn;
  final String? icon;
  @JsonKey(name: 'parent')
  final String? parentId;
  final int sortOrder;
  final bool isActive;
  final bool requiresOrderId;
  final bool requiresProductId;

  const TicketCategoryModel({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    this.descriptionAr,
    this.descriptionEn,
    this.icon,
    this.parentId,
    this.sortOrder = 0,
    this.isActive = true,
    this.requiresOrderId = false,
    this.requiresProductId = false,
  });

  factory TicketCategoryModel.fromJson(Map<String, dynamic> json) =>
      _$TicketCategoryModelFromJson(json);
  Map<String, dynamic> toJson() => _$TicketCategoryModelToJson(this);

  String getName(String locale) => locale == 'ar' ? nameAr : nameEn;
  String? getDescription(String locale) =>
      locale == 'ar' ? descriptionAr : descriptionEn;
}

/// التذكرة
@JsonSerializable()
class TicketModel {
  @JsonKey(name: '_id', readValue: _readId)
  final String id;
  final String ticketNumber;
  final TicketCustomerInfo customer;
  @JsonKey(includeFromJson: false, includeToJson: false)
  final String? categoryId;
  @JsonKey(name: 'category', fromJson: _categoryFromJson)
  final TicketCategoryModel? category;
  final String subject;
  final String description;
  @JsonKey(fromJson: _statusFromJson)
  final TicketStatus status;
  @JsonKey(fromJson: _priorityFromJson)
  final TicketPriority priority;
  @JsonKey(fromJson: _sourceFromJson)
  final TicketSource source;
  final String? assignedTo;
  final String? orderId;
  final String? productId;
  @JsonKey(defaultValue: [])
  final List<String> attachments;
  @JsonKey(defaultValue: [])
  final List<String> tags;
  final TicketSLA sla;
  final TicketResolution? resolution;
  @JsonKey(defaultValue: 0)
  final int messageCount;
  final DateTime? lastCustomerReplyAt;
  final DateTime? lastAgentReplyAt;
  final int? satisfactionRating;
  final String? satisfactionFeedback;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TicketModel({
    required this.id,
    required this.ticketNumber,
    required this.customer,
    this.categoryId,
    this.category,
    required this.subject,
    required this.description,
    required this.status,
    required this.priority,
    required this.source,
    this.assignedTo,
    this.orderId,
    this.productId,
    required this.attachments,
    required this.tags,
    required this.sla,
    this.resolution,
    required this.messageCount,
    this.lastCustomerReplyAt,
    this.lastAgentReplyAt,
    this.satisfactionRating,
    this.satisfactionFeedback,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    final model = _$TicketModelFromJson(json);
    // Extract categoryId from category field
    final category = json['category'];
    String catId = '';
    if (category is String) {
      catId = category;
    } else if (category is Map) {
      catId = category['_id']?.toString() ?? category['id']?.toString() ?? '';
    }
    return TicketModel(
      id: model.id,
      ticketNumber: model.ticketNumber,
      customer: model.customer,
      categoryId: catId,
      category: model.category,
      subject: model.subject,
      description: model.description,
      status: model.status,
      priority: model.priority,
      source: model.source,
      assignedTo: model.assignedTo,
      orderId: model.orderId,
      productId: model.productId,
      attachments: model.attachments,
      tags: model.tags,
      sla: model.sla,
      resolution: model.resolution,
      messageCount: model.messageCount,
      lastCustomerReplyAt: model.lastCustomerReplyAt,
      lastAgentReplyAt: model.lastAgentReplyAt,
      satisfactionRating: model.satisfactionRating,
      satisfactionFeedback: model.satisfactionFeedback,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );
  }
  Map<String, dynamic> toJson() => _$TicketModelToJson(this);

  /// هل التذكرة مفتوحة؟
  bool get isOpen =>
      ![TicketStatus.closed, TicketStatus.resolved].contains(status);

  /// هل يمكن التقييم؟
  bool get canRate =>
      status == TicketStatus.resolved && satisfactionRating == null;

  /// هل تم تجاوز SLA؟
  bool get isSlaBreached => sla.firstResponseBreached || sla.resolutionBreached;

  static TicketStatus _statusFromJson(String value) =>
      TicketStatus.fromString(value);
  static TicketPriority _priorityFromJson(String value) =>
      TicketPriority.fromString(value);
  static TicketSource _sourceFromJson(String value) =>
      TicketSource.fromString(value);
}

/// طلب إنشاء تذكرة
@JsonSerializable()
class CreateTicketRequest {
  @JsonKey(name: 'categoryId')
  final String categoryId;
  final String subject;
  final String description;
  final String? priority;
  final String? orderId;
  final String? productId;
  final List<String>? attachments;
  final String? source;
  @JsonKey(includeFromJson: false, includeToJson: false)
  final String? customerName;
  @JsonKey(includeFromJson: false, includeToJson: false)
  final String? customerEmail;

  const CreateTicketRequest({
    required this.categoryId,
    required this.subject,
    required this.description,
    this.priority,
    this.orderId,
    this.productId,
    this.attachments,
    this.source,
    this.customerName,
    this.customerEmail,
  });

  factory CreateTicketRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateTicketRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateTicketRequestToJson(this);
}
