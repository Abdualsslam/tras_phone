/// Wallet Remote DataSource - Real API implementation
library;

import '../../../../core/network/api_client.dart';
import '../../domain/enums/wallet_enums.dart';
import '../models/loyalty_points_model.dart';
import '../models/loyalty_tier_model.dart';
import '../models/loyalty_transaction_model.dart';
import '../models/wallet_summary_model.dart';
import '../models/wallet_transaction_model.dart';

part 'wallet_remote_datasource_support.dart';
part 'wallet_remote_datasource_balance.dart';
part 'wallet_remote_datasource_loyalty.dart';

abstract class WalletRemoteDataSource {
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

class WalletRemoteDataSourceImpl implements WalletRemoteDataSource {
  final ApiClient _apiClient;
  late final _WalletRemoteSupport _support = _WalletRemoteSupport(
    apiClient: _apiClient,
  );
  late final _WalletBalanceDelegate _balance = _WalletBalanceDelegate(
    support: _support,
  );
  late final _WalletLoyaltyDelegate _loyalty = _WalletLoyaltyDelegate(
    support: _support,
  );

  WalletRemoteDataSourceImpl(this._apiClient);

  @override
  Future<WalletSummary> getBalance() => _balance.getBalance();

  @override
  Future<List<WalletTransaction>> getTransactions({
    int page = 1,
    int limit = 20,
    WalletTransactionType? transactionType,
  }) => _balance.getTransactions(
    page: page,
    limit: limit,
    transactionType: transactionType,
  );

  @override
  Future<LoyaltyPoints> getPoints() => _loyalty.getPoints();

  @override
  Future<List<LoyaltyTransaction>> getPointsTransactions() =>
      _loyalty.getPointsTransactions();

  @override
  Future<List<LoyaltyTier>> getTiers() => _loyalty.getTiers();
}
