library;

import 'dart:async' as async;
import 'dart:io';

import 'package:dio/dio.dart';

import 'exceptions.dart';
import 'failures.dart';

class AppFailureMapper {
  const AppFailureMapper();

  Failure map(Object error) {
    if (error is Failure) {
      return error;
    }

    if (error is AppException) {
      return _mapAppException(error);
    }

    if (error is DioException) {
      return _mapDioException(error);
    }

    if (error is SocketException) {
      return const NetworkFailure();
    }

    if (error is async.TimeoutException) {
      return const TimeoutFailure();
    }

    if (error is FormatException) {
      return ValidationFailure(message: _normalizeMessage(error.message));
    }

    final message = _normalizeMessage(error.toString());
    if (_looksLikeNetworkError(message)) {
      return const NetworkFailure();
    }

    return UnknownFailure(message: message);
  }

  Failure _mapAppException(AppException exception) {
    if (exception is NetworkException) {
      return const NetworkFailure();
    }
    if (exception is CacheException) {
      return const CacheFailure();
    }
    if (exception is UnauthorizedException || exception is AuthException) {
      return AuthFailure(message: exception.message, code: exception.code);
    }
    if (exception is ValidationException) {
      return ValidationFailure(
        message: exception.message,
        code: exception.code,
        errors: exception.errors,
      );
    }
    if (exception is NotFoundException) {
      return NotFoundFailure(
        message: exception.message,
        code: exception.code,
      );
    }
    if (exception is TimeoutException) {
      return const TimeoutFailure();
    }
    if (exception is ServerException) {
      return ServerFailure(
        message: _normalizeMessage(exception.message),
        code: exception.code,
      );
    }

    return UnknownFailure(
      message: _normalizeMessage(exception.message),
      code: exception.code,
    );
  }

  Failure _mapDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const TimeoutFailure();
      case DioExceptionType.connectionError:
        return const NetworkFailure();
      case DioExceptionType.badResponse:
        return _mapBadResponse(error.response);
      case DioExceptionType.cancel:
        return const UnknownFailure(message: 'تم إلغاء الطلب');
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        final message = _extractMessageFromResponse(error.response) ??
            _normalizeMessage(error.message ?? error.toString());
        if (_looksLikeNetworkError(message)) {
          return const NetworkFailure();
        }
        return ServerFailure(message: message);
    }
  }

  Failure _mapBadResponse(Response<dynamic>? response) {
    final statusCode = response?.statusCode;
    final message = _extractMessageFromResponse(response) ??
        _fallbackMessageForStatus(statusCode);

    switch (statusCode) {
      case 401:
      case 403:
        return AuthFailure(message: message, code: '$statusCode');
      case 404:
        return NotFoundFailure(message: message, code: '$statusCode');
      case 408:
        return const TimeoutFailure();
      case 422:
        return ValidationFailure(
          message: message,
          code: '$statusCode',
          errors: _extractValidationErrors(response?.data),
        );
      default:
        return ServerFailure(message: message, code: '$statusCode');
    }
  }

  String? _extractMessageFromResponse(Response<dynamic>? response) {
    final data = response?.data;
    if (data is Map<String, dynamic>) {
      return _normalizeMessage(
        data['messageAr']?.toString() ??
            data['message']?.toString() ??
            data['error']?.toString() ??
            '',
      );
    }
    if (data is Map) {
      return _normalizeMessage(
        data['messageAr']?.toString() ??
            data['message']?.toString() ??
            data['error']?.toString() ??
            '',
      );
    }
    return null;
  }

  Map<String, List<String>>? _extractValidationErrors(dynamic data) {
    if (data is! Map) return null;

    final rawErrors = data['errors'];
    if (rawErrors is! Map) return null;

    return rawErrors.map<String, List<String>>((key, value) {
      if (value is List) {
        return MapEntry(
          key.toString(),
          value.map((item) => item.toString()).toList(),
        );
      }
      return MapEntry(key.toString(), [value.toString()]);
    });
  }

  String _fallbackMessageForStatus(int? statusCode) {
    switch (statusCode) {
      case 401:
        return 'غير مصرح لك بالوصول';
      case 403:
        return 'ليس لديك صلاحية لهذا الإجراء';
      case 404:
        return 'العنصر المطلوب غير موجود';
      case 422:
        return 'البيانات المدخلة غير صحيحة';
      default:
        return 'حدث خطأ غير متوقع';
    }
  }

  String _normalizeMessage(String rawMessage) {
    final cleaned = rawMessage
        .replaceFirst(RegExp(r'^Exception:\s*'), '')
        .replaceFirst(RegExp(r'^AppException:\s*'), '')
        .replaceFirst(RegExp(r'^Failure:\s*'), '')
        .trim();

    if (cleaned.isEmpty) {
      return 'حدث خطأ غير متوقع';
    }

    if (cleaned.contains('(code:')) {
      return cleaned.split('(code:').first.trim();
    }

    return cleaned;
  }

  bool _looksLikeNetworkError(String message) {
    final lower = message.toLowerCase();
    return lower.contains('socketexception') ||
        lower.contains('network error') ||
        lower.contains('networkexception') ||
        lower.contains('failed host lookup') ||
        lower.contains('connection error') ||
        lower.contains('internet') ||
        message.contains('لا يوجد اتصال');
  }
}
