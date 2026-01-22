/// API Client wrapper using Dio
library;

import 'dart:ui' as ui;
import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../errors/exceptions.dart';
import 'auth_interceptor.dart';
import 'token_manager.dart';
import '../constants/storage_keys.dart';
import '../storage/local_storage.dart';

class ApiClient {
  late final Dio _dio;
  TokenManager? _tokenManager;
  LocalStorage? _localStorage;

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

  /// Get current locale from storage or system
  String _getCurrentLocale() {
    if (_localStorage != null) {
      final savedLocale = _localStorage!.getString(StorageKeys.locale);
      if (savedLocale != null) {
        return savedLocale;
      }
    }
    // Fallback to system locale
    return ui.PlatformDispatcher.instance.locale.languageCode;
  }

  /// Translate common error messages based on locale
  String _translateError(String englishMessage) {
    final locale = _getCurrentLocale();
    if (locale != 'ar') {
      return englishMessage; // Return English if not Arabic
    }

    // Common error message translations
    final translations = {
      'Your account is under review. Please wait for activation':
          'حسابك قيد المراجعة. يرجى انتظار التفعيل',
      'Your account has been rejected': 'تم رفض حسابك',
      'Invalid credentials': 'رقم الجوال أو كلمة المرور غير صحيحة. يرجى المحاولة مرة أخرى',
      'User not found': 'المستخدم غير موجود',
      'Account is locked': 'الحساب مقفل',
      'Account suspended': 'الحساب معلق',
      'Email already exists': 'البريد الإلكتروني مستخدم بالفعل',
      'Phone number already exists': 'رقم الهاتف مستخدم بالفعل',
      'Invalid token': 'رمز غير صحيح',
      'Token expired': 'انتهت صلاحية الرمز',
      'Unauthorized': 'غير مصرح',
      'Forbidden': 'غير مسموح',
      'Not found': 'غير موجود',
      'Internal server error': 'خطأ في الخادم',
      'Bad request': 'طلب غير صحيح',
      'Validation error': 'خطأ في التحقق',
    };

    return translations[englishMessage] ?? englishMessage;
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
    
    final locale = _getCurrentLocale();
    
    // Extract both English and Arabic messages from response
    String? messageEn;
    String? messageAr;
    if (data is Map) {
      messageEn = data['message'] != null ? extractMessage(data['message']) : null;
      messageAr = data['messageAr'] != null ? extractMessage(data['messageAr']) : null;
    }
    
    // Check if this is an account under review error (before choosing locale message)
    final isAccountUnderReview = 
        (messageEn != null && (
          messageEn == AccountUnderReviewException.englishMessage ||
          messageEn.contains('account is under review') ||
          messageEn.contains('under review'))) ||
        (messageAr != null && (
          messageAr == AccountUnderReviewException.arabicMessage ||
          messageAr.contains('قيد المراجعة')));
    
    // Check if this is an account rejected error (before choosing locale message)
    final isAccountRejected = 
        (messageEn != null && (
          messageEn == AccountRejectedException.englishMessage ||
          messageEn.contains('account has been rejected') ||
          messageEn.contains('has been rejected'))) ||
        (messageAr != null && (
          messageAr == AccountRejectedException.arabicMessage ||
          messageAr.contains('تم رفض') ||
          messageAr.contains('رفض حسابك')));
    
    // Choose message based on locale: prefer messageAr for Arabic, message for others
    String message;
    if (data is Map) {
      if (locale == 'ar') {
        // For Arabic: prefer messageAr, fallback to translated message
        if (messageAr != null) {
          message = messageAr;
        } else if (messageEn != null) {
          // Translate English message to Arabic
          message = _translateError(messageEn);
        } else {
          message = 'خطأ في الخادم';
        }
      } else {
        // For English: prefer message, fallback to messageAr
        if (messageEn != null) {
          message = messageEn;
        } else if (messageAr != null) {
          message = messageAr;
        } else {
          message = 'Server error';
        }
      }
    } else {
      message = locale == 'ar' ? 'خطأ في الخادم' : 'Server error';
    }

    switch (statusCode) {
      case 400:
        return ServerException(message: message, statusCode: 400);
      case 401:
        // Return AccountUnderReviewException if detected
        if (isAccountUnderReview) {
          return AccountUnderReviewException(
            message: locale == 'ar' 
                ? AccountUnderReviewException.arabicMessage 
                : AccountUnderReviewException.englishMessage,
          );
        }
        // Return AccountRejectedException if detected
        if (isAccountRejected) {
          return AccountRejectedException(
            message: locale == 'ar' 
                ? AccountRejectedException.arabicMessage 
                : AccountRejectedException.englishMessage,
          );
        }
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
