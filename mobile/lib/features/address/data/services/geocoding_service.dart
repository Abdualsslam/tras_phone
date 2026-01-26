/// Geocoding Service - Google Geocoding API integration
library;

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/config/app_config.dart';
import '../models/geocoding_result.dart';

class GeocodingService {
  static const String _baseUrl = 'https://maps.googleapis.com/maps/api/geocode/json';

  /// Reverse geocoding - Convert coordinates to address
  Future<GeocodingResult?> reverseGeocode({
    required double latitude,
    required double longitude,
    String? language,
  }) async {
    try {
      final apiKey = AppConfig.googleMapsApiKey;
      final lang = language ?? 'ar';
      
      final url = Uri.parse(
        '$_baseUrl?latlng=$latitude,$longitude&key=$apiKey&language=$lang',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          return GeocodingResult.fromJson(data['results'][0]);
        } else if (data['status'] == 'ZERO_RESULTS') {
          return null;
        } else {
          throw Exception('Geocoding failed: ${data['status']}');
        }
      } else {
        throw Exception('HTTP error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Reverse geocoding error: $e');
    }
  }

  /// Forward geocoding - Convert address to coordinates
  Future<List<GeocodingResult>> forwardGeocode({
    required String address,
    String? language,
  }) async {
    try {
      final apiKey = AppConfig.googleMapsApiKey;
      final lang = language ?? 'ar';
      
      final encodedAddress = Uri.encodeComponent(address);
      final url = Uri.parse(
        '$_baseUrl?address=$encodedAddress&key=$apiKey&language=$lang',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          return (data['results'] as List)
              .map((result) => GeocodingResult.fromJson(result))
              .toList();
        } else if (data['status'] == 'ZERO_RESULTS') {
          return [];
        } else {
          throw Exception('Geocoding failed: ${data['status']}');
        }
      } else {
        throw Exception('HTTP error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Forward geocoding error: $e');
    }
  }

  /// Search places using Google Places API (Autocomplete)
  /// Note: This requires Places API to be enabled
  Future<List<PlaceAutocompleteResult>> searchPlaces({
    required String query,
    String? language,
    double? latitude,
    double? longitude,
    int radius = 50000, // 50km default
  }) async {
    try {
      final apiKey = AppConfig.googleMapsApiKey;
      final lang = language ?? 'ar';
      
      var url = 'https://maps.googleapis.com/maps/api/place/autocomplete/json?'
          'input=${Uri.encodeComponent(query)}'
          '&key=$apiKey'
          '&language=$lang';
      
      if (latitude != null && longitude != null) {
        url += '&location=$latitude,$longitude&radius=$radius';
      }
      
      final uri = Uri.parse(url);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'OK' && data['predictions'].isNotEmpty) {
          return (data['predictions'] as List)
              .map((prediction) => PlaceAutocompleteResult.fromJson(prediction))
              .toList();
        } else {
          return [];
        }
      } else {
        throw Exception('HTTP error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Places search error: $e');
    }
  }

  /// Get place details by place_id
  Future<GeocodingResult?> getPlaceDetails({
    required String placeId,
    String? language,
  }) async {
    try {
      final apiKey = AppConfig.googleMapsApiKey;
      final lang = language ?? 'ar';
      
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/details/json?'
        'place_id=$placeId&key=$apiKey&language=$lang',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'OK' && data['result'] != null) {
          final result = data['result'];
          return GeocodingResult(
            formattedAddress: result['formatted_address'],
            latitude: result['geometry']['location']['lat'],
            longitude: result['geometry']['location']['lng'],
            placeId: placeId,
            addressComponents: [],
          );
        } else {
          return null;
        }
      } else {
        throw Exception('HTTP error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Get place details error: $e');
    }
  }
}
