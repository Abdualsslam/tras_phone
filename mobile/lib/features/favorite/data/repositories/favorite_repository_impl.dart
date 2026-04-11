library;

import '../../domain/repositories/favorite_repository.dart';
import '../datasources/favorite_remote_datasource.dart';
import '../models/favorite_item_model.dart';

class FavoriteRepositoryImpl implements FavoriteRepository {
  final FavoriteRemoteDataSource _remoteDataSource;

  FavoriteRepositoryImpl({required FavoriteRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  @override
  Future<void> addToFavorites(String productId) =>
      _remoteDataSource.addToFavorites(productId);

  @override
  Future<bool> addToRecentlyViewed(String productId) =>
      _remoteDataSource.addToRecentlyViewed(productId);

  @override
  Future<void> clearFavorites() => _remoteDataSource.clearFavorites();

  @override
  Future<bool> clearRecentlyViewed() => _remoteDataSource.clearRecentlyViewed();

  @override
  Future<bool> createStockAlert(String productId) =>
      _remoteDataSource.createStockAlert(productId);

  @override
  Future<List<FavoriteItemModel>> getFavorites() =>
      _remoteDataSource.getFavorites();

  @override
  Future<Set<String>> getFavoriteProductIds() =>
      _remoteDataSource.getFavoriteProductIds();

  @override
  Future<List<Map<String, dynamic>>> getRecentlyViewed() =>
      _remoteDataSource.getRecentlyViewed();

  @override
  Future<List<Map<String, dynamic>>> getStockAlerts() =>
      _remoteDataSource.getStockAlerts();

  @override
  Future<bool> isFavorite(String productId) =>
      _remoteDataSource.isFavorite(productId);

  @override
  Future<void> removeFromFavorites(String productId) =>
      _remoteDataSource.removeFromFavorites(productId);

  @override
  Future<bool> removeStockAlert(String alertId) =>
      _remoteDataSource.removeStockAlert(alertId);

  @override
  Future<bool> toggleFavorite(String productId, bool isFavorite) =>
      _remoteDataSource.toggleFavorite(productId, isFavorite);
}
