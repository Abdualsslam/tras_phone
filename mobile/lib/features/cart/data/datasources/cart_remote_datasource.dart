/// Cart Remote DataSource - Real API implementation
library;

import 'dart:developer' as developer;

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/cart_entity.dart';
import '../../domain/entities/cart_sync_result_entity.dart';
import '../../domain/entities/checkout_session_entity.dart';
import '../models/cart_model.dart';
import '../models/checkout_session_model.dart';

part 'cart_remote_datasource_support.dart';
part 'cart_remote_datasource_cart.dart';
part 'cart_remote_datasource_checkout.dart';

abstract class CartRemoteDataSource {
  Future<CartEntity> getCart();

  Future<CartEntity> addToCart({
    required String productId,
    required int quantity,
    double? unitPrice,
  });

  Future<CartEntity> updateQuantity({
    required String productId,
    required int quantity,
  });

  Future<CartEntity> removeFromCart({required String productId});

  Future<CartEntity> clearCart();

  Future<CartEntity> applyCoupon({required String couponCode});

  Future<CartEntity> removeCoupon();

  Future<int> getCartCount();

  Future<CartEntity> syncCart({required List<Map<String, dynamic>> items});

  Future<CartSyncResultEntity> syncCartWithResults({
    required List<Map<String, dynamic>> items,
  });

  Future<CheckoutSessionEntity> getCheckoutSession({
    String? platform,
    String? couponCode,
  });
}

class CartRemoteDataSourceImpl implements CartRemoteDataSource {
  final ApiClient _apiClient;
  late final _CartRemoteSupport _support = _CartRemoteSupport(
    apiClient: _apiClient,
  );
  late final _CartRemoteCartDelegate _cart = _CartRemoteCartDelegate(
    support: _support,
  );
  late final _CartRemoteCheckoutDelegate _checkout =
      _CartRemoteCheckoutDelegate(support: _support);

  CartRemoteDataSourceImpl({required ApiClient apiClient})
    : _apiClient = apiClient;

  @override
  Future<CartEntity> getCart() => _cart.getCart();

  @override
  Future<CartEntity> addToCart({
    required String productId,
    required int quantity,
    double? unitPrice,
  }) => _cart.addToCart(
    productId: productId,
    quantity: quantity,
    unitPrice: unitPrice,
  );

  @override
  Future<CartEntity> updateQuantity({
    required String productId,
    required int quantity,
  }) => _cart.updateQuantity(productId: productId, quantity: quantity);

  @override
  Future<CartEntity> removeFromCart({required String productId}) =>
      _cart.removeFromCart(productId: productId);

  @override
  Future<CartEntity> clearCart() => _cart.clearCart();

  @override
  Future<CartEntity> applyCoupon({required String couponCode}) =>
      _cart.applyCoupon(couponCode: couponCode);

  @override
  Future<CartEntity> removeCoupon() => _cart.removeCoupon();

  @override
  Future<int> getCartCount() => _cart.getCartCount();

  @override
  Future<CartEntity> syncCart({required List<Map<String, dynamic>> items}) =>
      _cart.syncCart(items: items);

  @override
  Future<CartSyncResultEntity> syncCartWithResults({
    required List<Map<String, dynamic>> items,
  }) => _cart.syncCartWithResults(items: items);

  @override
  Future<CheckoutSessionEntity> getCheckoutSession({
    String? platform,
    String? couponCode,
  }) =>
      _checkout.getCheckoutSession(platform: platform, couponCode: couponCode);
}
