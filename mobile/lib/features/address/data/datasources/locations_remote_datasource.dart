/// Locations Remote DataSource
library;

import 'dart:developer' as developer;

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/city_model.dart';
import '../models/country_model.dart';
import '../models/geocoding_result.dart';
import '../models/market_model.dart';
import '../models/shipping_calculation_model.dart';
import '../models/shipping_zone_model.dart';

part 'locations_remote_datasource_support.dart';
part 'locations_remote_datasource_catalog.dart';
part 'locations_remote_datasource_geo.dart';

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
  Future<GeocodingResult?> reverseGeocode({
    required double latitude,
    required double longitude,
    String? language,
  });
  Future<List<GeocodingResult>> forwardGeocode({
    required String address,
    String? language,
  });
  Future<List<PlaceAutocompleteResult>> searchPlaces({
    required String query,
    String? language,
    double? latitude,
    double? longitude,
    int radius,
  });
  Future<GeocodingResult?> getPlaceDetails({
    required String placeId,
    String? language,
  });
}

class LocationsRemoteDataSourceImpl implements LocationsRemoteDataSource {
  final ApiClient _apiClient;
  late final _LocationsRemoteSupport _support = _LocationsRemoteSupport(
    apiClient: _apiClient,
  );
  late final _LocationsCatalogDelegate _catalog = _LocationsCatalogDelegate(
    support: _support,
  );
  late final _LocationsGeoDelegate _geo = _LocationsGeoDelegate(
    support: _support,
  );

  LocationsRemoteDataSourceImpl({required ApiClient apiClient})
    : _apiClient = apiClient;

  @override
  Future<List<CountryModel>> getCountries() => _catalog.getCountries();

  @override
  Future<List<CityModel>> getCities({String? countryId}) =>
      _catalog.getCities(countryId: countryId);

  @override
  Future<CityModel> getCityById(String cityId) => _catalog.getCityById(cityId);

  @override
  Future<List<MarketModel>> getMarketsByCity(String cityId) =>
      _catalog.getMarketsByCity(cityId);

  @override
  Future<MarketModel> getMarketById(String marketId) =>
      _catalog.getMarketById(marketId);

  @override
  Future<ShippingCalculationModel> calculateShipping({
    required String cityId,
    double? weight,
    double? orderTotal,
  }) => _catalog.calculateShipping(
    cityId: cityId,
    weight: weight,
    orderTotal: orderTotal,
  );

  @override
  Future<List<ShippingZoneModel>> getShippingZones() =>
      _catalog.getShippingZones();

  @override
  Future<GeocodingResult?> reverseGeocode({
    required double latitude,
    required double longitude,
    String? language,
  }) => _geo.reverseGeocode(
    latitude: latitude,
    longitude: longitude,
    language: language,
  );

  @override
  Future<List<GeocodingResult>> forwardGeocode({
    required String address,
    String? language,
  }) => _geo.forwardGeocode(address: address, language: language);

  @override
  Future<List<PlaceAutocompleteResult>> searchPlaces({
    required String query,
    String? language,
    double? latitude,
    double? longitude,
    int radius = 50000,
  }) => _geo.searchPlaces(
    query: query,
    language: language,
    latitude: latitude,
    longitude: longitude,
    radius: radius,
  );

  @override
  Future<GeocodingResult?> getPlaceDetails({
    required String placeId,
    String? language,
  }) => _geo.getPlaceDetails(placeId: placeId, language: language);
}
