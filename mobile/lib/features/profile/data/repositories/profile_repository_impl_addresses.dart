part of 'profile_repository_impl.dart';

class _ProfileRepositoryAddressesDelegate {
  final ProfileRemoteDataSource dataSource;

  const _ProfileRepositoryAddressesDelegate({required this.dataSource});

  Future<List<AddressEntity>> getAddresses() async {
    final models = await dataSource.getAddresses();
    return models.map((model) => model.toEntity()).toList();
  }

  Future<AddressEntity> getAddressById(String id) async {
    final model = await dataSource.getAddressById(id);
    return model.toEntity();
  }

  Future<AddressEntity> createAddress(AddressRequest request) async {
    final model = await dataSource.createAddress(request);
    return model.toEntity();
  }

  Future<AddressEntity> updateAddress(
    String id,
    Map<String, dynamic> updates,
  ) async {
    final model = await dataSource.updateAddress(id, updates);
    return model.toEntity();
  }

  Future<bool> deleteAddress(String id) => dataSource.deleteAddress(id);

  Future<bool> setDefaultAddress(String id) => dataSource.setDefaultAddress(id);
}
