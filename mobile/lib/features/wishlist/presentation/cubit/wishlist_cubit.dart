/// Wishlist Cubit - Manages wishlist state
library;

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/wishlist_remote_datasource.dart';
import 'wishlist_state.dart';

/// Cubit for managing wishlist
class WishlistCubit extends Cubit<WishlistState> {
  final WishlistRemoteDataSource _dataSource;

  WishlistCubit({required WishlistRemoteDataSource dataSource})
      : _dataSource = dataSource,
        super(const WishlistInitial());

  /// Load wishlist items
  Future<void> loadWishlist() async {
    emit(const WishlistLoading());

    try {
      final items = await _dataSource.getWishlist();
      emit(WishlistLoaded(items));
    } catch (e) {
      emit(WishlistError(e.toString()));
    }
  }

  /// Add product to wishlist
  Future<void> addToWishlist(String productId) async {
    try {
      await _dataSource.addToWishlist(productId);
      // Reload to get updated list
      loadWishlist();
    } catch (e) {
      emit(WishlistError(e.toString()));
      // Reload to sync state
      loadWishlist();
    }
  }

  /// Remove product from wishlist
  Future<void> removeFromWishlist(String productId) async {
    try {
      await _dataSource.removeFromWishlist(productId);
      // Reload to get updated list
      loadWishlist();
    } catch (e) {
      emit(WishlistError(e.toString()));
      // Reload to sync state
      loadWishlist();
    }
  }

  /// Toggle wishlist status
  Future<void> toggleWishlist(String productId) async {
    // Get current state to check if item is in wishlist
    final currentState = state;
    bool isInWishlist = false;

    if (currentState is WishlistLoaded) {
      isInWishlist = currentState.items.any((item) => item.productId.toString() == productId);
    }

    try {
      await _dataSource.toggleWishlist(productId, isInWishlist);
      // Reload to get updated list
      loadWishlist();
    } catch (e) {
      emit(WishlistError(e.toString()));
      // Reload to sync state
      loadWishlist();
    }
  }

  /// Clear entire wishlist
  Future<void> clearWishlist() async {
    try {
      await _dataSource.clearWishlist();
      // Clear local state
      emit(const WishlistLoaded([]));
    } catch (e) {
      emit(WishlistError(e.toString()));
    }
  }

  /// Get wishlist count
  Future<int> getWishlistCount() async {
    try {
      return await _dataSource.getWishlistCount();
    } catch (e) {
      return 0;
    }
  }

  /// Move item to cart
  Future<void> moveToCart(String productId) async {
    try {
      await _dataSource.moveToCart(productId);
      // Optionally remove from wishlist after moving to cart
      // Or just reload to sync state
      loadWishlist();
    } catch (e) {
      emit(WishlistError(e.toString()));
    }
  }

  /// Move all items to cart
  Future<void> moveAllToCart() async {
    try {
      await _dataSource.moveAllToCart();
      // Reload to sync state
      loadWishlist();
    } catch (e) {
      emit(WishlistError(e.toString()));
    }
  }
}
