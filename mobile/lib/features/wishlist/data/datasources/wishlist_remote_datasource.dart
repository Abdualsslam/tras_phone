/// Wishlist Remote DataSource - Real API implementation
library;

import 'dart:developer' as developer;
import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../models/wishlist_item_model.dart';
import '../../../catalog/data/models/product_model.dart';

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

  /// Convert Product JSON (from API doc format) to WishlistItemModel
  WishlistItemModel _productJsonToWishlistItem(Map<String, dynamic> json) {
    final productId = json['_id']?.toString() ?? json['id']?.toString() ?? '';
    final product = ProductModel.fromJson(json);
    return WishlistItemModel(
      id: productId,
      productData: json,
      productIdString: productId,
      product: product,
    );
  }

  @override
  Future<List<WishlistItemModel>> getWishlist() async {
    developer.log('Fetching wishlist', name: 'WishlistDataSource');

    try {
      final response = await _apiClient.get(ApiEndpoints.wishlistMy);
      
      // Handle response structure
      final data = response.data['data'] ?? response.data;
      
      // Ensure we have a list
      final List<dynamic> list = data is List ? data : [];
      
      developer.log(
        'Wishlist response: ${list.length} items',
        name: 'WishlistDataSource',
      );

      return list.map((json) {
        try {
          if (json is! Map<String, dynamic>) {
            throw Exception('Invalid wishlist item format');
          }
          // API doc (3-products.md): GET /products/wishlist/my returns Product objects
          // Some backends return WishlistItemModel {_id, customerId, productId, ...}
          final isProductFormat = json.containsKey('name') &&
              json.containsKey('basePrice') &&
              (json.containsKey('_id') || json.containsKey('id'));
          if (isProductFormat) {
            return _productJsonToWishlistItem(json);
          }
          return WishlistItemModel.fromJson(json);
        } catch (e) {
          developer.log(
            'Error parsing wishlist item: $e',
            name: 'WishlistDataSource',
            error: e,
          );
          rethrow;
        }
      }).toList();
    } catch (e) {
      developer.log(
        'Error fetching wishlist: $e',
        name: 'WishlistDataSource',
        error: e,
      );
      rethrow;
    }
  }

  @override
  Future<void> addToWishlist(String productId) async {
    developer.log('Adding to wishlist: $productId', name: 'WishlistDataSource');

    try {
      final response = await _apiClient.post(
        ApiEndpoints.productWishlist(productId),
      );

      // Print full response
      developer.log(
        'Add to wishlist response: ${response.statusCode}',
        name: 'WishlistDataSource',
      );
      developer.log(
        'Response data: ${response.data}',
        name: 'WishlistDataSource',
      );
      developer.log(
        'Response headers: ${response.headers}',
        name: 'WishlistDataSource',
      );

      // Check for success - Backend uses "status": "success" not "success": true
      final status = response.data['status'] as String?;
      final statusCode = response.data['statusCode'] as int?;
      
      // Consider successful if:
      // 1. HTTP status code is 200 or 201 (Created)
      // 2. OR response status is "success"
      // 3. OR statusCode in body is 200/201
      final isSuccess = response.statusCode == 200 || 
                        response.statusCode == 201 ||
                        status == 'success' ||
                        statusCode == 200 ||
                        statusCode == 201;

      if (!isSuccess) {
        throw Exception(
          response.data['messageAr'] ?? 
          response.data['message'] ?? 
          'Failed to add to wishlist',
        );
      }
      
      developer.log(
        'Successfully added to wishlist: ${response.data['messageAr'] ?? response.data['message'] ?? 'Success'}',
        name: 'WishlistDataSource',
      );
    } on DioException catch (e) {
      // Handle 409 Conflict - product already in wishlist
      if (e.response?.statusCode == 409) {
        developer.log(
          'Product already in wishlist: $productId',
          name: 'WishlistDataSource',
        );
        if (e.response?.data != null) {
          developer.log(
            '409 Conflict response: ${e.response!.data}',
            name: 'WishlistDataSource',
          );
        }
        // Don't throw error - product is already in wishlist, which is fine
        return;
      }
      // Print error response
      if (e.response != null) {
        developer.log(
          'Error response: ${e.response!.statusCode}',
          name: 'WishlistDataSource',
        );
        developer.log(
          'Error response data: ${e.response!.data}',
          name: 'WishlistDataSource',
        );
      }
      // Re-throw other errors
      rethrow;
    }
  }

  @override
  Future<void> removeFromWishlist(String productId) async {
    developer.log(
      'Removing from wishlist: $productId',
      name: 'WishlistDataSource',
    );

    try {
      final response = await _apiClient.delete(
        ApiEndpoints.productWishlist(productId),
      );

      // Print full response
      developer.log(
        'Remove from wishlist response: ${response.statusCode}',
        name: 'WishlistDataSource',
      );
      developer.log(
        'Response data: ${response.data}',
        name: 'WishlistDataSource',
      );
      developer.log(
        'Response headers: ${response.headers}',
        name: 'WishlistDataSource',
      );

      // Check for success - Backend uses "status": "success" not "success": true
      final status = response.data['status'] as String?;
      final statusCode = response.data['statusCode'] as int?;
      
      // Consider successful if:
      // 1. HTTP status code is 200 or 201
      // 2. OR response status is "success"
      // 3. OR statusCode in body is 200/201
      final isSuccess = response.statusCode == 200 || 
                        response.statusCode == 201 ||
                        status == 'success' ||
                        statusCode == 200 ||
                        statusCode == 201;

      if (!isSuccess) {
        throw Exception(
          response.data['messageAr'] ?? 
          response.data['message'] ?? 
          'Failed to remove from wishlist',
        );
      }
      
      developer.log(
        'Successfully removed from wishlist: ${response.data['messageAr'] ?? response.data['message'] ?? 'Success'}',
        name: 'WishlistDataSource',
      );
    } on DioException catch (e) {
      // Print error response
      if (e.response != null) {
        developer.log(
          'Error response: ${e.response!.statusCode}',
          name: 'WishlistDataSource',
        );
        developer.log(
          'Error response data: ${e.response!.data}',
          name: 'WishlistDataSource',
        );
      }
      rethrow;
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

    try {
      // Try to get the full wishlist and check if product is in it
      final wishlist = await getWishlist();
      return wishlist.any((item) => item.productId == productId);
    } catch (e) {
      developer.log(
        'Error checking wishlist status: $e',
        name: 'WishlistDataSource',
        error: e,
      );
      // Return false if check fails
      return false;
    }
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
