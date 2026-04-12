/// Profile Remote DataSource - Real API implementation
library;

import 'dart:developer' as developer;

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../auth/data/models/customer_model.dart';
import '../../../auth/domain/entities/customer_entity.dart';
import '../models/address_model.dart';
import '../models/referral_model.dart';
import '../models/update_customer_profile_dto.dart';
import '../models/wallet_model.dart';

part 'profile_remote_datasource_support.dart';
part 'profile_remote_datasource_profile.dart';
part 'profile_remote_datasource_addresses.dart';
part 'profile_remote_datasource_wallet.dart';
part 'profile_remote_datasource_locations.dart';

abstract class ProfileRemoteDataSource {
  Future<CustomerEntity> getProfile();
  Future<CustomerEntity> updateProfile(UpdateCustomerProfileDto dto);
  Future<bool> deleteAccount({String? reason});

  Future<List<AddressModel>> getAddresses();
  Future<AddressModel> getAddressById(String id);
  Future<AddressModel> createAddress(AddressRequest request);
  Future<AddressModel> updateAddress(String id, Map<String, dynamic> updates);
  Future<bool> deleteAddress(String id);
  Future<bool> setDefaultAddress(String id);

  Future<WalletModel> getWallet();
  Future<List<WalletTransactionModel>> getWalletTransactions({
    int page = 1,
    int limit = 20,
    String? type,
  });
  Future<bool> requestWithdrawal(double amount, String bankDetails);

  Future<LoyaltyModel> getLoyaltyPoints();
  Future<bool> redeemPoints(int points);

  Future<ReferralInfoModel> getReferralInfo();
  Future<bool> applyReferralCode(String code);

  Future<List<Map<String, dynamic>>> getCountries();
  Future<List<Map<String, dynamic>>> getCities(String countryId);
  Future<List<Map<String, dynamic>>> getAreas(String cityId);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final ApiClient _apiClient;
  late final _ProfileRemoteSupport _support = _ProfileRemoteSupport(
    apiClient: _apiClient,
  );
  late final _ProfileAccountDelegate _profile = _ProfileAccountDelegate(
    support: _support,
  );
  late final _ProfileAddressesDelegate _addresses = _ProfileAddressesDelegate(
    support: _support,
  );
  late final _ProfileWalletDelegate _wallet = _ProfileWalletDelegate(
    support: _support,
  );
  late final _ProfileLocationsDelegate _locations = _ProfileLocationsDelegate(
    support: _support,
  );

  ProfileRemoteDataSourceImpl({required ApiClient apiClient})
    : _apiClient = apiClient;

  @override
  Future<CustomerEntity> getProfile() => _profile.getProfile();

  @override
  Future<CustomerEntity> updateProfile(UpdateCustomerProfileDto dto) =>
      _profile.updateProfile(dto);

  @override
  Future<bool> deleteAccount({String? reason}) =>
      _profile.deleteAccount(reason: reason);

  @override
  Future<List<AddressModel>> getAddresses() => _addresses.getAddresses();

  @override
  Future<AddressModel> getAddressById(String id) =>
      _addresses.getAddressById(id);

  @override
  Future<AddressModel> createAddress(AddressRequest request) =>
      _addresses.createAddress(request);

  @override
  Future<AddressModel> updateAddress(String id, Map<String, dynamic> updates) =>
      _addresses.updateAddress(id, updates);

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
