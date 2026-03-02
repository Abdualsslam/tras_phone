/// Wallet Repository - Abstracts data source
library;

import '../../domain/enums/wallet_enums.dart';
import '../datasources/wallet_remote_datasource.dart';
import '../models/loyalty_points_model.dart';
import '../models/loyalty_tier_model.dart';
import '../models/loyalty_transaction_model.dart';
import '../models/wallet_summary_model.dart';
import '../models/wallet_transaction_model.dart';

/// Abstract interface for wallet repository
abstract class WalletRepository {
  Future<WalletSummary> getBalance();
  Future<List<WalletTransaction>> getTransactions({
    int page = 1,
    int limit = 20,
    WalletTransactionType? transactionType,
  });
  Future<LoyaltyPoints> getPoints();
  Future<List<LoyaltyTransaction>> getPointsTransactions();
  Future<List<LoyaltyTier>> getTiers();
}

/// Implementation of WalletRepository
class WalletRepositoryImpl implements WalletRepository {
  final WalletRemoteDataSource _remoteDataSource;

  WalletRepositoryImpl(this._remoteDataSource);

  @override
  Future<WalletSummary> getBalance() => _remoteDataSource.getBalance();

  @override
  Future<List<WalletTransaction>> getTransactions({
    int page = 1,
    int limit = 20,
    WalletTransactionType? transactionType,
  }) =>
      _remoteDataSource.getTransactions(
        page: page,
        limit: limit,
        transactionType: transactionType,
      );

  @override
  Future<LoyaltyPoints> getPoints() => _remoteDataSource.getPoints();

  @override
  Future<List<LoyaltyTransaction>> getPointsTransactions() =>
      _remoteDataSource.getPointsTransactions();

  @override
  Future<List<LoyaltyTier>> getTiers() => _remoteDataSource.getTiers();
}
