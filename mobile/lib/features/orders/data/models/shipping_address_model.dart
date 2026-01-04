/// Shipping Address Model - Data layer model for order shipping
library;

import 'package:json_annotation/json_annotation.dart';

part 'shipping_address_model.g.dart';

@JsonSerializable()
class ShippingAddressModel {
  final String fullName;
  final String phone;
  final String address;
  final String city;
  final String? district;
  final String? postalCode;
  final String? notes;

  const ShippingAddressModel({
    required this.fullName,
    required this.phone,
    required this.address,
    required this.city,
    this.district,
    this.postalCode,
    this.notes,
  });

  factory ShippingAddressModel.fromJson(Map<String, dynamic> json) =>
      _$ShippingAddressModelFromJson(json);
  Map<String, dynamic> toJson() => _$ShippingAddressModelToJson(this);

  /// Full formatted address
  String get formattedAddress {
    final parts = <String>[address];
    if (district != null) parts.add(district!);
    parts.add(city);
    return parts.join('، ');
  }
}
