/// Profile Repository - Domain layer interface
library;

import '../../../auth/domain/entities/customer_entity.dart';
import '../entities/address_entity.dart';
import '../../data/models/address_model.dart';
import '../../data/models/wallet_model.dart';
import '../../data/models/referral_model.dart';

/// Abstract repository for profile operations
abstract class ProfileRepository {
  // Profile
  Future<CustomerEntity> getProfile();
  Future<CustomerEntity> updateProfile({
    String? name,
    String? email,
    String? phone,
    String? avatar,
  });
  Future<bool> deleteAccount({String? reason});

  // Addresses
  Future<List<AddressEntity>> getAddresses();
  Future<AddressEntity> getAddressById(String id);
  Future<AddressEntity> createAddress(AddressRequest request);
  Future<AddressEntity> updateAddress(String id, Map<String, dynamic> updates);
  Future<bool> deleteAddress(String id);
  Future<bool> setDefaultAddress(String id);

  // Wallet
  Future<WalletModel> getWallet();
  Future<List<WalletTransactionModel>> getWalletTransactions({
    int page = 1,
    int limit = 20,
    String? type,
  });
  Future<bool> requestWithdrawal(double amount, String bankDetails);

  // Loyalty
  Future<LoyaltyModel> getLoyaltyPoints();
  Future<bool> redeemPoints(int points);

  // Referral
  Future<ReferralInfoModel> getReferralInfo();
  Future<bool> applyReferralCode(String code);

  // Locations
  Future<List<Map<String, dynamic>>> getCountries();
  Future<List<Map<String, dynamic>>> getCities(String countryId);
  Future<List<Map<String, dynamic>>> getAreas(String cityId);
}
