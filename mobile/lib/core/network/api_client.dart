/// API Client wrapper using Dio
library;

import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';

import '../config/app_config.dart';
import '../constants/storage_keys.dart';
import '../errors/exceptions.dart';
import '../storage/local_storage.dart';
import 'auth_interceptor.dart';
import 'token_manager.dart';

part 'api_client_support.dart';
part 'api_client_requests.dart';
part 'api_client_errors.dart';

class ApiClient {
  late final Dio _dio;
  TokenManager? _tokenManager;
  final LocalStorage? _localStorage;
  late final _ApiClientSupport _support;
  late final _ApiClientRequestExecutor _requestExecutor;
  late final _ApiClientErrorMapper _errorMapper;

  ApiClient({LocalStorage? localStorage}) : _localStorage = localStorage {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: AppConfig.apiTimeout,
        receiveTimeout: AppConfig.apiTimeout,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        validateStatus: (status) {
          return status != null && status >= 200 && status < 300;
        },
      ),
    );

    _support = _ApiClientSupport(dio: _dio, localStorage: _localStorage);
    _errorMapper = _ApiClientErrorMapper(_support);
    _requestExecutor = _ApiClientRequestExecutor(
      dio: _dio,
      errorMapper: _errorMapper,
    );
    _support.configureCertificatePinning();
  }

  Dio get dio => _dio;
  TokenManager? get tokenManager => _tokenManager;

  void initialize({
    required TokenManager tokenManager,
    OnLogoutCallback? onLogout,
    bool enableLogging = false,
  }) {
    _tokenManager = tokenManager;
    _dio.interceptors.clear();
    _dio.interceptors.add(
      AuthInterceptor(
        dio: _dio,
        tokenManager: tokenManager,
        onLogout: onLogout,
      ),
    );

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
  }) => _requestExecutor.get(
    path,
    queryParameters: queryParameters,
    options: options,
  );

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) => _requestExecutor.post(
    path,
    data: data,
    queryParameters: queryParameters,
    options: options,
  );

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) => _requestExecutor.put(
    path,
    data: data,
    queryParameters: queryParameters,
    options: options,
  );

  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) => _requestExecutor.patch(
    path,
    data: data,
    queryParameters: queryParameters,
    options: options,
  );

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) => _requestExecutor.delete(
    path,
    data: data,
    queryParameters: queryParameters,
    options: options,
  );

  Future<Response<T>> uploadFile<T>(
    String path, {
    required String filePath,
    required String fieldName,
    Map<String, dynamic>? additionalData,
    void Function(int, int)? onSendProgress,
  }) => _requestExecutor.uploadFile(
    path,
    filePath: filePath,
    fieldName: fieldName,
    additionalData: additionalData,
    onSendProgress: onSendProgress,
  );
}
