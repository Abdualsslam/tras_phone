/// Custom Exceptions for the application
library;

/// Base exception class
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  const AppException({required this.message, this.code, this.originalError});

  @override
  String toString() => 'AppException: $message (code: $code)';
}

/// Server-related exceptions
class ServerException extends AppException {
  final int? statusCode;

  const ServerException({
    required super.message,
    super.code,
    super.originalError,
    this.statusCode,
  });
}

/// Network/Connectivity exceptions
class NetworkException extends AppException {
  const NetworkException({
    super.message = 'لا يوجد اتصال بالإنترنت',
    super.code = 'NETWORK_ERROR',
    super.originalError,
  });
}

/// Cache-related exceptions
class CacheException extends AppException {
  const CacheException({
    super.message = 'خطأ في تحميل البيانات المحفوظة',
    super.code = 'CACHE_ERROR',
    super.originalError,
  });
}

/// Authentication exceptions
class AuthException extends AppException {
  const AuthException({
    required super.message,
    super.code = 'AUTH_ERROR',
    super.originalError,
  });
}

/// Unauthorized exception (401)
class UnauthorizedException extends AuthException {
  const UnauthorizedException({
    super.message = 'غير مصرح لك بالوصول',
    super.code = 'UNAUTHORIZED',
    super.originalError,
  });
}

/// Forbidden exception (403)
class ForbiddenException extends AppException {
  const ForbiddenException({
    super.message = 'ليس لديك صلاحية لهذا الإجراء',
    super.code = 'FORBIDDEN',
    super.originalError,
  });
}

/// Not found exception (404)
class NotFoundException extends AppException {
  const NotFoundException({
    super.message = 'العنصر المطلوب غير موجود',
    super.code = 'NOT_FOUND',
    super.originalError,
  });
}

/// Validation exception (422)
class ValidationException extends AppException {
  final Map<String, List<String>>? errors;

  const ValidationException({
    super.message = 'بيانات غير صحيحة',
    super.code = 'VALIDATION_ERROR',
    super.originalError,
    this.errors,
  });
}

/// Timeout exception
class TimeoutException extends AppException {
  const TimeoutException({
    super.message = 'انتهت مهلة الاتصال',
    super.code = 'TIMEOUT',
    super.originalError,
  });
}

/// Unknown exception
class UnknownException extends AppException {
  const UnknownException({
    super.message = 'حدث خطأ غير متوقع',
    super.code = 'UNKNOWN',
    super.originalError,
  });
}
