// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'address_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CityModel _$CityModelFromJson(Map<String, dynamic> json) => CityModel(
  id: CityModel._readId(json, 'id') as String,
  name: json['name'] as String,
  nameAr: json['nameAr'] as String?,
);

Map<String, dynamic> _$CityModelToJson(CityModel instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'nameAr': instance.nameAr,
};

AddressModel _$AddressModelFromJson(Map<String, dynamic> json) => AddressModel(
  id: AddressModel._readId(json, 'id') as String,
  customerId: AddressModel._readCustomerId(json, 'customerId') as String,
  label: json['label'] as String,
  recipientName: json['recipientName'] as String?,
  phone: json['phone'] as String?,
  cityId: AddressModel._readCityId(json, 'cityId') as String,
  marketId: AddressModel._readOptionalId(json, 'marketId') as String?,
  addressLine: json['addressLine'] as String,
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
  isDefault: json['isDefault'] as bool? ?? false,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  city: json['city'] == null
      ? null
      : CityModel.fromJson(json['city'] as Map<String, dynamic>),
);

Map<String, dynamic> _$AddressModelToJson(AddressModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'customerId': instance.customerId,
      'label': instance.label,
      'recipientName': instance.recipientName,
      'phone': instance.phone,
      'cityId': instance.cityId,
      'marketId': instance.marketId,
      'addressLine': instance.addressLine,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'isDefault': instance.isDefault,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

AddressRequest _$AddressRequestFromJson(Map<String, dynamic> json) =>
    AddressRequest(
      label: json['label'] as String,
      recipientName: json['recipientName'] as String?,
      phone: json['phone'] as String?,
      cityId: json['cityId'] as String,
      marketId: json['marketId'] as String?,
      addressLine: json['addressLine'] as String,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      isDefault: json['isDefault'] as bool? ?? false,
    );

Map<String, dynamic> _$AddressRequestToJson(AddressRequest instance) =>
    <String, dynamic>{
      'label': instance.label,
      'recipientName': instance.recipientName,
      'phone': instance.phone,
      'cityId': instance.cityId,
      'marketId': instance.marketId,
      'addressLine': instance.addressLine,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'isDefault': instance.isDefault,
    };
