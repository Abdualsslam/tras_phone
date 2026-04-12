part of 'profile_remote_datasource.dart';

class _ProfileAddressesDelegate {
  final _ProfileRemoteSupport _support;

  const _ProfileAddressesDelegate({required _ProfileRemoteSupport support})
    : _support = support;

  Future<List<AddressModel>> getAddresses() async {
    _support.log('Fetching addresses');
    final response = await _support.apiClient.get(ApiEndpoints.addresses);
    return _support
        .extractList(_support.extractPayload(response.data))
        .map((json) => AddressModel.fromJson(_support.extractMap(json)))
        .toList();
  }

  Future<AddressModel> getAddressById(String id) async {
    _support.log('Fetching address: $id');
    final response = await _support.apiClient.get(
      '${ApiEndpoints.addresses}/$id',
    );
    return AddressModel.fromJson(
      _support.extractMap(_support.extractPayload(response.data)),
    );
  }

  Future<AddressModel> createAddress(AddressRequest request) async {
    _support.log('Creating address');
    final response = await _support.apiClient.post(
      ApiEndpoints.addresses,
      data: request.toJson(),
    );
    return AddressModel.fromJson(
      _support.extractMap(_support.extractPayload(response.data)),
    );
  }

  Future<AddressModel> updateAddress(
    String id,
    Map<String, dynamic> updates,
  ) async {
    _support.log('Updating address: $id');
    final response = await _support.apiClient.put(
      '${ApiEndpoints.addresses}/$id',
      data: updates,
    );
    return AddressModel.fromJson(
      _support.extractMap(_support.extractPayload(response.data)),
    );
  }

  Future<bool> deleteAddress(String id) async {
    _support.log('Deleting address: $id');
    final response = await _support.apiClient.delete(
      '${ApiEndpoints.addresses}/$id',
    );
    return response.statusCode == 200 || response.statusCode == 204;
  }

  Future<bool> setDefaultAddress(String id) async {
    _support.log('Setting default address: $id');
    final response = await _support.apiClient.put(
      '${ApiEndpoints.addresses}/$id',
      data: {'isDefault': true},
    );
    return response.statusCode == 200;
  }
}
