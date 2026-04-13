part of 'locations_remote_datasource.dart';

class _LocationsCatalogDelegate {
  final _LocationsRemoteSupport _support;

  const _LocationsCatalogDelegate({required _LocationsRemoteSupport support})
    : _support = support;

  Future<List<CountryModel>> getCountries() async {
    final response = await _support.apiClient.get(
      ApiEndpoints.locationsCountries,
    );
    _support.log(
      'Countries response: success=${_support.extractMap(response.data)['success']}',
    );

    final data = _support.extractPayload(response.data);
    if (data is List) {
      return data
          .map((country) => CountryModel.fromJson(_support.extractMap(country)))
          .toList();
    }

    _support.ensureSuccess(
      response.data,
      fallbackMessage: 'Failed to get countries',
    );
    throw const NotFoundException(message: 'No countries data found');
  }

  Future<List<CityModel>> getCities({String? countryId}) async {
    final response = await _support.apiClient.get(
      ApiEndpoints.locationsCities,
      queryParameters: {if (countryId != null) 'countryId': countryId},
    );

    _support.log(
      'Cities response: countryId=$countryId, success=${_support.extractMap(response.data)['success']}',
    );

    final data = _support.extractPayload(response.data);
    if (data is List) {
      final cities = data
          .map((city) => CityModel.fromJson(_support.extractMap(city)))
          .toList();
      _support.log('Parsed ${cities.length} cities');
      return cities;
    }

    _support.ensureSuccess(
      response.data,
      fallbackMessage: 'Failed to get cities',
      allowStatusError: true,
    );
    throw const NotFoundException(message: 'No cities data found');
  }

  Future<CityModel> getCityById(String cityId) async {
    final response = await _support.apiClient.get(
      '${ApiEndpoints.locationsCities}/$cityId',
    );
    _support.ensureSuccess(
      response.data,
      fallbackMessage: 'Failed to get city',
    );
    return CityModel.fromJson(
      _support.extractMap(_support.extractPayload(response.data)),
    );
  }

  Future<List<MarketModel>> getMarketsByCity(String cityId) async {
    final response = await _support.apiClient.get(
      '${ApiEndpoints.locationsCities}/$cityId/markets',
    );
    _support.ensureSuccess(
      response.data,
      fallbackMessage: 'Failed to get markets',
    );

    return _support
        .extractList(_support.extractPayload(response.data))
        .map((market) => MarketModel.fromJson(_support.extractMap(market)))
        .toList();
  }

  Future<MarketModel> getMarketById(String marketId) async {
    final response = await _support.apiClient.get(
      '${ApiEndpoints.locationsMarkets}/$marketId',
    );
    _support.ensureSuccess(
      response.data,
      fallbackMessage: 'Failed to get market',
    );
    return MarketModel.fromJson(
      _support.extractMap(_support.extractPayload(response.data)),
    );
  }

  Future<ShippingCalculationModel> calculateShipping({
    required String cityId,
    double? weight,
    double? orderTotal,
  }) async {
    final response = await _support.apiClient.get(
      ApiEndpoints.locationsShippingCalculate,
      queryParameters: {
        'cityId': cityId,
        if (weight != null) 'weight': weight,
        if (orderTotal != null) 'orderTotal': orderTotal,
      },
    );

    _support.ensureSuccess(
      response.data,
      fallbackMessage: 'Failed to calculate shipping',
    );
    return ShippingCalculationModel.fromJson(
      _support.extractMap(_support.extractPayload(response.data)),
    );
  }

  Future<List<ShippingZoneModel>> getShippingZones() async {
    final response = await _support.apiClient.get(
      ApiEndpoints.locationsShippingZones,
    );
    _support.ensureSuccess(
      response.data,
      fallbackMessage: 'Failed to get shipping zones',
    );

    return _support
        .extractList(_support.extractPayload(response.data))
        .map((zone) => ShippingZoneModel.fromJson(_support.extractMap(zone)))
        .toList();
  }
}
