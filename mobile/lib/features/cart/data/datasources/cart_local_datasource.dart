/// Cart Local DataSource - Local storage for cart items
library;

import 'dart:developer' as developer;
import '../../../../core/storage/local_storage.dart';
import '../../../../core/constants/storage_keys.dart';
import '../models/local_cart_item_model.dart';

/// Abstract interface for local cart data source
abstract class CartLocalDataSource {
  /// Get local cart items
  Future<List<LocalCartItemModel>> getLocalCart();

  /// Save local cart items
  Future<void> saveLocalCart(List<LocalCartItemModel> items);

  /// Add item to local cart
  Future<List<LocalCartItemModel>> addToCartLocal({
    required String productId,
    required int quantity,
    required double unitPrice,
    String? productName,
    String? productNameAr,
    String? productImage,
    String? productSku,
  });

  /// Update item quantity in local cart
  Future<List<LocalCartItemModel>> updateQuantityLocal({
    required String productId,
    required int quantity,
  });

  /// Remove item from local cart
  Future<List<LocalCartItemModel>> removeFromCartLocal({
    required String productId,
  });

  /// Clear local cart
  Future<void> clearCartLocal();

  /// Get local cart count
  Future<int> getLocalCartCount();
}

/// Implementation of CartLocalDataSource using LocalStorage
class CartLocalDataSourceImpl implements CartLocalDataSource {
  final LocalStorage _storage;

  CartLocalDataSourceImpl({required LocalStorage storage}) : _storage = storage;

  @override
  Future<List<LocalCartItemModel>> getLocalCart() async {
    try {
      final itemsList = _storage.getObjectList(StorageKeys.cartItems);
      if (itemsList == null || itemsList.isEmpty) {
        return [];
      }

      // Parse items individually to avoid losing entire cart due to one corrupt entry
      final validItems = <LocalCartItemModel>[];
      for (var i = 0; i < itemsList.length; i++) {
        try {
          final item = itemsList[i] as Map;
          final map = Map<String, dynamic>.from(item);
          validItems.add(LocalCartItemModel.fromJson(map));
        } catch (e) {
          developer.log(
            'Skipping corrupt cart item at index $i: $e',
            name: 'CartLocalDataSource',
          );
        }
      }
      return validItems;
    } catch (e) {
      developer.log(
        'Error getting local cart: $e',
        name: 'CartLocalDataSource',
        error: e,
      );
      return [];
    }
  }

  @override
  Future<void> saveLocalCart(List<LocalCartItemModel> items) async {
    try {
      final itemsJson = items.map((item) => item.toJson()).toList();
      await _storage.setObjectList(StorageKeys.cartItems, itemsJson);

      // Update cart count
      final totalCount = items.fold<int>(0, (sum, item) => sum + item.quantity);
      await _storage.setInt(StorageKeys.cartCount, totalCount);

      developer.log(
        'Saved ${items.length} items to local cart (total quantity: $totalCount)',
        name: 'CartLocalDataSource',
      );
    } catch (e) {
      developer.log(
        'Error saving local cart: $e',
        name: 'CartLocalDataSource',
        error: e,
      );
      rethrow;
    }
  }

  @override
  Future<List<LocalCartItemModel>> addToCartLocal({
    required String productId,
    required int quantity,
    required double unitPrice,
    String? productName,
    String? productNameAr,
    String? productImage,
    String? productSku,
  }) async {
    try {
      final items = await getLocalCart();
      final existingIndex = items.indexWhere(
        (item) => item.productId == productId,
      );

      if (existingIndex >= 0) {
        // Update existing item
        final existingItem = items[existingIndex];
        items[existingIndex] = existingItem.copyWith(
          quantity: existingItem.quantity + quantity,
          productName: productName ?? existingItem.productName,
          productNameAr: productNameAr ?? existingItem.productNameAr,
          productImage: productImage ?? existingItem.productImage,
          productSku: productSku ?? existingItem.productSku,
        );
      } else {
        // Add new item
        items.add(
          LocalCartItemModel(
            productId: productId,
            quantity: quantity,
            unitPrice: unitPrice,
            addedAt: DateTime.now(),
            productName: productName,
            productNameAr: productNameAr,
            productImage: productImage,
            productSku: productSku,
          ),
        );
      }

      await saveLocalCart(items);
      return items;
    } catch (e) {
      developer.log(
        'Error adding to local cart: $e',
        name: 'CartLocalDataSource',
        error: e,
      );
      rethrow;
    }
  }

  @override
  Future<List<LocalCartItemModel>> updateQuantityLocal({
    required String productId,
    required int quantity,
  }) async {
    try {
      final items = await getLocalCart();
      final itemIndex = items.indexWhere((item) => item.productId == productId);

      if (itemIndex < 0) {
        throw Exception('Item not found in local cart');
      }

      if (quantity <= 0) {
        // Remove item if quantity is 0 or less
        items.removeAt(itemIndex);
      } else {
        // Update quantity
        items[itemIndex] = items[itemIndex].copyWith(quantity: quantity);
      }

      await saveLocalCart(items);
      return items;
    } catch (e) {
      developer.log(
        'Error updating quantity in local cart: $e',
        name: 'CartLocalDataSource',
        error: e,
      );
      rethrow;
    }
  }

  @override
  Future<List<LocalCartItemModel>> removeFromCartLocal({
    required String productId,
  }) async {
    try {
      final items = await getLocalCart();
      items.removeWhere((item) => item.productId == productId);
      await saveLocalCart(items);
      return items;
    } catch (e) {
      developer.log(
        'Error removing from local cart: $e',
        name: 'CartLocalDataSource',
        error: e,
      );
      rethrow;
    }
  }

  @override
  Future<void> clearCartLocal() async {
    try {
      await _storage.remove(StorageKeys.cartItems);
      await _storage.remove(StorageKeys.cartCount);
      developer.log('Cleared local cart', name: 'CartLocalDataSource');
    } catch (e) {
      developer.log(
        'Error clearing local cart: $e',
        name: 'CartLocalDataSource',
        error: e,
      );
      rethrow;
    }
  }

  @override
  Future<int> getLocalCartCount() async {
    try {
      final count = _storage.getInt(StorageKeys.cartCount);
      return count ?? 0;
    } catch (e) {
      developer.log(
        'Error getting local cart count: $e',
        name: 'CartLocalDataSource',
        error: e,
      );
      return 0;
    }
  }
}
