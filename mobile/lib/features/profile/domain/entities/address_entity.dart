/// Address Entity - Domain layer entity for customer addresses
library;

/// City entity
class CityEntity {
  final String id;
  final String name;
  final String? nameAr;

  const CityEntity({
    required this.id,
    required this.name,
    this.nameAr,
  });

  String getName(String locale) =>
      locale == 'ar' && nameAr != null ? nameAr! : name;
}

/// Address entity representing a customer's delivery address
class AddressEntity {
  final String id;
  final String customerId;
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
  final DateTime createdAt;
  final DateTime updatedAt;
  final CityEntity? city;

  const AddressEntity({
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

  String get fullAddress {
    final parts = <String>[];
    parts.add(addressLine);
    if (city != null) {
      parts.add(city!.nameAr ?? city!.name);
    }
    return parts.join('، ');
  }

  AddressEntity copyWith({
    String? id,
    String? customerId,
    String? label,
    String? recipientName,
    String? phone,
    String? cityId,
    String? cityName,
    String? marketName,
    String? addressLine,
    double? latitude,
    double? longitude,
    String? notes,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
    CityEntity? city,
  }) {
    return AddressEntity(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      label: label ?? this.label,
      recipientName: recipientName ?? this.recipientName,
      phone: phone ?? this.phone,
      cityId: cityId ?? this.cityId,
      cityName: cityName ?? this.cityName,
      marketName: marketName ?? this.marketName,
      addressLine: addressLine ?? this.addressLine,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      notes: notes ?? this.notes,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      city: city ?? this.city,
    );
  }
}
