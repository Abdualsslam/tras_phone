part of 'cart_remote_datasource.dart';

class _CartRemoteCartDelegate {
  final _CartRemoteSupport _support;

  const _CartRemoteCartDelegate({required _CartRemoteSupport support})
    : _support = support;

  Future<CartEntity> getCart() async {
    _support.log('Fetching cart');
    final response = await _support.apiClient.get(ApiEndpoints.cart);
    return _support.parseCart(_support.extractPayload(response.data));
  }

  Future<CartEntity> addToCart({
    required String productId,
    required int quantity,
    double? unitPrice,
  }) async {
    _support.log(
      'Adding to cart: product=$productId, qty=$quantity, price=$unitPrice',
    );

    final response = await _support.apiClient.post(
      ApiEndpoints.cartItems,
      data: {
        'productId': productId,
        'quantity': quantity,
        if (unitPrice != null) 'unitPrice': unitPrice,
      },
    );

    return _support.parseCart(_support.extractPayload(response.data));
  }

  Future<CartEntity> updateQuantity({
    required String productId,
    required int quantity,
  }) async {
    _support.log('Updating cart item: productId=$productId, qty=$quantity');

    final response = await _support.apiClient.put(
      '${ApiEndpoints.cartItems}/$productId',
      data: {'quantity': quantity},
    );

    return _support.parseCart(_support.extractPayload(response.data));
  }

  Future<CartEntity> removeFromCart({required String productId}) async {
    _support.log('Removing from cart: productId=$productId');

    final response = await _support.apiClient.delete(
      '${ApiEndpoints.cartItems}/$productId',
    );

    return _support.parseCart(_support.extractPayload(response.data));
  }

  Future<CartEntity> clearCart() async {
    _support.log('Clearing cart');
    final response = await _support.apiClient.delete(ApiEndpoints.cart);
    return _support.parseCart(_support.extractPayload(response.data));
  }

  Future<CartEntity> applyCoupon({required String couponCode}) async {
    _support.log('Applying coupon: code=$couponCode');

    final response = await _support.apiClient.post(
      ApiEndpoints.cartCoupon,
      data: {'couponCode': couponCode},
    );

    return _support.parseCart(_support.extractPayload(response.data));
  }

  Future<CartEntity> removeCoupon() async {
    _support.log('Removing coupon');
    final response = await _support.apiClient.delete(ApiEndpoints.cartCoupon);
    return _support.parseCart(_support.extractPayload(response.data));
  }

  Future<int> getCartCount() async {
    _support.log('Getting cart count');

    final response = await _support.apiClient.get(ApiEndpoints.cartCount);
    final payload = _support.extractMap(_support.extractPayload(response.data));
    return (payload['count'] as num?)?.toInt() ?? 0;
  }

  Future<CartEntity> syncCart({
    required List<Map<String, dynamic>> items,
  }) async {
    _support.log('Syncing cart with ${items.length} items');

    final response = await _support.apiClient.post(
      ApiEndpoints.cartSync,
      data: {'items': items},
    );

    final payload = _support.extractMap(_support.extractPayload(response.data));
    return _support.parseCart(payload['cart'] ?? payload);
  }

  Future<CartSyncResultEntity> syncCartWithResults({
    required List<Map<String, dynamic>> items,
  }) async {
    _support.log('Syncing cart with results: ${items.length} items');

    final response = await _support.apiClient.post(
      ApiEndpoints.cartSync,
      data: {'items': items},
    );

    return _support.buildSyncResult(_support.extractPayload(response.data));
  }
}
