/// Return Model - Data layer model with JSON serialization
library;

import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/return_entity.dart';
import 'return_components.dart';

export 'return_components.dart';
export 'return_requests.dart';

part 'return_model.g.dart';

/// Helper to extract ID from either String or Map
String extractIdFromJson(dynamic value) {
  if (value is String) return value;
  if (value is Map) return value['_id']?.toString() ?? '';
  return '';
}

/// Helper to extract orderIds from either List or single ID (backward compatibility)
List<String> extractOrderIdsFromJson(dynamic value) {
  if (value is List) {
    return value.map((e) => extractIdFromJson(e)).toList();
  }
  // Backward compatibility: if orderIds doesn't exist, check for orderId
  return [];
}

/// Return Request Model
@JsonSerializable()
class ReturnModel {
  @JsonKey(name: '_id', fromJson: extractIdFromJson)
  final String id;
  final String returnNumber;
  @JsonKey(fromJson: extractOrderIdsFromJson)
  final List<String> orderIds;
  @JsonKey(fromJson: extractIdFromJson)
  final String customerId;
  final String status;
  final String returnType;
  @JsonKey(fromJson: extractIdFromJson)
  final String reasonId;
  final ReturnReasonModel? reason;
  final String? customerNotes;
  final List<String>? customerImages;
  final double totalItemsValue;
  final double restockingFee;
  final double shippingDeduction;
  final double refundAmount;
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
    required this.orderIds,
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

  /// Get primary order ID (first in list)
  String get primaryOrderId => orderIds.isNotEmpty ? orderIds.first : '';

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
  DateTime? get scheduledPickupDateParsed => scheduledPickupDate != null
      ? DateTime.tryParse(scheduledPickupDate!)
      : null;
  DateTime? get approvedAtDate =>
      approvedAt != null ? DateTime.tryParse(approvedAt!) : null;
  DateTime? get rejectedAtDate =>
      rejectedAt != null ? DateTime.tryParse(rejectedAt!) : null;
  DateTime? get completedAtDate =>
      completedAt != null ? DateTime.tryParse(completedAt!) : null;

  /// Convert to domain entity
  ReturnEntity toEntity() {
    return ReturnEntity(
      id: id,
      returnNumber: returnNumber,
      orderIds: orderIds,
      customerId: customerId,
      status: statusEnum,
      returnType: returnTypeEnum,
      reasonId: reasonId,
      reason: reason?.toEntity(),
      customerNotes: customerNotes,
      customerImages: customerImages,
      totalItemsValue: totalItemsValue,
      restockingFee: restockingFee,
      shippingDeduction: shippingDeduction,
      refundAmount: refundAmount,
      scheduledPickupDate: scheduledPickupDateParsed,
      pickupTrackingNumber: pickupTrackingNumber,
      exchangeOrderId: exchangeOrderId,
      approvedAt: approvedAtDate,
      rejectedAt: rejectedAtDate,
      rejectionReason: rejectionReason,
      completedAt: completedAtDate,
      items: items?.map((item) => item.toEntity()).toList(),
      createdAt: createdAtDate ?? DateTime.now(),
      updatedAt: updatedAtDate ?? DateTime.now(),
    );
  }
}
