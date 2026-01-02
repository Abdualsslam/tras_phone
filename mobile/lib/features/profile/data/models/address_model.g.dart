// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'address_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AddressModel _$AddressModelFromJson(Map<String, dynamic> json) => AddressModel(
  id: (json['id'] as num).toInt(),
  title: json['title'] as String,
  recipientName: json['recipient_name'] as String,
  phone: json['phone'] as String,
  countryId: (json['country_id'] as num?)?.toInt(),
  cityId: (json['city_id'] as num?)?.toInt(),
  areaId: (json['area_id'] as num?)?.toInt(),
  country: json['country'] as String?,
  city: json['city'] as String?,
  area: json['area'] as String?,
  street: json['street'] as String?,
  buildingNumber: json['building_number'] as String?,
  floorNumber: json['floor_number'] as String?,
  apartmentNumber: json['apartment_number'] as String?,
  postalCode: json['postal_code'] as String?,
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
  isDefault: json['is_default'] as bool? ?? false,
  addressType: json['address_type'] as String? ?? 'home',
);

Map<String, dynamic> _$AddressModelToJson(AddressModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'recipient_name': instance.recipientName,
      'phone': instance.phone,
      'country_id': instance.countryId,
      'city_id': instance.cityId,
      'area_id': instance.areaId,
      'country': instance.country,
      'city': instance.city,
      'area': instance.area,
      'street': instance.street,
      'building_number': instance.buildingNumber,
      'floor_number': instance.floorNumber,
      'apartment_number': instance.apartmentNumber,
      'postal_code': instance.postalCode,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'is_default': instance.isDefault,
      'address_type': instance.addressType,
    };

AddressRequest _$AddressRequestFromJson(Map<String, dynamic> json) =>
    AddressRequest(
      title: json['title'] as String,
      recipientName: json['recipient_name'] as String,
      phone: json['phone'] as String,
      cityId: (json['city_id'] as num).toInt(),
      areaId: (json['area_id'] as num?)?.toInt(),
      street: json['street'] as String?,
      buildingNumber: json['building_number'] as String?,
      isDefault: json['is_default'] as bool? ?? false,
      addressType: json['address_type'] as String? ?? 'home',
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$AddressRequestToJson(AddressRequest instance) =>
    <String, dynamic>{
      'title': instance.title,
      'recipient_name': instance.recipientName,
      'phone': instance.phone,
      'city_id': instance.cityId,
      'area_id': instance.areaId,
      'street': instance.street,
      'building_number': instance.buildingNumber,
      'is_default': instance.isDefault,
      'address_type': instance.addressType,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
    };
