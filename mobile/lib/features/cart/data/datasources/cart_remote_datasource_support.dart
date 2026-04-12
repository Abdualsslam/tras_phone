part of 'cart_remote_datasource.dart';

class _CartRemoteSupport {
  final ApiClient apiClient;

  const _CartRemoteSupport({required this.apiClient});

  void log(String message, {String name = 'CartDataSource'}) {
    developer.log(message, name: name);
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

  CartEntity parseCart(dynamic value) {
    return CartModel.fromJson(extractMap(value)).toEntity();
  }

  CartSyncResultEntity buildSyncResult(dynamic value) {
    final payload = extractMap(value);
    if (payload['cart'] != null) {
      return CartSyncResultEntity.fromJson(payload);
    }

    return CartSyncResultEntity(
      syncedCart: parseCart(payload),
      removedItems: const [],
      priceChangedItems: const [],
      quantityAdjustedItems: const [],
    );
  }

  String buildCheckoutSessionPath({String? platform, String? couponCode}) {
    final queryParams = <String, String>{};
    if (platform != null) queryParams['platform'] = platform;
    if (couponCode != null) queryParams['couponCode'] = couponCode;

    if (queryParams.isEmpty) return ApiEndpoints.checkoutSession;

    final queryString = queryParams.entries
        .map((entry) => '${entry.key}=${entry.value}')
        .join('&');
    return '${ApiEndpoints.checkoutSession}?$queryString';
  }
}
