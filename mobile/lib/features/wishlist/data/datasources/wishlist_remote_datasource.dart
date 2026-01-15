/// Wishlist Remote DataSource - Real API implementation
library;

import 'dart:developer' as developer;
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../models/wishlist_item_model.dart';

/// Abstract interface for wishlist data source
abstract class WishlistRemoteDataSource {
  /// Get all wishlist items
  Future<List<WishlistItemModel>> getWishlist();

  /// Add product to wishlist
  Future<void> addToWishlist(String productId);

  /// Remove product from wishlist
  Future<void> removeFromWishlist(String productId);

  /// Toggle wishlist status
  Future<bool> toggleWishlist(String productId, bool isInWishlist);

  /// Check if product is in wishlist
  Future<bool> isInWishlist(String productId);

  /// Clear entire wishlist
  Future<bool> clearWishlist();

  /// Get wishlist count
  Future<int> getWishlistCount();

  /// Move item to cart
  Future<bool> moveToCart(String productId);

  /// Move all items to cart
  Future<bool> moveAllToCart();

  /// Get recently viewed products
  Future<List<Map<String, dynamic>>> getRecentlyViewed();

  /// Add to recently viewed
  Future<bool> addToRecentlyViewed(String productId);

  /// Clear recently viewed
  Future<bool> clearRecentlyViewed();

  /// Create stock alert for product
  Future<bool> createStockAlert(String productId);

  /// Remove stock alert
  Future<bool> removeStockAlert(String productId);

  /// Get stock alerts
  Future<List<Map<String, dynamic>>> getStockAlerts();
}

/// Implementation of WishlistRemoteDataSource using API client
class WishlistRemoteDataSourceImpl implements WishlistRemoteDataSource {
  final ApiClient _apiClient;

  WishlistRemoteDataSourceImpl({required ApiClient apiClient})
    : _apiClient = apiClient;

  @override
  Future<List<WishlistItemModel>> getWishlist() async {
    developer.log('Fetching wishlist', name: 'WishlistDataSource');

    final response = await _apiClient.get(ApiEndpoints.wishlistMy);
    final data = response.data['data'] ?? response.data;
    final List<dynamic> list = data is List ? data : [];

    return list.map((json) => WishlistItemModel.fromJson(json)).toList();
  }

  @override
  Future<void> addToWishlist(String productId) async {
    developer.log('Adding to wishlist: $productId', name: 'WishlistDataSource');

    final response = await _apiClient.post(
      ApiEndpoints.productWishlist(productId),
    );

    if (response.data['success'] != true) {
      throw Exception(response.data['messageAr'] ?? 'Failed to add to wishlist');
    }
  }

  @override
  Future<void> removeFromWishlist(String productId) async {
    developer.log(
      'Removing from wishlist: $productId',
      name: 'WishlistDataSource',
    );

    final response = await _apiClient.delete(
      ApiEndpoints.productWishlist(productId),
    );

    if (response.data['success'] != true) {
      throw Exception(response.data['messageAr'] ?? 'Failed to remove from wishlist');
    }
  }

  @override
  Future<bool> toggleWishlist(String productId, bool isInWishlist) async {
    if (isInWishlist) {
      await removeFromWishlist(productId);
      return false;
    } else {
      await addToWishlist(productId);
      return true;
    }
  }

  @override
  Future<bool> isInWishlist(String productId) async {
    developer.log('Checking wishlist: $productId', name: 'WishlistDataSource');

    final response = await _apiClient.get(
      '${ApiEndpoints.wishlist}/check/$productId',
    );

    final data = response.data['data'] ?? response.data;
    return data['in_wishlist'] ?? false;
  }

  @override
  Future<bool> clearWishlist() async {
    developer.log('Clearing wishlist', name: 'WishlistDataSource');

    final response = await _apiClient.delete(ApiEndpoints.wishlist);
    return response.statusCode == 200;
  }

  @override
  Future<int> getWishlistCount() async {
    developer.log('Getting wishlist count', name: 'WishlistDataSource');

    final response = await _apiClient.get('${ApiEndpoints.wishlist}/count');
    final data = response.data['data'] ?? response.data;

    return data['count'] ?? 0;
  }

  @override
  Future<bool> moveToCart(String productId) async {
    developer.log('Moving to cart: $productId', name: 'WishlistDataSource');

    final response = await _apiClient.post(
      '${ApiEndpoints.wishlist}/$productId/move-to-cart',
    );

    return response.statusCode == 200;
  }

  @override
  Future<bool> moveAllToCart() async {
    developer.log('Moving all to cart', name: 'WishlistDataSource');

    final response = await _apiClient.post(
      '${ApiEndpoints.wishlist}/move-all-to-cart',
    );

    return response.statusCode == 200;
  }

  @override
  Future<List<Map<String, dynamic>>> getRecentlyViewed() async {
    developer.log('Fetching recently viewed', name: 'WishlistDataSource');

    final response = await _apiClient.get(ApiEndpoints.recentlyViewed);
    final data = response.data['data'] ?? response.data;

    if (data is List) {
      return data.cast<Map<String, dynamic>>();
    }
    return [];
  }

  @override
  Future<bool> addToRecentlyViewed(String productId) async {
    developer.log(
      'Adding to recently viewed: $productId',
      name: 'WishlistDataSource',
    );

    final response = await _apiClient.post(
      ApiEndpoints.recentlyViewed,
      data: {'product_id': productId},
    );

    return response.statusCode == 200;
  }

  @override
  Future<bool> clearRecentlyViewed() async {
    developer.log('Clearing recently viewed', name: 'WishlistDataSource');

    final response = await _apiClient.delete(ApiEndpoints.recentlyViewed);
    return response.statusCode == 200;
  }

  @override
  Future<bool> createStockAlert(String productId) async {
    developer.log(
      'Creating stock alert: $productId',
      name: 'WishlistDataSource',
    );

    final response = await _apiClient.post(
      ApiEndpoints.stockAlerts,
      data: {'product_id': productId},
    );

    return response.statusCode == 200;
  }

  @override
  Future<bool> removeStockAlert(String productId) async {
    developer.log(
      'Removing stock alert: $productId',
      name: 'WishlistDataSource',
    );

    final response = await _apiClient.delete(
      '${ApiEndpoints.stockAlerts}/$productId',
    );

    return response.statusCode == 200;
  }

  @override
  Future<List<Map<String, dynamic>>> getStockAlerts() async {
    developer.log('Fetching stock alerts', name: 'WishlistDataSource');

    final response = await _apiClient.get(ApiEndpoints.stockAlerts);
    final data = response.data['data'] ?? response.data;

    if (data is List) {
      return data.cast<Map<String, dynamic>>();
    }
    return [];
  }
}
