/// Wallet State
library;

import '../../data/models/loyalty_points_model.dart';
import '../../data/models/loyalty_tier_model.dart';
import '../../data/models/loyalty_transaction_model.dart';
import '../../data/models/wallet_transaction_model.dart';

abstract class WalletState {
  const WalletState();
}

class WalletInitial extends WalletState {
  const WalletInitial();
}

class WalletLoading extends WalletState {
  const WalletLoading();
}

class WalletLoaded extends WalletState {
  final double? balance;
  final List<WalletTransaction>? transactions;
  final LoyaltyPoints? loyaltyPoints;
  final List<LoyaltyTransaction>? loyaltyTransactions;
  final List<LoyaltyTier>? tiers;

  const WalletLoaded({
    this.balance,
    this.transactions,
    this.loyaltyPoints,
    this.loyaltyTransactions,
    this.tiers,
  });

  WalletLoaded copyWith({
    double? balance,
    List<WalletTransaction>? transactions,
    LoyaltyPoints? loyaltyPoints,
    List<LoyaltyTransaction>? loyaltyTransactions,
    List<LoyaltyTier>? tiers,
  }) {
    return WalletLoaded(
      balance: balance ?? this.balance,
      transactions: transactions ?? this.transactions,
      loyaltyPoints: loyaltyPoints ?? this.loyaltyPoints,
      loyaltyTransactions: loyaltyTransactions ?? this.loyaltyTransactions,
      tiers: tiers ?? this.tiers,
    );
  }
}

class WalletError extends WalletState {
  final String message;

  const WalletError(this.message);
}
