part of 'catalog_remote_datasource.dart';

class _CatalogReviewsRemote {
  final _CatalogRemoteSupport _support;

  const _CatalogReviewsRemote(this._support);

  Future<List<ProductReviewModel>> getProductReviews(String productId) async {
    _support.log('Fetching reviews for product: $productId');

    final response = await _support.apiClient.get(
      ApiEndpoints.productReviews(productId),
    );

    final responseData = Map<String, dynamic>.from(response.data);
    final status = responseData['status'] as String?;
    final success = responseData['success'] == true;
    final statusOk = status == 'success' || responseData['statusCode'] == 200;

    if (success || statusOk) {
      return _support.parseEntityList(
        responseData['data'] ?? const [],
        ProductReviewModel.fromJson,
      );
    }

    throw ServerException(
      message:
          responseData['messageAr']?.toString() ?? 'Failed to fetch reviews',
    );
  }

  Future<ProductReviewModel?> getMyReview(String productId) async {
    try {
      final response = await _support.apiClient.get(
        ApiEndpoints.productReviewsMine(productId),
      );
      final responseData = Map<String, dynamic>.from(response.data);
      final success =
          responseData['success'] == true || responseData['statusCode'] == 200;

      if (!success) return null;

      final payload = responseData['data'];
      if (payload == null) return null;
      return ProductReviewModel.fromJson(
        payload is Map<String, dynamic>
            ? payload
            : Map<String, dynamic>.from(payload as Map),
      );
    } catch (_) {
      return null;
    }
  }

  Future<ProductReviewModel> addReview({
    required String productId,
    required int rating,
    String? title,
    String? comment,
    List<String>? images,
  }) async {
    _support.log('Adding review for product: $productId');

    final response = await _support.apiClient.post(
      ApiEndpoints.productReviews(productId),
      data: {
        'rating': rating,
        if (title != null) 'title': title,
        if (comment != null) 'comment': comment,
        if (images != null && images.isNotEmpty) 'images': images,
      },
    );

    final responseData = Map<String, dynamic>.from(response.data);
    final status = responseData['status'] as String?;
    final success = responseData['success'] == true;
    final statusOk =
        status == 'success' ||
        responseData['statusCode'] == 200 ||
        responseData['statusCode'] == 201;

    if (success || statusOk) {
      return ProductReviewModel.fromJson(
        Map<String, dynamic>.from(responseData['data'] as Map),
      );
    }

    throw ServerException(
      message: responseData['messageAr']?.toString() ?? 'Failed to add review',
    );
  }

  Future<ProductReviewModel> updateReview({
    required String productId,
    required String reviewId,
    required int rating,
    String? title,
    String? comment,
    List<String>? images,
  }) async {
    final response = await _support.apiClient.put(
      ApiEndpoints.productReviewUpdate(productId, reviewId),
      data: {
        'rating': rating,
        if (title != null) 'title': title,
        if (comment != null) 'comment': comment,
        if (images != null && images.isNotEmpty) 'images': images,
      },
    );

    final responseData = Map<String, dynamic>.from(response.data);
    final success =
        responseData['success'] == true || responseData['statusCode'] == 200;

    if (success) {
      return ProductReviewModel.fromJson(
        Map<String, dynamic>.from(responseData['data'] as Map),
      );
    }

    throw ServerException(
      message:
          responseData['messageAr']?.toString() ?? 'Failed to update review',
    );
  }
}
