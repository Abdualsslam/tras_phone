part of 'profile_repository_impl.dart';

class _ProfileRepositoryLocationsDelegate {
  final ProfileRemoteDataSource dataSource;

  const _ProfileRepositoryLocationsDelegate({required this.dataSource});

  Future<List<Map<String, dynamic>>> getCountries() =>
      dataSource.getCountries();

  Future<List<Map<String, dynamic>>> getCities(String countryId) =>
      dataSource.getCities(countryId);

  Future<List<Map<String, dynamic>>> getAreas(String cityId) =>
      dataSource.getAreas(cityId);
}
