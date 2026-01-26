/// Map Location Cubit - State management for map location picker
library;

import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import '../../data/services/geocoding_service.dart';
import 'map_location_state.dart';

class MapLocationCubit extends Cubit<MapLocationState> {
  final GeocodingService _geocodingService;
  Timer? _debounceTimer;

  MapLocationCubit({GeocodingService? geocodingService})
    : _geocodingService = geocodingService ?? GeocodingService(),
      super(const MapLocationState());

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
  }

  /// Initialize with initial coordinates (if provided)
  void initialize({double? initialLatitude, double? initialLongitude}) {
    if (isClosed) return;

    if (initialLatitude != null && initialLongitude != null) {
      emit(
        state.copyWith(
          latitude: initialLatitude,
          longitude: initialLongitude,
          status: MapLocationStatus.success,
        ),
      );
      // Get address for initial location
      _reverseGeocode(initialLatitude, initialLongitude);
    } else {
      // Try to get current location
      getCurrentLocation();
    }
  }

  /// Get current device location
  Future<void> getCurrentLocation() async {
    if (isClosed) return;

    emit(
      state.copyWith(
        status: MapLocationStatus.locationLoading,
        errorMessage: null,
      ),
    );

    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (isClosed) return;
        emit(
          state.copyWith(
            status: MapLocationStatus.error,
            errorMessage: 'خدمات الموقع غير مفعلة. يرجى تفعيلها من الإعدادات.',
            hasLocationPermission: false,
          ),
        );
        return;
      }

      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (isClosed) return;
          emit(
            state.copyWith(
              status: MapLocationStatus.error,
              errorMessage:
                  'تم رفض إذن الموقع. يرجى السماح بالوصول إلى الموقع.',
              hasLocationPermission: false,
            ),
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (isClosed) return;
        emit(
          state.copyWith(
            status: MapLocationStatus.error,
            errorMessage:
                'تم رفض إذن الموقع بشكل دائم. يرجى تفعيله من إعدادات التطبيق.',
            hasLocationPermission: false,
          ),
        );
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (isClosed) return;

      emit(
        state.copyWith(
          status: MapLocationStatus.success,
          latitude: position.latitude,
          longitude: position.longitude,
          hasLocationPermission: true,
          errorMessage: null,
        ),
      );

      // Get address for current location
      _reverseGeocode(position.latitude, position.longitude);
    } catch (e) {
      developer.log(
        'Error getting current location: $e',
        name: 'MapLocationCubit',
        error: e,
      );
      if (isClosed) return;
      emit(
        state.copyWith(
          status: MapLocationStatus.error,
          errorMessage: 'فشل الحصول على الموقع الحالي: $e',
          hasLocationPermission: false,
        ),
      );
    }
  }

  /// Update location coordinates (when user drags map or marker)
  void updateLocation(double latitude, double longitude) {
    if (isClosed) return;

    // Check if coordinates actually changed (avoid unnecessary updates)
    if (state.latitude == latitude && state.longitude == longitude) {
      return;
    }

    // Cancel previous debounce timer
    _debounceTimer?.cancel();

    // Update coordinates immediately
    emit(
      state.copyWith(
        latitude: latitude,
        longitude: longitude,
        status: MapLocationStatus.success,
        errorMessage: null,
      ),
    );

    // Debounce reverse geocoding to avoid too many API calls
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (!isClosed) {
        _reverseGeocode(latitude, longitude);
      }
    });
  }

  /// Reverse geocoding - Get address from coordinates
  Future<void> _reverseGeocode(double latitude, double longitude) async {
    if (isClosed) return;

    emit(state.copyWith(status: MapLocationStatus.geocodingLoading));

    try {
      final result = await _geocodingService.reverseGeocode(
        latitude: latitude,
        longitude: longitude,
        language: 'ar',
      );

      if (isClosed) return;

      if (result != null) {
        emit(
          state.copyWith(
            status: MapLocationStatus.success,
            formattedAddress: result.formattedAddress,
            address: result.formattedAddress,
            errorMessage: null,
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: MapLocationStatus.success,
            formattedAddress: null,
            address: null,
            errorMessage: null,
          ),
        );
      }
    } catch (e) {
      developer.log(
        'Error reverse geocoding: $e',
        name: 'MapLocationCubit',
        error: e,
      );
      if (isClosed) return;
      emit(
        state.copyWith(
          status: MapLocationStatus.success,
          errorMessage: 'فشل الحصول على العنوان',
        ),
      );
    }
  }

  /// Search for addresses
  Future<void> searchAddress(String query) async {
    if (isClosed) return;

    if (query.trim().isEmpty) {
      emit(
        state.copyWith(
          searchResults: [],
          isSearching: false,
          clearSearchResults: true,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: MapLocationStatus.searchLoading,
        isSearching: true,
      ),
    );

    try {
      // Try Places API first (if available)
      try {
        final places = await _geocodingService.searchPlaces(
          query: query,
          language: 'ar',
          latitude: state.latitude,
          longitude: state.longitude,
        );

        if (places.isNotEmpty) {
          final results = places.map((place) {
            return MapLocationSearchResult(
              placeId: place.placeId,
              description: place.description,
              latitude: 0.0, // Will be fetched when selected
              longitude: 0.0,
            );
          }).toList();

          if (isClosed) return;

          emit(
            state.copyWith(
              status: MapLocationStatus.success,
              searchResults: results,
              isSearching: false,
            ),
          );
          return;
        }
      } catch (e) {
        developer.log(
          'Places API not available, using geocoding: $e',
          name: 'MapLocationCubit',
        );
      }

      // Fallback to forward geocoding
      final results = await _geocodingService.forwardGeocode(
        address: query,
        language: 'ar',
      );

      final searchResults = results.map((result) {
        return MapLocationSearchResult(
          placeId: result.placeId ?? '',
          description: result.formattedAddress ?? '',
          latitude: result.latitude,
          longitude: result.longitude,
          formattedAddress: result.formattedAddress,
        );
      }).toList();

      if (isClosed) return;

      emit(
        state.copyWith(
          status: MapLocationStatus.success,
          searchResults: searchResults,
          isSearching: false,
        ),
      );
    } catch (e) {
      developer.log(
        'Error searching address: $e',
        name: 'MapLocationCubit',
        error: e,
      );
      if (isClosed) return;
      emit(
        state.copyWith(
          status: MapLocationStatus.error,
          errorMessage: 'فشل البحث عن العنوان',
          isSearching: false,
          searchResults: [],
        ),
      );
    }
  }

  /// Select a search result
  Future<void> selectSearchResult(MapLocationSearchResult result) async {
    if (isClosed) return;

    // If we have coordinates, use them directly
    if (result.latitude != 0.0 && result.longitude != 0.0) {
      updateLocation(result.latitude, result.longitude);
      if (isClosed) return;
      emit(
        state.copyWith(
          searchResults: [],
          isSearching: false,
          clearSearchResults: true,
        ),
      );
      return;
    }

    // Otherwise, get place details
    if (result.placeId.isNotEmpty) {
      try {
        final placeDetails = await _geocodingService.getPlaceDetails(
          placeId: result.placeId,
          language: 'ar',
        );

        if (isClosed) return;

        if (placeDetails != null) {
          updateLocation(placeDetails.latitude, placeDetails.longitude);
          if (isClosed) return;
          emit(
            state.copyWith(
              searchResults: [],
              isSearching: false,
              clearSearchResults: true,
            ),
          );
        }
      } catch (e) {
        developer.log(
          'Error getting place details: $e',
          name: 'MapLocationCubit',
          error: e,
        );
        if (isClosed) return;
        emit(
          state.copyWith(
            status: MapLocationStatus.error,
            errorMessage: 'فشل الحصول على تفاصيل المكان',
          ),
        );
      }
    }
  }

  /// Clear search results
  void clearSearch() {
    if (isClosed) return;
    emit(
      state.copyWith(
        searchResults: [],
        isSearching: false,
        clearSearchResults: true,
      ),
    );
  }

  /// Reset state
  void reset() {
    if (isClosed) return;
    emit(const MapLocationState());
  }
}
