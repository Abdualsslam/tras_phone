/// Wallet Cubit
library;

import 'package:flutter_bloc/flutter_bloc.dart';
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
      final balance = await _repository.getBalance();
      final currentState = state;
      if (currentState is WalletLoaded) {
        emit(currentState.copyWith(balance: balance));
      } else {
        emit(WalletLoaded(balance: balance));
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
    emit(const WalletLoading());
    try {
      final transactions = await _repository.getTransactions(
        page: page,
        limit: limit,
        transactionType: transactionType,
      );
      final currentState = state;
      if (currentState is WalletLoaded) {
        emit(currentState.copyWith(transactions: transactions));
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
      final balance = await _repository.getBalance();
      final points = await _repository.getPoints();
      final tiers = await _repository.getTiers();
      emit(WalletLoaded(
        balance: balance,
        loyaltyPoints: points,
        tiers: tiers,
      ));
    } catch (e) {
      emit(WalletError(e.toString()));
    }
  }

  /// جلب رصيد المحفظة مع المعاملات
  Future<void> loadWalletWithTransactions() async {
    emit(const WalletLoading());
    try {
      final balance = await _repository.getBalance();
      final transactions = await _repository.getTransactions();
      emit(WalletLoaded(balance: balance, transactions: transactions));
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
      emit(WalletLoaded(
        loyaltyPoints: points,
        loyaltyTransactions: transactions,
      ));
    } catch (e) {
      emit(WalletError(e.toString()));
    }
  }
}
