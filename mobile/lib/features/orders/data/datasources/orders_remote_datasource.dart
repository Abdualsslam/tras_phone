/// Orders Remote DataSource - Real API implementation
library;

import 'dart:developer' as developer;
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/enums/order_enums.dart';
import '../models/order_model.dart';
import '../models/shipping_address_model.dart';

/// Response for paginated orders
class OrdersResponseData {
  final List<OrderEntity> orders;
  final int total;

  OrdersResponseData({required this.orders, required this.total});
}

/// Abstract interface for orders data source
abstract class OrdersRemoteDataSource {
  /// Get my orders with optional filtering and pagination
  Future<OrdersResponseData> getMyOrders({
    OrderStatus? status,
    int page = 1,
    int limit = 20,
  });

  /// Get order by ID
  Future<OrderEntity> getOrderById(String orderId);

  /// Create new order (checkout)
  Future<OrderEntity> createOrder({
    String? shippingAddressId,
    ShippingAddressModel? shippingAddress,
    OrderPaymentMethod? paymentMethod,
    String? customerNotes,
    String? couponCode,
  });

  /// Cancel order
  Future<OrderEntity> cancelOrder(String orderId, {String? reason});

  /// Reorder (create new order from existing)
  Future<OrderEntity> reorder(String orderId);

  /// Track order
  Future<Map<String, dynamic>> trackOrder(String orderId);

  /// Get order invoice
  Future<String> getOrderInvoice(String orderId);

  /// Rate order / product
  Future<bool> rateOrder({
    required String orderId,
    required int rating,
    String? comment,
  });

  /// Get available payment methods
  Future<List<Map<String, dynamic>>> getPaymentMethods();

  /// Get shipping addresses
  Future<List<Map<String, dynamic>>> getShippingAddresses();

  /// Calculate shipping cost
  Future<double> calculateShipping({
    required String addressId,
    required List<String> productIds,
  });
}

/// Implementation of OrdersRemoteDataSource using API client
class OrdersRemoteDataSourceImpl implements OrdersRemoteDataSource {
  final ApiClient _apiClient;

  OrdersRemoteDataSourceImpl({required ApiClient apiClient})
    : _apiClient = apiClient;

  @override
  Future<OrdersResponseData> getMyOrders({
    OrderStatus? status,
    int page = 1,
    int limit = 20,
  }) async {
    developer.log('Fetching my orders (page: $page)', name: 'OrdersDataSource');

    final response = await _apiClient.get(
      ApiEndpoints.ordersMy,
      queryParameters: {
        'page': page,
        'limit': limit,
        if (status != null) 'status': status.name,
      },
    );

    final data = response.data['data'] ?? response.data;
    final List<dynamic> list = data is List ? data : [];
    final total = response.data['meta']?['total'] ?? list.length;

    return OrdersResponseData(
      orders: list.map((json) => OrderModel.fromJson(json).toEntity()).toList(),
      total: total,
    );
  }

  @override
  Future<OrderEntity> getOrderById(String orderId) async {
    developer.log('Fetching order: $orderId', name: 'OrdersDataSource');

    final response = await _apiClient.get('${ApiEndpoints.orders}/$orderId');
    final data = response.data['data'] ?? response.data;

    return OrderModel.fromJson(data).toEntity();
  }

  @override
  Future<OrderEntity> createOrder({
    String? shippingAddressId,
    ShippingAddressModel? shippingAddress,
    OrderPaymentMethod? paymentMethod,
    String? customerNotes,
    String? couponCode,
  }) async {
    developer.log('Creating order', name: 'OrdersDataSource');

    final response = await _apiClient.post(
      ApiEndpoints.orders,
      data: {
        if (shippingAddressId != null) 'shippingAddressId': shippingAddressId,
        if (shippingAddress != null) 'shippingAddress': shippingAddress.toJson(),
        if (paymentMethod != null) 'paymentMethod': paymentMethod.value,
        if (customerNotes != null) 'customerNotes': customerNotes,
        if (couponCode != null) 'couponCode': couponCode,
      },
    );

    final data = response.data['data'] ?? response.data;
    return OrderModel.fromJson(data).toEntity();
  }

  @override
  Future<OrderEntity> cancelOrder(String orderId, {String? reason}) async {
    developer.log('Cancelling order: $orderId', name: 'OrdersDataSource');

    final response = await _apiClient.post(
      '${ApiEndpoints.orders}/$orderId/cancel',
      data: {if (reason != null) 'reason': reason},
    );

    final data = response.data['data'] ?? response.data;
    return OrderModel.fromJson(data).toEntity();
  }

  @override
  Future<OrderEntity> reorder(String orderId) async {
    developer.log('Reordering from: $orderId', name: 'OrdersDataSource');

    final response = await _apiClient.post(
      '${ApiEndpoints.orders}/$orderId/reorder',
    );

    final data = response.data['data'] ?? response.data;
    return OrderModel.fromJson(data).toEntity();
  }

  @override
  Future<Map<String, dynamic>> trackOrder(String orderId) async {
    developer.log('Tracking order: $orderId', name: 'OrdersDataSource');

    final response = await _apiClient.get(
      '${ApiEndpoints.orders}/$orderId/track',
    );

    return response.data['data'] ?? response.data;
  }

  @override
  Future<String> getOrderInvoice(String orderId) async {
    developer.log(
      'Getting invoice for order: $orderId',
      name: 'OrdersDataSource',
    );

    final response = await _apiClient.get(
      '${ApiEndpoints.orders}/$orderId/invoice',
    );

    return response.data['data']?['url'] ?? '';
  }

  @override
  Future<bool> rateOrder({
    required String orderId,
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
    required String addressId,
    required List<String> productIds,
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
