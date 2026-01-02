/// Profile Remote DataSource - Real API implementation
library;

import 'dart:developer' as developer;
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../auth/data/models/customer_model.dart';
import '../../../auth/domain/entities/customer_entity.dart';
import '../models/address_model.dart';
import '../models/wallet_model.dart';

/// Abstract interface for profile data source
abstract class ProfileRemoteDataSource {
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
  Future<List<AddressModel>> getAddresses();
  Future<AddressModel> getAddressById(int id);
  Future<AddressModel> createAddress(AddressRequest request);
  Future<AddressModel> updateAddress(int id, AddressRequest request);
  Future<bool> deleteAddress(int id);
  Future<bool> setDefaultAddress(int id);

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
  Future<ReferralModel> getReferralInfo();
  Future<bool> applyReferralCode(String code);

  // Locations
  Future<List<Map<String, dynamic>>> getCountries();
  Future<List<Map<String, dynamic>>> getCities(int countryId);
  Future<List<Map<String, dynamic>>> getAreas(int cityId);
}

/// Implementation of ProfileRemoteDataSource using API client
class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final ApiClient _apiClient;

  ProfileRemoteDataSourceImpl({required ApiClient apiClient})
    : _apiClient = apiClient;

  // ═══════════════════════════════════════════════════════════════════════════
  // PROFILE
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  Future<CustomerEntity> getProfile() async {
    developer.log('Fetching profile', name: 'ProfileDataSource');

    final response = await _apiClient.get(ApiEndpoints.profile);
    final data = response.data['data'] ?? response.data;

    return CustomerModel.fromJson(data).toEntity();
  }

  @override
  Future<CustomerEntity> updateProfile({
    String? name,
    String? email,
    String? phone,
    String? avatar,
  }) async {
    developer.log('Updating profile', name: 'ProfileDataSource');

    final response = await _apiClient.put(
      ApiEndpoints.profile,
      data: {
        if (name != null) 'name': name,
        if (email != null) 'email': email,
        if (phone != null) 'phone': phone,
        if (avatar != null) 'avatar': avatar,
      },
    );

    final data = response.data['data'] ?? response.data;
    return CustomerModel.fromJson(data).toEntity();
  }

  @override
  Future<bool> deleteAccount({String? reason}) async {
    developer.log('Deleting account', name: 'ProfileDataSource');

    final response = await _apiClient.delete(
      ApiEndpoints.profile,
      data: {if (reason != null) 'reason': reason},
    );

    return response.statusCode == 200;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ADDRESSES
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  Future<List<AddressModel>> getAddresses() async {
    developer.log('Fetching addresses', name: 'ProfileDataSource');

    final response = await _apiClient.get(ApiEndpoints.addresses);
    final data = response.data['data'] ?? response.data;
    final List<dynamic> list = data is List ? data : [];

    return list.map((json) => AddressModel.fromJson(json)).toList();
  }

  @override
  Future<AddressModel> getAddressById(int id) async {
    developer.log('Fetching address: $id', name: 'ProfileDataSource');

    final response = await _apiClient.get('${ApiEndpoints.addresses}/$id');
    final data = response.data['data'] ?? response.data;

    return AddressModel.fromJson(data);
  }

  @override
  Future<AddressModel> createAddress(AddressRequest request) async {
    developer.log('Creating address', name: 'ProfileDataSource');

    final response = await _apiClient.post(
      ApiEndpoints.addresses,
      data: request.toJson(),
    );

    final data = response.data['data'] ?? response.data;
    return AddressModel.fromJson(data);
  }

  @override
  Future<AddressModel> updateAddress(int id, AddressRequest request) async {
    developer.log('Updating address: $id', name: 'ProfileDataSource');

    final response = await _apiClient.put(
      '${ApiEndpoints.addresses}/$id',
      data: request.toJson(),
    );

    final data = response.data['data'] ?? response.data;
    return AddressModel.fromJson(data);
  }

  @override
  Future<bool> deleteAddress(int id) async {
    developer.log('Deleting address: $id', name: 'ProfileDataSource');

    final response = await _apiClient.delete('${ApiEndpoints.addresses}/$id');
    return response.statusCode == 200;
  }

  @override
  Future<bool> setDefaultAddress(int id) async {
    developer.log('Setting default address: $id', name: 'ProfileDataSource');

    final response = await _apiClient.post(
      '${ApiEndpoints.addresses}/$id/default',
    );

    return response.statusCode == 200;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // WALLET
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  Future<WalletModel> getWallet() async {
    developer.log('Fetching wallet', name: 'ProfileDataSource');

    final response = await _apiClient.get(ApiEndpoints.wallet);
    final data = response.data['data'] ?? response.data;

    return WalletModel.fromJson(data);
  }

  @override
  Future<List<WalletTransactionModel>> getWalletTransactions({
    int page = 1,
    int limit = 20,
    String? type,
  }) async {
    developer.log('Fetching wallet transactions', name: 'ProfileDataSource');

    final response = await _apiClient.get(
      ApiEndpoints.walletTransactions,
      queryParameters: {
        'page': page,
        'limit': limit,
        if (type != null) 'type': type,
      },
    );

    final data = response.data['data'] ?? response.data;
    final List<dynamic> list = data is List ? data : [];

    return list.map((json) => WalletTransactionModel.fromJson(json)).toList();
  }

  @override
  Future<bool> requestWithdrawal(double amount, String bankDetails) async {
    developer.log('Requesting withdrawal: $amount', name: 'ProfileDataSource');

    final response = await _apiClient.post(
      '${ApiEndpoints.wallet}/withdraw',
      data: {'amount': amount, 'bank_details': bankDetails},
    );

    return response.statusCode == 200;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // LOYALTY
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  Future<LoyaltyModel> getLoyaltyPoints() async {
    developer.log('Fetching loyalty points', name: 'ProfileDataSource');

    final response = await _apiClient.get(ApiEndpoints.loyalty);
    final data = response.data['data'] ?? response.data;

    return LoyaltyModel.fromJson(data);
  }

  @override
  Future<bool> redeemPoints(int points) async {
    developer.log('Redeeming points: $points', name: 'ProfileDataSource');

    final response = await _apiClient.post(
      '${ApiEndpoints.loyalty}/redeem',
      data: {'points': points},
    );

    return response.statusCode == 200;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // REFERRAL
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  Future<ReferralModel> getReferralInfo() async {
    developer.log('Fetching referral info', name: 'ProfileDataSource');

    final response = await _apiClient.get(ApiEndpoints.referral);
    final data = response.data['data'] ?? response.data;

    return ReferralModel.fromJson(data);
  }

  @override
  Future<bool> applyReferralCode(String code) async {
    developer.log('Applying referral code: $code', name: 'ProfileDataSource');

    final response = await _apiClient.post(
      '${ApiEndpoints.referral}/apply',
      data: {'code': code},
    );

    return response.statusCode == 200;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // LOCATIONS
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  Future<List<Map<String, dynamic>>> getCountries() async {
    developer.log('Fetching countries', name: 'ProfileDataSource');

    final response = await _apiClient.get(ApiEndpoints.countries);
    final data = response.data['data'] ?? response.data;

    if (data is List) {
      return data.cast<Map<String, dynamic>>();
    }
    return [];
  }

  @override
  Future<List<Map<String, dynamic>>> getCities(int countryId) async {
    developer.log(
      'Fetching cities for country: $countryId',
      name: 'ProfileDataSource',
    );

    final response = await _apiClient.get(
      ApiEndpoints.cities,
      queryParameters: {'country_id': countryId},
    );
    final data = response.data['data'] ?? response.data;

    if (data is List) {
      return data.cast<Map<String, dynamic>>();
    }
    return [];
  }

  @override
  Future<List<Map<String, dynamic>>> getAreas(int cityId) async {
    developer.log(
      'Fetching areas for city: $cityId',
      name: 'ProfileDataSource',
    );

    final response = await _apiClient.get(
      '${ApiEndpoints.cities}/$cityId/areas',
    );
    final data = response.data['data'] ?? response.data;

    if (data is List) {
      return data.cast<Map<String, dynamic>>();
    }
    return [];
  }
}
