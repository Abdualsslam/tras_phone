/// Address Model - Data layer model for customer addresses
library;

import 'package:json_annotation/json_annotation.dart';

part 'address_model.g.dart';

@JsonSerializable()
class AddressModel {
  final int id;
  final String title;
  @JsonKey(name: 'recipient_name')
  final String recipientName;
  final String phone;
  @JsonKey(name: 'country_id')
  final int? countryId;
  @JsonKey(name: 'city_id')
  final int? cityId;
  @JsonKey(name: 'area_id')
  final int? areaId;
  final String? country;
  final String? city;
  final String? area;
  final String? street;
  @JsonKey(name: 'building_number')
  final String? buildingNumber;
  @JsonKey(name: 'floor_number')
  final String? floorNumber;
  @JsonKey(name: 'apartment_number')
  final String? apartmentNumber;
  @JsonKey(name: 'postal_code')
  final String? postalCode;
  final double? latitude;
  final double? longitude;
  @JsonKey(name: 'is_default')
  final bool isDefault;
  @JsonKey(name: 'address_type')
  final String addressType; // 'home', 'work', 'other'

  const AddressModel({
    required this.id,
    required this.title,
    required this.recipientName,
    required this.phone,
    this.countryId,
    this.cityId,
    this.areaId,
    this.country,
    this.city,
    this.area,
    this.street,
    this.buildingNumber,
    this.floorNumber,
    this.apartmentNumber,
    this.postalCode,
    this.latitude,
    this.longitude,
    this.isDefault = false,
    this.addressType = 'home',
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) =>
      _$AddressModelFromJson(json);
  Map<String, dynamic> toJson() => _$AddressModelToJson(this);

  String get fullAddress {
    final parts = <String>[];
    if (street != null) parts.add(street!);
    if (buildingNumber != null) parts.add('مبنى $buildingNumber');
    if (area != null) parts.add(area!);
    if (city != null) parts.add(city!);
    return parts.join('، ');
  }
}

/// Request model for creating/updating address
@JsonSerializable()
class AddressRequest {
  final String title;
  @JsonKey(name: 'recipient_name')
  final String recipientName;
  final String phone;
  @JsonKey(name: 'city_id')
  final int cityId;
  @JsonKey(name: 'area_id')
  final int? areaId;
  final String? street;
  @JsonKey(name: 'building_number')
  final String? buildingNumber;
  @JsonKey(name: 'is_default')
  final bool isDefault;
  @JsonKey(name: 'address_type')
  final String addressType;
  final double? latitude;
  final double? longitude;

  const AddressRequest({
    required this.title,
    required this.recipientName,
    required this.phone,
    required this.cityId,
    this.areaId,
    this.street,
    this.buildingNumber,
    this.isDefault = false,
    this.addressType = 'home',
    this.latitude,
    this.longitude,
  });

  factory AddressRequest.fromJson(Map<String, dynamic> json) =>
      _$AddressRequestFromJson(json);
  Map<String, dynamic> toJson() => _$AddressRequestToJson(this);
}
