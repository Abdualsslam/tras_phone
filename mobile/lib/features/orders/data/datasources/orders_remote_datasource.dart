/// Orders Remote DataSource - Real API implementation
library;

import 'dart:developer' as developer;

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/bank_account_entity.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/entities/order_stats_entity.dart';
import '../models/bank_account_model.dart';
import '../models/order_model.dart';
import '../models/order_stats_model.dart';
import '../models/shipping_address_model.dart';

part 'orders_remote_datasource_support.dart';
part 'orders_remote_datasource_orders.dart';
part 'orders_remote_datasource_checkout.dart';

class OrdersResponseData {
  final List<OrderEntity> orders;
  final int total;

  OrdersResponseData({required this.orders, required this.total});
}

abstract class OrdersRemoteDataSource {
  Future<OrdersResponseData> getMyOrders({
    OrderStatus? status,
    PaymentStatus? paymentStatus,
    String? orderNumber,
    String? sortBy,
    String? sortOrder,
    int page = 1,
    int limit = 20,
  });

  Future<OrderEntity> getOrderById(String orderId);

  Future<OrderEntity> createOrder({
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
  });

  Future<OrderEntity> cancelOrder(String orderId, {required String reason});

  Future<OrderEntity> reorder(String orderId);

  Future<Map<String, dynamic>> trackOrder(String orderId);

  Future<String> getOrderInvoice(String orderId);

  Future<OrderEntity> rateOrder({
    required String orderId,
    required int rating,
    String? comment,
  });

  Future<OrderStatsEntity> getMyOrderStats();

  Future<List<OrderEntity>> getPendingPaymentOrders();

  Future<List<BankAccountEntity>> getBankAccounts();

  Future<OrderEntity> uploadReceipt({
    required String orderId,
    required String receiptImage,
    String? transferReference,
    String? transferDate,
    String? notes,
  });

  Future<List<Map<String, dynamic>>> getPaymentMethods();

  Future<List<Map<String, dynamic>>> getShippingAddresses();

  Future<double> calculateShipping({
    required String addressId,
    required List<String> productIds,
  });
}

class OrdersRemoteDataSourceImpl implements OrdersRemoteDataSource {
  final ApiClient _apiClient;
  late final _OrdersRemoteSupport _support = _OrdersRemoteSupport(
    apiClient: _apiClient,
  );
  late final _OrdersRemoteOrdersDelegate _orders = _OrdersRemoteOrdersDelegate(
    support: _support,
  );
  late final _OrdersRemoteCheckoutDelegate _checkout =
      _OrdersRemoteCheckoutDelegate(support: _support);

  OrdersRemoteDataSourceImpl({required ApiClient apiClient})
    : _apiClient = apiClient;

  @override
  Future<OrdersResponseData> getMyOrders({
    OrderStatus? status,
    PaymentStatus? paymentStatus,
    String? orderNumber,
    String? sortBy,
    String? sortOrder,
    int page = 1,
    int limit = 20,
  }) {
    return _orders.getMyOrders(
      status: status,
      paymentStatus: paymentStatus,
      orderNumber: orderNumber,
      sortBy: sortBy,
      sortOrder: sortOrder,
      page: page,
      limit: limit,
    );
  }

  @override
  Future<OrderEntity> getOrderById(String orderId) =>
      _orders.getOrderById(orderId);

  @override
  Future<OrderEntity> createOrder({
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
  }) {
    return _checkout.createOrder(
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
  }

  @override
  Future<OrderEntity> cancelOrder(String orderId, {required String reason}) =>
      _orders.cancelOrder(orderId, reason: reason);

  @override
  Future<OrderEntity> reorder(String orderId) => _orders.reorder(orderId);

  @override
  Future<Map<String, dynamic>> trackOrder(String orderId) =>
      _orders.trackOrder(orderId);

  @override
  Future<String> getOrderInvoice(String orderId) =>
      _orders.getOrderInvoice(orderId);

  @override
  Future<OrderEntity> rateOrder({
    required String orderId,
    required int rating,
    String? comment,
  }) => _orders.rateOrder(orderId: orderId, rating: rating, comment: comment);

  @override
  Future<OrderStatsEntity> getMyOrderStats() => _orders.getMyOrderStats();

  @override
  Future<List<OrderEntity>> getPendingPaymentOrders() =>
      _orders.getPendingPaymentOrders();

  @override
  Future<List<BankAccountEntity>> getBankAccounts() =>
      _orders.getBankAccounts();

  @override
  Future<OrderEntity> uploadReceipt({
    required String orderId,
    required String receiptImage,
    String? transferReference,
    String? transferDate,
    String? notes,
  }) {
    return _checkout.uploadReceipt(
      orderId: orderId,
      receiptImage: receiptImage,
      transferReference: transferReference,
      transferDate: transferDate,
      notes: notes,
    );
  }

  @override
  Future<List<Map<String, dynamic>>> getPaymentMethods() =>
      _checkout.getPaymentMethods();

  @override
  Future<List<Map<String, dynamic>>> getShippingAddresses() =>
      _checkout.getShippingAddresses();

  @override
  Future<double> calculateShipping({
    required String addressId,
    required List<String> productIds,
  }) =>
      _checkout.calculateShipping(addressId: addressId, productIds: productIds);
}
