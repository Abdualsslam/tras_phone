/// API Client wrapper using Dio
library;

import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../errors/exceptions.dart';
import 'auth_interceptor.dart';
import 'token_manager.dart';

class ApiClient {
  late final Dio _dio;
  TokenManager? _tokenManager;

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: AppConfig.apiTimeout,
        receiveTimeout: AppConfig.apiTimeout,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );
  }

  Dio get dio => _dio;

  /// Get the token manager if initialized
  TokenManager? get tokenManager => _tokenManager;

  /// Initialize with TokenManager and interceptors
  void initialize({
    required TokenManager tokenManager,
    OnLogoutCallback? onLogout,
    bool enableLogging = false,
  }) {
    _tokenManager = tokenManager;

    // Clear existing interceptors
    _dio.interceptors.clear();

    // Add auth interceptor
    _dio.interceptors.add(
      AuthInterceptor(
        dio: _dio,
        tokenManager: tokenManager,
        onLogout: onLogout,
      ),
    );

    // Add logging interceptor in debug mode
    if (enableLogging) {
      _dio.interceptors.add(LoggingInterceptor());
    }
  }

  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  void removeAuthToken() {
    _dio.options.headers.remove('Authorization');
  }

  void setLanguage(String locale) {
    _dio.options.headers['Accept-Language'] = locale;
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Upload file with multipart form data
  Future<Response<T>> uploadFile<T>(
    String path, {
    required String filePath,
    required String fieldName,
    Map<String, dynamic>? additionalData,
    void Function(int, int)? onSendProgress,
  }) async {
    try {
      final formData = FormData.fromMap({
        fieldName: await MultipartFile.fromFile(filePath),
        ...?additionalData,
      });

      return await _dio.post<T>(
        path,
        data: formData,
        onSendProgress: onSendProgress,
        options: Options(contentType: 'multipart/form-data'),
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  AppException _handleDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const TimeoutException();

      case DioExceptionType.connectionError:
        return const NetworkException();

      case DioExceptionType.badResponse:
        return _handleBadResponse(e.response);

      case DioExceptionType.cancel:
        return const UnknownException(message: 'تم إلغاء الطلب');

      default:
        return UnknownException(originalError: e);
    }
  }

  AppException _handleBadResponse(Response? response) {
    if (response == null) {
      return const ServerException(message: 'خطأ في الخادم');
    }

    final statusCode = response.statusCode;
    final data = response.data;
    
    // Extract error message, handling both String and List types
    String extractMessage(dynamic value) {
      if (value is String) return value;
      if (value is List) {
        return value.map((e) => e.toString()).join(', ');
      }
      return value?.toString() ?? 'خطأ في الخادم';
    }
    
    final String message = data is Map
        ? extractMessage(data['messageAr'] ?? data['message'] ?? 'خطأ في الخادم')
        : 'خطأ في الخادم';

    switch (statusCode) {
      case 400:
        return ServerException(message: message, statusCode: 400);
      case 401:
        return UnauthorizedException(message: message);
      case 403:
        return ForbiddenException(message: message);
      case 404:
        return NotFoundException(message: message);
      case 422:
        final errors = data is Map
            ? (data['errors'] as Map<String, dynamic>?)?.map(
                (key, value) => MapEntry(key, List<String>.from(value)),
              )
            : null;
        return ValidationException(message: message, errors: errors);
      case 500:
      case 502:
      case 503:
        return const ServerException(
          message: 'خطأ في الخادم، يرجى المحاولة لاحقاً',
        );
      default:
        return ServerException(message: message, statusCode: statusCode);
    }
  }
}
