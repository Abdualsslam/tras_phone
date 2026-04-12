/// Profile Repository Implementation
library;

import '../../../auth/domain/entities/customer_entity.dart';
import '../../domain/entities/address_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_datasource.dart';
import '../models/address_model.dart';
import '../models/referral_model.dart';
import '../models/update_customer_profile_dto.dart';
import '../models/wallet_model.dart';

part 'profile_repository_impl_profile.dart';
part 'profile_repository_impl_addresses.dart';
part 'profile_repository_impl_wallet.dart';
part 'profile_repository_impl_locations.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource _dataSource;
  late final _ProfileRepositoryProfileDelegate _profile =
      _ProfileRepositoryProfileDelegate(dataSource: _dataSource);
  late final _ProfileRepositoryAddressesDelegate _addresses =
      _ProfileRepositoryAddressesDelegate(dataSource: _dataSource);
  late final _ProfileRepositoryWalletDelegate _wallet =
      _ProfileRepositoryWalletDelegate(dataSource: _dataSource);
  late final _ProfileRepositoryLocationsDelegate _locations =
      _ProfileRepositoryLocationsDelegate(dataSource: _dataSource);

  ProfileRepositoryImpl({required ProfileRemoteDataSource dataSource})
    : _dataSource = dataSource;

  @override
  Future<CustomerEntity> getProfile() => _profile.getProfile();

  @override
  Future<CustomerEntity> updateProfile(UpdateCustomerProfileDto dto) =>
      _profile.updateProfile(dto);

  @override
  Future<bool> deleteAccount({String? reason}) =>
      _profile.deleteAccount(reason: reason);

  @override
  Future<List<AddressEntity>> getAddresses() => _addresses.getAddresses();

  @override
  Future<AddressEntity> getAddressById(String id) =>
      _addresses.getAddressById(id);

  @override
  Future<AddressEntity> createAddress(AddressRequest request) =>
      _addresses.createAddress(request);

  @override
  Future<AddressEntity> updateAddress(
    String id,
    Map<String, dynamic> updates,
  ) => _addresses.updateAddress(id, updates);

  @override
  Future<bool> deleteAddress(String id) => _addresses.deleteAddress(id);

  @override
  Future<bool> setDefaultAddress(String id) => _addresses.setDefaultAddress(id);

  @override
  Future<WalletModel> getWallet() => _wallet.getWallet();

  @override
  Future<List<WalletTransactionModel>> getWalletTransactions({
    int page = 1,
    int limit = 20,
    String? type,
  }) => _wallet.getWalletTransactions(page: page, limit: limit, type: type);

  @override
  Future<bool> requestWithdrawal(double amount, String bankDetails) =>
      _wallet.requestWithdrawal(amount, bankDetails);

  @override
  Future<LoyaltyModel> getLoyaltyPoints() => _wallet.getLoyaltyPoints();

  @override
  Future<bool> redeemPoints(int points) => _wallet.redeemPoints(points);

  @override
  Future<ReferralInfoModel> getReferralInfo() => _wallet.getReferralInfo();

  @override
  Future<bool> applyReferralCode(String code) =>
      _wallet.applyReferralCode(code);

  @override
  Future<List<Map<String, dynamic>>> getCountries() =>
      _locations.getCountries();

  @override
  Future<List<Map<String, dynamic>>> getCities(String countryId) =>
      _locations.getCities(countryId);

  @override
  Future<List<Map<String, dynamic>>> getAreas(String cityId) =>
      _locations.getAreas(cityId);
}
