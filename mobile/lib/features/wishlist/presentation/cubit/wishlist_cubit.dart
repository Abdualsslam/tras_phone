/// Wishlist Cubit - Manages wishlist state
library;

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/wishlist_repository.dart';
import 'wishlist_state.dart';

/// Cubit for managing wishlist
class WishlistCubit extends Cubit<WishlistState> {
  final WishlistRepository _repository;

  WishlistCubit({required WishlistRepository repository})
      : _repository = repository,
        super(const WishlistInitial());

  /// Load wishlist items
  Future<void> loadWishlist() async {
    emit(const WishlistLoading());

    final result = await _repository.getWishlist();

    result.fold(
      (failure) => emit(WishlistError(failure.message)),
      (items) => emit(WishlistLoaded(items)),
    );
  }

  /// Add product to wishlist
  Future<void> addToWishlist(String productId) async {
    final result = await _repository.addToWishlist(productId);

    result.fold(
      (failure) {
        emit(WishlistError(failure.message));
        // Reload to sync state
        loadWishlist();
      },
      (_) {
        // Reload to get updated list
        loadWishlist();
      },
    );
  }

  /// Remove product from wishlist
  Future<void> removeFromWishlist(String productId) async {
    final result = await _repository.removeFromWishlist(productId);

    result.fold(
      (failure) {
        emit(WishlistError(failure.message));
        // Reload to sync state
        loadWishlist();
      },
      (_) {
        // Reload to get updated list
        loadWishlist();
      },
    );
  }

  /// Toggle wishlist status
  Future<void> toggleWishlist(String productId) async {
    // Get current state to check if item is in wishlist
    final currentState = state;
    bool isInWishlist = false;

    if (currentState is WishlistLoaded) {
      isInWishlist = currentState.items.any((item) => item.productId == productId);
    }

    final result = await _repository.toggleWishlist(productId, isInWishlist);

    result.fold(
      (failure) {
        emit(WishlistError(failure.message));
        // Reload to sync state
        loadWishlist();
      },
      (_) {
        // Reload to get updated list
        loadWishlist();
      },
    );
  }

  /// Clear entire wishlist
  Future<void> clearWishlist() async {
    final result = await _repository.clearWishlist();

    result.fold(
      (failure) => emit(WishlistError(failure.message)),
      (_) {
        // Clear local state
        emit(const WishlistLoaded([]));
      },
    );
  }

  /// Get wishlist count
  Future<int> getWishlistCount() async {
    final result = await _repository.getWishlistCount();

    return result.fold(
      (failure) => 0,
      (count) => count,
    );
  }

  /// Move item to cart
  Future<void> moveToCart(String productId, {int quantity = 1}) async {
    final result = await _repository.moveToCart(productId, quantity: quantity);

    result.fold(
      (failure) => emit(WishlistError(failure.message)),
      (_) {
        // Optionally remove from wishlist after moving to cart
        // Or just reload to sync state
        loadWishlist();
      },
    );
  }

  /// Move all items to cart
  Future<void> moveAllToCart() async {
    final result = await _repository.moveAllToCart();

    result.fold(
      (failure) => emit(WishlistError(failure.message)),
      (_) {
        // Reload to sync state
        loadWishlist();
      },
    );
  }
}
