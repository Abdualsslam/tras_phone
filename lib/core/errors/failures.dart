/// Failure classes for functional error handling with dartz
library;

import 'package:equatable/equatable.dart';

/// Base failure class
abstract class Failure extends Equatable {
  final String message;
  final String? code;

  const Failure({required this.message, this.code});

  @override
  List<Object?> get props => [message, code];
}

/// Server failure
class ServerFailure extends Failure {
  const ServerFailure({required super.message, super.code});
}

/// Network failure
class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'لا يوجد اتصال بالإنترنت',
    super.code = 'NETWORK_ERROR',
  });
}

/// Cache failure
class CacheFailure extends Failure {
  const CacheFailure({
    super.message = 'خطأ في تحميل البيانات المحفوظة',
    super.code = 'CACHE_ERROR',
  });
}

/// Authentication failure
class AuthFailure extends Failure {
  const AuthFailure({required super.message, super.code = 'AUTH_ERROR'});
}

/// Validation failure
class ValidationFailure extends Failure {
  final Map<String, List<String>>? errors;

  const ValidationFailure({
    super.message = 'بيانات غير صحيحة',
    super.code = 'VALIDATION_ERROR',
    this.errors,
  });

  @override
  List<Object?> get props => [message, code, errors];
}

/// Not found failure
class NotFoundFailure extends Failure {
  const NotFoundFailure({
    super.message = 'العنصر المطلوب غير موجود',
    super.code = 'NOT_FOUND',
  });
}

/// Timeout failure
class TimeoutFailure extends Failure {
  const TimeoutFailure({
    super.message = 'انتهت مهلة الاتصال',
    super.code = 'TIMEOUT',
  });
}

/// Unknown failure
class UnknownFailure extends Failure {
  const UnknownFailure({
    super.message = 'حدث خطأ غير متوقع',
    super.code = 'UNKNOWN',
  });
}
