/// Return Model - Data layer model with JSON serialization
library;

import 'package:json_annotation/json_annotation.dart';
import '../../domain/enums/return_enums.dart';

part 'return_model.g.dart';

/// عنوان الاستلام
@JsonSerializable()
class PickupAddress {
  final String fullName;
  final String phone;
  final String address;
  final String city;
  final String? notes;

  const PickupAddress({
    required this.fullName,
    required this.phone,
    required this.address,
    required this.city,
    this.notes,
  });

  factory PickupAddress.fromJson(Map<String, dynamic> json) =>
      _$PickupAddressFromJson(json);
  Map<String, dynamic> toJson() => _$PickupAddressToJson(this);
}

/// Return Request Model
@JsonSerializable()
class ReturnModel {
  @JsonKey(name: '_id', fromJson: _idFromJson)
  final String id;
  final String returnNumber;
  @JsonKey(fromJson: _idFromJson)
  final String orderId;
  @JsonKey(fromJson: _idFromJson)
  final String customerId;
  final String status;
  final String returnType;
  @JsonKey(fromJson: _idFromJson)
  final String reasonId;
  final ReturnReasonModel? reason;
  final String? customerNotes;
  final List<String>? customerImages;
  final double totalItemsValue;
  final double restockingFee;
  final double shippingDeduction;
  final double refundAmount;
  final PickupAddress? pickupAddress;
  final String? scheduledPickupDate;
  final String? pickupTrackingNumber;
  final String? exchangeOrderId;
  final String? approvedAt;
  final String? rejectedAt;
  final String? rejectionReason;
  final String? completedAt;
  final List<ReturnItemModel>? items;
  final String createdAt;
  final String updatedAt;

  const ReturnModel({
    required this.id,
    required this.returnNumber,
    required this.orderId,
    required this.customerId,
    required this.status,
    required this.returnType,
    required this.reasonId,
    this.reason,
    this.customerNotes,
    this.customerImages,
    this.totalItemsValue = 0,
    this.restockingFee = 0,
    this.shippingDeduction = 0,
    this.refundAmount = 0,
    this.pickupAddress,
    this.scheduledPickupDate,
    this.pickupTrackingNumber,
    this.exchangeOrderId,
    this.approvedAt,
    this.rejectedAt,
    this.rejectionReason,
    this.completedAt,
    this.items,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ReturnModel.fromJson(Map<String, dynamic> json) =>
      _$ReturnModelFromJson(json);
  Map<String, dynamic> toJson() => _$ReturnModelToJson(this);

  /// Helper to extract ID from either String or Map
  static String _idFromJson(dynamic value) {
    if (value is String) return value;
    if (value is Map) return value['_id']?.toString() ?? '';
    return '';
  }

  ReturnStatus get statusEnum => ReturnStatus.fromString(status);
  ReturnType get returnTypeEnum => ReturnType.fromString(returnType);

  /// هل يمكن إلغاء الطلب؟
  bool get canCancel => statusEnum == ReturnStatus.pending;

  /// هل الطلب نشط؟
  bool get isActive => ![
        ReturnStatus.completed,
        ReturnStatus.cancelled,
        ReturnStatus.rejected,
      ].contains(statusEnum);

  /// المبلغ الصافي للاسترداد
  double get netRefund => totalItemsValue - restockingFee - shippingDeduction;

  DateTime? get createdAtDate => DateTime.tryParse(createdAt);
  DateTime? get updatedAtDate => DateTime.tryParse(updatedAt);
  DateTime? get scheduledPickupDateParsed =>
      scheduledPickupDate != null ? DateTime.tryParse(scheduledPickupDate!) : null;
  DateTime? get approvedAtDate =>
      approvedAt != null ? DateTime.tryParse(approvedAt!) : null;
  DateTime? get rejectedAtDate =>
      rejectedAt != null ? DateTime.tryParse(rejectedAt!) : null;
  DateTime? get completedAtDate =>
      completedAt != null ? DateTime.tryParse(completedAt!) : null;
}

/// Return Item Model
@JsonSerializable()
class ReturnItemModel {
  @JsonKey(name: '_id', fromJson: ReturnModel._idFromJson)
  final String id;
  @JsonKey(fromJson: ReturnModel._idFromJson)
  final String returnRequestId;
  @JsonKey(fromJson: ReturnModel._idFromJson)
  final String orderItemId;
  @JsonKey(fromJson: ReturnModel._idFromJson)
  final String productId;
  final String productSku;
  final String productName;
  final String? productImage;
  final int quantity;
  final double unitPrice;
  final double totalValue;
  final String inspectionStatus;
  final String? condition;
  final int approvedQuantity;
  final int rejectedQuantity;
  final String? inspectionNotes;

  const ReturnItemModel({
    required this.id,
    this.returnRequestId = '',
    this.orderItemId = '',
    required this.productId,
    this.productSku = '',
    required this.productName,
    this.productImage,
    required this.quantity,
    required this.unitPrice,
    this.totalValue = 0,
    this.inspectionStatus = 'pending',
    this.condition,
    this.approvedQuantity = 0,
    this.rejectedQuantity = 0,
    this.inspectionNotes,
  });

  factory ReturnItemModel.fromJson(Map<String, dynamic> json) =>
      _$ReturnItemModelFromJson(json);
  Map<String, dynamic> toJson() => _$ReturnItemModelToJson(this);

  InspectionStatus get inspectionStatusEnum =>
      InspectionStatus.fromString(inspectionStatus);
  ItemCondition? get conditionEnum =>
      condition != null ? ItemCondition.fromString(condition!) : null;
}

/// Return Reason Model
@JsonSerializable()
class ReturnReasonModel {
  @JsonKey(name: '_id', fromJson: ReturnModel._idFromJson)
  final String id;
  final String name;
  final String nameAr;
  final String? description;
  final String category;
  final bool requiresPhoto;
  final bool eligibleForRefund;
  final bool eligibleForExchange;
  final int displayOrder;
  final bool isActive;

  const ReturnReasonModel({
    required this.id,
    required this.name,
    required this.nameAr,
    this.description,
    this.category = 'other',
    this.requiresPhoto = true,
    this.eligibleForRefund = true,
    this.eligibleForExchange = true,
    this.displayOrder = 0,
    this.isActive = true,
  });

  factory ReturnReasonModel.fromJson(Map<String, dynamic> json) =>
      _$ReturnReasonModelFromJson(json);
  Map<String, dynamic> toJson() => _$ReturnReasonModelToJson(this);

  ReasonCategory get categoryEnum => ReasonCategory.fromString(category);

  /// الحصول على الاسم حسب اللغة
  String getName(String locale) => locale == 'ar' ? nameAr : name;
}

/// Create Return Request
@JsonSerializable()
class CreateReturnRequest {
  final String orderId;
  final String returnType;
  final String reasonId;
  final String? customerNotes;
  final List<String>? customerImages;
  final List<CreateReturnItemRequest> items;
  final PickupAddress? pickupAddress;

  const CreateReturnRequest({
    required this.orderId,
    required this.returnType,
    required this.reasonId,
    this.customerNotes,
    this.customerImages,
    required this.items,
    this.pickupAddress,
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
