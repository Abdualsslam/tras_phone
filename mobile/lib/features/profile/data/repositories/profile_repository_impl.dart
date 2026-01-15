/// Profile Repository Implementation
library;

import '../../../auth/domain/entities/customer_entity.dart';
import '../../domain/entities/address_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_datasource.dart';
import '../models/address_model.dart';
import '../models/wallet_model.dart';
import '../models/referral_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource _dataSource;

  ProfileRepositoryImpl({required ProfileRemoteDataSource dataSource})
      : _dataSource = dataSource;

  // ═══════════════════════════════════════════════════════════════════════════
  // PROFILE
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  Future<CustomerEntity> getProfile() async {
    return await _dataSource.getProfile();
  }

  @override
  Future<CustomerEntity> updateProfile({
    String? name,
    String? email,
    String? phone,
    String? avatar,
  }) async {
    return await _dataSource.updateProfile(
      name: name,
      email: email,
      phone: phone,
      avatar: avatar,
    );
  }

  @override
  Future<bool> deleteAccount({String? reason}) async {
    return await _dataSource.deleteAccount(reason: reason);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ADDRESSES
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  Future<List<AddressEntity>> getAddresses() async {
    final models = await _dataSource.getAddresses();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<AddressEntity> getAddressById(String id) async {
    final model = await _dataSource.getAddressById(id);
    return model.toEntity();
  }

  @override
  Future<AddressEntity> createAddress(AddressRequest request) async {
    final model = await _dataSource.createAddress(request);
    return model.toEntity();
  }

  @override
  Future<AddressEntity> updateAddress(
    String id,
    Map<String, dynamic> updates,
  ) async {
    final model = await _dataSource.updateAddress(id, updates);
    return model.toEntity();
  }

  @override
  Future<bool> deleteAddress(String id) async {
    return await _dataSource.deleteAddress(id);
  }

  @override
  Future<bool> setDefaultAddress(String id) async {
    return await _dataSource.setDefaultAddress(id);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // WALLET
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  Future<WalletModel> getWallet() async {
    return await _dataSource.getWallet();
  }

  @override
  Future<List<WalletTransactionModel>> getWalletTransactions({
    int page = 1,
    int limit = 20,
    String? type,
  }) async {
    return await _dataSource.getWalletTransactions(
      page: page,
      limit: limit,
      type: type,
    );
  }

  @override
  Future<bool> requestWithdrawal(double amount, String bankDetails) async {
    return await _dataSource.requestWithdrawal(amount, bankDetails);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // LOYALTY
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  Future<LoyaltyModel> getLoyaltyPoints() async {
    return await _dataSource.getLoyaltyPoints();
  }

  @override
  Future<bool> redeemPoints(int points) async {
    return await _dataSource.redeemPoints(points);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // REFERRAL
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  Future<ReferralInfoModel> getReferralInfo() async {
    return await _dataSource.getReferralInfo();
  }

  @override
  Future<bool> applyReferralCode(String code) async {
    return await _dataSource.applyReferralCode(code);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // LOCATIONS
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  Future<List<Map<String, dynamic>>> getCountries() async {
    return await _dataSource.getCountries();
  }

  @override
  Future<List<Map<String, dynamic>>> getCities(String countryId) async {
    return await _dataSource.getCities(countryId);
  }

  @override
  Future<List<Map<String, dynamic>>> getAreas(String cityId) async {
    return await _dataSource.getAreas(cityId);
  }
}
