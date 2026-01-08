// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shipping_address_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ShippingAddressModel _$ShippingAddressModelFromJson(
  Map<String, dynamic> json,
) => ShippingAddressModel(
  fullName: json['fullName'] as String,
  phone: json['phone'] as String,
  address: json['address'] as String,
  city: json['city'] as String,
  district: json['district'] as String?,
  postalCode: json['postalCode'] as String?,
  notes: json['notes'] as String?,
);

Map<String, dynamic> _$ShippingAddressModelToJson(
  ShippingAddressModel instance,
) => <String, dynamic>{
  'fullName': instance.fullName,
  'phone': instance.phone,
  'address': instance.address,
  'city': instance.city,
  'district': instance.district,
  'postalCode': instance.postalCode,
  'notes': instance.notes,
};
