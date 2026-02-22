/// Favorite Remote DataSource - Real API implementation
library;

import 'dart:developer' as developer;
import 'package:dio/dio.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../catalog/data/models/product_model.dart';
import '../models/favorite_item_model.dart';

abstract class FavoriteRemoteDataSource {
  Future<List<FavoriteItemModel>> getFavorites();
  Future<void> addToFavorites(String productId);
  Future<void> removeFromFavorites(String productId);
  Future<bool> toggleFavorite(String productId, bool isFavorite);
  Future<bool> isFavorite(String productId);
  Future<void> clearFavorites();
  Future<List<Map<String, dynamic>>> getRecentlyViewed();
  Future<bool> addToRecentlyViewed(String productId);
  Future<bool> clearRecentlyViewed();
  Future<bool> createStockAlert(String productId);
  Future<bool> removeStockAlert(String alertId);
  Future<List<Map<String, dynamic>>> getStockAlerts();
}

class FavoriteRemoteDataSourceImpl implements FavoriteRemoteDataSource {
  final ApiClient _apiClient;

  FavoriteRemoteDataSourceImpl({required ApiClient apiClient})
    : _apiClient = apiClient;

  FavoriteItemModel _productJsonToFavoriteItem(Map<String, dynamic> json) {
    final productId = json['_id']?.toString() ?? json['id']?.toString() ?? '';
    final product = ProductModel.fromJson(json);
    return FavoriteItemModel(
      id: productId,
      productData: json,
      productIdString: productId,
      product: product,
    );
  }

  @override
  Future<List<FavoriteItemModel>> getFavorites() async {
    developer.log('Fetching favorites', name: 'FavoriteDataSource');
    final response = await _apiClient.get(ApiEndpoints.favoritesMy);
    final data = response.data['data'] ?? response.data;
    final list = data is List ? data : <dynamic>[];

    return list.map((json) {
      if (json is! Map<String, dynamic>) {
        throw Exception('Invalid favorite item format');
      }

      final isProductFormat = json.containsKey('name') &&
          json.containsKey('basePrice') &&
          (json.containsKey('_id') || json.containsKey('id'));

      if (isProductFormat) {
        return _productJsonToFavoriteItem(json);
      }

      return FavoriteItemModel.fromJson(json);
    }).toList();
  }

  @override
  Future<void> addToFavorites(String productId) async {
    developer.log('Adding to favorites: $productId', name: 'FavoriteDataSource');

    try {
      await _apiClient.post(ApiEndpoints.productFavorite(productId));
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        return;
      }
      rethrow;
    }
  }

  @override
  Future<void> removeFromFavorites(String productId) async {
    developer.log(
      'Removing from favorites: $productId',
      name: 'FavoriteDataSource',
    );
    await _apiClient.delete(ApiEndpoints.productFavorite(productId));
  }

  @override
  Future<bool> toggleFavorite(String productId, bool isFavorite) async {
    if (isFavorite) {
      await removeFromFavorites(productId);
      return false;
    }

    await addToFavorites(productId);
    return true;
  }

  @override
  Future<bool> isFavorite(String productId) async {
    developer.log('Checking favorite: $productId', name: 'FavoriteDataSource');

    try {
      final response = await _apiClient.get(
        ApiEndpoints.productFavoriteCheck(productId),
      );
      final data = response.data['data'] ?? response.data;
      if (data is Map && data.containsKey('isFavorite')) {
        return data['isFavorite'] == true;
      }
    } catch (_) {
      // Fallback to full list when check endpoint fails.
    }

    final favorites = await getFavorites();
    final normalizedProductId = productId.trim();
    return favorites.any(
      (item) => item.productId.toString().trim() == normalizedProductId,
    );
  }

  @override
  Future<void> clearFavorites() async {
    final favorites = await getFavorites();
    for (final item in favorites) {
      if (item.productId.isEmpty) continue;
      await removeFromFavorites(item.productId);
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getRecentlyViewed() async {
    final response = await _apiClient.get(ApiEndpoints.recentlyViewed);
    final data = response.data['data'] ?? response.data;
    if (data is List) {
      return data.cast<Map<String, dynamic>>();
    }
    return [];
  }

  @override
  Future<bool> addToRecentlyViewed(String productId) async {
    final response = await _apiClient.post(
      '${ApiEndpoints.recentlyViewed}/$productId',
    );
    return response.statusCode == 200 || response.statusCode == 201;
  }

  @override
  Future<bool> clearRecentlyViewed() async {
    final response = await _apiClient.delete(ApiEndpoints.recentlyViewed);
    return response.statusCode == 200 || response.statusCode == 204;
  }

  @override
  Future<bool> createStockAlert(String productId) async {
    final response = await _apiClient.post(
      ApiEndpoints.stockAlerts,
      data: {'productId': productId, 'alertType': 'back_in_stock'},
    );
    return response.statusCode == 200 || response.statusCode == 201;
  }

  @override
  Future<bool> removeStockAlert(String alertId) async {
    final response = await _apiClient.delete(
      '${ApiEndpoints.stockAlerts}/$alertId',
    );
    return response.statusCode == 200 || response.statusCode == 204;
  }

  @override
  Future<List<Map<String, dynamic>>> getStockAlerts() async {
    final response = await _apiClient.get(ApiEndpoints.stockAlerts);
    final data = response.data['data'] ?? response.data;
    if (data is List) {
      return data.cast<Map<String, dynamic>>();
    }
    return [];
  }
}
