/// Geocoding Result Model
library;

class GeocodingResult {
  final String? formattedAddress;
  final double latitude;
  final double longitude;
  final String? placeId;
  final List<AddressComponent> addressComponents;

  GeocodingResult({
    this.formattedAddress,
    required this.latitude,
    required this.longitude,
    this.placeId,
    this.addressComponents = const [],
  });

  factory GeocodingResult.fromJson(Map<String, dynamic> json) {
    final geometry = json['geometry'] as Map<String, dynamic>;
    final location = geometry['location'] as Map<String, dynamic>;

    return GeocodingResult(
      formattedAddress: json['formatted_address'] as String?,
      latitude: (location['lat'] as num).toDouble(),
      longitude: (location['lng'] as num).toDouble(),
      placeId: json['place_id'] as String?,
      addressComponents: (json['address_components'] as List<dynamic>?)
              ?.map((component) => AddressComponent.fromJson(component))
              .toList() ??
          [],
    );
  }

  String? get streetNumber {
    return addressComponents
        .firstWhere(
          (c) => c.types.contains('street_number'),
          orElse: () => AddressComponent(types: [], longName: '', shortName: ''),
        )
        .longName
        .isEmpty
        ? null
        : addressComponents
            .firstWhere((c) => c.types.contains('street_number'))
            .longName;
  }

  String? get route {
    return addressComponents
        .firstWhere(
          (c) => c.types.contains('route'),
          orElse: () => AddressComponent(types: [], longName: '', shortName: ''),
        )
        .longName
        .isEmpty
        ? null
        : addressComponents
            .firstWhere((c) => c.types.contains('route'))
            .longName;
  }

  String? get locality {
    return addressComponents
        .firstWhere(
          (c) => c.types.contains('locality'),
          orElse: () => AddressComponent(types: [], longName: '', shortName: ''),
        )
        .longName
        .isEmpty
        ? null
        : addressComponents
            .firstWhere((c) => c.types.contains('locality'))
            .longName;
  }

  String? get administrativeArea {
    return addressComponents
        .firstWhere(
          (c) => c.types.contains('administrative_area_level_1'),
          orElse: () => AddressComponent(types: [], longName: '', shortName: ''),
        )
        .longName
        .isEmpty
        ? null
        : addressComponents
            .firstWhere((c) => c.types.contains('administrative_area_level_1'))
            .longName;
  }

  String? get country {
    return addressComponents
        .firstWhere(
          (c) => c.types.contains('country'),
          orElse: () => AddressComponent(types: [], longName: '', shortName: ''),
        )
        .longName
        .isEmpty
        ? null
        : addressComponents
            .firstWhere((c) => c.types.contains('country'))
            .longName;
  }
}

class AddressComponent {
  final List<String> types;
  final String longName;
  final String shortName;

  AddressComponent({
    required this.types,
    required this.longName,
    required this.shortName,
  });

  factory AddressComponent.fromJson(Map<String, dynamic> json) {
    return AddressComponent(
      types: (json['types'] as List<dynamic>).cast<String>(),
      longName: json['long_name'] as String,
      shortName: json['short_name'] as String,
    );
  }
}

class PlaceAutocompleteResult {
  final String placeId;
  final String description;
  final List<String> types;

  PlaceAutocompleteResult({
    required this.placeId,
    required this.description,
    this.types = const [],
  });

  factory PlaceAutocompleteResult.fromJson(Map<String, dynamic> json) {
    return PlaceAutocompleteResult(
      placeId: json['place_id'] as String,
      description: json['description'] as String,
      types: (json['types'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }
}
