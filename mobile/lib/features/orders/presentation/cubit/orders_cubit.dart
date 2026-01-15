/// Orders Cubit - State management for orders
library;

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/enums/order_enums.dart';
import '../../data/datasources/orders_remote_datasource.dart';
import '../../data/models/shipping_address_model.dart';
import 'orders_state.dart';

class OrdersCubit extends Cubit<OrdersState> {
  final OrdersRemoteDataSource _dataSource;

  OrdersCubit({required OrdersRemoteDataSource dataSource})
    : _dataSource = dataSource,
      super(const OrdersInitial());

  /// Load my orders
  Future<void> loadOrders({OrderStatus? status, int page = 1, int limit = 20}) async {
    emit(const OrdersLoading());

    try {
      final response = await _dataSource.getMyOrders(
        status: status,
        page: page,
        limit: limit,
      );
      emit(OrdersLoaded(
        response.orders,
        total: response.total,
        filterStatus: status,
      ));
    } catch (e) {
      emit(OrdersError(e.toString()));
    }
  }

  /// Filter orders by status
  Future<void> filterByStatus(OrderStatus? status) async {
    await loadOrders(status: status);
  }

  /// Create new order
  Future<OrderEntity?> createOrder({
    String? shippingAddressId,
    ShippingAddressModel? shippingAddress,
    OrderPaymentMethod? paymentMethod,
    String? customerNotes,
    String? couponCode,
  }) async {
    try {
      return await _dataSource.createOrder(
        shippingAddressId: shippingAddressId,
        shippingAddress: shippingAddress,
        paymentMethod: paymentMethod,
        customerNotes: customerNotes,
        couponCode: couponCode,
      );
    } catch (e) {
      emit(OrdersError(e.toString()));
      return null;
    }
  }

  /// Cancel order
  Future<void> cancelOrder(String orderId, {String? reason}) async {
    try {
      await _dataSource.cancelOrder(orderId, reason: reason);
      await loadOrders();
    } catch (e) {
      emit(OrdersError(e.toString()));
    }
  }

  /// Reorder
  Future<void> reorder(String orderId) async {
    try {
      await _dataSource.reorder(orderId);
      await loadOrders();
    } catch (e) {
      emit(OrdersError(e.toString()));
    }
  }

  /// Get order by ID
  Future<OrderEntity?> getOrderById(String orderId) async {
    try {
      return await _dataSource.getOrderById(orderId);
    } catch (e) {
      return null;
    }
  }

  /// Track order
  Future<Map<String, dynamic>?> trackOrder(String orderId) async {
    try {
      return await _dataSource.trackOrder(orderId);
    } catch (e) {
      return null;
    }
  }

  /// Rate order
  Future<bool> rateOrder({
    required String orderId,
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
