/// Wallet Remote DataSource - Real API implementation
library;

import '../../../../core/network/api_client.dart';
import '../../domain/enums/wallet_enums.dart';
import '../models/loyalty_points_model.dart';
import '../models/loyalty_tier_model.dart';
import '../models/loyalty_transaction_model.dart';
import '../models/wallet_transaction_model.dart';

/// Abstract interface for wallet data source
abstract class WalletRemoteDataSource {
  /// Get wallet balance
  Future<double> getBalance();

  /// Get wallet transactions
  Future<List<WalletTransaction>> getTransactions({
    int page = 1,
    int limit = 20,
    WalletTransactionType? transactionType,
  });

  /// Get loyalty points with tier info
  Future<LoyaltyPoints> getPoints();

  /// Get loyalty points transactions
  Future<List<LoyaltyTransaction>> getPointsTransactions();

  /// Get all loyalty tiers (public endpoint)
  Future<List<LoyaltyTier>> getTiers();
}

/// Implementation of WalletRemoteDataSource
class WalletRemoteDataSourceImpl implements WalletRemoteDataSource {
  final ApiClient _apiClient;

  WalletRemoteDataSourceImpl(this._apiClient);

  @override
  Future<double> getBalance() async {
    final response = await _apiClient.get('/wallet/balance');
    final data = response.data;

    if (data['success'] == true) {
      return (data['data']['balance'] ?? 0).toDouble();
    }
    throw Exception(data['messageAr'] ?? 'فشل في جلب رصيد المحفظة');
  }

  @override
  Future<List<WalletTransaction>> getTransactions({
    int page = 1,
    int limit = 20,
    WalletTransactionType? transactionType,
  }) async {
    final response = await _apiClient.get(
      '/wallet/transactions',
      queryParameters: {
        'page': page,
        'limit': limit,
        if (transactionType != null) 'transactionType': transactionType.apiValue,
      },
    );
    final data = response.data;

    if (data['success'] == true) {
      return (data['data'] as List)
          .map((t) => WalletTransaction.fromJson(t))
          .toList();
    }
    throw Exception(data['messageAr'] ?? 'فشل في جلب معاملات المحفظة');
  }

  @override
  Future<LoyaltyPoints> getPoints() async {
    final response = await _apiClient.get('/wallet/points');
    final data = response.data;

    if (data['success'] == true) {
      return LoyaltyPoints.fromJson(data['data']);
    }
    throw Exception(data['messageAr'] ?? 'فشل في جلب نقاط الولاء');
  }

  @override
  Future<List<LoyaltyTransaction>> getPointsTransactions() async {
    final response = await _apiClient.get('/wallet/points/transactions');
    final data = response.data;

    if (data['success'] == true) {
      return (data['data'] as List)
          .map((t) => LoyaltyTransaction.fromJson(t))
          .toList();
    }
    throw Exception(data['messageAr'] ?? 'فشل في جلب معاملات النقاط');
  }

  @override
  Future<List<LoyaltyTier>> getTiers() async {
    final response = await _apiClient.get('/wallet/tiers');
    final data = response.data;

    if (data['success'] == true) {
      return (data['data'] as List)
          .map((t) => LoyaltyTier.fromJson(t))
          .toList();
    }
    throw Exception(data['messageAr'] ?? 'فشل في جلب مستويات الولاء');
  }
}
