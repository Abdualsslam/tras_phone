part of 'orders_remote_datasource.dart';

class _OrdersRemoteCheckoutDelegate {
  final _OrdersRemoteSupport _support;

  const _OrdersRemoteCheckoutDelegate({required _OrdersRemoteSupport support})
    : _support = support;

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
  }) async {
    _support.log('Creating order');

    final response = await _support.apiClient.post(
      ApiEndpoints.orders,
      data: {
        if (shippingAddressId != null) 'shippingAddressId': shippingAddressId,
        if (shippingAddress != null)
          'shippingAddress': shippingAddress.toJson(),
        if (paymentMethod != null) 'paymentMethod': paymentMethod.value,
        if (customerNotes != null) 'customerNotes': customerNotes,
        if (couponCode != null) 'couponCode': couponCode,
        if (bankAccountId != null) 'bankAccountId': bankAccountId,
        if (receiptImage != null) 'receiptImage': receiptImage,
        if (transferReference != null) 'transferReference': transferReference,
        if (transferDate != null) 'transferDate': transferDate,
        if (transferNotes != null) 'notes': transferNotes,
      },
    );

    return _support.parseOrderEntity(_support.extractPayload(response.data));
  }

  Future<OrderEntity> uploadReceipt({
    required String orderId,
    required String receiptImage,
    String? transferReference,
    String? transferDate,
    String? notes,
  }) async {
    _support.log('Uploading receipt for order: $orderId');

    final response = await _support.apiClient.post(
      '${ApiEndpoints.orders}/$orderId/upload-receipt',
      data: {
        'receiptImage': receiptImage,
        if (transferReference != null) 'transferReference': transferReference,
        if (transferDate != null) 'transferDate': transferDate,
        if (notes != null) 'notes': notes,
      },
    );

    return _support.parseOrderEntity(_support.extractPayload(response.data));
  }

  Future<List<Map<String, dynamic>>> getPaymentMethods() async {
    _support.log('Fetching payment methods');

    final response = await _support.apiClient.get(ApiEndpoints.paymentMethods);
    var payload = _support.extractPayload(response.data);
    if (payload is! List && payload is Map && payload['data'] is List) {
      payload = payload['data'];
    }

    return _support
        .extractList(payload)
        .map((item) => _support.extractMap(item))
        .toList();
  }

  Future<List<Map<String, dynamic>>> getShippingAddresses() async {
    _support.log('Fetching shipping addresses');

    final response = await _support.apiClient.get(ApiEndpoints.addresses);
    return _support
        .extractList(_support.extractPayload(response.data))
        .map((item) => _support.extractMap(item))
        .toList();
  }

  Future<double> calculateShipping({
    required String addressId,
    required List<String> productIds,
  }) async {
    _support.log('Calculating shipping');

    final response = await _support.apiClient.post(
      ApiEndpoints.calculateShipping,
      data: {'address_id': addressId, 'product_ids': productIds},
    );

    final payload = _support.extractMap(_support.extractPayload(response.data));
    return (payload['shipping_cost'] as num?)?.toDouble() ?? 0.0;
  }
}
