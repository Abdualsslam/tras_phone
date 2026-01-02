/// Return Model - Data layer model with JSON serialization
library;

import 'package:json_annotation/json_annotation.dart';

part 'return_model.g.dart';

/// Return Status Enum
enum ReturnStatus {
  pending,
  approved,
  rejected,
  processing,
  shipped,
  received,
  refunded,
  completed,
  cancelled;

  String get displayName {
    switch (this) {
      case ReturnStatus.pending:
        return 'قيد المراجعة';
      case ReturnStatus.approved:
        return 'مقبول';
      case ReturnStatus.rejected:
        return 'مرفوض';
      case ReturnStatus.processing:
        return 'قيد المعالجة';
      case ReturnStatus.shipped:
        return 'تم الشحن';
      case ReturnStatus.received:
        return 'تم الاستلام';
      case ReturnStatus.refunded:
        return 'تم الاسترداد';
      case ReturnStatus.completed:
        return 'مكتمل';
      case ReturnStatus.cancelled:
        return 'ملغي';
    }
  }
}

@JsonSerializable()
class ReturnModel {
  final int id;
  @JsonKey(name: 'return_number')
  final String returnNumber;
  @JsonKey(name: 'order_id')
  final int orderId;
  @JsonKey(name: 'order_number')
  final String? orderNumber;
  final String status;
  final String reason;
  @JsonKey(name: 'reason_details')
  final String? reasonDetails;
  final List<ReturnItemModel> items;
  @JsonKey(name: 'refund_amount')
  final double refundAmount;
  @JsonKey(name: 'refund_method')
  final String? refundMethod;
  final List<String>? images;
  @JsonKey(name: 'admin_notes')
  final String? adminNotes;
  @JsonKey(name: 'created_at')
  final String createdAt;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  const ReturnModel({
    required this.id,
    required this.returnNumber,
    required this.orderId,
    this.orderNumber,
    required this.status,
    required this.reason,
    this.reasonDetails,
    this.items = const [],
    required this.refundAmount,
    this.refundMethod,
    this.images,
    this.adminNotes,
    required this.createdAt,
    this.updatedAt,
  });

  factory ReturnModel.fromJson(Map<String, dynamic> json) =>
      _$ReturnModelFromJson(json);
  Map<String, dynamic> toJson() => _$ReturnModelToJson(this);

  ReturnStatus get statusEnum {
    return ReturnStatus.values.firstWhere(
      (s) => s.name == status.toLowerCase(),
      orElse: () => ReturnStatus.pending,
    );
  }
}

@JsonSerializable()
class ReturnItemModel {
  final int id;
  @JsonKey(name: 'product_id')
  final int productId;
  @JsonKey(name: 'product_name')
  final String productName;
  @JsonKey(name: 'product_image')
  final String? productImage;
  final int quantity;
  @JsonKey(name: 'unit_price')
  final double unitPrice;
  final String? reason;
  final String? condition;

  const ReturnItemModel({
    required this.id,
    required this.productId,
    required this.productName,
    this.productImage,
    required this.quantity,
    required this.unitPrice,
    this.reason,
    this.condition,
  });

  factory ReturnItemModel.fromJson(Map<String, dynamic> json) =>
      _$ReturnItemModelFromJson(json);
  Map<String, dynamic> toJson() => _$ReturnItemModelToJson(this);
}

@JsonSerializable()
class ReturnReasonModel {
  final int id;
  final String name;
  @JsonKey(name: 'name_ar')
  final String? nameAr;
  @JsonKey(name: 'requires_details')
  final bool requiresDetails;
  @JsonKey(name: 'requires_images')
  final bool requiresImages;

  const ReturnReasonModel({
    required this.id,
    required this.name,
    this.nameAr,
    this.requiresDetails = false,
    this.requiresImages = false,
  });

  factory ReturnReasonModel.fromJson(Map<String, dynamic> json) =>
      _$ReturnReasonModelFromJson(json);
  Map<String, dynamic> toJson() => _$ReturnReasonModelToJson(this);

  String get displayName => nameAr ?? name;
}

@JsonSerializable()
class CreateReturnRequest {
  @JsonKey(name: 'order_id')
  final int orderId;
  @JsonKey(name: 'reason_id')
  final int reasonId;
  @JsonKey(name: 'reason_details')
  final String? reasonDetails;
  final List<CreateReturnItemRequest> items;
  final List<String>? images;

  const CreateReturnRequest({
    required this.orderId,
    required this.reasonId,
    this.reasonDetails,
    required this.items,
    this.images,
  });

  factory CreateReturnRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateReturnRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateReturnRequestToJson(this);
}

@JsonSerializable()
class CreateReturnItemRequest {
  @JsonKey(name: 'order_item_id')
  final int orderItemId;
  final int quantity;
  final String? condition;

  const CreateReturnItemRequest({
    required this.orderItemId,
    required this.quantity,
    this.condition,
  });

  factory CreateReturnItemRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateReturnItemRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateReturnItemRequestToJson(this);
}
