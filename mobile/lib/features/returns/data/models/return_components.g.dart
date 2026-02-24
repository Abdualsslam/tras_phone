// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'return_components.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReturnItemModel _$ReturnItemModelFromJson(Map<String, dynamic> json) =>
    ReturnItemModel(
      id: extractIdFromJson(json['_id']),
      returnRequestId: json['returnRequestId'] == null
          ? ''
          : extractIdFromJson(json['returnRequestId']),
      orderItemId: json['orderItemId'] == null
          ? ''
          : extractIdFromJson(json['orderItemId']),
      productId: extractIdFromJson(json['productId']),
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
      id: extractIdFromJson(json['_id']),
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
