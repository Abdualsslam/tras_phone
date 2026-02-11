/// Cart Remote DataSource - Real API implementation
library;

import 'dart:developer' as developer;
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../domain/entities/cart_entity.dart';
import '../../domain/entities/cart_sync_result_entity.dart';
import '../../domain/entities/checkout_session_entity.dart';
import '../models/cart_model.dart';
import '../models/checkout_session_model.dart';

/// Abstract interface for cart data source
abstract class CartRemoteDataSource {
  /// Get current cart
  Future<CartEntity> getCart();

  /// Add item to cart
  /// [unitPrice] is optional - server calculates price from customer's price level
  Future<CartEntity> addToCart({
    required String productId,
    required int quantity,
    double? unitPrice,
  });

  /// Update item quantity
  Future<CartEntity> updateQuantity({
    required String productId,
    required int quantity,
  });

  /// Remove item from cart
  Future<CartEntity> removeFromCart({required String productId});

  /// Clear entire cart
  Future<CartEntity> clearCart();

  /// Apply coupon code
  Future<CartEntity> applyCoupon({
    String? couponId,
    String? couponCode,
    double? discountAmount,
  });

  /// Remove coupon
  Future<CartEntity> removeCoupon();

  /// Get cart count
  Future<int> getCartCount();

  /// Sync local cart with server (for after login)
  Future<CartEntity> syncCart({required List<Map<String, dynamic>> items});

  /// Sync local cart with server and get sync results
  Future<CartSyncResultEntity> syncCartWithResults({
    required List<Map<String, dynamic>> items,
  });

  /// Get checkout session with cart, addresses, payment methods, and coupon validation
  Future<CheckoutSessionEntity> getCheckoutSession({
    String? platform,
    String? couponCode,
  });
}

/// Implementation of CartRemoteDataSource using API client
class CartRemoteDataSourceImpl implements CartRemoteDataSource {
  final ApiClient _apiClient;

  CartRemoteDataSourceImpl({required ApiClient apiClient})
    : _apiClient = apiClient;

  @override
  Future<CartEntity> getCart() async {
    developer.log('Fetching cart', name: 'CartDataSource');

    final response = await _apiClient.get(ApiEndpoints.cart);
    final data = response.data['data'] ?? response.data;

    return CartModel.fromJson(data).toEntity();
  }

  @override
  Future<CartEntity> addToCart({
    required String productId,
    required int quantity,
    double? unitPrice,
  }) async {
    developer.log(
      'Adding to cart: product=$productId, qty=$quantity, price=$unitPrice',
      name: 'CartDataSource',
    );

    final response = await _apiClient.post(
      ApiEndpoints.cartItems,
      data: {
        'productId': productId,
        'quantity': quantity,
        if (unitPrice != null) 'unitPrice': unitPrice,
      },
    );

    final data = response.data['data'] ?? response.data;
    return CartModel.fromJson(data).toEntity();
  }

  @override
  Future<CartEntity> updateQuantity({
    required String productId,
    required int quantity,
  }) async {
    developer.log(
      'Updating cart item: productId=$productId, qty=$quantity',
      name: 'CartDataSource',
    );

    final response = await _apiClient.put(
      '${ApiEndpoints.cartItems}/$productId',
      data: {'quantity': quantity},
    );

    final data = response.data['data'] ?? response.data;
    return CartModel.fromJson(data).toEntity();
  }

  @override
  Future<CartEntity> removeFromCart({required String productId}) async {
    developer.log(
      'Removing from cart: productId=$productId',
      name: 'CartDataSource',
    );

    final response = await _apiClient.delete(
      '${ApiEndpoints.cartItems}/$productId',
    );

    final data = response.data['data'] ?? response.data;
    return CartModel.fromJson(data).toEntity();
  }

  @override
  Future<CartEntity> clearCart() async {
    developer.log('Clearing cart', name: 'CartDataSource');

    final response = await _apiClient.delete(ApiEndpoints.cart);
    final data = response.data['data'] ?? response.data;

    return CartModel.fromJson(data).toEntity();
  }

  @override
  Future<CartEntity> applyCoupon({
    String? couponId,
    String? couponCode,
    double? discountAmount,
  }) async {
    developer.log(
      'Applying coupon: code=$couponCode, id=$couponId, discount=$discountAmount',
      name: 'CartDataSource',
    );

    final response = await _apiClient.post(
      ApiEndpoints.cartCoupon,
      data: {
        if (couponId != null) 'couponId': couponId,
        if (couponCode != null) 'couponCode': couponCode,
        if (discountAmount != null) 'discountAmount': discountAmount,
      },
    );

    final data = response.data['data'] ?? response.data;
    return CartModel.fromJson(data).toEntity();
  }

  @override
  Future<CartEntity> removeCoupon() async {
    developer.log('Removing coupon', name: 'CartDataSource');

    final response = await _apiClient.delete(ApiEndpoints.cartCoupon);
    final data = response.data['data'] ?? response.data;

    return CartModel.fromJson(data).toEntity();
  }

  @override
  Future<int> getCartCount() async {
    developer.log('Getting cart count', name: 'CartDataSource');

    final response = await _apiClient.get(ApiEndpoints.cartCount);
    final data = response.data['data'] ?? response.data;

    return data['count'] ?? 0;
  }

  @override
  Future<CartEntity> syncCart({
    required List<Map<String, dynamic>> items,
  }) async {
    developer.log(
      'Syncing cart with ${items.length} items',
      name: 'CartDataSource',
    );

    final response = await _apiClient.post(
      ApiEndpoints.cartSync,
      data: {'items': items},
    );

    final data = response.data['data'] ?? response.data;

    // Handle both old format (cart only) and new format (with sync results)
    if (data['cart'] != null) {
      return CartModel.fromJson(
        data['cart'] as Map<String, dynamic>,
      ).toEntity();
    }

    return CartModel.fromJson(data).toEntity();
  }

  @override
  Future<CartSyncResultEntity> syncCartWithResults({
    required List<Map<String, dynamic>> items,
  }) async {
    developer.log(
      'Syncing cart with results: ${items.length} items',
      name: 'CartDataSource',
    );

    final response = await _apiClient.post(
      ApiEndpoints.cartSync,
      data: {'items': items},
    );

    final responseData = response.data['data'] ?? response.data;

    // Check if response has sync results format
    if (responseData['cart'] != null) {
      return CartSyncResultEntity.fromJson(responseData);
    }

    // Fallback to old format (cart only)
    final cart = CartModel.fromJson(responseData).toEntity();
    return CartSyncResultEntity(
      syncedCart: cart,
      removedItems: [],
      priceChangedItems: [],
      quantityAdjustedItems: [],
    );
  }

  @override
  Future<CheckoutSessionEntity> getCheckoutSession({
    String? platform,
    String? couponCode,
  }) async {
    developer.log(
      'Getting checkout session: platform=$platform, couponCode=$couponCode',
      name: 'CartDataSource',
    );

    // Build query parameters
    final queryParams = <String, String>{};
    if (platform != null) queryParams['platform'] = platform;
    if (couponCode != null) queryParams['couponCode'] = couponCode;

    final queryString = queryParams.isNotEmpty
        ? '?${queryParams.entries.map((e) => '${e.key}=${e.value}').join('&')}'
        : '';

    final path = '${ApiEndpoints.checkoutSession}$queryString';
    print('[API] → GET $path');

    final response = await _apiClient.get(path);

    print('[API] ← ${response.statusCode} $path');

    final data = response.data['data'] ?? response.data;

    return CheckoutSessionModel.fromJson(data).toEntity();
  }
}
