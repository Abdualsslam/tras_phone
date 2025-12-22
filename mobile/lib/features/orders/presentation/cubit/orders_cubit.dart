/// Orders Cubit - State management for orders
library;

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/order_entity.dart';
import '../../data/datasources/orders_mock_datasource.dart';
import 'orders_state.dart';

class OrdersCubit extends Cubit<OrdersState> {
  final OrdersMockDataSource _dataSource;

  OrdersCubit({OrdersMockDataSource? dataSource})
    : _dataSource = dataSource ?? OrdersMockDataSource(),
      super(const OrdersInitial());

  /// Load orders
  Future<void> loadOrders({OrderStatus? status}) async {
    emit(const OrdersLoading());

    try {
      final orders = await _dataSource.getOrders(status: status);
      emit(OrdersLoaded(orders, filterStatus: status));
    } catch (e) {
      emit(OrdersError(e.toString()));
    }
  }

  /// Filter orders by status
  Future<void> filterByStatus(OrderStatus? status) async {
    await loadOrders(status: status);
  }

  /// Cancel order
  Future<void> cancelOrder(int orderId) async {
    try {
      await _dataSource.cancelOrder(orderId);
      await loadOrders();
    } catch (e) {
      emit(OrdersError(e.toString()));
    }
  }

  /// Reorder
  Future<void> reorder(int orderId) async {
    try {
      await _dataSource.reorder(orderId);
      await loadOrders();
    } catch (e) {
      emit(OrdersError(e.toString()));
    }
  }
}
