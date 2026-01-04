/// Cart Cubit - State management for shopping cart
library;

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/cart_mock_datasource.dart';
import 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  final CartMockDataSource _dataSource;

  CartCubit({CartMockDataSource? dataSource})
    : _dataSource = dataSource ?? CartMockDataSource(),
      super(const CartInitial());

  /// Load cart
  Future<void> loadCart() async {
    emit(const CartLoading());

    try {
      final cart = await _dataSource.getCart();
      emit(CartLoaded(cart));
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  /// Add product to cart
  Future<void> addToCart({
    required String productId,
    required String productName,
    String? productNameAr,
    String? productImage,
    required double unitPrice,
    int quantity = 1,
  }) async {
    final currentCart = state is CartLoaded ? (state as CartLoaded).cart : null;
    if (currentCart != null) {
      emit(CartUpdating(currentCart));
    }

    try {
      final cart = await _dataSource.addToCart(
        productId: productId,
        productName: productName,
        productNameAr: productNameAr,
        productImage: productImage,
        unitPrice: unitPrice,
        quantity: quantity,
      );
      emit(CartLoaded(cart));
    } catch (e) {
      emit(CartError(e.toString(), previousCart: currentCart));
    }
  }

  /// Update item quantity
  Future<void> updateQuantity(String productId, int quantity) async {
    final currentCart = state is CartLoaded ? (state as CartLoaded).cart : null;
    if (currentCart != null) {
      emit(CartUpdating(currentCart));
    }

    try {
      final cart = await _dataSource.updateQuantity(
        productId: productId,
        quantity: quantity,
      );
      emit(CartLoaded(cart));
    } catch (e) {
      emit(CartError(e.toString(), previousCart: currentCart));
    }
  }

  /// Remove item from cart
  Future<void> removeFromCart(String productId) async {
    final currentCart = state is CartLoaded ? (state as CartLoaded).cart : null;
    if (currentCart != null) {
      emit(CartUpdating(currentCart));
    }

    try {
      final cart = await _dataSource.removeFromCart(productId: productId);
      emit(CartLoaded(cart));
    } catch (e) {
      emit(CartError(e.toString(), previousCart: currentCart));
    }
  }

  /// Clear cart
  Future<void> clearCart() async {
    emit(const CartLoading());

    try {
      final cart = await _dataSource.clearCart();
      emit(CartLoaded(cart));
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  /// Apply coupon
  Future<void> applyCoupon(String code) async {
    final currentCart = state is CartLoaded ? (state as CartLoaded).cart : null;
    if (currentCart != null) {
      emit(CartUpdating(currentCart));
    }

    try {
      final cart = await _dataSource.applyCoupon(code: code);
      emit(CartLoaded(cart));
    } catch (e) {
      emit(CartError(e.toString(), previousCart: currentCart));
    }
  }

  /// Remove coupon
  Future<void> removeCoupon() async {
    final currentCart = state is CartLoaded ? (state as CartLoaded).cart : null;
    if (currentCart != null) {
      emit(CartUpdating(currentCart));
    }

    try {
      final cart = await _dataSource.removeCoupon();
      emit(CartLoaded(cart));
    } catch (e) {
      emit(CartError(e.toString(), previousCart: currentCart));
    }
  }
}
