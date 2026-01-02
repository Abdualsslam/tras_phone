/// Cart Remote DataSource - Real API implementation
library;

import 'dart:developer' as developer;
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../domain/entities/cart_entity.dart';
import '../models/cart_model.dart';

/// Abstract interface for cart data source
abstract class CartRemoteDataSource {
  /// Get current cart
  Future<CartEntity> getCart();

  /// Add item to cart
  Future<CartEntity> addToCart({required int productId, int quantity = 1});

  /// Update item quantity
  Future<CartEntity> updateQuantity({
    required int itemId,
    required int quantity,
  });

  /// Remove item from cart
  Future<CartEntity> removeFromCart({required int itemId});

  /// Clear entire cart
  Future<CartEntity> clearCart();

  /// Apply coupon code
  Future<CartEntity> applyCoupon({required String code});

  /// Remove coupon
  Future<CartEntity> removeCoupon();

  /// Get cart count
  Future<int> getCartCount();

  /// Sync local cart with server (for after login)
  Future<CartEntity> syncCart({required List<Map<String, dynamic>> items});
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
    required int productId,
    int quantity = 1,
  }) async {
    developer.log(
      'Adding to cart: product=$productId, qty=$quantity',
      name: 'CartDataSource',
    );

    final response = await _apiClient.post(
      ApiEndpoints.cartAdd,
      data: {'product_id': productId, 'quantity': quantity},
    );

    final data = response.data['data'] ?? response.data;
    return CartModel.fromJson(data).toEntity();
  }

  @override
  Future<CartEntity> updateQuantity({
    required int itemId,
    required int quantity,
  }) async {
    developer.log(
      'Updating cart item: id=$itemId, qty=$quantity',
      name: 'CartDataSource',
    );

    final response = await _apiClient.put(
      '${ApiEndpoints.cartUpdate}/$itemId',
      data: {'quantity': quantity},
    );

    final data = response.data['data'] ?? response.data;
    return CartModel.fromJson(data).toEntity();
  }

  @override
  Future<CartEntity> removeFromCart({required int itemId}) async {
    developer.log('Removing from cart: id=$itemId', name: 'CartDataSource');

    final response = await _apiClient.delete(
      '${ApiEndpoints.cartRemove}/$itemId',
    );

    final data = response.data['data'] ?? response.data;
    return CartModel.fromJson(data).toEntity();
  }

  @override
  Future<CartEntity> clearCart() async {
    developer.log('Clearing cart', name: 'CartDataSource');

    final response = await _apiClient.delete(ApiEndpoints.cartClear);
    final data = response.data['data'] ?? response.data;

    return CartModel.fromJson(data).toEntity();
  }

  @override
  Future<CartEntity> applyCoupon({required String code}) async {
    developer.log('Applying coupon: $code', name: 'CartDataSource');

    final response = await _apiClient.post(
      ApiEndpoints.cartApplyCoupon,
      data: {'code': code},
    );

    final data = response.data['data'] ?? response.data;
    return CartModel.fromJson(data).toEntity();
  }

  @override
  Future<CartEntity> removeCoupon() async {
    developer.log('Removing coupon', name: 'CartDataSource');

    final response = await _apiClient.delete(ApiEndpoints.cartRemoveCoupon);
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
    return CartModel.fromJson(data).toEntity();
  }
}
