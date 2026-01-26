/// Map Location State - State management for map location picker
library;

import 'package:equatable/equatable.dart';

enum MapLocationStatus {
  initial,
  loading,
  locationLoading,
  geocodingLoading,
  searchLoading,
  success,
  error,
}

class MapLocationState extends Equatable {
  final MapLocationStatus status;
  final double? latitude;
  final double? longitude;
  final String? address;
  final String? formattedAddress;
  final List<MapLocationSearchResult> searchResults;
  final String? errorMessage;
  final bool hasLocationPermission;
  final bool isSearching;

  const MapLocationState({
    this.status = MapLocationStatus.initial,
    this.latitude,
    this.longitude,
    this.address,
    this.formattedAddress,
    this.searchResults = const [],
    this.errorMessage,
    this.hasLocationPermission = false,
    this.isSearching = false,
  });

  MapLocationState copyWith({
    MapLocationStatus? status,
    double? latitude,
    double? longitude,
    String? address,
    String? formattedAddress,
    List<MapLocationSearchResult>? searchResults,
    String? errorMessage,
    bool? hasLocationPermission,
    bool? isSearching,
    bool clearAddress = false,
    bool clearSearchResults = false,
  }) {
    return MapLocationState(
      status: status ?? this.status,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: clearAddress ? null : (address ?? this.address),
      formattedAddress:
          clearAddress ? null : (formattedAddress ?? this.formattedAddress),
      searchResults: clearSearchResults
          ? const []
          : (searchResults ?? this.searchResults),
      errorMessage: errorMessage,
      hasLocationPermission:
          hasLocationPermission ?? this.hasLocationPermission,
      isSearching: isSearching ?? this.isSearching,
    );
  }

  bool get hasCoordinates =>
      latitude != null && longitude != null;

  bool get hasAddress => formattedAddress != null && formattedAddress!.isNotEmpty;

  @override
  List<Object?> get props => [
        status,
        latitude,
        longitude,
        address,
        formattedAddress,
        searchResults,
        errorMessage,
        hasLocationPermission,
        isSearching,
      ];
}

/// Search result model for address search
class MapLocationSearchResult extends Equatable {
  final String placeId;
  final String description;
  final double latitude;
  final double longitude;
  final String? formattedAddress;

  const MapLocationSearchResult({
    required this.placeId,
    required this.description,
    required this.latitude,
    required this.longitude,
    this.formattedAddress,
  });

  @override
  List<Object?> get props => [
        placeId,
        description,
        latitude,
        longitude,
        formattedAddress,
      ];
}
