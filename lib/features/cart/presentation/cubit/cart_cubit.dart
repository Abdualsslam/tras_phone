/// Cart Cubit - State management for shopping cart
library;

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../catalog/domain/entities/product_entity.dart';
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
  Future<void> addToCart(ProductEntity product, {int quantity = 1}) async {
    final currentCart = state is CartLoaded ? (state as CartLoaded).cart : null;
    if (currentCart != null) {
      emit(CartUpdating(currentCart));
    }

    try {
      final cart = await _dataSource.addToCart(
        product: product,
        quantity: quantity,
      );
      emit(CartLoaded(cart));
    } catch (e) {
      emit(CartError(e.toString(), previousCart: currentCart));
    }
  }

  /// Update item quantity
  Future<void> updateQuantity(int itemId, int quantity) async {
    final currentCart = state is CartLoaded ? (state as CartLoaded).cart : null;
    if (currentCart != null) {
      emit(CartUpdating(currentCart));
    }

    try {
      final cart = await _dataSource.updateQuantity(
        itemId: itemId,
        quantity: quantity,
      );
      emit(CartLoaded(cart));
    } catch (e) {
      emit(CartError(e.toString(), previousCart: currentCart));
    }
  }

  /// Remove item from cart
  Future<void> removeFromCart(int itemId) async {
    final currentCart = state is CartLoaded ? (state as CartLoaded).cart : null;
    if (currentCart != null) {
      emit(CartUpdating(currentCart));
    }

    try {
      final cart = await _dataSource.removeFromCart(itemId: itemId);
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
