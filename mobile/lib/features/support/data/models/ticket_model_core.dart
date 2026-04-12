part of 'ticket_models.dart';

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
    final categoryId = _extractCategoryId(json['category']);
    return TicketModel(
      id: model.id,
      ticketNumber: model.ticketNumber,
      customer: model.customer,
      categoryId: categoryId,
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

  bool get isOpen =>
      ![TicketStatus.closed, TicketStatus.resolved].contains(status);

  bool get canRate =>
      status == TicketStatus.resolved && satisfactionRating == null;

  bool get isSlaBreached => sla.firstResponseBreached || sla.resolutionBreached;

  static TicketStatus _statusFromJson(String value) =>
      TicketStatus.fromString(value);
  static TicketPriority _priorityFromJson(String value) =>
      TicketPriority.fromString(value);
  static TicketSource _sourceFromJson(String value) =>
      TicketSource.fromString(value);
}
