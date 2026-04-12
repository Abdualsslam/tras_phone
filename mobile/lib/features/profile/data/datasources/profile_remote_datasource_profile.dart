part of 'profile_remote_datasource.dart';

class _ProfileAccountDelegate {
  final _ProfileRemoteSupport _support;

  const _ProfileAccountDelegate({required _ProfileRemoteSupport support})
    : _support = support;

  Future<CustomerEntity> getProfile() async {
    _support.log('Fetching profile');
    final response = await _support.apiClient.get(ApiEndpoints.profile);
    return CustomerModel.fromJson(
      _support.extractMap(_support.extractPayload(response.data)),
    ).toEntity();
  }

  Future<CustomerEntity> updateProfile(UpdateCustomerProfileDto dto) async {
    _support.log('Updating profile');
    final response = await _support.apiClient.put(
      ApiEndpoints.profile,
      data: dto.toJson(),
    );
    return CustomerModel.fromJson(
      _support.extractMap(_support.extractPayload(response.data)),
    ).toEntity();
  }

  Future<bool> deleteAccount({String? reason}) async {
    _support.log('Deleting account');
    final response = await _support.apiClient.delete(
      ApiEndpoints.profile,
      data: {if (reason != null) 'reason': reason},
    );
    return response.statusCode == 200;
  }
}
