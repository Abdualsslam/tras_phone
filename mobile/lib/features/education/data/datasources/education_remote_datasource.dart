/// Education Remote DataSource
library;

import 'dart:developer' as developer;
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../domain/entities/educational_category_entity.dart';
import '../../domain/entities/educational_content_entity.dart';
import '../models/educational_category_model.dart';
import '../models/educational_content_model.dart';

/// Abstract interface for education data source
abstract class EducationRemoteDataSource {
  // Categories
  Future<List<EducationalCategoryEntity>> getCategories({bool? activeOnly});
  Future<EducationalCategoryEntity?> getCategoryBySlug(String slug);

  // Content
  Future<Map<String, dynamic>> getContent({
    String? categoryId,
    ContentType? type,
    String? status,
    bool? featured,
    String? search,
    int page,
    int limit,
  });

  Future<EducationalContentEntity?> getContentBySlug(String slug);
  Future<EducationalContentEntity?> getContentById(String id);
  Future<Map<String, dynamic>> getProductEducationalContent({
    required String productId,
    int page,
    int limit,
  });
  Future<List<EducationalContentEntity>> getFeaturedContent({int? limit});
  Future<List<EducationalContentEntity>> getContentByCategory(
    String categorySlug, {
    int? limit,
  });

  // Interactions
  Future<void> likeContent(String id);
  Future<void> shareContent(String id);
}

/// Implementation of EducationRemoteDataSource
class EducationRemoteDataSourceImpl implements EducationRemoteDataSource {
  final ApiClient _apiClient;

  EducationRemoteDataSourceImpl({required ApiClient apiClient})
    : _apiClient = apiClient;

  @override
  Future<List<EducationalCategoryEntity>> getCategories({
    bool? activeOnly,
  }) async {
    developer.log(
      'Fetching educational categories (activeOnly: $activeOnly)',
      name: 'EducationDataSource',
    );

    final response = await _apiClient.get(
      ApiEndpoints.educationCategories,
      queryParameters: activeOnly != null ? {'activeOnly': activeOnly} : null,
    );

    final data = response.data['data'] ?? response.data;
    final List<dynamic> list = data is List ? data : [];

    return list
        .map((json) => EducationalCategoryModel.fromJson(json).toEntity())
        .toList();
  }

  @override
  Future<EducationalCategoryEntity?> getCategoryBySlug(String slug) async {
    developer.log(
      'Fetching educational category: $slug',
      name: 'EducationDataSource',
    );

    try {
      final response = await _apiClient.get(
        '${ApiEndpoints.educationCategories}/$slug',
      );
      final data = response.data['data'] ?? response.data;
      return EducationalCategoryModel.fromJson(data).toEntity();
    } catch (e) {
      developer.log('Category not found: $slug', name: 'EducationDataSource');
      return null;
    }
  }

  @override
  Future<Map<String, dynamic>> getContent({
    String? categoryId,
    ContentType? type,
    String? status,
    bool? featured,
    String? search,
    int page = 1,
    int limit = 20,
  }) async {
    developer.log(
      'Fetching educational content (page: $page)',
      name: 'EducationDataSource',
    );

    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
      if (categoryId != null) 'categoryId': categoryId,
      if (type != null) 'type': _contentTypeToString(type),
      if (status != null) 'status': status,
      if (featured != null) 'featured': featured,
      if (search != null && search.isNotEmpty) 'search': search,
    };

    try {
      final response = await _apiClient.get(
        ApiEndpoints.educationContent,
        queryParameters: queryParams,
      );

      final responseData = response.data;

      // Handle paginated response (from documentation: response.data['data'] and response.data['pagination'])
      if (responseData is Map && responseData.containsKey('data')) {
        final List<dynamic> list = responseData['data'] ?? [];
        final contentList = list
            .map((json) => EducationalContentModel.fromJson(json).toEntity())
            .toList();

        // Extract pagination info
        final pagination = responseData['pagination'] as Map<String, dynamic>?;

        return {
          'content': contentList,
          'pagination':
              pagination ??
              {
                'page': page,
                'limit': limit,
                'total': responseData['total'] ?? contentList.length,
                'pages': (responseData['total'] ?? contentList.length / limit)
                    .ceil(),
              },
        };
      } else {
        // Handle simple list response
        final List<dynamic> list = responseData is List ? responseData : [];
        final contentList = list
            .map((json) => EducationalContentModel.fromJson(json).toEntity())
            .toList();

        return {
          'content': contentList,
          'pagination': {
            'page': page,
            'limit': limit,
            'total': contentList.length,
            'pages': (contentList.length / limit).ceil(),
          },
        };
      }
    } catch (e) {
      developer.log(
        'Error fetching educational content: $e',
        name: 'EducationDataSource',
        error: e,
      );
      rethrow;
    }
  }

  @override
  Future<EducationalContentEntity?> getContentBySlug(String slug) async {
    developer.log(
      'Fetching educational content: $slug',
      name: 'EducationDataSource',
    );

    try {
      final response = await _apiClient.get(
        '${ApiEndpoints.educationContent}/$slug',
      );
      final data = response.data['data'] ?? response.data;
      return EducationalContentModel.fromJson(data).toEntity();
    } catch (e) {
      developer.log('Content not found: $slug', name: 'EducationDataSource');
      return null;
    }
  }

  @override
  Future<EducationalContentEntity?> getContentById(String id) async {
    developer.log(
      'Fetching educational content by ID: $id',
      name: 'EducationDataSource',
    );

    try {
      final response = await _apiClient.get(
        '${ApiEndpoints.educationContent}/$id',
      );
      final data = response.data['data'] ?? response.data;
      return EducationalContentModel.fromJson(data).toEntity();
    } catch (e) {
      developer.log('Content not found: $id', name: 'EducationDataSource');
      return null;
    }
  }

  @override
  Future<Map<String, dynamic>> getProductEducationalContent({
    required String productId,
    int page = 1,
    int limit = 20,
  }) async {
    developer.log(
      'Fetching product educational content (productId: $productId, page: $page)',
      name: 'EducationDataSource',
    );

    try {
      final response = await _apiClient.get(
        ApiEndpoints.productEducationalContent(productId),
        queryParameters: {'page': page, 'limit': limit},
      );

      final responseData = response.data;
      final Map<String, dynamic> normalized =
          responseData is Map<String, dynamic>
          ? responseData
          : <String, dynamic>{};

      final rawList = normalized['data'];
      final List<dynamic> list = rawList is List ? rawList : <dynamic>[];
      final contentList = list
          .map((json) => EducationalContentModel.fromJson(json).toEntity())
          .toList();

      final rawPagination = normalized['pagination'];
      final pagination = rawPagination is Map<String, dynamic>
          ? rawPagination
          : <String, dynamic>{};

      final total =
          (pagination['total'] as num?)?.toInt() ??
          (normalized['total'] as num?)?.toInt() ??
          contentList.length;
      final pages =
          (pagination['pages'] as num?)?.toInt() ??
          (total / limit).ceil().clamp(1, 1000000);

      return {
        'content': contentList,
        'pagination': {
          'page': (pagination['page'] as num?)?.toInt() ?? page,
          'limit': (pagination['limit'] as num?)?.toInt() ?? limit,
          'total': total,
          'pages': pages,
        },
      };
    } catch (e) {
      developer.log(
        'Error fetching product educational content: $e',
        name: 'EducationDataSource',
        error: e,
      );
      rethrow;
    }
  }

  @override
  Future<List<EducationalContentEntity>> getFeaturedContent({
    int? limit,
  }) async {
    developer.log(
      'Fetching featured educational content',
      name: 'EducationDataSource',
    );

    final response = await _apiClient.get(
      '${ApiEndpoints.educationContent}/featured',
      queryParameters: limit != null ? {'limit': limit} : null,
    );

    final data = response.data['data'] ?? response.data;
    final List<dynamic> list = data is List ? data : [];

    return list
        .map((json) => EducationalContentModel.fromJson(json).toEntity())
        .toList();
  }

  @override
  Future<List<EducationalContentEntity>> getContentByCategory(
    String categorySlug, {
    int? limit,
  }) async {
    developer.log(
      'Fetching educational content by category: $categorySlug',
      name: 'EducationDataSource',
    );

    final response = await _apiClient.get(
      '${ApiEndpoints.educationContent}/category/$categorySlug',
      queryParameters: limit != null ? {'limit': limit} : null,
    );

    final data = response.data['data'] ?? response.data;
    final List<dynamic> list = data is List ? data : [];

    return list
        .map((json) => EducationalContentModel.fromJson(json).toEntity())
        .toList();
  }

  @override
  Future<void> likeContent(String id) async {
    developer.log(
      'Liking educational content: $id',
      name: 'EducationDataSource',
    );

    await _apiClient.post('${ApiEndpoints.educationContent}/$id/like');
  }

  @override
  Future<void> shareContent(String id) async {
    developer.log(
      'Sharing educational content: $id',
      name: 'EducationDataSource',
    );

    await _apiClient.post('${ApiEndpoints.educationContent}/$id/share');
  }

  // Helper method to convert ContentType enum to string
  String _contentTypeToString(ContentType type) {
    return type.value;
  }
}
