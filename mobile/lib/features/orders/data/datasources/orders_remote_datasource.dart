/// Orders Remote DataSource - Real API implementation
library;

import 'dart:developer' as developer;
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/entities/order_stats_entity.dart';
import '../../domain/entities/bank_account_entity.dart';
import '../models/order_model.dart';
import '../models/order_stats_model.dart';
import '../models/bank_account_model.dart';
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
    PaymentStatus? paymentStatus,
    String? orderNumber,
    String? sortBy,
    String? sortOrder,
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

  /// Cancel order (reason is required by API)
  Future<OrderEntity> cancelOrder(String orderId, {required String reason});

  /// Reorder (create new order from existing)
  Future<OrderEntity> reorder(String orderId);

  /// Track order
  Future<Map<String, dynamic>> trackOrder(String orderId);

  /// Get order invoice
  Future<String> getOrderInvoice(String orderId);

  /// Rate order / product
  Future<OrderEntity> rateOrder({
    required String orderId,
    required int rating,
    String? comment,
  });

  /// Get my order statistics
  Future<OrderStatsEntity> getMyOrderStats();

  /// Get pending payment orders
  Future<List<OrderEntity>> getPendingPaymentOrders();

  /// Get bank accounts (public endpoint)
  Future<List<BankAccountEntity>> getBankAccounts();

  /// Upload receipt for order
  Future<OrderEntity> uploadReceipt({
    required String orderId,
    required String receiptImage,
    String? transferReference,
    String? transferDate,
    String? notes,
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
    PaymentStatus? paymentStatus,
    String? orderNumber,
    String? sortBy,
    String? sortOrder,
    int page = 1,
    int limit = 20,
  }) async {
    developer.log('Fetching my orders (page: $page)', name: 'OrdersDataSource');

    final response = await _apiClient.get(
      ApiEndpoints.ordersMy,
      queryParameters: {
        'page': page,
        'limit': limit,
        if (status != null) 'status': status.value,
        if (paymentStatus != null) 'paymentStatus': paymentStatus.name,
        if (orderNumber != null) 'orderNumber': orderNumber,
        if (sortBy != null) 'sortBy': sortBy,
        if (sortOrder != null) 'sortOrder': sortOrder,
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

  /// Map API order item format (productSku, productName, etc.) to OrderItemModel format
  static Map<String, dynamic> _mapApiItemToOrderItemModel(
    Map<String, dynamic> apiItem,
  ) {
    final productId = apiItem['productId'];
    final productIdStr = productId is Map
        ? (productId['_id'] ?? productId['\$oid'])?.toString()
        : productId?.toString();
    final orderItemId = apiItem['_id'] ?? apiItem['id'];
    final orderItemIdStr = orderItemId is Map
        ? (orderItemId['\$oid'] ?? orderItemId['_id'])?.toString()
        : orderItemId?.toString();
    final quantity = (apiItem['quantity'] as num?)?.toInt() ?? 0;
    final returnedQuantity =
        (apiItem['returnedQuantity'] as num?)?.toInt() ?? 0;
    final returnableQuantity =
        (apiItem['returnableQuantity'] as num?)?.toInt() ??
        (quantity - returnedQuantity).clamp(0, quantity);
    final reservedQuantity =
        (apiItem['reservedQuantity'] as num?)?.toInt() ?? 0;
    final isEffectivelyFullyReturned =
        apiItem['isEffectivelyFullyReturned'] as bool? ?? false;
    return {
      if (orderItemIdStr != null && orderItemIdStr.isNotEmpty) '_id': orderItemIdStr,
      'productId': productIdStr ?? '',
      'sku': apiItem['productSku'] ?? apiItem['sku'] ?? '',
      'name': apiItem['productName'] ?? apiItem['name'] ?? '',
      'nameAr': apiItem['productNameAr'] ?? apiItem['nameAr'],
      'image': apiItem['productImage'] ?? apiItem['image'],
      'quantity': quantity,
      'returnedQuantity': returnedQuantity,
      'returnableQuantity': returnableQuantity,
      'reservedQuantity': reservedQuantity,
      'isEffectivelyFullyReturned': isEffectivelyFullyReturned,
      'unitPrice': (apiItem['unitPrice'] as num?)?.toDouble() ?? 0.0,
      'discount': (apiItem['discount'] as num?)?.toDouble() ?? 0.0,
      'total':
          ((apiItem['totalPrice'] ?? apiItem['total']) as num?)?.toDouble() ??
          0.0,
    };
  }

  @override
  Future<OrderEntity> getOrderById(String orderId) async {
    developer.log('Fetching order: $orderId', name: 'OrdersDataSource');

    final response = await _apiClient.get('${ApiEndpoints.orders}/$orderId');
    final responseData = response.data['data'] ?? response.data;
    final responseMap = responseData as Map<String, dynamic>;

    // New format: merged object with items (responseData is the order)
    // Old format: { order, items, history } - merge items into order
    Map<String, dynamic> orderData;
    if (responseMap['order'] != null && responseMap['items'] != null) {
      // Old format - merge items with field mapping
      orderData = Map<String, dynamic>.from(responseMap['order'] as Map);
      final rawItems = responseMap['items'] as List<dynamic>? ?? [];
      orderData['items'] = rawItems
          .map((e) => _mapApiItemToOrderItemModel(e as Map<String, dynamic>))
          .toList();
    } else {
      // New format - use directly (items already in client format from backend)
      orderData = responseMap;
    }

    return OrderModel.fromJson(orderData).toEntity();
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
        if (shippingAddress != null)
          'shippingAddress': shippingAddress.toJson(),
        if (paymentMethod != null) 'paymentMethod': paymentMethod.value,
        if (customerNotes != null) 'customerNotes': customerNotes,
        if (couponCode != null) 'couponCode': couponCode,
      },
    );

    final data = response.data['data'] ?? response.data;
    return OrderModel.fromJson(data).toEntity();
  }

  @override
  Future<OrderEntity> cancelOrder(
    String orderId, {
    required String reason,
  }) async {
    developer.log('Cancelling order: $orderId', name: 'OrdersDataSource');

    final response = await _apiClient.post(
      '${ApiEndpoints.orders}/$orderId/cancel',
      data: {'reason': reason},
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
  Future<OrderEntity> rateOrder({
    required String orderId,
    required int rating,
    String? comment,
  }) async {
    developer.log('Rating order: $orderId', name: 'OrdersDataSource');

    final response = await _apiClient.post(
      '${ApiEndpoints.orders}/$orderId/rate',
      data: {'rating': rating, if (comment != null) 'comment': comment},
    );

    final responseData = response.data['data'] ?? response.data;
    final orderData = responseData['order'] ?? responseData;

    return OrderModel.fromJson(orderData as Map<String, dynamic>).toEntity();
  }

  @override
  Future<List<Map<String, dynamic>>> getPaymentMethods() async {
    developer.log('Fetching payment methods', name: 'OrdersDataSource');

    final response = await _apiClient.get(ApiEndpoints.paymentMethods);
    dynamic data = response.data['data'] ?? response.data;
    // Handle double-nested { data: { data: [...] } } from some backends
    if (data is! List && data is Map && data['data'] is List) {
      data = data['data'];
    }

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

  @override
  Future<OrderStatsEntity> getMyOrderStats() async {
    developer.log('Fetching order stats', name: 'OrdersDataSource');

    final response = await _apiClient.get('${ApiEndpoints.ordersMy}/stats');
    final data = response.data['data'] ?? response.data;

    return OrderStatsModel.fromJson(data as Map<String, dynamic>).toEntity();
  }

  @override
  Future<List<OrderEntity>> getPendingPaymentOrders() async {
    developer.log('Fetching pending payment orders', name: 'OrdersDataSource');

    final response = await _apiClient.get(ApiEndpoints.ordersPendingPayment);
    final data = response.data['data'] ?? response.data;
    final List<dynamic> list = data is List ? data : [];

    return list
        .map(
          (json) =>
              OrderModel.fromJson(json as Map<String, dynamic>).toEntity(),
        )
        .toList();
  }

  @override
  Future<List<BankAccountEntity>> getBankAccounts() async {
    developer.log('Fetching bank accounts', name: 'OrdersDataSource');

    final response = await _apiClient.get(ApiEndpoints.bankAccounts);
    final data = response.data['data'] ?? response.data;
    final List<dynamic> list = data is List ? data : [];

    return list
        .map(
          (json) => BankAccountModel.fromJson(
            json as Map<String, dynamic>,
          ).toEntity(),
        )
        .toList();
  }

  @override
  Future<OrderEntity> uploadReceipt({
    required String orderId,
    required String receiptImage,
    String? transferReference,
    String? transferDate,
    String? notes,
  }) async {
    developer.log(
      'Uploading receipt for order: $orderId',
      name: 'OrdersDataSource',
    );

    final response = await _apiClient.post(
      '${ApiEndpoints.orders}/$orderId/upload-receipt',
      data: {
        'receiptImage': receiptImage,
        if (transferReference != null) 'transferReference': transferReference,
        if (transferDate != null) 'transferDate': transferDate,
        if (notes != null) 'notes': notes,
      },
    );

    final responseData = response.data['data'] ?? response.data;
    final orderData = responseData['order'] ?? responseData;

    return OrderModel.fromJson(orderData as Map<String, dynamic>).toEntity();
  }
}
