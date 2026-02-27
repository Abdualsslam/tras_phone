// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'return_requests.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateReturnRequest _$CreateReturnRequestFromJson(Map<String, dynamic> json) =>
    CreateReturnRequest(
      returnType: json['returnType'] as String,
      reasonId: json['reasonId'] as String,
      customerNotes: json['customerNotes'] as String?,
      customerImages: (json['customerImages'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      items: (json['items'] as List<dynamic>)
          .map(
            (e) => CreateReturnItemRequest.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    );

Map<String, dynamic> _$CreateReturnRequestToJson(
  CreateReturnRequest instance,
) => <String, dynamic>{
  'returnType': instance.returnType,
  'reasonId': instance.reasonId,
  'customerNotes': instance.customerNotes,
  'customerImages': instance.customerImages,
  'items': instance.items,
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
