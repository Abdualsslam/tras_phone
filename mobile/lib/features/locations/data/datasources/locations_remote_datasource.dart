/// Locations Remote DataSource
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

    if (response.data['success'] == true) {
      return (response.data['data'] as List)
          .map((c) => CountryModel.fromJson(c))
          .toList();
    }
    throw Exception(response.data['messageAr'] ?? 'Failed to get countries');
  }

  @override
  Future<List<CityModel>> getCities({String? countryId}) async {
    final response = await _apiClient.get(
      ApiEndpoints.locationsCities,
      queryParameters: {
        if (countryId != null) 'countryId': countryId,
      },
    );

    if (response.data['success'] == true) {
      return (response.data['data'] as List)
          .map((c) => CityModel.fromJson(c))
          .toList();
    }
    throw Exception(response.data['messageAr'] ?? 'Failed to get cities');
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
