part of 'favorite_remote_datasource.dart';

class _FavoriteRemoteFavoritesDelegate {
  final _FavoriteRemoteSupport _support;
  Future<Set<String>>? _favoriteIdsInFlight;

  _FavoriteRemoteFavoritesDelegate(this._support);

  Future<List<FavoriteItemModel>> getFavorites() async {
    _support.log('Fetching favorites');

    final cachedFavorites = await _support.cacheService.getFavorites();
    if (cachedFavorites != null) {
      unawaited(_refreshFavoritesCache());
      return cachedFavorites;
    }

    return _fetchFavoritesFromApi();
  }

  Future<Set<String>> getFavoriteProductIds() async {
    final cachedIds = await _support.cacheService.getFavoriteIds();
    if (cachedIds != null) {
      return cachedIds;
    }

    if (_favoriteIdsInFlight != null) {
      return _favoriteIdsInFlight!;
    }

    _favoriteIdsInFlight = _resolveFavoriteIds();
    try {
      return await _favoriteIdsInFlight!;
    } finally {
      _favoriteIdsInFlight = null;
    }
  }

  Future<void> addToFavorites(String productId) async {
    _support.log('Adding to favorites: $productId');

    try {
      await _support.apiClient.post(ApiEndpoints.productFavorite(productId));
      await _support.cacheService.markFavorite(productId);
      await _support.cacheService.clearFavoritesList();
    } on DioException catch (error) {
      if (error.response?.statusCode == 409) {
        await _support.cacheService.markFavorite(productId);
        return;
      }
      rethrow;
    }
  }

  Future<void> removeFromFavorites(String productId) async {
    _support.log('Removing from favorites: $productId');
    await _support.apiClient.delete(ApiEndpoints.productFavorite(productId));
    await _support.cacheService.unmarkFavorite(productId);
    await _support.cacheService.clearFavoritesList();
  }

  Future<bool> toggleFavorite(String productId, bool isFavorite) async {
    if (isFavorite) {
      await removeFromFavorites(productId);
      return false;
    }

    await addToFavorites(productId);
    return true;
  }

  Future<bool> isFavorite(String productId) async {
    _support.log('Checking favorite: $productId');

    final cached = await _support.cacheService.isFavorite(productId);
    if (cached != null) {
      return cached;
    }

    try {
      final response = await _support.apiClient.get(
        ApiEndpoints.productFavoriteCheck(productId),
      );
      final data = response.data['data'] ?? response.data;
      if (data is Map && data.containsKey('isFavorite')) {
        final isFavorite = data['isFavorite'] == true;
        if (isFavorite) {
          await _support.cacheService.markFavorite(productId);
        } else {
          await _support.cacheService.unmarkFavorite(productId);
        }
        return isFavorite;
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

  Future<void> clearFavorites() async {
    final favorites = await getFavorites();
    for (final item in favorites) {
      if (item.productId.isEmpty) continue;
      await removeFromFavorites(item.productId);
    }
    await _support.cacheService.clearAll();
  }

  Future<Set<String>> _resolveFavoriteIds() async {
    final favorites = await getFavorites();
    return favorites
        .map((item) => item.productId.trim())
        .where((id) => id.isNotEmpty)
        .toSet();
  }

  Future<void> _refreshFavoritesCache() async {
    try {
      await _fetchFavoritesFromApi();
    } catch (_) {
      // Ignore background refresh errors.
    }
  }

  Future<List<FavoriteItemModel>> _fetchFavoritesFromApi() async {
    final response = await _support.apiClient.get(ApiEndpoints.favoritesMy);
    final data = response.data['data'] ?? response.data;
    final list = data is List ? data : <dynamic>[];

    final items = list.map((json) {
      if (json is! Map<String, dynamic>) {
        throw Exception('Invalid favorite item format');
      }

      final isProductFormat = json.containsKey('name') &&
          json.containsKey('basePrice') &&
          (json.containsKey('_id') || json.containsKey('id'));

      if (isProductFormat) {
        return _support.productJsonToFavoriteItem(json);
      }

      return FavoriteItemModel.fromJson(json);
    }).toList();

    await _support.cacheService.saveFavorites(items);
    return items;
  }
}
