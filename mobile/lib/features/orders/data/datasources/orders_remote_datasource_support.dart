part of 'orders_remote_datasource.dart';

class _OrdersRemoteSupport {
  final ApiClient apiClient;

  const _OrdersRemoteSupport({required this.apiClient});

  void log(String message) {
    developer.log(message, name: 'OrdersDataSource');
  }

  dynamic extractPayload(dynamic responseBody) {
    if (responseBody is Map<String, dynamic>) {
      return responseBody['data'] ?? responseBody;
    }
    return responseBody;
  }

  Map<String, dynamic> extractMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return <String, dynamic>{};
  }

  List<dynamic> extractList(dynamic value) {
    return value is List ? value : const [];
  }

  OrdersResponseData buildOrdersResponse(dynamic responseBody) {
    final payload = extractPayload(responseBody);
    final list = extractList(payload);
    final metaSource = extractMap(responseBody);
    final total = metaSource['meta']?['total'] ?? list.length;

    return OrdersResponseData(
      orders: list.map(parseOrderEntity).toList(),
      total: total is int ? total : (total as num?)?.toInt() ?? list.length,
    );
  }

  OrderEntity parseOrderEntity(dynamic value) {
    final orderData = normalizeOrderPayload(value);
    return OrderModel.fromJson(orderData).toEntity();
  }

  List<OrderEntity> parseOrderEntities(dynamic value) {
    return extractList(value).map(parseOrderEntity).toList();
  }

  List<BankAccountEntity> parseBankAccounts(dynamic value) {
    return extractList(value)
        .map((item) => BankAccountModel.fromJson(extractMap(item)).toEntity())
        .toList();
  }

  Map<String, dynamic> normalizeOrderPayload(dynamic value) {
    final payload = extractMap(value);
    if (payload['order'] is Map) {
      return extractMap(payload['order']);
    }
    return payload;
  }

  Map<String, dynamic> normalizeOrderDetailsPayload(dynamic value) {
    final payload = extractMap(value);
    if (payload['order'] is Map && payload['items'] is List) {
      final orderData = extractMap(payload['order']);
      orderData['items'] = extractList(
        payload['items'],
      ).map((item) => mapApiItemToOrderItemModel(extractMap(item))).toList();
      return orderData;
    }
    return payload;
  }

  Map<String, dynamic> mapApiItemToOrderItemModel(
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

    return {
      if (orderItemIdStr != null && orderItemIdStr.isNotEmpty)
        '_id': orderItemIdStr,
      'productId': productIdStr ?? '',
      'sku': apiItem['productSku'] ?? apiItem['sku'] ?? '',
      'name': apiItem['productName'] ?? apiItem['name'] ?? '',
      'nameAr': apiItem['productNameAr'] ?? apiItem['nameAr'],
      'image': apiItem['productImage'] ?? apiItem['image'],
      'quantity': quantity,
      'returnedQuantity': returnedQuantity,
      'returnableQuantity': returnableQuantity,
      'reservedQuantity': reservedQuantity,
      'isEffectivelyFullyReturned':
          apiItem['isEffectivelyFullyReturned'] as bool? ?? false,
      'unitPrice': (apiItem['unitPrice'] as num?)?.toDouble() ?? 0.0,
      'discount': (apiItem['discount'] as num?)?.toDouble() ?? 0.0,
      'total':
          ((apiItem['totalPrice'] ?? apiItem['total']) as num?)?.toDouble() ??
          0.0,
    };
  }
}
