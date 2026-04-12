part of 'education_remote_datasource.dart';

class _EducationRemoteSupport {
  final ApiClient apiClient;

  const _EducationRemoteSupport({required this.apiClient});

  void log(String message, {Object? error}) {
    developer.log(
      message,
      name: 'EducationDataSource',
      error: error,
    );
  }

  dynamic extractPayload(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data['data'] ?? data;
    }
    return data;
  }

  List<dynamic> extractList(dynamic data) {
    final payload = extractPayload(data);
    return payload is List ? payload : const <dynamic>[];
  }

  List<EducationalCategoryEntity> parseCategories(dynamic data) {
    return extractList(data)
        .map((json) => EducationalCategoryModel.fromJson(json).toEntity())
        .toList();
  }

  List<EducationalContentEntity> parseContent(dynamic data) {
    return extractList(data)
        .map((json) => EducationalContentModel.fromJson(json).toEntity())
        .toList();
  }

  Map<String, dynamic> normalizeContentResponse(
    dynamic responseData, {
    required int page,
    required int limit,
  }) {
    if (responseData is Map && responseData.containsKey('data')) {
      final content = parseContent(responseData);
      final rootPagination = responseData['pagination'];
      final rootMeta = responseData['meta'];
      final metaPagination = rootMeta is Map ? rootMeta['pagination'] : null;
      final pagination = rootPagination is Map
          ? Map<String, dynamic>.from(rootPagination)
          : metaPagination is Map
          ? Map<String, dynamic>.from(metaPagination)
          : <String, dynamic>{};

      final total =
          (pagination['total'] as num?)?.toInt() ??
          (responseData['total'] as num?)?.toInt() ??
          content.length;
      final pages =
          (pagination['pages'] as num?)?.toInt() ??
          (pagination['totalPages'] as num?)?.toInt() ??
          (total / limit).ceil().clamp(1, 1000000);

      return {
        'content': content,
        'pagination': {
          'page': (pagination['page'] as num?)?.toInt() ?? page,
          'limit': (pagination['limit'] as num?)?.toInt() ?? limit,
          'total': total,
          'pages': pages,
        },
      };
    }

    final content = parseContent(responseData);
    return {
      'content': content,
      'pagination': {
        'page': page,
        'limit': limit,
        'total': content.length,
        'pages': (content.length / limit).ceil(),
      },
    };
  }

  String contentTypeToString(ContentType type) => type.value;
}
