part of 'orders_remote_datasource.dart';

class _OrdersRemoteOrdersDelegate {
  final _OrdersRemoteSupport _support;

  const _OrdersRemoteOrdersDelegate({required _OrdersRemoteSupport support})
    : _support = support;

  Future<OrdersResponseData> getMyOrders({
    OrderStatus? status,
    PaymentStatus? paymentStatus,
    String? orderNumber,
    String? sortBy,
    String? sortOrder,
    int page = 1,
    int limit = 20,
  }) async {
    _support.log('Fetching my orders (page: $page)');

    final response = await _support.apiClient.get(
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

    return _support.buildOrdersResponse(response.data);
  }

  Future<OrderEntity> getOrderById(String orderId) async {
    _support.log('Fetching order: $orderId');

    final response = await _support.apiClient.get(
      '${ApiEndpoints.orders}/$orderId',
    );
    final orderData = _support.normalizeOrderDetailsPayload(
      _support.extractPayload(response.data),
    );

    return OrderModel.fromJson(orderData).toEntity();
  }

  Future<OrderEntity> cancelOrder(
    String orderId, {
    required String reason,
  }) async {
    _support.log('Cancelling order: $orderId');

    final response = await _support.apiClient.post(
      '${ApiEndpoints.orders}/$orderId/cancel',
      data: {'reason': reason},
    );

    return _support.parseOrderEntity(_support.extractPayload(response.data));
  }

  Future<OrderEntity> reorder(String orderId) async {
    _support.log('Reordering from: $orderId');

    final response = await _support.apiClient.post(
      '${ApiEndpoints.orders}/$orderId/reorder',
    );

    return _support.parseOrderEntity(_support.extractPayload(response.data));
  }

  Future<Map<String, dynamic>> trackOrder(String orderId) async {
    _support.log('Tracking order: $orderId');

    final response = await _support.apiClient.get(
      '${ApiEndpoints.orders}/$orderId/track',
    );

    return _support.extractMap(_support.extractPayload(response.data));
  }

  Future<String> getOrderInvoice(String orderId) async {
    _support.log('Getting invoice for order: $orderId');

    final response = await _support.apiClient.get(
      '${ApiEndpoints.orders}/$orderId/invoice',
    );
    final payload = _support.extractMap(_support.extractPayload(response.data));
    return payload['url']?.toString() ?? '';
  }

  Future<OrderEntity> rateOrder({
    required String orderId,
    required int rating,
    String? comment,
  }) async {
    _support.log('Rating order: $orderId');

    final response = await _support.apiClient.post(
      '${ApiEndpoints.orders}/$orderId/rate',
      data: {'rating': rating, if (comment != null) 'comment': comment},
    );

    return _support.parseOrderEntity(_support.extractPayload(response.data));
  }

  Future<OrderStatsEntity> getMyOrderStats() async {
    _support.log('Fetching order stats');

    final response = await _support.apiClient.get(
      '${ApiEndpoints.ordersMy}/stats',
    );
    final payload = _support.extractMap(_support.extractPayload(response.data));
    return OrderStatsModel.fromJson(payload).toEntity();
  }

  Future<List<OrderEntity>> getPendingPaymentOrders() async {
    _support.log('Fetching pending payment orders');

    final response = await _support.apiClient.get(
      ApiEndpoints.ordersPendingPayment,
    );
    return _support.parseOrderEntities(_support.extractPayload(response.data));
  }

  Future<List<BankAccountEntity>> getBankAccounts() async {
    _support.log('Fetching bank accounts');

    final response = await _support.apiClient.get(ApiEndpoints.bankAccounts);
    return _support.parseBankAccounts(_support.extractPayload(response.data));
  }
}
