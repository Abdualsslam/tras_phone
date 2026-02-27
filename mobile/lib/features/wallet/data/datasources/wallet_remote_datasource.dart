/// Wallet Remote DataSource - Real API implementation
library;

import '../../../../core/network/api_client.dart';
import '../../domain/enums/wallet_enums.dart';
import '../models/loyalty_points_model.dart';
import '../models/loyalty_tier_model.dart';
import '../models/loyalty_transaction_model.dart';
import '../models/wallet_summary_model.dart';
import '../models/wallet_transaction_model.dart';

/// Abstract interface for wallet data source
abstract class WalletRemoteDataSource {
  /// Get wallet balance
  Future<WalletSummary> getBalance();

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

  Map<String, dynamic> _asMap(dynamic raw) {
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) return Map<String, dynamic>.from(raw);
    return const <String, dynamic>{};
  }

  bool _isSuccessResponse(Map<String, dynamic> body) {
    final success = body['success'];
    if (success is bool) return success;

    final status = body['status']?.toString().toLowerCase();
    if (status != null && status.isNotEmpty) {
      return status == 'success' || status == 'ok';
    }

    final statusCode = body['statusCode'];
    if (statusCode is num) {
      return statusCode >= 200 && statusCode < 300;
    }

    return false;
  }

  String _extractMessage(Map<String, dynamic> body, String fallback) {
    final messageAr = body['messageAr'];
    if (messageAr is String && messageAr.trim().isNotEmpty) return messageAr;

    final message = body['message'];
    if (message is String && message.trim().isNotEmpty) return message;

    return fallback;
  }

  @override
  Future<WalletSummary> getBalance() async {
    try {
      final response = await _apiClient.get('/wallet/balance');
      final body = _asMap(response.data);

      if (_isSuccessResponse(body)) {
        final payload = _asMap(body['data']);
        return WalletSummary.fromJson(payload);
      }
      throw Exception(_extractMessage(body, 'فشل في جلب رصيد المحفظة'));
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
      final queryParams = <String, dynamic>{'page': page, 'limit': limit};

      // Use 'type' parameter as per API documentation
      if (transactionType != null) {
        queryParams['type'] = transactionType.apiValue;
      }

      final response = await _apiClient.get(
        '/wallet/transactions',
        queryParameters: queryParams,
      );
      final body = _asMap(response.data);

      if (_isSuccessResponse(body)) {
        final transactionsList = body['data'] as List? ?? [];
        return transactionsList
            .map((t) => WalletTransaction.fromJson(t))
            .toList();
      }
      throw Exception(_extractMessage(body, 'فشل في جلب معاملات المحفظة'));
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('فشل في جلب معاملات المحفظة: ${e.toString()}');
    }
  }

  @override
  Future<LoyaltyPoints> getPoints() async {
    try {
      final response = await _apiClient.get('/wallet/points');
      final body = _asMap(response.data);

      if (_isSuccessResponse(body)) {
        return LoyaltyPoints.fromJson(_asMap(body['data']));
      }
      throw Exception(_extractMessage(body, 'فشل في جلب نقاط الولاء'));
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('فشل في جلب نقاط الولاء: ${e.toString()}');
    }
  }

  @override
  Future<List<LoyaltyTransaction>> getPointsTransactions() async {
    try {
      final response = await _apiClient.get('/wallet/points/transactions');
      final body = _asMap(response.data);

      if (_isSuccessResponse(body)) {
        final transactionsList = body['data'] as List? ?? [];
        return transactionsList
            .map((t) => LoyaltyTransaction.fromJson(t))
            .toList();
      }
      throw Exception(_extractMessage(body, 'فشل في جلب معاملات النقاط'));
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('فشل في جلب معاملات النقاط: ${e.toString()}');
    }
  }

  @override
  Future<List<LoyaltyTier>> getTiers() async {
    try {
      final response = await _apiClient.get('/wallet/tiers');
      final body = _asMap(response.data);

      if (_isSuccessResponse(body)) {
        final tiersList = body['data'] as List? ?? [];
        return tiersList.map((t) => LoyaltyTier.fromJson(t)).toList();
      }
      throw Exception(_extractMessage(body, 'فشل في جلب مستويات الولاء'));
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('فشل في جلب مستويات الولاء: ${e.toString()}');
    }
  }
}
