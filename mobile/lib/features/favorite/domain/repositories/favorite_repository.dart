library;

import '../../data/models/favorite_item_model.dart';

abstract class FavoriteRepository {
  Future<List<FavoriteItemModel>> getFavorites();
  Future<Set<String>> getFavoriteProductIds();
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
