part of 'education_remote_datasource.dart';

class _EducationContentRemote {
  final _EducationRemoteSupport _support;

  const _EducationContentRemote(this._support);

  Future<Map<String, dynamic>> getContent({
    String? categoryId,
    ContentType? type,
    String? status,
    bool? featured,
    String? search,
    required int page,
    required int limit,
  }) async {
    _support.log('Fetching educational content (page: $page)');

    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
      if (categoryId != null) 'categoryId': categoryId,
      if (type != null) 'type': _support.contentTypeToString(type),
      if (status != null) 'status': status,
      if (featured != null) 'featured': featured,
      if (search != null && search.isNotEmpty) 'search': search,
    };

    try {
      final response = await _support.apiClient.get(
        ApiEndpoints.educationContent,
        queryParameters: queryParams,
      );
      return _support.normalizeContentResponse(
        response.data,
        page: page,
        limit: limit,
      );
    } catch (error) {
      _support.log('Error fetching educational content: $error', error: error);
      rethrow;
    }
  }

  Future<EducationalContentEntity?> getContentBySlug(String slug) async {
    _support.log('Fetching educational content: $slug');
    return _getSingleContent('${ApiEndpoints.educationContent}/$slug', slug);
  }

  Future<EducationalContentEntity?> getContentById(String id) async {
    _support.log('Fetching educational content by ID: $id');
    return _getSingleContent('${ApiEndpoints.educationContent}/$id', id);
  }

  Future<Map<String, dynamic>> getProductEducationalContent({
    required String productId,
    required int page,
    required int limit,
  }) async {
    _support.log(
      'Fetching product educational content (productId: $productId, page: $page)',
    );

    try {
      final response = await _support.apiClient.get(
        ApiEndpoints.productEducationalContent(productId),
        queryParameters: {'page': page, 'limit': limit},
      );
      return _support.normalizeContentResponse(
        response.data,
        page: page,
        limit: limit,
      );
    } catch (error) {
      _support.log(
        'Error fetching product educational content: $error',
        error: error,
      );
      rethrow;
    }
  }

  Future<List<EducationalContentEntity>> getFeaturedContent({int? limit}) async {
    _support.log('Fetching featured educational content');

    final response = await _support.apiClient.get(
      '${ApiEndpoints.educationContent}/featured',
      queryParameters: limit != null ? {'limit': limit} : null,
    );

    return _support.parseContent(response.data);
  }

  Future<List<EducationalContentEntity>> getContentByCategory(
    String categorySlug, {
    int? limit,
  }) async {
    _support.log('Fetching educational content by category: $categorySlug');

    final response = await _support.apiClient.get(
      '${ApiEndpoints.educationContent}/category/$categorySlug',
      queryParameters: limit != null ? {'limit': limit} : null,
    );

    return _support.parseContent(response.data);
  }

  Future<EducationalContentEntity?> _getSingleContent(
    String path,
    String identifier,
  ) async {
    try {
      final response = await _support.apiClient.get(path);
      final payload = _support.extractPayload(response.data);
      if (payload is! Map<String, dynamic>) return null;
      return EducationalContentModel.fromJson(payload).toEntity();
    } catch (_) {
      _support.log('Content not found: $identifier');
      return null;
    }
  }
}
