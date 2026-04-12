part of 'favorite_remote_datasource.dart';

class _FavoriteRemoteAlertsDelegate {
  final _FavoriteRemoteSupport _support;

  const _FavoriteRemoteAlertsDelegate(this._support);

  Future<bool> createStockAlert(String productId) async {
    final response = await _support.apiClient.post(
      ApiEndpoints.stockAlerts,
      data: {'productId': productId, 'alertType': 'back_in_stock'},
    );
    return response.statusCode == 200 || response.statusCode == 201;
  }

  Future<bool> removeStockAlert(String alertId) async {
    final response = await _support.apiClient.delete(
      '${ApiEndpoints.stockAlerts}/$alertId',
    );
    return response.statusCode == 200 || response.statusCode == 204;
  }

  Future<List<Map<String, dynamic>>> getStockAlerts() async {
    final response = await _support.apiClient.get(ApiEndpoints.stockAlerts);
    return _support.extractMapList(response.data);
  }
}
