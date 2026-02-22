/// Stock Alerts Cubit - Manages stock alerts state
library;

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/favorite_remote_datasource.dart';
import 'stock_alerts_state.dart';

/// Cubit for managing stock alerts
class StockAlertsCubit extends Cubit<StockAlertsState> {
  final FavoriteRemoteDataSource _dataSource;

  StockAlertsCubit({required FavoriteRemoteDataSource dataSource})
      : _dataSource = dataSource,
        super(const StockAlertsInitial());

  /// Load stock alerts
  Future<void> loadStockAlerts() async {
    emit(const StockAlertsLoading());

    try {
      final alerts = await _dataSource.getStockAlerts();
      emit(StockAlertsLoaded(alerts));
    } catch (e) {
      emit(StockAlertsError(e.toString()));
    }
  }

  /// Create stock alert for product
  Future<void> createStockAlert(String productId) async {
    try {
      await _dataSource.createStockAlert(productId);
      // Reload to get updated list
      loadStockAlerts();
    } catch (e) {
      emit(StockAlertsError(e.toString()));
    }
  }

  /// Remove stock alert
  Future<void> removeStockAlert(String alertId) async {
    try {
      await _dataSource.removeStockAlert(alertId);
      // Reload to get updated list
      loadStockAlerts();
    } catch (e) {
      emit(StockAlertsError(e.toString()));
    }
  }
}
