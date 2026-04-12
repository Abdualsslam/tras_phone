part of 'profile_remote_datasource.dart';

class _ProfileLocationsDelegate {
  final _ProfileRemoteSupport _support;

  const _ProfileLocationsDelegate({required _ProfileRemoteSupport support})
    : _support = support;

  Future<List<Map<String, dynamic>>> getCountries() async {
    _support.log('Fetching countries');
    final response = await _support.apiClient.get(ApiEndpoints.countries);
    return _support
        .extractList(_support.extractPayload(response.data))
        .map((item) => _support.extractMap(item))
        .toList();
  }

  Future<List<Map<String, dynamic>>> getCities(String countryId) async {
    _support.log('Fetching cities for country: $countryId');
    final response = await _support.apiClient.get(
      ApiEndpoints.cities,
      queryParameters: {'countryId': countryId},
    );
    return _support
        .extractList(_support.extractPayload(response.data))
        .map((item) => _support.extractMap(item))
        .toList();
  }

  Future<List<Map<String, dynamic>>> getAreas(String cityId) async {
    _support.log('Fetching areas for city: $cityId');
    final response = await _support.apiClient.get(
      '${ApiEndpoints.cities}/$cityId/areas',
    );
    return _support
        .extractList(_support.extractPayload(response.data))
        .map((item) => _support.extractMap(item))
        .toList();
  }
}
