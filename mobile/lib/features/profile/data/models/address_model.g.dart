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
