/// Locations Remote DataSource
import 'dart:developer' as developer;
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../models/country_model.dart';
import '../models/city_model.dart';
import '../models/market_model.dart';
import '../models/shipping_zone_model.dart';
import '../models/shipping_calculation_model.dart';

abstract class LocationsRemoteDataSource {
  /// جلب قائمة الدول
  Future<List<CountryModel>> getCountries();

  /// جلب قائمة المدن
  Future<List<CityModel>> getCities({String? countryId});

  /// جلب تفاصيل مدينة
  Future<CityModel> getCityById(String cityId);

  /// جلب أسواق/أحياء المدينة
  Future<List<MarketModel>> getMarketsByCity(String cityId);

  /// جلب تفاصيل سوق/حي
  Future<MarketModel> getMarketById(String marketId);

  /// حساب تكلفة الشحن
  Future<ShippingCalculationModel> calculateShipping({
    required String cityId,
    double? weight,
    double? orderTotal,
  });

  /// جلب مناطق الشحن
  Future<List<ShippingZoneModel>> getShippingZones();
}

class LocationsRemoteDataSourceImpl implements LocationsRemoteDataSource {
  final ApiClient _apiClient;

  LocationsRemoteDataSourceImpl({required ApiClient apiClient})
      : _apiClient = apiClient;

  @override
  Future<List<CountryModel>> getCountries() async {
    final response = await _apiClient.get(ApiEndpoints.locationsCountries);

    // Print full response to terminal
    print('═══════════════════════════════════════════════════════');
    print('📍 [LocationsDataSource] Countries API Full Response:');
    print('═══════════════════════════════════════════════════════');
    print(response.data);
    print('═══════════════════════════════════════════════════════');

    developer.log('Countries API response: success=${response.data['success']}, data type=${response.data['data']?.runtimeType}', name: 'LocationsDataSource');
    
    // Check if data exists (some APIs return data directly without success field)
    final data = response.data['data'] ?? response.data;
    
    // If data is a List, parse it regardless of success field
    if (data is List) {
      developer.log('Parsing ${data.length} countries', name: 'LocationsDataSource');
      final countries = data
          .map((c) => CountryModel.fromJson(c))
          .toList();
      developer.log('Parsed ${countries.length} countries successfully', name: 'LocationsDataSource');
      return countries;
    }
    
    // If success is explicitly false or error message exists, throw error
    if (response.data['success'] == false) {
      throw Exception(response.data['messageAr'] ?? response.data['message'] ?? 'Failed to get countries');
    }
    
    // If no data found, throw error
    throw Exception(response.data['messageAr'] ?? response.data['message'] ?? 'No countries data found');
  }

  @override
  Future<List<CityModel>> getCities({String? countryId}) async {
    // Print request details
    print('═══════════════════════════════════════════════════════');
    print('🏙️ [LocationsDataSource] Cities API Request:');
    print('   Endpoint: ${ApiEndpoints.locationsCities}');
    print('   CountryId: $countryId');
    print('   Query Parameters: ${countryId != null ? {'countryId': countryId} : {}}');
    print('═══════════════════════════════════════════════════════');

    final response = await _apiClient.get(
      ApiEndpoints.locationsCities,
      queryParameters: {
        if (countryId != null) 'countryId': countryId,
      },
    );

    // Print full response to terminal
    print('═══════════════════════════════════════════════════════');
    print('🏙️ [LocationsDataSource] Cities API Full Response:');
    print('   CountryId: $countryId');
    print('═══════════════════════════════════════════════════════');
    print(response.data);
    print('═══════════════════════════════════════════════════════');

    developer.log('Cities API response: status=${response.data['status']}, success=${response.data['success']}, data type=${response.data['data']?.runtimeType}, countryId=$countryId', name: 'LocationsDataSource');
    
    // Check if data exists (some APIs return data directly without success field)
    final data = response.data['data'] ?? response.data;
    
    // Print data details
    if (data is List) {
      print('📋 [LocationsDataSource] Data List Details:');
      print('   List length: ${data.length}');
      if (data.isNotEmpty) {
        print('   First item: ${data.first}');
        print('   All cities data:');
        for (var i = 0; i < data.length; i++) {
          print('   [$i] ${data[i]}');
        }
      } else {
        print('   ⚠️ WARNING: Cities list is EMPTY!');
        print('   This might mean:');
        print('     1. No cities exist for countryId: $countryId');
        print('     2. API query parameter issue');
        print('     3. Backend data issue');
      }
      print('═══════════════════════════════════════════════════════');
    } else {
      print('⚠️ [LocationsDataSource] Data is NOT a List! Type: ${data?.runtimeType}');
      print('   Data value: $data');
      print('═══════════════════════════════════════════════════════');
    }
    
    // If data is a List, parse it regardless of success field
    if (data is List) {
      developer.log('Parsing ${data.length} cities', name: 'LocationsDataSource');
      final cities = data
          .map((c) {
            developer.log('Parsing city: $c', name: 'LocationsDataSource');
            return CityModel.fromJson(c);
          })
          .toList();
      
      print('✅ [LocationsDataSource] Parsed Cities:');
      for (var i = 0; i < cities.length; i++) {
        final city = cities[i];
        print('   [$i] ${city.nameAr} (id: ${city.id}) - Capital: ${city.isCapital}');
      }
      if (cities.isEmpty) {
        print('   ⚠️ No cities parsed - list is empty');
      }
      print('═══════════════════════════════════════════════════════');
      
      developer.log('Parsed ${cities.length} cities successfully', name: 'LocationsDataSource');
      return cities;
    }
    
    // If success is explicitly false or error message exists, throw error
    if (response.data['success'] == false || response.data['status'] == 'error') {
      throw Exception(response.data['messageAr'] ?? response.data['message'] ?? 'Failed to get cities');
    }
    
    // If no data found, throw error
    throw Exception(response.data['messageAr'] ?? response.data['message'] ?? 'No cities data found');
  }

  @override
  Future<CityModel> getCityById(String cityId) async {
    final response =
        await _apiClient.get('${ApiEndpoints.locationsCities}/$cityId');

    if (response.data['success'] == true) {
      return CityModel.fromJson(response.data['data']);
    }
    throw Exception(response.data['messageAr'] ?? 'Failed to get city');
  }

  @override
  Future<List<MarketModel>> getMarketsByCity(String cityId) async {
    final response = await _apiClient
        .get('${ApiEndpoints.locationsCities}/$cityId/markets');

    if (response.data['success'] == true) {
      return (response.data['data'] as List)
          .map((m) => MarketModel.fromJson(m))
          .toList();
    }
    throw Exception(response.data['messageAr'] ?? 'Failed to get markets');
  }

  @override
  Future<MarketModel> getMarketById(String marketId) async {
    final response =
        await _apiClient.get('${ApiEndpoints.locationsMarkets}/$marketId');

    if (response.data['success'] == true) {
      return MarketModel.fromJson(response.data['data']);
    }
    throw Exception(response.data['messageAr'] ?? 'Failed to get market');
  }

  @override
  Future<ShippingCalculationModel> calculateShipping({
    required String cityId,
    double? weight,
    double? orderTotal,
  }) async {
    final response = await _apiClient.get(
      ApiEndpoints.locationsShippingCalculate,
      queryParameters: {
        'cityId': cityId,
        if (weight != null) 'weight': weight,
        if (orderTotal != null) 'orderTotal': orderTotal,
      },
    );

    if (response.data['success'] == true) {
      return ShippingCalculationModel.fromJson(response.data['data']);
    }
    throw Exception(
        response.data['messageAr'] ?? 'Failed to calculate shipping');
  }

  @override
  Future<List<ShippingZoneModel>> getShippingZones() async {
    final response = await _apiClient.get(ApiEndpoints.locationsShippingZones);

    if (response.data['success'] == true) {
      return (response.data['data'] as List)
          .map((z) => ShippingZoneModel.fromJson(z))
          .toList();
    }
    throw Exception(
        response.data['messageAr'] ?? 'Failed to get shipping zones');
  }
}
