/// Address Model - Data layer model for customer addresses
library;

import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/address_entity.dart';

part 'address_model.g.dart';

/// City model for populated cityId
@JsonSerializable()
class CityModel {
  @JsonKey(name: 'id', readValue: _readId)
  final String id;
  final String name;
  final String? nameAr;

  const CityModel({required this.id, required this.name, this.nameAr});

  static Object? _readId(Map<dynamic, dynamic> json, String key) {
    final value = json['_id'] ?? json['id'];
    if (value is Map) {
      return value['\$oid'] ?? value.toString();
    }
    return value?.toString();
  }

  factory CityModel.fromJson(Map<String, dynamic> json) =>
      _$CityModelFromJson(json);
  Map<String, dynamic> toJson() => _$CityModelToJson(this);

  String getName(String locale) =>
      locale == 'ar' && nameAr != null ? nameAr! : name;
}

class AddressModel {
  @JsonKey(name: 'id', readValue: _readId)
  final String id;

  @JsonKey(name: 'customerId', readValue: _readCustomerId)
  final String customerId;

  final String label;
  final String? recipientName;
  final String? phone;

  @JsonKey(name: 'cityId', readValue: _readCityId)
  final String? cityId;

  final String? cityName;
  final String? marketName;

  final String addressLine;
  final double latitude;
  final double longitude;
  final String? notes;

  @JsonKey(defaultValue: false)
  final bool isDefault;

  final DateTime createdAt;
  final DateTime updatedAt;

  // Populated city object
  @JsonKey(includeFromJson: true, includeToJson: false)
  final CityModel? city;

  const AddressModel({
    required this.id,
    required this.customerId,
    required this.label,
    this.recipientName,
    this.phone,
    this.cityId,
    this.cityName,
    this.marketName,
    required this.addressLine,
    required this.latitude,
    required this.longitude,
    this.notes,
    this.isDefault = false,
    required this.createdAt,
    required this.updatedAt,
    this.city,
  });

  /// Handle MongoDB _id or id field
  static Object? _readId(Map<dynamic, dynamic> json, String key) {
    final value = json['_id'] ?? json['id'];
    if (value is Map) {
      return value['\$oid'] ?? value.toString();
    }
    return value?.toString();
  }

  /// Handle customerId which can be String or populated object
  static Object? _readCustomerId(Map<dynamic, dynamic> json, String key) {
    final value = json['customerId'];
    if (value is String) return value;
    if (value is Map) {
      return value['_id']?.toString() ?? value['\$oid']?.toString();
    }
    return value?.toString();
  }

  /// Handle cityId which can be String or populated City object
  static Object? _readCityId(Map<dynamic, dynamic> json, String key) {
    final value = json['cityId'];
    if (value is String) return value;
    if (value is Map) {
      return value['_id']?.toString() ?? value['\$oid']?.toString();
    }
    return value?.toString();
  }

  /// Handle optional ID fields
  static Object? _readOptionalId(Map<dynamic, dynamic> json, String key) {
    final value = json[key];
    if (value == null) return null;
    if (value is String) return value;
    if (value is Map) {
      return value['_id']?.toString() ?? value['\$oid']?.toString();
    }
    return value.toString();
  }

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    // Extract city if populated
    CityModel? cityObj;
    if (json['cityId'] is Map) {
      cityObj = CityModel.fromJson(json['cityId'] as Map<String, dynamic>);
    }

    return AddressModel(
      id: _readId(json, 'id')?.toString() ?? '',
      customerId: _readCustomerId(json, 'customerId')?.toString() ?? '',
      label: json['label'] ?? '',
      recipientName: json['recipientName'] as String?,
      phone: json['phone'] as String?,
      cityId: _readCityId(json, 'cityId')?.toString(),
      cityName: json['cityName'] as String?,
      marketName: json['marketName'] as String?,
      addressLine: json['addressLine'] ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      notes: json['notes'] as String?,
      isDefault: json['isDefault'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      city: cityObj,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'customerId': customerId,
    'label': label,
    'recipientName': recipientName,
    'phone': phone,
    'cityId': cityId,
    'cityName': cityName,
    'marketName': marketName,
    'addressLine': addressLine,
    'latitude': latitude,
    'longitude': longitude,
    'notes': notes,
    'isDefault': isDefault,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  String get fullAddress {
    final parts = <String>[];
    parts.add(addressLine);
    if (city != null) {
      parts.add(city!.nameAr ?? city!.name);
    }
    return parts.join('، ');
  }

  /// Convert to domain entity
  AddressEntity toEntity() {
    return AddressEntity(
      id: id,
      customerId: customerId,
      label: label,
      recipientName: recipientName,
      phone: phone,
      cityId: cityId,
      cityName: cityName,
      marketName: marketName,
      addressLine: addressLine,
      latitude: latitude,
      longitude: longitude,
      notes: notes,
      isDefault: isDefault,
      createdAt: createdAt,
      updatedAt: updatedAt,
      city: city != null
          ? CityEntity(id: city!.id, name: city!.name, nameAr: city!.nameAr)
          : null,
    );
  }
}

/// Request model for creating/updating address
@JsonSerializable()
class AddressRequest {
  final String label;
  final String? recipientName;
  final String? phone;
  final String? cityId;
  final String? cityName;
  final String? marketName;
  final String addressLine;
  final double latitude;
  final double longitude;
  final String? notes;
  final bool isDefault;

  const AddressRequest({
    required this.label,
    this.recipientName,
    this.phone,
    this.cityId,
    this.cityName,
    this.marketName,
    required this.addressLine,
    required this.latitude,
    required this.longitude,
    this.notes,
    this.isDefault = false,
  });

  factory AddressRequest.fromJson(Map<String, dynamic> json) =>
      _$AddressRequestFromJson(json);
  Map<String, dynamic> toJson() => _$AddressRequestToJson(this);
}
