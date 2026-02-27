/// Auth Interceptor - Handles automatic token injection and refresh
library;

import 'dart:convert';
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
    final hasQuery = options.queryParameters.isNotEmpty;
    final requestTarget = hasQuery ? options.uri.toString() : options.path;

    // Add logging at the very start
    developer.log(
      'onRequest: ${options.method} $requestTarget',
      name: 'AuthInterceptor',
    );

    // Skip if this is a retry request (token already added in _retryRequest)
    if (options.headers['X-Retry-Request'] == 'true') {
      developer.log(
        'Skipping token check - this is a retry request',
        name: 'AuthInterceptor',
      );
      // Ensure token is present
      final authHeader = options.headers['Authorization'];
      if (authHeader == null || !authHeader.toString().startsWith('Bearer ')) {
        // Token missing in retry request - try to add it
        final token = await _tokenManager.getAccessToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
      }
      return handler.next(options);
    }

    // Public endpoints: skip token refresh, but add token when available
    // (e.g. products API returns 'price' per customer tier when token is sent)
    if (_isPublicEndpoint(options.path)) {
      if (_isAuthEntryEndpoint(options.path)) {
        developer.log(
          'Public auth entry endpoint - skipping token attachment',
          name: 'AuthInterceptor',
        );
        return handler.next(options);
      }

      developer.log(
        'Public endpoint - adding token if available (for optional auth e.g. pricing)',
        name: 'AuthInterceptor',
      );
      final token = await _tokenManager.getAccessToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
        developer.log(
          'Added token to public endpoint request',
          name: 'AuthInterceptor',
        );
      }
      return handler.next(options);
    }

    // Check if token needs refresh before sending request
    developer.log(
      'Fetching token data for authenticated endpoint...',
      name: 'AuthInterceptor',
    );

    final tokenData = await _tokenManager.getTokenData();
    if (tokenData != null) {
      final now = DateTime.now();
      developer.log(
        'Token check: expiresAt=${tokenData.expiresAt}, isExpired=${tokenData.isExpired}, willExpireSoon=${tokenData.willExpireSoon}, now=$now',
        name: 'AuthInterceptor',
      );

      // If expiresAt is null, log warning
      if (tokenData.expiresAt == null) {
        developer.log(
          'WARNING: Token expiresAt is null - cannot check expiration! Will rely on backend validation.',
          name: 'AuthInterceptor',
        );
      }

      // Check if token is expired or will expire soon
      if (tokenData.isExpired) {
        developer.log(
          'Token is expired, refreshing before request',
          name: 'AuthInterceptor',
        );
        // Token expired - refresh proactively
        if (!_isRefreshing) {
          _isRefreshing = true;
          try {
            final refreshed = await _refreshToken();
            _isRefreshing = false;

            if (!refreshed) {
              developer.log(
                'Failed to refresh expired token',
                name: 'AuthInterceptor',
              );
              await _handleLogout();
              return handler.reject(
                DioException(
                  requestOptions: options,
                  error: 'Token expired and refresh failed',
                  type: DioExceptionType.badResponse,
                  response: Response(requestOptions: options, statusCode: 401),
                ),
              );
            }

            // After successful refresh, get the new token
            developer.log(
              'Token refreshed successfully, using new token for request',
              name: 'AuthInterceptor',
            );
          } catch (e) {
            _isRefreshing = false;
            developer.log(
              'Error refreshing expired token: $e',
              name: 'AuthInterceptor',
              error: e,
            );
            await _handleLogout();
            return handler.reject(
              DioException(
                requestOptions: options,
                error: 'Token refresh error: $e',
                type: DioExceptionType.unknown,
              ),
            );
          }
        } else {
          // Wait for ongoing refresh - add to pending requests
          developer.log(
            'Token expired but refresh in progress - adding to pending requests',
            name: 'AuthInterceptor',
          );
          _pendingRequests.add(options);
          // Don't send request yet - it will be retried after refresh completes
          return;
        }
      } else if (tokenData.willExpireSoon) {
        developer.log(
          'Token will expire soon (${tokenData.expiresAt?.difference(now).inMinutes} minutes), refreshing proactively in background',
          name: 'AuthInterceptor',
        );
        // Token will expire soon - refresh in background (don't wait)
        if (!_isRefreshing) {
          _isRefreshing = true;
          _refreshToken()
              .then((_) {
                _isRefreshing = false;
                developer.log(
                  'Background token refresh completed',
                  name: 'AuthInterceptor',
                );
              })
              .catchError((e) {
                _isRefreshing = false;
                developer.log(
                  'Background token refresh failed: $e',
                  name: 'AuthInterceptor',
                  error: e,
                );
              });
        }
      } else {
        final minutesUntilExpiry = tokenData.expiresAt
            ?.difference(now)
            .inMinutes;
        developer.log(
          'Token is valid, expires in ${minutesUntilExpiry ?? "unknown"} minutes',
          name: 'AuthInterceptor',
        );
      }
    } else {
      developer.log(
        'CRITICAL: No token data available! Request may fail.',
        name: 'AuthInterceptor',
      );
    }

    // Add auth token if available (will be new token if refresh happened above)
    final token = await _tokenManager.getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
      developer.log('Added token to request headers', name: 'AuthInterceptor');
    } else {
      developer.log(
        'WARNING: No token available for request',
        name: 'AuthInterceptor',
      );
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

      // Login/register/password-reset endpoints should return their original
      // 401 message (e.g. invalid credentials) without token refresh/retry.
      if (_isAuthEntryEndpoint(requestOptions.path)) {
        developer.log(
          '401 on auth entry endpoint - skipping token refresh/retry',
          name: 'AuthInterceptor',
        );
        return handler.next(err);
      }

      // Don't retry if this is already a retry request (prevent infinite loop)
      if (requestOptions.headers['X-Retry-Request'] == 'true') {
        // Don't logout here - just pass the error
        developer.log(
          'Retry request failed, not clearing tokens',
          name: 'AuthInterceptor',
        );
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
            try {
              final response = await _retryRequest(requestOptions);
              return handler.resolve(response);
            } on DioException catch (retryError) {
              // If retry returns 401 again, token refresh didn't work properly
              if (retryError.response?.statusCode == 401) {
                developer.log(
                  'Retry still returned 401 after refresh - clearing tokens',
                  name: 'AuthInterceptor',
                  error: retryError,
                );
                await _handleLogout();
                return handler.next(retryError);
              }
              // For other errors (like 409 Conflict), just pass them through
              developer.log(
                'Retry returned error: ${retryError.response?.statusCode}',
                name: 'AuthInterceptor',
                error: retryError,
              );
              return handler.next(retryError);
            } catch (retryError) {
              // Unexpected error during retry
              developer.log(
                'Failed to retry request: ${requestOptions.path}',
                name: 'AuthInterceptor',
                error: retryError,
              );
              return handler.next(
                DioException(
                  requestOptions: requestOptions,
                  error: retryError,
                  type: DioExceptionType.unknown,
                ),
              );
            }
          } else {
            // Refresh failed - clear tokens and logout
            await _handleLogout();
          }
        } catch (e) {
          _isRefreshing = false;
          // Only logout if refresh itself failed
          developer.log(
            'Token refresh failed',
            name: 'AuthInterceptor',
            error: e,
          );
          await _handleLogout();
        }
      } else {
        // Wait for refresh to complete then retry
        _pendingRequests.add(requestOptions);
      }
    }

    return handler.next(err);
  }

  /// Endpoints used before authentication.
  /// A 401 from these endpoints should be returned directly to the UI.
  bool _isAuthEntryEndpoint(String path) {
    final basePath = path.split('?').first;
    const authEntryEndpoints = [
      ApiEndpoints.login,
      ApiEndpoints.register,
      ApiEndpoints.sendOtp,
      ApiEndpoints.verifyOtp,
      ApiEndpoints.forgotPassword,
      ApiEndpoints.requestPasswordReset,
      ApiEndpoints.verifyResetOtp,
      ApiEndpoints.resetPassword,
    ];

    return authEntryEndpoints.contains(basePath);
  }

  /// Check if endpoint is public (no auth required)
  bool _isPublicEndpoint(String path) {
    // Extract base path (remove query parameters)
    final basePath = path.split('?').first;

    // Exact match endpoints (public)
    const exactPublicEndpoints = [
      ApiEndpoints.login,
      ApiEndpoints.register,
      ApiEndpoints.sendOtp,
      ApiEndpoints.verifyOtp,
      ApiEndpoints.forgotPassword,
      ApiEndpoints.resetPassword,
      ApiEndpoints.refreshToken,
      ApiEndpoints.brands,
      ApiEndpoints.categories,
      ApiEndpoints.products,
      ApiEndpoints.banners,
      ApiEndpoints.faqs,
      ApiEndpoints.settings,
      ApiEndpoints.appVersion,
    ];

    // Check exact matches
    if (exactPublicEndpoints.any((endpoint) => basePath == endpoint)) {
      return true;
    }

    // Public GET endpoints (read-only operations)
    // /products/:id - GET product details (public)
    // /products/:id/reviews - GET reviews (public)
    if (basePath.startsWith('/products/') &&
        (basePath.endsWith('/reviews') ||
            RegExp(r'^/products/[^/]+$').hasMatch(basePath))) {
      return true;
    }

    // Private endpoints (require authentication)
    // /products/:id/favorite - POST/DELETE favorite (private)
    // /products/favorite/my - GET my favorites (private)
    if (basePath.contains('/favorite') ||
        basePath.contains('/cart') ||
        basePath.contains('/orders') ||
        basePath.contains('/customer/') ||
        basePath.contains('/tickets') ||
        basePath.contains('/stock-alerts')) {
      return false;
    }

    // Default: check if path starts with known public endpoints
    const prefixPublicEndpoints = [
      '/auth/',
      '/catalog/',
      '/products/featured',
      '/products/new-arrivals',
      '/products/best-sellers',
      '/products/on-offer',
      '/products/search',
    ];

    return prefixPublicEndpoints.any((prefix) => basePath.startsWith(prefix));
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

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.data != null) {
        developer.log(
          'Refresh response: ${response.data}',
          name: 'AuthInterceptor',
        );
        await _tokenManager.saveTokensFromResponse(response.data);

        // Verify token was saved correctly
        final savedToken = await _tokenManager.getAccessToken();
        developer.log(
          'Verified saved token: ${savedToken?.substring(0, 30)}...',
          name: 'AuthInterceptor',
        );

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
    if (token == null || token.isEmpty) {
      throw DioException(
        requestOptions: requestOptions,
        error: 'Access token not found after refresh',
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: requestOptions,
          statusCode: 401,
          statusMessage: 'Access token not found',
        ),
      );
    }

    developer.log('Retrying ${requestOptions.path}', name: 'AuthInterceptor');
    developer.log(
      'Full token for retry: ${token.substring(0, 30)}...',
      name: 'AuthInterceptor',
    );

    // Extract relative path (remove base URL if present)
    String relativePath = requestOptions.path;
    final baseUrl = _dio.options.baseUrl;
    if (baseUrl.isNotEmpty && relativePath.startsWith(baseUrl)) {
      relativePath = relativePath.substring(baseUrl.length);
    }
    // Ensure path starts with / (Dio expects it)
    if (!relativePath.startsWith('/')) {
      relativePath = '/$relativePath';
    }

    // Create new options to avoid modifying the original
    final newOptions = Options(
      method: requestOptions.method,
      headers: {
        ...requestOptions.headers,
        'Authorization': 'Bearer $token',
        'X-Retry-Request': 'true', // Mark as retry to prevent infinite loop
      },
      contentType: requestOptions.contentType,
      responseType: requestOptions.responseType,
      followRedirects: requestOptions.followRedirects,
      validateStatus: requestOptions.validateStatus,
    );

    try {
      return await _dio.request(
        relativePath,
        data: requestOptions.data,
        queryParameters: requestOptions.queryParameters,
        options: newOptions,
      );
    } on DioException catch (e) {
      // If we get 409 (Conflict) or other non-auth errors, don't retry again
      if (e.response?.statusCode != null && e.response!.statusCode! != 401) {
        developer.log(
          'Retry returned non-401 error: ${e.response!.statusCode}',
          name: 'AuthInterceptor',
        );
        rethrow;
      }
      // If we get 401 again, something is wrong with the token
      developer.log(
        'Retry still returned 401 - token may be invalid',
        name: 'AuthInterceptor',
        error: e,
      );
      rethrow;
    }
  }

  /// Retry all pending requests after successful refresh
  Future<void> _retryPendingRequests() async {
    final requests = List<RequestOptions>.from(_pendingRequests);
    _pendingRequests.clear();

    developer.log(
      'Retrying ${requests.length} pending requests after token refresh',
      name: 'AuthInterceptor',
    );

    for (final request in requests) {
      try {
        developer.log(
          'Retrying pending request: ${request.method} ${request.path}',
          name: 'AuthInterceptor',
        );
        await _retryRequest(request);
      } catch (e) {
        developer.log(
          'Failed to retry pending request: ${request.path}',
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
    final hasQuery = options.queryParameters.isNotEmpty;
    final requestTarget = hasQuery ? options.uri.toString() : options.path;
    developer.log('→ ${options.method} $requestTarget', name: 'API');
    if (options.data != null) {
      developer.log('Request data: ${options.data}', name: 'API');
    }
    return handler.next(options);
  }

  /// Paths that return large lists (e.g. Home featured/new/best-sellers).
  /// We log only a summary to avoid choking the terminal.
  static bool _isListEndpoint(String path) {
    final p = path.split('?').first;
    if (p == ApiEndpoints.products ||
        p == ApiEndpoints.productsFeatured ||
        p == ApiEndpoints.productsNewArrivals ||
        p == ApiEndpoints.productsBestSellers ||
        p == ApiEndpoints.productsOnOffer ||
        p == ApiEndpoints.categories ||
        p == ApiEndpoints.categoriesTree ||
        p == ApiEndpoints.brands) {
      return true;
    }
    // e.g. /catalog/brands/id/products, /catalog/categories/id/products
    if (p.endsWith('/products') && p != ApiEndpoints.products) {
      return true;
    }
    return false;
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
          final pretty = _prettyJson(data);
          developer.log(
            'Response: list of $count items:\n$pretty',
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
              : (data is List ? {'data': data} : {'raw': data});
          final pretty = _prettyJson(toPrint);
          developer.log('Response data:\n$pretty', name: 'API');
        } catch (_) {
          developer.log('Response data: $data', name: 'API');
        }
      }
    }
    return handler.next(response);
  }

  static String _prettyJson(dynamic obj) {
    const encoder = JsonEncoder.withIndent('  ');
    try {
      return encoder.convert(obj);
    } catch (_) {
      return obj.toString();
    }
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
