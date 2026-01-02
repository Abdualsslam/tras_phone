// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'return_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReturnModel _$ReturnModelFromJson(Map<String, dynamic> json) => ReturnModel(
  id: (json['id'] as num).toInt(),
  returnNumber: json['return_number'] as String,
  orderId: (json['order_id'] as num).toInt(),
  orderNumber: json['order_number'] as String?,
  status: json['status'] as String,
  reason: json['reason'] as String,
  reasonDetails: json['reason_details'] as String?,
  items:
      (json['items'] as List<dynamic>?)
          ?.map((e) => ReturnItemModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  refundAmount: (json['refund_amount'] as num).toDouble(),
  refundMethod: json['refund_method'] as String?,
  images: (json['images'] as List<dynamic>?)?.map((e) => e as String).toList(),
  adminNotes: json['admin_notes'] as String?,
  createdAt: json['created_at'] as String,
  updatedAt: json['updated_at'] as String?,
);

Map<String, dynamic> _$ReturnModelToJson(ReturnModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'return_number': instance.returnNumber,
      'order_id': instance.orderId,
      'order_number': instance.orderNumber,
      'status': instance.status,
      'reason': instance.reason,
      'reason_details': instance.reasonDetails,
      'items': instance.items,
      'refund_amount': instance.refundAmount,
      'refund_method': instance.refundMethod,
      'images': instance.images,
      'admin_notes': instance.adminNotes,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };

ReturnItemModel _$ReturnItemModelFromJson(Map<String, dynamic> json) =>
    ReturnItemModel(
      id: (json['id'] as num).toInt(),
      productId: (json['product_id'] as num).toInt(),
      productName: json['product_name'] as String,
      productImage: json['product_image'] as String?,
      quantity: (json['quantity'] as num).toInt(),
      unitPrice: (json['unit_price'] as num).toDouble(),
      reason: json['reason'] as String?,
      condition: json['condition'] as String?,
    );

Map<String, dynamic> _$ReturnItemModelToJson(ReturnItemModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'product_id': instance.productId,
      'product_name': instance.productName,
      'product_image': instance.productImage,
      'quantity': instance.quantity,
      'unit_price': instance.unitPrice,
      'reason': instance.reason,
      'condition': instance.condition,
    };

ReturnReasonModel _$ReturnReasonModelFromJson(Map<String, dynamic> json) =>
    ReturnReasonModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      nameAr: json['name_ar'] as String?,
      requiresDetails: json['requires_details'] as bool? ?? false,
      requiresImages: json['requires_images'] as bool? ?? false,
    );

Map<String, dynamic> _$ReturnReasonModelToJson(ReturnReasonModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'name_ar': instance.nameAr,
      'requires_details': instance.requiresDetails,
      'requires_images': instance.requiresImages,
    };

CreateReturnRequest _$CreateReturnRequestFromJson(
  Map<String, dynamic> json,
) => CreateReturnRequest(
  orderId: (json['order_id'] as num).toInt(),
  reasonId: (json['reason_id'] as num).toInt(),
  reasonDetails: json['reason_details'] as String?,
  items: (json['items'] as List<dynamic>)
      .map((e) => CreateReturnItemRequest.fromJson(e as Map<String, dynamic>))
      .toList(),
  images: (json['images'] as List<dynamic>?)?.map((e) => e as String).toList(),
);

Map<String, dynamic> _$CreateReturnRequestToJson(
  CreateReturnRequest instance,
) => <String, dynamic>{
  'order_id': instance.orderId,
  'reason_id': instance.reasonId,
  'reason_details': instance.reasonDetails,
  'items': instance.items,
  'images': instance.images,
};

CreateReturnItemRequest _$CreateReturnItemRequestFromJson(
  Map<String, dynamic> json,
) => CreateReturnItemRequest(
  orderItemId: (json['order_item_id'] as num).toInt(),
  quantity: (json['quantity'] as num).toInt(),
  condition: json['condition'] as String?,
);

Map<String, dynamic> _$CreateReturnItemRequestToJson(
  CreateReturnItemRequest instance,
) => <String, dynamic>{
  'order_item_id': instance.orderItemId,
  'quantity': instance.quantity,
  'condition': instance.condition,
};
