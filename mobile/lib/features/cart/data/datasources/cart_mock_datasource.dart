/// Cart Mock DataSource - Provides mock data for cart operations
library;

import '../../../catalog/domain/entities/product_entity.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../../domain/entities/cart_entity.dart';

class CartMockDataSource {
  // Simulated delay for network calls
  static const _delay = Duration(milliseconds: 500);

  // Mock cart storage
  final List<CartItemEntity> _cartItems = [];
  int _nextItemId = 1;
  String? _appliedCoupon;
  double _discount = 0;

  /// Get current cart
  Future<CartEntity> getCart() async {
    await Future.delayed(_delay);
    return _buildCart();
  }

  /// Add item to cart
  Future<CartEntity> addToCart({
    required ProductEntity product,
    int quantity = 1,
  }) async {
    await Future.delayed(_delay);

    // Check if product already in cart
    final existingIndex = _cartItems.indexWhere(
      (item) => item.product.id == product.id,
    );

    if (existingIndex >= 0) {
      // Update quantity
      final existing = _cartItems[existingIndex];
      _cartItems[existingIndex] = existing.copyWith(
        quantity: existing.quantity + quantity,
      );
    } else {
      // Add new item
      _cartItems.add(
        CartItemEntity(
          id: _nextItemId++,
          product: product,
          quantity: quantity,
          unitPrice: product.price,
          addedAt: DateTime.now(),
        ),
      );
    }

    return _buildCart();
  }

  /// Update item quantity
  Future<CartEntity> updateQuantity({
    required int itemId,
    required int quantity,
  }) async {
    await Future.delayed(_delay);

    if (quantity <= 0) {
      return removeFromCart(itemId: itemId);
    }

    final index = _cartItems.indexWhere((item) => item.id == itemId);
    if (index >= 0) {
      _cartItems[index] = _cartItems[index].copyWith(quantity: quantity);
    }

    return _buildCart();
  }

  /// Remove item from cart
  Future<CartEntity> removeFromCart({required int itemId}) async {
    await Future.delayed(_delay);
    _cartItems.removeWhere((item) => item.id == itemId);
    return _buildCart();
  }

  /// Clear entire cart
  Future<CartEntity> clearCart() async {
    await Future.delayed(_delay);
    _cartItems.clear();
    _appliedCoupon = null;
    _discount = 0;
    return _buildCart();
  }

  /// Apply coupon code
  Future<CartEntity> applyCoupon({required String code}) async {
    await Future.delayed(_delay);

    // Mock coupon validation
    final validCoupons = {
      'TRAS10': 0.10, // 10% off
      'TRAS20': 0.20, // 20% off
      'WELCOME': 0.15, // 15% off
    };

    if (!validCoupons.containsKey(code.toUpperCase())) {
      throw Exception('رمز الخصم غير صالح');
    }

    _appliedCoupon = code.toUpperCase();
    final subtotal = _calculateSubtotal();
    _discount = subtotal * validCoupons[_appliedCoupon]!;

    return _buildCart();
  }

  /// Remove coupon
  Future<CartEntity> removeCoupon() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _appliedCoupon = null;
    _discount = 0;
    return _buildCart();
  }

  // Helper methods
  CartEntity _buildCart() {
    return CartEntity(
      items: List.from(_cartItems),
      subtotal: _calculateSubtotal(),
      shippingCost: _cartItems.isEmpty
          ? 0
          : 50, // Free shipping over certain amount
      discount: _discount,
      couponCode: _appliedCoupon,
      updatedAt: DateTime.now(),
    );
  }

  double _calculateSubtotal() {
    return _cartItems.fold(0, (sum, item) => sum + item.totalPrice);
  }
}
