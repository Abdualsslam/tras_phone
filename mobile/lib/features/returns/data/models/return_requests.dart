import 'package:json_annotation/json_annotation.dart';

part 'return_requests.g.dart';

/// Create Return Request
@JsonSerializable()
class CreateReturnRequest {
  final String returnType;
  final String reasonId;
  final String? customerNotes;
  final List<String>? customerImages;
  final List<CreateReturnItemRequest> items;

  const CreateReturnRequest({
    required this.returnType,
    required this.reasonId,
    this.customerNotes,
    this.customerImages,
    required this.items,
  });

  factory CreateReturnRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateReturnRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateReturnRequestToJson(this);
}

/// Create Return Item Request
@JsonSerializable()
class CreateReturnItemRequest {
  final String orderItemId;
  final int quantity;

  const CreateReturnItemRequest({
    required this.orderItemId,
    required this.quantity,
  });

  factory CreateReturnItemRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateReturnItemRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateReturnItemRequestToJson(this);
}
