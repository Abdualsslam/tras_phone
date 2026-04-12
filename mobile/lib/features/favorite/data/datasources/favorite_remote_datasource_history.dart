part of 'favorite_remote_datasource.dart';

class _FavoriteRemoteHistoryDelegate {
  final _FavoriteRemoteSupport _support;

  const _FavoriteRemoteHistoryDelegate(this._support);

  Future<List<Map<String, dynamic>>> getRecentlyViewed() async {
    final response = await _support.apiClient.get(ApiEndpoints.recentlyViewed);
    return _support.extractMapList(response.data);
  }

  Future<bool> addToRecentlyViewed(String productId) async {
    final response = await _support.apiClient.post(
      '${ApiEndpoints.recentlyViewed}/$productId',
    );
    return response.statusCode == 200 || response.statusCode == 201;
  }

  Future<bool> clearRecentlyViewed() async {
    final response = await _support.apiClient.delete(ApiEndpoints.recentlyViewed);
    return response.statusCode == 200 || response.statusCode == 204;
  }
}
