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
    try {
      final response = await _apiClient.get('/wallet/balance');
      final data = response.data;

      if (data['success'] == true) {
        return (data['data']['balance'] ?? 0).toDouble();
      }
      throw Exception(data['messageAr'] ?? data['message'] ?? 'فشل في جلب رصيد المحفظة');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('فشل في جلب رصيد المحفظة: ${e.toString()}');
    }
  }

  @override
  Future<List<WalletTransaction>> getTransactions({
    int page = 1,
    int limit = 20,
    WalletTransactionType? transactionType,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      
      // Use 'type' parameter as per API documentation
      if (transactionType != null) {
        queryParams['type'] = transactionType.apiValue;
      }

      final response = await _apiClient.get(
        '/wallet/transactions',
        queryParameters: queryParams,
      );
      final data = response.data;

      if (data['success'] == true) {
        final transactionsList = data['data'] as List? ?? [];
        return transactionsList
            .map((t) => WalletTransaction.fromJson(t))
            .toList();
      }
      throw Exception(data['messageAr'] ?? data['message'] ?? 'فشل في جلب معاملات المحفظة');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('فشل في جلب معاملات المحفظة: ${e.toString()}');
    }
  }

  @override
  Future<LoyaltyPoints> getPoints() async {
    try {
      final response = await _apiClient.get('/wallet/points');
      final data = response.data;

      if (data['success'] == true) {
        return LoyaltyPoints.fromJson(data['data'] ?? {});
      }
      throw Exception(data['messageAr'] ?? data['message'] ?? 'فشل في جلب نقاط الولاء');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('فشل في جلب نقاط الولاء: ${e.toString()}');
    }
  }

  @override
  Future<List<LoyaltyTransaction>> getPointsTransactions() async {
    try {
      final response = await _apiClient.get('/wallet/points/transactions');
      final data = response.data;

      if (data['success'] == true) {
        final transactionsList = data['data'] as List? ?? [];
        return transactionsList
            .map((t) => LoyaltyTransaction.fromJson(t))
            .toList();
      }
      throw Exception(data['messageAr'] ?? data['message'] ?? 'فشل في جلب معاملات النقاط');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('فشل في جلب معاملات النقاط: ${e.toString()}');
    }
  }

  @override
  Future<List<LoyaltyTier>> getTiers() async {
    try {
      final response = await _apiClient.get('/wallet/tiers');
      final data = response.data;

      if (data['success'] == true) {
        final tiersList = data['data'] as List? ?? [];
        return tiersList
            .map((t) => LoyaltyTier.fromJson(t))
            .toList();
      }
      throw Exception(data['messageAr'] ?? data['message'] ?? 'فشل في جلب مستويات الولاء');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('فشل في جلب مستويات الولاء: ${e.toString()}');
    }
  }
}
