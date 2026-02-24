// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'return_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReturnModel _$ReturnModelFromJson(Map<String, dynamic> json) => ReturnModel(
  id: extractIdFromJson(json['_id']),
  returnNumber: json['returnNumber'] as String,
  orderIds: extractOrderIdsFromJson(json['orderIds']),
  customerId: extractIdFromJson(json['customerId']),
  status: json['status'] as String,
  returnType: json['returnType'] as String,
  reasonId: extractIdFromJson(json['reasonId']),
  reason: json['reason'] == null
      ? null
      : ReturnReasonModel.fromJson(json['reason'] as Map<String, dynamic>),
  customerNotes: json['customerNotes'] as String?,
  customerImages: (json['customerImages'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  totalItemsValue: (json['totalItemsValue'] as num?)?.toDouble() ?? 0,
  restockingFee: (json['restockingFee'] as num?)?.toDouble() ?? 0,
  shippingDeduction: (json['shippingDeduction'] as num?)?.toDouble() ?? 0,
  refundAmount: (json['refundAmount'] as num?)?.toDouble() ?? 0,
  scheduledPickupDate: json['scheduledPickupDate'] as String?,
  pickupTrackingNumber: json['pickupTrackingNumber'] as String?,
  exchangeOrderId: json['exchangeOrderId'] as String?,
  approvedAt: json['approvedAt'] as String?,
  rejectedAt: json['rejectedAt'] as String?,
  rejectionReason: json['rejectionReason'] as String?,
  completedAt: json['completedAt'] as String?,
  items: (json['items'] as List<dynamic>?)
      ?.map((e) => ReturnItemModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  createdAt: json['createdAt'] as String,
  updatedAt: json['updatedAt'] as String,
);

Map<String, dynamic> _$ReturnModelToJson(ReturnModel instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'returnNumber': instance.returnNumber,
      'orderIds': instance.orderIds,
      'customerId': instance.customerId,
      'status': instance.status,
      'returnType': instance.returnType,
      'reasonId': instance.reasonId,
      'reason': instance.reason,
      'customerNotes': instance.customerNotes,
      'customerImages': instance.customerImages,
      'totalItemsValue': instance.totalItemsValue,
      'restockingFee': instance.restockingFee,
      'shippingDeduction': instance.shippingDeduction,
      'refundAmount': instance.refundAmount,
      'scheduledPickupDate': instance.scheduledPickupDate,
      'pickupTrackingNumber': instance.pickupTrackingNumber,
      'exchangeOrderId': instance.exchangeOrderId,
      'approvedAt': instance.approvedAt,
      'rejectedAt': instance.rejectedAt,
      'rejectionReason': instance.rejectionReason,
      'completedAt': instance.completedAt,
      'items': instance.items,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
    };
