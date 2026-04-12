part of 'auth_interceptor.dart';

/// Logging interceptor for debugging API calls
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final requestTarget = options.queryParameters.isNotEmpty
        ? options.uri.toString()
        : options.path;
    developer.log('→ ${options.method} $requestTarget', name: 'API');
    if (options.data != null) {
      developer.log('Request data: ${options.data}', name: 'API');
    }
    handler.next(options);
  }

  static bool _isListEndpoint(String path) {
    final normalizedPath = path.split('?').first;
    if (normalizedPath == ApiEndpoints.products ||
        normalizedPath == ApiEndpoints.productsFeatured ||
        normalizedPath == ApiEndpoints.productsNewArrivals ||
        normalizedPath == ApiEndpoints.productsBestSellers ||
        normalizedPath == ApiEndpoints.productsOnOffer ||
        normalizedPath == ApiEndpoints.categories ||
        normalizedPath == ApiEndpoints.categoriesTree ||
        normalizedPath == ApiEndpoints.brands) {
      return true;
    }
    return normalizedPath.endsWith('/products') &&
        normalizedPath != ApiEndpoints.products;
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    developer.log(
      '← ${response.statusCode} ${response.requestOptions.path}',
      name: 'API',
    );

    final data = response.data;
    if (data != null) {
      final path = response.requestOptions.path;
      if (_isListEndpoint(path)) {
        final list = data is Map ? data['data'] ?? data : data;
        final count = list is List ? list.length : 0;
        try {
          developer.log(
            'Response: list of $count items:\n${_prettyJson(data)}',
            name: 'API',
          );
        } catch (_) {
          developer.log(
            'Response: list of $count items (body not printed)',
            name: 'API',
          );
        }
      } else {
        try {
          final toPrint = data is Map
              ? data
              : data is List
              ? {'data': data}
              : {'raw': data};
          developer.log('Response data:\n${_prettyJson(toPrint)}', name: 'API');
        } catch (_) {
          developer.log('Response data: $data', name: 'API');
        }
      }
    }

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final statusCode = err.response?.statusCode ?? 'ERROR';
    final path = err.requestOptions.path;
    developer.log('✗ $statusCode $path', name: 'API', level: 900);

    if (err.response?.data != null) {
      final errorData = err.response!.data;
      if (errorData is Map) {
        final messageValue = errorData['messageAr'] ?? errorData['message'];
        final errorMessage = messageValue is String
            ? messageValue
            : messageValue is List
            ? messageValue.map((item) => item.toString()).join(', ')
            : errorData.toString();
        developer.log('Error message: $errorMessage', name: 'API', level: 900);
      } else {
        developer.log('Error response: $errorData', name: 'API', level: 900);
      }
    } else {
      developer.log(
        'Error: ${err.message ?? 'Unknown error'}',
        name: 'API',
        level: 900,
        error: err,
      );
    }

    handler.next(err);
  }

  static String _prettyJson(dynamic object) {
    const encoder = JsonEncoder.withIndent('  ');
    try {
      return encoder.convert(object);
    } catch (_) {
      return object.toString();
    }
  }
}
