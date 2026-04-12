part of 'favorite_remote_datasource.dart';

class _FavoriteRemoteSupport {
  final ApiClient apiClient;
  final FavoriteCacheService cacheService;

  const _FavoriteRemoteSupport({
    required this.apiClient,
    required this.cacheService,
  });

  void log(String message) {
    developer.log(message, name: 'FavoriteDataSource');
  }

  FavoriteItemModel productJsonToFavoriteItem(Map<String, dynamic> json) {
    final productId = json['_id']?.toString() ?? json['id']?.toString() ?? '';
    final product = ProductModel.fromJson(json);
    return FavoriteItemModel(
      id: productId,
      productData: json,
      productIdString: productId,
      product: product,
    );
  }

  List<Map<String, dynamic>> extractMapList(dynamic data) {
    final payload = data is Map<String, dynamic> ? data['data'] ?? data : data;
    if (payload is List) {
      return payload.cast<Map<String, dynamic>>();
    }
    return const [];
  }
}
