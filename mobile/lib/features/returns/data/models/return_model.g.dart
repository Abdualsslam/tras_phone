// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'return_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PickupAddress _$PickupAddressFromJson(Map<String, dynamic> json) =>
    PickupAddress(
      fullName: json['fullName'] as String,
      phone: json['phone'] as String,
      address: json['address'] as String,
      city: json['city'] as String,
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$PickupAddressToJson(PickupAddress instance) =>
    <String, dynamic>{
      'fullName': instance.fullName,
      'phone': instance.phone,
      'address': instance.address,
      'city': instance.city,
      'notes': instance.notes,
    };

ReturnModel _$ReturnModelFromJson(Map<String, dynamic> json) => ReturnModel(
  id: ReturnModel._idFromJson(json['_id']),
  returnNumber: json['returnNumber'] as String,
  orderIds: ReturnModel._orderIdsFromJson(json['orderIds']),
  customerId: ReturnModel._idFromJson(json['customerId']),
  status: json['status'] as String,
  returnType: json['returnType'] as String,
  reasonId: ReturnModel._idFromJson(json['reasonId']),
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
  pickupAddress: json['pickupAddress'] == null
      ? null
      : PickupAddress.fromJson(json['pickupAddress'] as Map<String, dynamic>),
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
      'pickupAddress': instance.pickupAddress,
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

ReturnItemModel _$ReturnItemModelFromJson(Map<String, dynamic> json) =>
    ReturnItemModel(
      id: ReturnModel._idFromJson(json['_id']),
      returnRequestId: json['returnRequestId'] == null
          ? ''
          : ReturnModel._idFromJson(json['returnRequestId']),
      orderItemId: json['orderItemId'] == null
          ? ''
          : ReturnModel._idFromJson(json['orderItemId']),
      productId: ReturnModel._idFromJson(json['productId']),
      productSku: json['productSku'] as String? ?? '',
      productName: json['productName'] as String,
      productImage: json['productImage'] as String?,
      quantity: (json['quantity'] as num).toInt(),
      unitPrice: (json['unitPrice'] as num).toDouble(),
      totalValue: (json['totalValue'] as num?)?.toDouble() ?? 0,
      inspectionStatus: json['inspectionStatus'] as String? ?? 'pending',
      condition: json['condition'] as String?,
      approvedQuantity: (json['approvedQuantity'] as num?)?.toInt() ?? 0,
      rejectedQuantity: (json['rejectedQuantity'] as num?)?.toInt() ?? 0,
      inspectionNotes: json['inspectionNotes'] as String?,
    );

Map<String, dynamic> _$ReturnItemModelToJson(ReturnItemModel instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'returnRequestId': instance.returnRequestId,
      'orderItemId': instance.orderItemId,
      'productId': instance.productId,
      'productSku': instance.productSku,
      'productName': instance.productName,
      'productImage': instance.productImage,
      'quantity': instance.quantity,
      'unitPrice': instance.unitPrice,
      'totalValue': instance.totalValue,
      'inspectionStatus': instance.inspectionStatus,
      'condition': instance.condition,
      'approvedQuantity': instance.approvedQuantity,
      'rejectedQuantity': instance.rejectedQuantity,
      'inspectionNotes': instance.inspectionNotes,
    };

ReturnReasonModel _$ReturnReasonModelFromJson(Map<String, dynamic> json) =>
    ReturnReasonModel(
      id: ReturnModel._idFromJson(json['_id']),
      name: json['name'] as String,
      nameAr: json['nameAr'] as String,
      description: json['description'] as String?,
      category: json['category'] as String? ?? 'other',
      requiresPhoto: json['requiresPhoto'] as bool? ?? true,
      eligibleForRefund: json['eligibleForRefund'] as bool? ?? true,
      eligibleForExchange: json['eligibleForExchange'] as bool? ?? true,
      displayOrder: (json['displayOrder'] as num?)?.toInt() ?? 0,
      isActive: json['isActive'] as bool? ?? true,
    );

Map<String, dynamic> _$ReturnReasonModelToJson(ReturnReasonModel instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'name': instance.name,
      'nameAr': instance.nameAr,
      'description': instance.description,
      'category': instance.category,
      'requiresPhoto': instance.requiresPhoto,
      'eligibleForRefund': instance.eligibleForRefund,
      'eligibleForExchange': instance.eligibleForExchange,
      'displayOrder': instance.displayOrder,
      'isActive': instance.isActive,
    };

CreateReturnRequest _$CreateReturnRequestFromJson(
  Map<String, dynamic> json,
) => CreateReturnRequest(
  returnType: json['returnType'] as String,
  reasonId: json['reasonId'] as String,
  customerNotes: json['customerNotes'] as String?,
  customerImages: (json['customerImages'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  items: (json['items'] as List<dynamic>)
      .map((e) => CreateReturnItemRequest.fromJson(e as Map<String, dynamic>))
      .toList(),
  pickupAddress: json['pickupAddress'] == null
      ? null
      : PickupAddress.fromJson(json['pickupAddress'] as Map<String, dynamic>),
);

Map<String, dynamic> _$CreateReturnRequestToJson(
  CreateReturnRequest instance,
) => <String, dynamic>{
  'returnType': instance.returnType,
  'reasonId': instance.reasonId,
  'customerNotes': instance.customerNotes,
  'customerImages': instance.customerImages,
  'items': instance.items,
  'pickupAddress': instance.pickupAddress,
};

CreateReturnItemRequest _$CreateReturnItemRequestFromJson(
  Map<String, dynamic> json,
) => CreateReturnItemRequest(
  orderItemId: json['orderItemId'] as String,
  quantity: (json['quantity'] as num).toInt(),
);

Map<String, dynamic> _$CreateReturnItemRequestToJson(
  CreateReturnItemRequest instance,
) => <String, dynamic>{
  'orderItemId': instance.orderItemId,
  'quantity': instance.quantity,
};
