/// Locations Remote DataSource
library;

import 'dart:developer' as developer;
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../models/country_model.dart';
import '../models/city_model.dart';
import '../models/market_model.dart';
import '../models/shipping_zone_model.dart';
import '../models/shipping_calculation_model.dart';

abstract class LocationsRemoteDataSource {
  Future<List<CountryModel>> getCountries();
  Future<List<CityModel>> getCities({String? countryId});
  Future<CityModel> getCityById(String cityId);
  Future<List<MarketModel>> getMarketsByCity(String cityId);
  Future<MarketModel> getMarketById(String marketId);
  Future<ShippingCalculationModel> calculateShipping({
    required String cityId,
    double? weight,
    double? orderTotal,
  });
  Future<List<ShippingZoneModel>> getShippingZones();
}

class LocationsRemoteDataSourceImpl implements LocationsRemoteDataSource {
  final ApiClient _apiClient;

  LocationsRemoteDataSourceImpl({required ApiClient apiClient})
      : _apiClient = apiClient;

  @override
  Future<List<CountryModel>> getCountries() async {
    final response = await _apiClient.get(ApiEndpoints.locationsCountries);
    developer.log(
      'Countries response: success=${response.data['success']}',
      name: 'LocationsDataSource',
    );

    final data = response.data['data'] ?? response.data;

    if (data is List) {
      return data.map((c) => CountryModel.fromJson(c)).toList();
    }

    if (response.data['success'] == false) {
      throw Exception(
        response.data['messageAr'] ??
            response.data['message'] ??
            'Failed to get countries',
      );
    }

    throw Exception('No countries data found');
  }

  @override
  Future<List<CityModel>> getCities({String? countryId}) async {
    final response = await _apiClient.get(
      ApiEndpoints.locationsCities,
      queryParameters: {if (countryId != null) 'countryId': countryId},
    );

    developer.log(
      'Cities response: countryId=$countryId, success=${response.data['success']}',
      name: 'LocationsDataSource',
    );

    final data = response.data['data'] ?? response.data;

    if (data is List) {
      final cities = data.map((c) => CityModel.fromJson(c)).toList();
      developer.log('Parsed ${cities.length} cities', name: 'LocationsDataSource');
      return cities;
    }

    if (response.data['success'] == false ||
        response.data['status'] == 'error') {
      throw Exception(
        response.data['messageAr'] ??
            response.data['message'] ??
            'Failed to get cities',
      );
    }

    throw Exception('No cities data found');
  }

  @override
  Future<CityModel> getCityById(String cityId) async {
    final response = await _apiClient.get(
      '${ApiEndpoints.locationsCities}/$cityId',
    );

    if (response.data['success'] == true) {
      return CityModel.fromJson(response.data['data']);
    }
    throw Exception(response.data['messageAr'] ?? 'Failed to get city');
  }

  @override
  Future<List<MarketModel>> getMarketsByCity(String cityId) async {
    final response = await _apiClient.get(
      '${ApiEndpoints.locationsCities}/$cityId/markets',
    );

    if (response.data['success'] == true) {
      return (response.data['data'] as List)
          .map((m) => MarketModel.fromJson(m))
          .toList();
    }
    throw Exception(response.data['messageAr'] ?? 'Failed to get markets');
  }

  @override
  Future<MarketModel> getMarketById(String marketId) async {
    final response = await _apiClient.get(
      '${ApiEndpoints.locationsMarkets}/$marketId',
    );

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
      response.data['messageAr'] ?? 'Failed to calculate shipping',
    );
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
      response.data['messageAr'] ?? 'Failed to get shipping zones',
    );
  }
}
