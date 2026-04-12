part of 'catalog_remote_datasource.dart';

class _CatalogRemoteSupport {
  final ApiClient apiClient;

  const _CatalogRemoteSupport({required this.apiClient});

  void log(String message) {
    developer.log(message, name: 'CatalogDataSource');
  }

  void printApiUrl(String endpoint, {Map<String, dynamic>? queryParams}) {
    final uri = Uri.parse('${AppConfig.baseUrl}$endpoint');
    final finalUri = queryParams != null && queryParams.isNotEmpty
        ? uri.replace(
            queryParameters: queryParams.map(
              (key, value) => MapEntry(key, value.toString()),
            ),
          )
        : uri;
    log('API URL: ${finalUri.toString()}');
  }

  dynamic extractPayload(dynamic responseData) {
    if (responseData is Map<String, dynamic>) {
      return responseData['data'] ?? responseData;
    }
    return responseData;
  }

  List<dynamic> extractList(dynamic responseData) {
    final payload = extractPayload(responseData);
    return payload is List ? payload : const [];
  }

  List<String> extractStringList(dynamic responseData) {
    return extractList(responseData).map((item) => item.toString()).toList();
  }

  List<Map<String, dynamic>> extractMapList(dynamic responseData) {
    return extractList(
      responseData,
    ).whereType<Map>().map((item) => Map<String, dynamic>.from(item)).toList();
  }

  int toInt(dynamic value, {int fallback = 0}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
  }

  List<ProductEntity> parseProductsList(
    dynamic data, {
    required String source,
  }) {
    final products = <ProductEntity>[];

    for (final item in extractList(data)) {
      if (item is! Map) continue;
      try {
        products.add(
          ProductModel.fromJson(Map<String, dynamic>.from(item)).toEntity(),
        );
      } catch (error, stackTrace) {
        developer.log(
          'Skipping invalid product payload in $source',
          name: 'CatalogDataSource',
          error: error,
          stackTrace: stackTrace,
        );
      }
    }

    return products;
  }

  List<T> parseEntityList<T>(
    dynamic data,
    T Function(Map<String, dynamic> json) parser,
  ) {
    return extractList(data)
        .whereType<Map>()
        .map((item) => parser(Map<String, dynamic>.from(item)))
        .toList();
  }

  Map<String, dynamic> extractPagination(
    Map<String, dynamic> responseData, {
    required int page,
    required int limit,
    required int fallbackTotal,
  }) {
    final raw = responseData['pagination'] ?? responseData['meta'];

    if (raw is Map) {
      final rawMap = Map<String, dynamic>.from(raw);
      final parsedPage = toInt(rawMap['page'], fallback: page);
      final parsedLimit = toInt(rawMap['limit'], fallback: limit);
      final parsedTotal = toInt(rawMap['total'], fallback: fallbackTotal);
      final parsedPages = toInt(
        rawMap['pages'] ?? rawMap['totalPages'],
        fallback: parsedTotal > 0 ? (parsedTotal / parsedLimit).ceil() : 1,
      );

      return {
        ...rawMap,
        'page': parsedPage,
        'limit': parsedLimit,
        'total': parsedTotal,
        'pages': parsedPages,
      };
    }

    final total = toInt(responseData['total'], fallback: fallbackTotal);
    final pages = total > 0 ? (total / limit).ceil() : 1;

    return {'page': page, 'limit': limit, 'total': total, 'pages': pages};
  }

  ProductsResponse parseProductsResponse(
    dynamic responseData, {
    required int page,
    required int limit,
    required String failureMessage,
  }) {
    if (responseData is Map<String, dynamic>) {
      final isSuccess =
          responseData['success'] == true ||
          responseData['status'] == 'success' ||
          responseData['statusCode'] == 200;

      if (isSuccess || responseData.containsKey('data')) {
        return ProductsResponse.fromJson(responseData);
      }

      throw Exception(responseData['messageAr'] ?? failureMessage);
    }

    if (responseData is List) {
      return ProductsResponse.fromJson({
        'data': responseData,
        'meta': {
          'page': page,
          'limit': limit,
          'total': responseData.length,
          'pages': 1,
        },
      });
    }

    throw Exception(failureMessage);
  }
}
