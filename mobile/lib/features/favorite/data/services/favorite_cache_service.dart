/// Favorite Cache Service - Manages favorites caching with Hive
library;

import 'dart:convert';

import '../../../../core/cache/hive_cache_service.dart';
import '../models/favorite_item_model.dart';

class FavoriteCacheService {
  final HiveCacheService _cacheService;

  static const String _favoritesListKey = 'favorites_list_v1';
  static const String _favoriteIdsKey = 'favorite_ids_v1';
  static const Duration _defaultTtl = Duration(minutes: 5);

  FavoriteCacheService(this._cacheService);

  Future<List<FavoriteItemModel>?> getFavorites() async {
    try {
      if (!await isFavoritesCacheValid()) return null;

      final cachedJson = await _cacheService.get<String>(_favoritesListKey);
      if (cachedJson == null) return null;

      final decoded = jsonDecode(cachedJson) as Map<String, dynamic>;
      final items = decoded['items'];
      if (items is! List) return null;

      return items
          .whereType<Map<String, dynamic>>()
          .map(FavoriteItemModel.fromJson)
          .toList();
    } catch (_) {
      return null;
    }
  }

  Future<void> saveFavorites(List<FavoriteItemModel> items) async {
    try {
      final payload = {
        'items': items.map((e) => e.toJson()).toList(),
        'cachedAt': DateTime.now().toIso8601String(),
      };

      await _cacheService.set<String>(
        _favoritesListKey,
        jsonEncode(payload),
        ttl: _defaultTtl,
      );

      final ids = items
          .map((e) => e.productId)
          .where((id) => id.isNotEmpty)
          .toSet();
      await saveFavoriteIds(ids);
    } catch (_) {
      // Ignore cache errors
    }
  }

  Future<void> clearFavoritesList() async {
    await _cacheService.delete(_favoritesListKey);
  }

  Future<void> clearAll() async {
    await _cacheService.delete(_favoritesListKey);
    await _cacheService.delete(_favoriteIdsKey);
  }

  Future<bool> isFavoritesCacheValid() async {
    if (!_cacheService.containsKey(_favoritesListKey)) return false;
    return !_cacheService.isExpired(_favoritesListKey);
  }

  Future<Set<String>?> getFavoriteIds() async {
    try {
      if (!_cacheService.containsKey(_favoriteIdsKey) ||
          _cacheService.isExpired(_favoriteIdsKey)) {
        return null;
      }

      final cachedJson = await _cacheService.get<String>(_favoriteIdsKey);
      if (cachedJson == null) return null;

      final decoded = jsonDecode(cachedJson) as Map<String, dynamic>;
      final ids = decoded['ids'];
      if (ids is! List) return null;

      return ids.map((e) => e.toString()).toSet();
    } catch (_) {
      return null;
    }
  }

  Future<void> saveFavoriteIds(Set<String> ids) async {
    final payload = {
      'ids': ids.toList(),
      'cachedAt': DateTime.now().toIso8601String(),
    };
    await _cacheService.set<String>(
      _favoriteIdsKey,
      jsonEncode(payload),
      ttl: _defaultTtl,
    );
  }

  Future<bool?> isFavorite(String productId) async {
    final ids = await getFavoriteIds();
    if (ids == null) return null;
    return ids.contains(productId);
  }

  Future<void> markFavorite(String productId) async {
    if (productId.isEmpty) return;
    final ids = await getFavoriteIds() ?? <String>{};
    ids.add(productId);
    await saveFavoriteIds(ids);
  }

  Future<void> unmarkFavorite(String productId) async {
    if (productId.isEmpty) return;
    final ids = await getFavoriteIds();
    if (ids == null) return;
    ids.remove(productId);
    await saveFavoriteIds(ids);
  }
}
