/// Orders Cubit - State management for orders
library;

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/order_entity.dart';
import '../../data/datasources/orders_remote_datasource.dart';
import 'orders_state.dart';

class OrdersCubit extends Cubit<OrdersState> {
  final OrdersRemoteDataSource _dataSource;

  OrdersCubit({required OrdersRemoteDataSource dataSource})
    : _dataSource = dataSource,
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
  Future<void> cancelOrder(int orderId, {String? reason}) async {
    try {
      await _dataSource.cancelOrder(orderId, reason: reason);
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

  /// Get order by ID
  Future<OrderEntity?> getOrderById(int orderId) async {
    try {
      return await _dataSource.getOrderById(orderId);
    } catch (e) {
      return null;
    }
  }

  /// Track order
  Future<Map<String, dynamic>?> trackOrder(int orderId) async {
    try {
      return await _dataSource.trackOrder(orderId);
    } catch (e) {
      return null;
    }
  }

  /// Rate order
  Future<bool> rateOrder({
    required int orderId,
    required int rating,
    String? comment,
  }) async {
    try {
      return await _dataSource.rateOrder(
        orderId: orderId,
        rating: rating,
        comment: comment,
      );
    } catch (e) {
      return false;
    }
  }
}
