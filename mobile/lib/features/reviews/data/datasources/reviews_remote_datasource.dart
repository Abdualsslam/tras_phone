/// Reviews Remote DataSource - Real API implementation
library;

import 'dart:developer' as developer;
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../models/review_model.dart';

/// Abstract interface for reviews data source
abstract class ReviewsRemoteDataSource {
  // Product Reviews
  Future<List<ReviewModel>> getProductReviews(
    int productId, {
    int page = 1,
    int limit = 20,
    String? sortBy,
    int? filterRating,
  });
  Future<ProductRatingSummary> getProductRatingSummary(int productId);

  // My Reviews
  Future<List<ReviewModel>> getMyReviews({int page = 1, int limit = 20});
  Future<List<PendingReviewModel>> getPendingReviews();
  Future<ReviewModel> createReview(CreateReviewRequest request);
  Future<ReviewModel> updateReview(int id, CreateReviewRequest request);
  Future<bool> deleteReview(int id);

  // Interactions
  Future<bool> markHelpful(int reviewId);
  Future<bool> reportReview(int reviewId, String reason);

  // Images
  Future<List<String>> uploadReviewImages(List<String> imagePaths);
}

/// Implementation of ReviewsRemoteDataSource using API client
class ReviewsRemoteDataSourceImpl implements ReviewsRemoteDataSource {
  final ApiClient _apiClient;

  ReviewsRemoteDataSourceImpl({required ApiClient apiClient})
    : _apiClient = apiClient;

  @override
  Future<List<ReviewModel>> getProductReviews(
    int productId, {
    int page = 1,
    int limit = 20,
    String? sortBy,
    int? filterRating,
  }) async {
    developer.log(
      'Fetching reviews for product: $productId',
      name: 'ReviewsDataSource',
    );

    final response = await _apiClient.get(
      '${ApiEndpoints.products}/$productId/reviews',
      queryParameters: {
        'page': page,
        'limit': limit,
        if (sortBy != null) 'sort_by': sortBy,
        if (filterRating != null) 'rating': filterRating,
      },
    );

    final data = response.data['data'] ?? response.data;
    final List<dynamic> list = data is List ? data : [];

    return list.map((json) => ReviewModel.fromJson(json)).toList();
  }

  @override
  Future<ProductRatingSummary> getProductRatingSummary(int productId) async {
    developer.log(
      'Fetching rating summary for product: $productId',
      name: 'ReviewsDataSource',
    );

    final response = await _apiClient.get(
      '${ApiEndpoints.products}/$productId/rating',
    );

    final data = response.data['data'] ?? response.data;
    return ProductRatingSummary.fromJson(data);
  }

  @override
  Future<List<ReviewModel>> getMyReviews({int page = 1, int limit = 20}) async {
    developer.log('Fetching my reviews', name: 'ReviewsDataSource');

    final response = await _apiClient.get(
      ApiEndpoints.myReviews,
      queryParameters: {'page': page, 'limit': limit},
    );

    final data = response.data['data'] ?? response.data;
    final List<dynamic> list = data is List ? data : [];

    return list.map((json) => ReviewModel.fromJson(json)).toList();
  }

  @override
  Future<List<PendingReviewModel>> getPendingReviews() async {
    developer.log('Fetching pending reviews', name: 'ReviewsDataSource');

    final response = await _apiClient.get(ApiEndpoints.pendingReviews);
    final data = response.data['data'] ?? response.data;
    final List<dynamic> list = data is List ? data : [];

    return list.map((json) => PendingReviewModel.fromJson(json)).toList();
  }

  @override
  Future<ReviewModel> createReview(CreateReviewRequest request) async {
    developer.log(
      'Creating review for product: ${request.productId}',
      name: 'ReviewsDataSource',
    );

    final response = await _apiClient.post(
      ApiEndpoints.reviews,
      data: request.toJson(),
    );

    final data = response.data['data'] ?? response.data;
    return ReviewModel.fromJson(data);
  }

  @override
  Future<ReviewModel> updateReview(int id, CreateReviewRequest request) async {
    developer.log('Updating review: $id', name: 'ReviewsDataSource');

    final response = await _apiClient.put(
      '${ApiEndpoints.reviews}/$id',
      data: request.toJson(),
    );

    final data = response.data['data'] ?? response.data;
    return ReviewModel.fromJson(data);
  }

  @override
  Future<bool> deleteReview(int id) async {
    developer.log('Deleting review: $id', name: 'ReviewsDataSource');

    final response = await _apiClient.delete('${ApiEndpoints.reviews}/$id');
    return response.statusCode == 200;
  }

  @override
  Future<bool> markHelpful(int reviewId) async {
    developer.log(
      'Marking review as helpful: $reviewId',
      name: 'ReviewsDataSource',
    );

    final response = await _apiClient.post(
      '${ApiEndpoints.reviews}/$reviewId/helpful',
    );

    return response.statusCode == 200;
  }

  @override
  Future<bool> reportReview(int reviewId, String reason) async {
    developer.log('Reporting review: $reviewId', name: 'ReviewsDataSource');

    final response = await _apiClient.post(
      '${ApiEndpoints.reviews}/$reviewId/report',
      data: {'reason': reason},
    );

    return response.statusCode == 200;
  }

  @override
  Future<List<String>> uploadReviewImages(List<String> imagePaths) async {
    developer.log('Uploading review images', name: 'ReviewsDataSource');

    final uploadedUrls = <String>[];
    for (final path in imagePaths) {
      final response = await _apiClient.uploadFile(
        '${ApiEndpoints.reviews}/upload-image',
        filePath: path,
        fieldName: 'image',
      );

      final url = response.data['data']?['url'] ?? response.data['url'];
      if (url != null) uploadedUrls.add(url);
    }

    return uploadedUrls;
  }
}
