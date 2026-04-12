/// Favorite Remote DataSource - Real API implementation
library;

import 'dart:async';
import 'dart:developer' as developer;

import 'package:dio/dio.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../catalog/data/models/product_model.dart';
import '../models/favorite_item_model.dart';
import '../services/favorite_cache_service.dart';

part 'favorite_remote_datasource_support.dart';
part 'favorite_remote_datasource_favorites.dart';
part 'favorite_remote_datasource_history.dart';
part 'favorite_remote_datasource_alerts.dart';

abstract class FavoriteRemoteDataSource {
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

class FavoriteRemoteDataSourceImpl implements FavoriteRemoteDataSource {
  final ApiClient _apiClient;
  final FavoriteCacheService _cacheService;

  late final _FavoriteRemoteSupport _support;
  late final _FavoriteRemoteFavoritesDelegate _favorites;
  late final _FavoriteRemoteHistoryDelegate _history;
  late final _FavoriteRemoteAlertsDelegate _alerts;

  FavoriteRemoteDataSourceImpl({
    required ApiClient apiClient,
    required FavoriteCacheService cacheService,
  }) : _apiClient = apiClient,
       _cacheService = cacheService {
    _support = _FavoriteRemoteSupport(
      apiClient: _apiClient,
      cacheService: _cacheService,
    );
    _favorites = _FavoriteRemoteFavoritesDelegate(_support);
    _history = _FavoriteRemoteHistoryDelegate(_support);
    _alerts = _FavoriteRemoteAlertsDelegate(_support);
  }

  @override
  Future<List<FavoriteItemModel>> getFavorites() => _favorites.getFavorites();

  @override
  Future<Set<String>> getFavoriteProductIds() =>
      _favorites.getFavoriteProductIds();

  @override
  Future<void> addToFavorites(String productId) =>
      _favorites.addToFavorites(productId);

  @override
  Future<void> removeFromFavorites(String productId) =>
      _favorites.removeFromFavorites(productId);

  @override
  Future<bool> toggleFavorite(String productId, bool isFavorite) =>
      _favorites.toggleFavorite(productId, isFavorite);

  @override
  Future<bool> isFavorite(String productId) => _favorites.isFavorite(productId);

  @override
  Future<void> clearFavorites() => _favorites.clearFavorites();

  @override
  Future<List<Map<String, dynamic>>> getRecentlyViewed() =>
      _history.getRecentlyViewed();

  @override
  Future<bool> addToRecentlyViewed(String productId) =>
      _history.addToRecentlyViewed(productId);

  @override
  Future<bool> clearRecentlyViewed() => _history.clearRecentlyViewed();

  @override
  Future<bool> createStockAlert(String productId) =>
      _alerts.createStockAlert(productId);

  @override
  Future<bool> removeStockAlert(String alertId) =>
      _alerts.removeStockAlert(alertId);

  @override
  Future<List<Map<String, dynamic>>> getStockAlerts() =>
      _alerts.getStockAlerts();
}
