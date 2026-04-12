part of 'ticket_models.dart';

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
