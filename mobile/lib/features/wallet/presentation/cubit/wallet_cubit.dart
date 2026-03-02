/// Wallet Cubit
library;

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/loyalty_points_model.dart';
import '../../data/models/loyalty_tier_model.dart';
import '../../data/models/wallet_summary_model.dart';
import '../../data/models/wallet_transaction_model.dart';
import '../../data/repositories/wallet_repository.dart';
import '../../domain/enums/wallet_enums.dart';
import 'wallet_state.dart';

class WalletCubit extends Cubit<WalletState> {
  final WalletRepository _repository;

  WalletCubit(this._repository) : super(const WalletInitial());

  /// جلب رصيد المحفظة
  Future<void> loadBalance() async {
    emit(const WalletLoading());
    try {
      final summary = await _repository.getBalance();
      final currentState = state;
      if (currentState is WalletLoaded) {
        emit(
          currentState.copyWith(
            balance: summary.balance,
            creditLimit: summary.creditLimit,
            creditUsed: summary.creditUsed,
            availableCredit: summary.availableCredit,
          ),
        );
      } else {
        emit(
          WalletLoaded(
            balance: summary.balance,
            creditLimit: summary.creditLimit,
            creditUsed: summary.creditUsed,
            availableCredit: summary.availableCredit,
          ),
        );
      }
    } catch (e) {
      emit(WalletError(e.toString()));
    }
  }

  /// جلب معاملات المحفظة
  Future<void> loadTransactions({
    int page = 1,
    int limit = 20,
    WalletTransactionType? transactionType,
  }) async {
    if (page == 1) emit(const WalletLoading());
    try {
      final transactions = await _repository.getTransactions(
        page: page,
        limit: limit,
        transactionType: transactionType,
      );
      final currentState = state;
      if (currentState is WalletLoaded) {
        emit(
          currentState.copyWith(
            transactions: page > 1
                ? [...?currentState.transactions, ...transactions]
                : transactions,
          ),
        );
      } else {
        emit(WalletLoaded(transactions: transactions));
      }
    } catch (e) {
      emit(WalletError(e.toString()));
    }
  }

  /// جلب نقاط الولاء
  Future<void> loadPoints() async {
    emit(const WalletLoading());
    try {
      final points = await _repository.getPoints();
      final currentState = state;
      if (currentState is WalletLoaded) {
        emit(currentState.copyWith(loyaltyPoints: points));
      } else {
        emit(WalletLoaded(loyaltyPoints: points));
      }
    } catch (e) {
      emit(WalletError(e.toString()));
    }
  }

  /// جلب معاملات النقاط
  Future<void> loadPointsTransactions() async {
    emit(const WalletLoading());
    try {
      final transactions = await _repository.getPointsTransactions();
      final currentState = state;
      if (currentState is WalletLoaded) {
        emit(currentState.copyWith(loyaltyTransactions: transactions));
      } else {
        emit(WalletLoaded(loyaltyTransactions: transactions));
      }
    } catch (e) {
      emit(WalletError(e.toString()));
    }
  }

  /// جلب مستويات الولاء
  Future<void> loadTiers() async {
    emit(const WalletLoading());
    try {
      final tiers = await _repository.getTiers();
      final currentState = state;
      if (currentState is WalletLoaded) {
        emit(currentState.copyWith(tiers: tiers));
      } else {
        emit(WalletLoaded(tiers: tiers));
      }
    } catch (e) {
      emit(WalletError(e.toString()));
    }
  }

  /// جلب جميع بيانات المحفظة
  Future<void> loadAll() async {
    emit(const WalletLoading());
    try {
      final results = await Future.wait<dynamic>([
        _repository.getBalance(),
        _repository.getTransactions(limit: 5),
        _repository.getPoints(),
        _repository.getTiers(),
      ]);
      final summary = results[0] as WalletSummary;
      emit(
        WalletLoaded(
          balance: summary.balance,
          creditLimit: summary.creditLimit,
          creditUsed: summary.creditUsed,
          availableCredit: summary.availableCredit,
          transactions: (results[1] as List).cast<WalletTransaction>(),
          loyaltyPoints: results[2] as LoyaltyPoints,
          tiers: results[3] as List<LoyaltyTier>,
        ),
      );
    } catch (e) {
      emit(WalletError(e.toString()));
    }
  }

  /// جلب رصيد المحفظة مع المعاملات
  Future<void> loadWalletWithTransactions() async {
    emit(const WalletLoading());
    try {
      final summary = await _repository.getBalance();
      final transactions = await _repository.getTransactions();
      emit(
        WalletLoaded(
          balance: summary.balance,
          creditLimit: summary.creditLimit,
          creditUsed: summary.creditUsed,
          availableCredit: summary.availableCredit,
          transactions: transactions,
        ),
      );
    } catch (e) {
      emit(WalletError(e.toString()));
    }
  }

  /// جلب النقاط مع المعاملات
  Future<void> loadPointsWithTransactions() async {
    emit(const WalletLoading());
    try {
      final points = await _repository.getPoints();
      final transactions = await _repository.getPointsTransactions();
      emit(
        WalletLoaded(loyaltyPoints: points, loyaltyTransactions: transactions),
      );
    } catch (e) {
      emit(WalletError(e.toString()));
    }
  }
}
