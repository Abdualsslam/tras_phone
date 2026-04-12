/// Auth Interceptor - Handles automatic token injection and refresh
library;

import 'dart:convert';
import 'dart:developer' as developer;

import 'package:dio/dio.dart';

import '../constants/api_endpoints.dart';
import 'token_manager.dart';

part 'auth_interceptor_policy.dart';
part 'auth_interceptor_logging.dart';

typedef OnLogoutCallback = Future<void> Function();

class AuthInterceptor extends Interceptor {
  final Dio _dio;
  final TokenManager _tokenManager;
  final OnLogoutCallback? _onLogout;
  final _AuthEndpointPolicy _policy = const _AuthEndpointPolicy();
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
    developer.log(
      'onRequest: ${options.method} ${_formatRequestTarget(options)}',
      name: 'AuthInterceptor',
    );

    if (await _handleRetryRequest(options, handler)) return;
    if (await _handlePublicRequest(options, handler)) return;

    final shouldProceed = await _prepareAuthenticatedRequest(options, handler);
    if (!shouldProceed) return;

    await _attachTokenIfAvailable(options);
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode != 401) {
      handler.next(err);
      return;
    }

    final requestOptions = err.requestOptions;
    if (_policy.isRefreshEndpoint(requestOptions.path)) {
      await _handleLogout();
      handler.next(err);
      return;
    }

    if (_policy.isAuthEntryEndpoint(requestOptions.path)) {
      developer.log(
        '401 on auth entry endpoint - skipping token refresh/retry',
        name: 'AuthInterceptor',
      );
      handler.next(err);
      return;
    }

    if (requestOptions.headers['X-Retry-Request'] == 'true') {
      developer.log(
        'Retry request failed, not clearing tokens',
        name: 'AuthInterceptor',
      );
      handler.next(err);
      return;
    }

    if (_isRefreshing) {
      _pendingRequests.add(requestOptions);
      handler.next(err);
      return;
    }

    _isRefreshing = true;
    try {
      final refreshed = await _refreshToken();
      _isRefreshing = false;

      if (!refreshed) {
        await _handleLogout();
        handler.next(err);
        return;
      }

      try {
        final response = await _retryRequest(requestOptions);
        handler.resolve(response);
      } on DioException catch (retryError) {
        if (retryError.response?.statusCode == 401) {
          developer.log(
            'Retry still returned 401 after refresh - clearing tokens',
            name: 'AuthInterceptor',
            error: retryError,
          );
          await _handleLogout();
        } else {
          developer.log(
            'Retry returned error: ${retryError.response?.statusCode}',
            name: 'AuthInterceptor',
            error: retryError,
          );
        }
        handler.next(retryError);
      } catch (retryError) {
        developer.log(
          'Failed to retry request: ${requestOptions.path}',
          name: 'AuthInterceptor',
          error: retryError,
        );
        handler.next(
          DioException(
            requestOptions: requestOptions,
            error: retryError,
            type: DioExceptionType.unknown,
          ),
        );
      }
    } catch (error) {
      _isRefreshing = false;
      developer.log(
        'Token refresh failed',
        name: 'AuthInterceptor',
        error: error,
      );
      await _handleLogout();
      handler.next(err);
    }
  }

  Future<bool> _handleRetryRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.headers['X-Retry-Request'] != 'true') {
      return false;
    }

    developer.log(
      'Skipping token check - this is a retry request',
      name: 'AuthInterceptor',
    );

    final authHeader = options.headers['Authorization'];
    if (authHeader == null || !authHeader.toString().startsWith('Bearer ')) {
      final token = await _tokenManager.getAccessToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }

    handler.next(options);
    return true;
  }
  Future<bool> _handlePublicRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (!_policy.isPublicEndpoint(options.path)) {
      return false;
    }

    if (_policy.isAuthEntryEndpoint(options.path)) {
      developer.log(
        'Public auth entry endpoint - skipping token attachment',
        name: 'AuthInterceptor',
      );
      handler.next(options);
      return true;
    }

    developer.log(
      'Public endpoint - adding token if available (for optional auth e.g. pricing)',
      name: 'AuthInterceptor',
    );
    await _attachTokenIfAvailable(options);
    handler.next(options);
    return true;
  }
  Future<bool> _prepareAuthenticatedRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    developer.log(
      'Fetching token data for authenticated endpoint...',
      name: 'AuthInterceptor',
    );

    final tokenData = await _tokenManager.getTokenData();
    if (tokenData == null) {
      developer.log(
        'CRITICAL: No token data available! Request may fail.',
        name: 'AuthInterceptor',
      );
      return true;
    }

    final now = DateTime.now();
    developer.log(
      'Token check: expiresAt=${tokenData.expiresAt}, isExpired=${tokenData.isExpired}, willExpireSoon=${tokenData.willExpireSoon}, now=$now',
      name: 'AuthInterceptor',
    );

    if (tokenData.expiresAt == null) {
      developer.log(
        'WARNING: Token expiresAt is null - cannot check expiration! Will rely on backend validation.',
        name: 'AuthInterceptor',
      );
    }

    if (tokenData.isExpired) {
      return _handleExpiredToken(options, handler);
    }

    if (tokenData.willExpireSoon) {
      _refreshTokenInBackground(tokenData.expiresAt?.difference(now).inMinutes);
    } else {
      developer.log(
        'Token is valid, expires in ${tokenData.expiresAt?.difference(now).inMinutes ?? "unknown"} minutes',
        name: 'AuthInterceptor',
      );
    }

    return true;
  }
  Future<bool> _handleExpiredToken(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    developer.log(
      'Token is expired, refreshing before request',
      name: 'AuthInterceptor',
    );

    if (_isRefreshing) {
      developer.log(
        'Token expired but refresh in progress - adding to pending requests',
        name: 'AuthInterceptor',
      );
      _pendingRequests.add(options);
      return false;
    }

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
        handler.reject(
          DioException(
            requestOptions: options,
            error: 'Token expired and refresh failed',
            type: DioExceptionType.badResponse,
            response: Response(requestOptions: options, statusCode: 401),
          ),
        );
        return false;
      }

      developer.log(
        'Token refreshed successfully, using new token for request',
        name: 'AuthInterceptor',
      );
      return true;
    } catch (error) {
      _isRefreshing = false;
      developer.log(
        'Error refreshing expired token: $error',
        name: 'AuthInterceptor',
        error: error,
      );
      await _handleLogout();
      handler.reject(
        DioException(
          requestOptions: options,
          error: 'Token refresh error: $error',
          type: DioExceptionType.unknown,
        ),
      );
      return false;
    }
  }
  void _refreshTokenInBackground(int? minutesUntilExpiry) {
    developer.log(
      'Token will expire soon ($minutesUntilExpiry minutes), refreshing proactively in background',
      name: 'AuthInterceptor',
    );

    if (_isRefreshing) return;

    _isRefreshing = true;
    _refreshToken()
        .then((_) {
          _isRefreshing = false;
          developer.log(
            'Background token refresh completed',
            name: 'AuthInterceptor',
          );
        })
        .catchError((error) {
          _isRefreshing = false;
          developer.log(
            'Background token refresh failed: $error',
            name: 'AuthInterceptor',
            error: error,
          );
        });
  }

  Future<void> _attachTokenIfAvailable(RequestOptions options) async {
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
  }

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

        final savedToken = await _tokenManager.getAccessToken();
        developer.log(
          'Verified saved token: ${savedToken?.substring(0, 30)}...',
          name: 'AuthInterceptor',
        );

        await _retryPendingRequests();
        developer.log('Token refreshed successfully', name: 'AuthInterceptor');
        return true;
      }

      return false;
    } catch (error) {
      developer.log(
        'Failed to refresh token',
        name: 'AuthInterceptor',
        error: error,
      );
      return false;
    }
  }

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

    var relativePath = requestOptions.path;
    final baseUrl = _dio.options.baseUrl;
    if (baseUrl.isNotEmpty && relativePath.startsWith(baseUrl)) {
      relativePath = relativePath.substring(baseUrl.length);
    }
    if (!relativePath.startsWith('/')) {
      relativePath = '/$relativePath';
    }

    final newOptions = Options(
      method: requestOptions.method,
      headers: {
        ...requestOptions.headers,
        'Authorization': 'Bearer $token',
        'X-Retry-Request': 'true',
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
    } on DioException catch (error) {
      if (error.response?.statusCode != null &&
          error.response!.statusCode! != 401) {
        developer.log(
          'Retry returned non-401 error: ${error.response!.statusCode}',
          name: 'AuthInterceptor',
        );
      } else {
        developer.log(
          'Retry still returned 401 - token may be invalid',
          name: 'AuthInterceptor',
          error: error,
        );
      }
      rethrow;
    }
  }

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
      } catch (error) {
        developer.log(
          'Failed to retry pending request: ${request.path}',
          name: 'AuthInterceptor',
          error: error,
        );
      }
    }
  }

  Future<void> _handleLogout() async {
    await _tokenManager.clearTokens();
    _pendingRequests.clear();
    _isRefreshing = false;

    if (_onLogout != null) {
      await _onLogout();
    }
  }

  String _formatRequestTarget(RequestOptions options) {
    return options.queryParameters.isNotEmpty
        ? options.uri.toString()
        : options.path;
  }
}
