/// Orders Remote DataSource - Real API implementation
library;

import 'dart:developer' as developer;
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../domain/entities/order_entity.dart';
import '../models/order_model.dart';

/// Abstract interface for orders data source
abstract class OrdersRemoteDataSource {
  /// Get all orders with optional filtering and pagination
  Future<List<OrderEntity>> getOrders({
    OrderStatus? status,
    int page = 1,
    int limit = 20,
  });

  /// Get order by ID
  Future<OrderEntity> getOrderById(int id);

  /// Create new order (checkout)
  Future<OrderEntity> createOrder({
    int? shippingAddressId,
    String? shippingAddress,
    required String paymentMethod,
    String? notes,
    String? couponCode,
  });

  /// Cancel order
  Future<OrderEntity> cancelOrder(int id, {String? reason});

  /// Reorder (create new order from existing)
  Future<OrderEntity> reorder(int orderId);

  /// Track order
  Future<Map<String, dynamic>> trackOrder(int id);

  /// Get order invoice
  Future<String> getOrderInvoice(int id);

  /// Rate order / product
  Future<bool> rateOrder({
    required int orderId,
    required int rating,
    String? comment,
  });

  /// Get available payment methods
  Future<List<Map<String, dynamic>>> getPaymentMethods();

  /// Get shipping addresses
  Future<List<Map<String, dynamic>>> getShippingAddresses();

  /// Calculate shipping cost
  Future<double> calculateShipping({
    required int addressId,
    required List<int> productIds,
  });
}

/// Implementation of OrdersRemoteDataSource using API client
class OrdersRemoteDataSourceImpl implements OrdersRemoteDataSource {
  final ApiClient _apiClient;

  OrdersRemoteDataSourceImpl({required ApiClient apiClient})
    : _apiClient = apiClient;

  @override
  Future<List<OrderEntity>> getOrders({
    OrderStatus? status,
    int page = 1,
    int limit = 20,
  }) async {
    developer.log('Fetching orders (page: $page)', name: 'OrdersDataSource');

    final response = await _apiClient.get(
      ApiEndpoints.orders,
      queryParameters: {
        'page': page,
        'limit': limit,
        if (status != null) 'status': status.name,
      },
    );

    final data = response.data['data'] ?? response.data;
    final List<dynamic> list = data is List ? data : [];

    return list.map((json) => OrderModel.fromJson(json).toEntity()).toList();
  }

  @override
  Future<OrderEntity> getOrderById(int id) async {
    developer.log('Fetching order: $id', name: 'OrdersDataSource');

    final response = await _apiClient.get('${ApiEndpoints.orders}/$id');
    final data = response.data['data'] ?? response.data;

    return OrderModel.fromJson(data).toEntity();
  }

  @override
  Future<OrderEntity> createOrder({
    int? shippingAddressId,
    String? shippingAddress,
    required String paymentMethod,
    String? notes,
    String? couponCode,
  }) async {
    developer.log('Creating order', name: 'OrdersDataSource');

    final response = await _apiClient.post(
      ApiEndpoints.ordersCreate,
      data: {
        if (shippingAddressId != null) 'shipping_address_id': shippingAddressId,
        if (shippingAddress != null) 'shipping_address': shippingAddress,
        'payment_method': paymentMethod,
        if (notes != null) 'notes': notes,
        if (couponCode != null) 'coupon_code': couponCode,
      },
    );

    final data = response.data['data'] ?? response.data;
    return OrderModel.fromJson(data).toEntity();
  }

  @override
  Future<OrderEntity> cancelOrder(int id, {String? reason}) async {
    developer.log('Cancelling order: $id', name: 'OrdersDataSource');

    final response = await _apiClient.post(
      '${ApiEndpoints.orders}/$id/cancel',
      data: {if (reason != null) 'reason': reason},
    );

    final data = response.data['data'] ?? response.data;
    return OrderModel.fromJson(data).toEntity();
  }

  @override
  Future<OrderEntity> reorder(int orderId) async {
    developer.log('Reordering from: $orderId', name: 'OrdersDataSource');

    final response = await _apiClient.post(
      '${ApiEndpoints.orders}/$orderId/reorder',
    );

    final data = response.data['data'] ?? response.data;
    return OrderModel.fromJson(data).toEntity();
  }

  @override
  Future<Map<String, dynamic>> trackOrder(int id) async {
    developer.log('Tracking order: $id', name: 'OrdersDataSource');

    final response = await _apiClient.get('${ApiEndpoints.orders}/$id/track');

    return response.data['data'] ?? response.data;
  }

  @override
  Future<String> getOrderInvoice(int id) async {
    developer.log('Getting invoice for order: $id', name: 'OrdersDataSource');

    final response = await _apiClient.get('${ApiEndpoints.orders}/$id/invoice');

    return response.data['data']?['url'] ?? '';
  }

  @override
  Future<bool> rateOrder({
    required int orderId,
    required int rating,
    String? comment,
  }) async {
    developer.log('Rating order: $orderId', name: 'OrdersDataSource');

    final response = await _apiClient.post(
      '${ApiEndpoints.orders}/$orderId/rate',
      data: {'rating': rating, if (comment != null) 'comment': comment},
    );

    return response.statusCode == 200;
  }

  @override
  Future<List<Map<String, dynamic>>> getPaymentMethods() async {
    developer.log('Fetching payment methods', name: 'OrdersDataSource');

    final response = await _apiClient.get(ApiEndpoints.paymentMethods);
    final data = response.data['data'] ?? response.data;

    if (data is List) {
      return data.cast<Map<String, dynamic>>();
    }
    return [];
  }

  @override
  Future<List<Map<String, dynamic>>> getShippingAddresses() async {
    developer.log('Fetching shipping addresses', name: 'OrdersDataSource');

    final response = await _apiClient.get(ApiEndpoints.addresses);
    final data = response.data['data'] ?? response.data;

    if (data is List) {
      return data.cast<Map<String, dynamic>>();
    }
    return [];
  }

  @override
  Future<double> calculateShipping({
    required int addressId,
    required List<int> productIds,
  }) async {
    developer.log('Calculating shipping', name: 'OrdersDataSource');

    final response = await _apiClient.post(
      ApiEndpoints.calculateShipping,
      data: {'address_id': addressId, 'product_ids': productIds},
    );

    final data = response.data['data'] ?? response.data;
    return (data['shipping_cost'] ?? 0).toDouble();
  }
}
