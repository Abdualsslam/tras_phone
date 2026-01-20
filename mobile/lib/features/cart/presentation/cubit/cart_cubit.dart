/// Cart Cubit - State management for shopping cart
library;

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/cart_remote_datasource.dart';
import '../../data/datasources/cart_local_datasource.dart';
import '../../data/models/local_cart_item_model.dart';
import '../../domain/entities/cart_entity.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../../domain/entities/cart_sync_result_entity.dart';
import '../../domain/enums/cart_enums.dart';
import 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  final CartRemoteDataSource _remoteDataSource;
  final CartLocalDataSource _localDataSource;

  CartCubit({
    required CartRemoteDataSource remoteDataSource,
    required CartLocalDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource,
        super(const CartInitial()) {
    // Load local cart on initialization
    _loadLocalCart();
  }

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
    required int quantity,
    required double unitPrice,
  }) async {
    final currentCart = state is CartLoaded ? (state as CartLoaded).cart : null;
    if (currentCart != null) {
      emit(CartUpdating(currentCart));
    }

    try {
      final cart = await _dataSource.addToCart(
        productId: productId,
        quantity: quantity,
        unitPrice: unitPrice,
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
  Future<void> applyCoupon(
    String couponCode, {
    String? couponId,
    double? discountAmount,
  }) async {
    final currentCart = state is CartLoaded ? (state as CartLoaded).cart : null;
    if (currentCart != null) {
      emit(CartUpdating(currentCart));
    }

    try {
      final cart = await _dataSource.applyCoupon(
        couponId: couponId,
        couponCode: couponCode,
        discountAmount: discountAmount,
      );
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

  /// Get cart count
  Future<int> getCartCount() async {
    try {
      return await _remoteDataSource.getCartCount();
    } catch (e) {
      // Fallback to local cart count
      return await _localDataSource.getLocalCartCount();
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // LOCAL CART OPERATIONS (Instant - No server calls)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Load local cart and convert to CartEntity for state
  Future<void> _loadLocalCart() async {
    try {
      final localItems = await _localDataSource.getLocalCart();
      if (localItems.isEmpty) {
        if (state is CartInitial) {
          // Keep initial state if cart is empty
          return;
        }
        emit(const CartLoaded(CartEntity(
          id: 'local',
          customerId: '',
          items: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        )));
        return;
      }

      final cartEntity = _convertLocalItemsToCartEntity(localItems);
      emit(CartLoaded(cartEntity));
    } catch (e) {
      // Silent fail on initialization
    }
  }

  /// Load local cart (public method)
  Future<void> loadLocalCart() async {
    await _loadLocalCart();
  }

  /// Add item to local cart (instant)
  Future<void> addToCartLocal({
    required String productId,
    required int quantity,
    required double unitPrice,
    String? productName,
    String? productNameAr,
    String? productImage,
    String? productSku,
  }) async {
    try {
      final items = await _localDataSource.addToCartLocal(
        productId: productId,
        quantity: quantity,
        unitPrice: unitPrice,
        productName: productName,
        productNameAr: productNameAr,
        productImage: productImage,
        productSku: productSku,
      );

      // Convert to CartEntity and emit immediately
      final cartEntity = _convertLocalItemsToCartEntity(items);
      emit(CartLoaded(cartEntity));
    } catch (e) {
      emit(CartError('Failed to add item: ${e.toString()}'));
    }
  }

  /// Update quantity in local cart (instant)
  Future<void> updateQuantityLocal(String productId, int quantity) async {
    try {
      final items = await _localDataSource.updateQuantityLocal(
        productId: productId,
        quantity: quantity,
      );

      // Convert to CartEntity and emit immediately
      final cartEntity = _convertLocalItemsToCartEntity(items);
      emit(CartLoaded(cartEntity));
    } catch (e) {
      emit(CartError('Failed to update quantity: ${e.toString()}'));
    }
  }

  /// Remove item from local cart (instant)
  Future<void> removeFromCartLocal(String productId) async {
    try {
      final items = await _localDataSource.removeFromCartLocal(
        productId: productId,
      );

      // Convert to CartEntity and emit immediately
      final cartEntity = _convertLocalItemsToCartEntity(items);
      emit(CartLoaded(cartEntity));
    } catch (e) {
      emit(CartError('Failed to remove item: ${e.toString()}'));
    }
  }

  /// Clear local cart (instant)
  Future<void> clearCartLocal() async {
    try {
      await _localDataSource.clearCartLocal();
      emit(const CartLoaded(CartEntity(
        id: 'local',
        customerId: '',
        items: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      )));
    } catch (e) {
      emit(CartError('Failed to clear cart: ${e.toString()}'));
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SYNC OPERATIONS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Sync local cart with server
  /// This validates stock, prices, and availability
  Future<CartSyncResultEntity?> syncCart({bool silent = false}) async {
    final currentCart = state is CartLoaded ? (state as CartLoaded).cart : null;

    if (!silent) {
      emit(CartSyncing(currentCart: currentCart));
    }

    try {
      // Get local cart items
      final localItems = await _localDataSource.getLocalCart();
      
      if (localItems.isEmpty) {
        // If local cart is empty, just load server cart
        if (!silent) {
          await loadCart();
        }
        return null;
      }

      // Convert to format expected by server
      final itemsForSync = localItems.map((item) => {
        'productId': item.productId,
        'quantity': item.quantity,
        'unitPrice': item.unitPrice,
      }).toList();

      // Sync with server
      final syncResult = await _remoteDataSource.syncCartWithResults(
        items: itemsForSync,
      );

      // Update local cart with synced items
      final syncedItems = syncResult.syncedCart.items.map((item) {
        return LocalCartItemModel(
          productId: item.productId,
          quantity: item.quantity,
          unitPrice: item.unitPrice,
          addedAt: item.addedAt,
          productName: item.productName,
          productNameAr: item.productNameAr,
          productImage: item.productImage,
          productSku: item.productSku,
        );
      }).toList();

      await _localDataSource.saveLocalCart(syncedItems);

      // Emit synced cart
      if (!silent) {
        emit(CartSyncCompleted(syncResult));
        // Also emit as loaded cart for compatibility
        emit(CartLoaded(syncResult.syncedCart));
      }

      return syncResult;
    } catch (e) {
      if (!silent) {
        emit(CartSyncError('Sync failed: ${e.toString()}'));
      }
      return null;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // HELPER METHODS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Convert LocalCartItem list to CartEntity
  CartEntity _convertLocalItemsToCartEntity(List<LocalCartItemModel> items) {
    if (items.isEmpty) {
      return CartEntity(
        id: 'local',
        customerId: '',
        items: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }

    final cartItems = items.map((item) {
      return CartItemEntity(
        productId: item.productId,
        quantity: item.quantity,
        unitPrice: item.unitPrice,
        totalPrice: item.totalPrice,
        addedAt: item.addedAt,
        productName: item.productName,
        productNameAr: item.productNameAr,
        productImage: item.productImage,
        productSku: item.productSku,
      );
    }).toList();

    final itemsCount = cartItems.fold<int>(0, (sum, item) => sum + item.quantity);
    final subtotal = cartItems.fold<double>(0, (sum, item) => sum + item.totalPrice);

    return CartEntity(
      id: 'local',
      customerId: '',
      status: CartStatus.active,
      items: cartItems,
      itemsCount: itemsCount,
      subtotal: subtotal,
      discount: 0,
      taxAmount: 0,
      shippingCost: 0,
      total: subtotal,
      couponDiscount: 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}
