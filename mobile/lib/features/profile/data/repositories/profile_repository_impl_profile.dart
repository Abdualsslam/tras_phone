part of 'profile_repository_impl.dart';

class _ProfileRepositoryProfileDelegate {
  final ProfileRemoteDataSource dataSource;

  const _ProfileRepositoryProfileDelegate({required this.dataSource});

  Future<CustomerEntity> getProfile() => dataSource.getProfile();

  Future<CustomerEntity> updateProfile(UpdateCustomerProfileDto dto) =>
      dataSource.updateProfile(dto);

  Future<bool> deleteAccount({String? reason}) =>
      dataSource.deleteAccount(reason: reason);
}
