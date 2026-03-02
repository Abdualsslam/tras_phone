/// Orders Cubit - State management for orders
library;

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/entities/order_stats_entity.dart';
import '../../data/datasources/orders_remote_datasource.dart'
    show OrdersRemoteDataSource, OrdersResponseData;
import '../../data/models/shipping_address_model.dart';
import 'orders_state.dart';

class OrdersCubit extends Cubit<OrdersState> {
  final OrdersRemoteDataSource _dataSource;

  OrdersCubit({required OrdersRemoteDataSource dataSource})
    : _dataSource = dataSource,
      super(const OrdersInitial());

  /// Load my orders
  Future<void> loadOrders({
    OrderStatus? status,
    PaymentStatus? paymentStatus,
    String? orderNumber,
    String? sortBy,
    String? sortOrder,
    int page = 1,
    int limit = 20,
  }) async {
    emit(const OrdersLoading());

    try {
      final results = await Future.wait([
        _dataSource.getMyOrders(
          status: status,
          paymentStatus: paymentStatus,
          orderNumber: orderNumber,
          sortBy: sortBy,
          sortOrder: sortOrder,
          page: page,
          limit: limit,
        ),
        _dataSource.getMyOrderStats(),
      ]);
      final response = results[0] as OrdersResponseData;
      final stats = results[1] as OrderStatsEntity;
      emit(
        OrdersLoaded(
          response.orders,
          total: response.total,
          filterStatus: status,
          stats: stats,
        ),
      );
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
    String? bankAccountId,
    String? receiptImage,
    String? transferReference,
    String? transferDate,
    String? transferNotes,
  }) async {
    try {
      return await _dataSource.createOrder(
        shippingAddressId: shippingAddressId,
        shippingAddress: shippingAddress,
        paymentMethod: paymentMethod,
        customerNotes: customerNotes,
        couponCode: couponCode,
        bankAccountId: bankAccountId,
        receiptImage: receiptImage,
        transferReference: transferReference,
        transferDate: transferDate,
        transferNotes: transferNotes,
      );
    } catch (e) {
      emit(OrdersError(e.toString()));
      return null;
    }
  }

  /// Cancel order (reason is required by API)
  Future<void> cancelOrder(String orderId, {required String reason}) async {
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

  /// Get order invoice URL
  Future<String> getOrderInvoice(String orderId) async {
    return await _dataSource.getOrderInvoice(orderId);
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
  Future<OrderEntity?> rateOrder({
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
      emit(OrdersError(e.toString()));
      return null;
    }
  }

  /// Load order statistics
  Future<void> loadOrderStats() async {
    try {
      final stats = await _dataSource.getMyOrderStats();
      emit(OrdersStatsLoaded(stats));
    } catch (e) {
      emit(OrdersError(e.toString()));
    }
  }

  /// Load pending payment orders
  Future<void> loadPendingPaymentOrders() async {
    try {
      final orders = await _dataSource.getPendingPaymentOrders();
      emit(OrdersPendingPaymentLoaded(orders));
    } catch (e) {
      emit(OrdersError(e.toString()));
    }
  }

  /// Load bank accounts
  Future<void> loadBankAccounts() async {
    try {
      final accounts = await _dataSource.getBankAccounts();
      emit(BankAccountsLoaded(accounts));
    } catch (e) {
      emit(OrdersError(e.toString()));
    }
  }

  /// Upload receipt for order
  Future<OrderEntity?> uploadReceipt({
    required String orderId,
    required String receiptImage,
    String? transferReference,
    String? transferDate,
    String? notes,
  }) async {
    emit(OrderReceiptUploading(orderId));
    try {
      final order = await _dataSource.uploadReceipt(
        orderId: orderId,
        receiptImage: receiptImage,
        transferReference: transferReference,
        transferDate: transferDate,
        notes: notes,
      );
      // Reload orders to get updated state
      await loadOrders();
      return order;
    } catch (e) {
      emit(OrdersError(e.toString()));
      return null;
    }
  }
}
