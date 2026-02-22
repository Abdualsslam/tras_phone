/// Stock Alerts State - States for stock alerts feature
library;

import 'package:equatable/equatable.dart';

/// Base state for stock alerts
abstract class StockAlertsState extends Equatable {
  const StockAlertsState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class StockAlertsInitial extends StockAlertsState {
  const StockAlertsInitial();
}

/// Loading state
class StockAlertsLoading extends StockAlertsState {
  const StockAlertsLoading();
}

/// Loaded state with stock alerts
class StockAlertsLoaded extends StockAlertsState {
  final List<Map<String, dynamic>> alerts;

  const StockAlertsLoaded(this.alerts);

  @override
  List<Object?> get props => [alerts];
}

/// Error state
class StockAlertsError extends StockAlertsState {
  final String message;

  const StockAlertsError(this.message);

  @override
  List<Object?> get props => [message];
}
