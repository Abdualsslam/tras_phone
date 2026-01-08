/// Cart Mock DataSource - Provides mock data for cart operations
library;

import '../../domain/entities/cart_item_entity.dart';
import '../../domain/entities/cart_entity.dart';
import '../../domain/enums/cart_enums.dart';

class CartMockDataSource {
  // Simulated delay for network calls
  static const _delay = Duration(milliseconds: 500);

  // Mock cart storage
  final List<CartItemEntity> _cartItems = [];
  String? _appliedCoupon;
  double _discount = 0;

  /// Get current cart
  Future<CartEntity> getCart() async {
    await Future.delayed(_delay);
    return _buildCart();
  }

  /// Add item to cart
  Future<CartEntity> addToCart({
    required String productId,
    required String productName,
    String? productNameAr,
    String? productImage,
    required double unitPrice,
    int quantity = 1,
  }) async {
    await Future.delayed(_delay);

    // Check if product already in cart
    final existingIndex = _cartItems.indexWhere(
      (item) => item.productId == productId,
    );

    if (existingIndex >= 0) {
      // Update quantity
      final existing = _cartItems[existingIndex];
      _cartItems[existingIndex] = existing.copyWith(
        quantity: existing.quantity + quantity,
        totalPrice: (existing.quantity + quantity) * existing.unitPrice,
      );
    } else {
      // Add new item
      _cartItems.add(
        CartItemEntity(
          productId: productId,
          quantity: quantity,
          unitPrice: unitPrice,
          totalPrice: unitPrice * quantity,
          addedAt: DateTime.now(),
          productName: productName,
          productNameAr: productNameAr,
          productImage: productImage,
        ),
      );
    }

    return _buildCart();
  }

  /// Update item quantity
  Future<CartEntity> updateQuantity({
    required String productId,
    required int quantity,
  }) async {
    await Future.delayed(_delay);

    if (quantity <= 0) {
      return removeFromCart(productId: productId);
    }

    final index = _cartItems.indexWhere((item) => item.productId == productId);
    if (index >= 0) {
      final item = _cartItems[index];
      _cartItems[index] = item.copyWith(
        quantity: quantity,
        totalPrice: quantity * item.unitPrice,
      );
    }

    return _buildCart();
  }

  /// Remove item from cart
  Future<CartEntity> removeFromCart({required String productId}) async {
    await Future.delayed(_delay);
    _cartItems.removeWhere((item) => item.productId == productId);
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
    final subtotal = _calculateSubtotal();
    final shippingCost = _cartItems.isEmpty ? 0.0 : 50.0;
    return CartEntity(
      id: 'mock_cart_001',
      customerId: 'mock_customer_001',
      status: CartStatus.active,
      items: List.from(_cartItems),
      itemsCount: _cartItems.length,
      subtotal: subtotal,
      discount: _discount,
      taxAmount: subtotal * 0.15, // 15% VAT
      shippingCost: shippingCost,
      total: subtotal + shippingCost - _discount,
      couponCode: _appliedCoupon,
      couponDiscount: _discount,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  double _calculateSubtotal() {
    return _cartItems.fold(0, (sum, item) => sum + item.totalPrice);
  }
}
