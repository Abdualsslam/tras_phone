library;

import '../enums/wallet_enums.dart';
import '../../data/models/loyalty_points_model.dart';
import '../../data/models/loyalty_tier_model.dart';
import '../../data/models/loyalty_transaction_model.dart';
import '../../data/models/wallet_summary_model.dart';
import '../../data/models/wallet_transaction_model.dart';

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
