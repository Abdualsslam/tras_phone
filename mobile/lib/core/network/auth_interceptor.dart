/// Auth Interceptor - Handles automatic token injection and refresh
library;

import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import '../constants/api_endpoints.dart';
import 'token_manager.dart';

/// Callback for handling logout when refresh fails
typedef OnLogoutCallback = Future<void> Function();

/// Interceptor that handles authentication headers and token refresh
class AuthInterceptor extends Interceptor {
  final Dio _dio;
  final TokenManager _tokenManager;
  final OnLogoutCallback? _onLogout;

  bool _isRefreshing = false;
  final List<RequestOptions> _pendingRequests = [];

  AuthInterceptor({
    required Dio dio,
    required TokenManager tokenManager,
    OnLogoutCallback? onLogout,
  }) : _dio = dio,
       _tokenManager = tokenManager,
       _onLogout = onLogout;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip auth header for public endpoints
    if (_isPublicEndpoint(options.path)) {
      return handler.next(options);
    }

    // Add auth token if available
    final token = await _tokenManager.getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Handle 401 Unauthorized - attempt token refresh
    if (err.response?.statusCode == 401) {
      final requestOptions = err.requestOptions;

      // Don't retry refresh token endpoint
      if (requestOptions.path.contains(ApiEndpoints.refreshToken)) {
        await _handleLogout();
        return handler.next(err);
      }

      // Try to refresh token
      if (!_isRefreshing) {
        _isRefreshing = true;

        try {
          final refreshed = await _refreshToken();
          _isRefreshing = false;

          if (refreshed) {
            // Retry original request
            final response = await _retryRequest(requestOptions);
            return handler.resolve(response);
          } else {
            await _handleLogout();
          }
        } catch (e) {
          _isRefreshing = false;
          await _handleLogout();
          developer.log(
            'Token refresh failed',
            name: 'AuthInterceptor',
            error: e,
          );
        }
      } else {
        // Wait for refresh to complete then retry
        _pendingRequests.add(requestOptions);
      }
    }

    return handler.next(err);
  }

  /// Check if endpoint is public (no auth required)
  bool _isPublicEndpoint(String path) {
    const publicEndpoints = [
      ApiEndpoints.login,
      ApiEndpoints.register,
      ApiEndpoints.sendOtp,
      ApiEndpoints.verifyOtp,
      ApiEndpoints.forgotPassword,
      ApiEndpoints.resetPassword,
      ApiEndpoints.brands,
      ApiEndpoints.categories,
      ApiEndpoints.products,
      ApiEndpoints.banners,
      ApiEndpoints.faqs,
      ApiEndpoints.settings,
      ApiEndpoints.appVersion,
    ];

    return publicEndpoints.any((endpoint) => path.contains(endpoint));
  }

  /// Attempt to refresh the access token
  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _tokenManager.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        return false;
      }

      final response = await _dio.post(
        ApiEndpoints.refreshToken,
        data: {'refreshToken': refreshToken},
        options: Options(headers: {'Authorization': 'Bearer $refreshToken'}),
      );

      if (response.statusCode == 200 && response.data != null) {
        await _tokenManager.saveTokensFromResponse(response.data);

        // Retry pending requests
        await _retryPendingRequests();

        developer.log('Token refreshed successfully', name: 'AuthInterceptor');
        return true;
      }

      return false;
    } catch (e) {
      developer.log(
        'Failed to refresh token',
        name: 'AuthInterceptor',
        error: e,
      );
      return false;
    }
  }

  /// Retry a request with new token
  Future<Response<dynamic>> _retryRequest(RequestOptions requestOptions) async {
    final token = await _tokenManager.getAccessToken();
    requestOptions.headers['Authorization'] = 'Bearer $token';

    return await _dio.fetch(requestOptions);
  }

  /// Retry all pending requests after successful refresh
  Future<void> _retryPendingRequests() async {
    final requests = List<RequestOptions>.from(_pendingRequests);
    _pendingRequests.clear();

    for (final request in requests) {
      try {
        await _retryRequest(request);
      } catch (e) {
        developer.log(
          'Failed to retry request: ${request.path}',
          name: 'AuthInterceptor',
          error: e,
        );
      }
    }
  }

  /// Handle logout when refresh fails
  Future<void> _handleLogout() async {
    await _tokenManager.clearTokens();
    _pendingRequests.clear();
    _isRefreshing = false;

    if (_onLogout != null) {
      await _onLogout();
    }
  }
}

/// Logging interceptor for debugging API calls
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    developer.log('→ ${options.method} ${options.path}', name: 'API');
    if (options.data != null) {
      developer.log('Request data: ${options.data}', name: 'API');
    }
    return handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    developer.log(
      '← ${response.statusCode} ${response.requestOptions.path}',
      name: 'API',
    );
    return handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final statusCode = err.response?.statusCode ?? 'ERROR';
    final path = err.requestOptions.path;

    developer.log('✗ $statusCode $path', name: 'API', level: 900);

    // Log error response body if available
    if (err.response != null && err.response!.data != null) {
      final errorData = err.response!.data;
      if (errorData is Map) {
        // Extract error message, handling both String and List types
        dynamic messageValue = errorData['messageAr'] ?? errorData['message'];
        String errorMessage;
        if (messageValue is String) {
          errorMessage = messageValue;
        } else if (messageValue is List) {
          errorMessage = messageValue.map((e) => e.toString()).join(', ');
        } else {
          errorMessage = errorData.toString();
        }
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

    return handler.next(err);
  }
}
