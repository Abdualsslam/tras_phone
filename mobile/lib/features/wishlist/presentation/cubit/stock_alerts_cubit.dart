/// Stock Alerts Cubit - Manages stock alerts state
library;

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/wishlist_repository.dart';
import 'stock_alerts_state.dart';

/// Cubit for managing stock alerts
class StockAlertsCubit extends Cubit<StockAlertsState> {
  final WishlistRepository _repository;

  StockAlertsCubit({required WishlistRepository repository})
      : _repository = repository,
        super(const StockAlertsInitial());

  /// Load stock alerts
  Future<void> loadStockAlerts() async {
    emit(const StockAlertsLoading());

    final result = await _repository.getStockAlerts();

    result.fold(
      (failure) => emit(StockAlertsError(failure.message)),
      (alerts) => emit(StockAlertsLoaded(alerts)),
    );
  }

  /// Create stock alert for product
  Future<void> createStockAlert(String productId) async {
    final result = await _repository.createStockAlert(productId);

    result.fold(
      (failure) => emit(StockAlertsError(failure.message)),
      (_) {
        // Reload to get updated list
        loadStockAlerts();
      },
    );
  }

  /// Remove stock alert
  Future<void> removeStockAlert(String productId) async {
    final result = await _repository.removeStockAlert(productId);

    result.fold(
      (failure) => emit(StockAlertsError(failure.message)),
      (_) {
        // Reload to get updated list
        loadStockAlerts();
      },
    );
  }
}
