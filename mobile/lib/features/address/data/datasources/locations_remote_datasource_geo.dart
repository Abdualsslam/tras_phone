part of 'locations_remote_datasource.dart';

class _LocationsGeoDelegate {
  final _LocationsRemoteSupport _support;

  const _LocationsGeoDelegate({required _LocationsRemoteSupport support})
    : _support = support;

  Future<GeocodingResult?> reverseGeocode({
    required double latitude,
    required double longitude,
    String? language,
  }) async {
    final response = await _support.apiClient.get(
      ApiEndpoints.locationsGeocodeReverse,
      queryParameters: {
        'lat': latitude,
        'lng': longitude,
        if (language != null) 'language': language,
      },
    );

    _support.ensureSuccess(
      response.data,
      fallbackMessage: 'Failed to reverse geocode location',
    );
    final data = _support.extractPayload(response.data);
    if (data == null) return null;
    return GeocodingResult.fromJson(_support.extractMap(data));
  }

  Future<List<GeocodingResult>> forwardGeocode({
    required String address,
    String? language,
  }) async {
    final response = await _support.apiClient.get(
      ApiEndpoints.locationsGeocodeForward,
      queryParameters: {
        'address': address,
        if (language != null) 'language': language,
      },
    );

    _support.ensureSuccess(
      response.data,
      fallbackMessage: 'Failed to search addresses',
    );
    return _support
        .extractList(_support.extractPayload(response.data))
        .map((result) => GeocodingResult.fromJson(_support.extractMap(result)))
        .toList();
  }

  Future<List<PlaceAutocompleteResult>> searchPlaces({
    required String query,
    String? language,
    double? latitude,
    double? longitude,
    int radius = 50000,
  }) async {
    final response = await _support.apiClient.get(
      ApiEndpoints.locationsPlacesAutocomplete,
      queryParameters: {
        'input': query,
        if (language != null) 'language': language,
        if (latitude != null) 'lat': latitude,
        if (longitude != null) 'lng': longitude,
        'radius': radius,
      },
    );

    _support.ensureSuccess(
      response.data,
      fallbackMessage: 'Failed to get place suggestions',
    );
    return _support
        .extractList(_support.extractPayload(response.data))
        .map(
          (prediction) =>
              PlaceAutocompleteResult.fromJson(_support.extractMap(prediction)),
        )
        .toList();
  }

  Future<GeocodingResult?> getPlaceDetails({
    required String placeId,
    String? language,
  }) async {
    final response = await _support.apiClient.get(
      ApiEndpoints.locationsPlaceDetails(placeId),
      queryParameters: {if (language != null) 'language': language},
    );

    _support.ensureSuccess(
      response.data,
      fallbackMessage: 'Failed to get place details',
    );
    final data = _support.extractPayload(response.data);
    if (data == null) return null;
    return GeocodingResult.fromJson(_support.extractMap(data));
  }
}
