part of 'api_client.dart';

class _ApiClientErrorMapper {
  final _ApiClientSupport support;

  const _ApiClientErrorMapper(this.support);

  AppException handleDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const TimeoutException();
      case DioExceptionType.connectionError:
        return const NetworkException();
      case DioExceptionType.badResponse:
        return handleBadResponse(error.response);
      case DioExceptionType.cancel:
        return const UnknownException(message: 'تم إلغاء الطلب');
      default:
        return UnknownException(originalError: error);
    }
  }

  AppException handleBadResponse(Response? response) {
    if (response == null) {
      return ServerException(message: support.defaultArabicServerError);
    }

    final statusCode = response.statusCode;
    final data = response.data;
    final locale = support.getCurrentLocale();
    final defaultMessage = locale == 'ar'
        ? support.defaultArabicServerError
        : support.defaultEnglishServerError;

    String? messageEn;
    String? messageAr;
    if (data is Map) {
      messageEn = data['message'] != null
          ? support.extractMessage(
              data['message'],
              fallbackMessage: support.defaultEnglishServerError,
            )
          : null;
      messageAr = data['messageAr'] != null
          ? support.extractMessage(
              data['messageAr'],
              fallbackMessage: support.defaultArabicServerError,
            )
          : null;
    }

    final isAccountUnderReview = _matchesAccountUnderReview(
      messageEn: messageEn,
      messageAr: messageAr,
    );
    final isAccountRejected = _matchesAccountRejected(
      messageEn: messageEn,
      messageAr: messageAr,
    );
    final isUserAlreadyExists = _matchesUserAlreadyExists(
      messageEn: messageEn,
      messageAr: messageAr,
    );

    final message = _resolveLocalizedMessage(
      locale: locale,
      messageEn: messageEn,
      messageAr: messageAr,
      defaultMessage: defaultMessage,
    );

    switch (statusCode) {
      case 400:
        return ServerException(message: message, statusCode: 400);
      case 401:
        if (isAccountUnderReview) {
          return AccountUnderReviewException(
            message: locale == 'ar'
                ? AccountUnderReviewException.arabicMessage
                : AccountUnderReviewException.englishMessage,
          );
        }
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
      case 409:
        if (isUserAlreadyExists) {
          return ConflictException(
            message: locale == 'ar'
                ? ConflictException.userAlreadyExistsAr
                : ConflictException.userAlreadyExistsEn,
          );
        }
        return ConflictException(message: message);
      case 422:
        return ValidationException(
          message: message,
          errors: _extractValidationErrors(data),
        );
      case 500:
      case 502:
      case 503:
        return ServerException(message: support.retryableArabicServerError);
      default:
        return ServerException(message: message, statusCode: statusCode);
    }
  }

  String _resolveLocalizedMessage({
    required String locale,
    required String? messageEn,
    required String? messageAr,
    required String defaultMessage,
  }) {
    if (locale == 'ar') {
      if (messageAr != null) return messageAr;
      if (messageEn != null) return support.translateError(messageEn);
      return defaultMessage;
    }
    return messageEn ?? messageAr ?? defaultMessage;
  }

  bool _matchesAccountUnderReview({
    required String? messageEn,
    required String? messageAr,
  }) {
    return (messageEn != null &&
            (messageEn == AccountUnderReviewException.englishMessage ||
                messageEn.contains('account is under review') ||
                messageEn.contains('under review'))) ||
        (messageAr != null &&
            (messageAr == AccountUnderReviewException.arabicMessage ||
                messageAr.contains('قيد المراجعة')));
  }

  bool _matchesAccountRejected({
    required String? messageEn,
    required String? messageAr,
  }) {
    return (messageEn != null &&
            (messageEn == AccountRejectedException.englishMessage ||
                messageEn.contains('account has been rejected') ||
                messageEn.contains('has been rejected'))) ||
        (messageAr != null &&
            (messageAr == AccountRejectedException.arabicMessage ||
                messageAr.contains('تم رفض') ||
                messageAr.contains('رفض حسابك')));
  }

  bool _matchesUserAlreadyExists({
    required String? messageEn,
    required String? messageAr,
  }) {
    return (messageEn != null &&
            (messageEn == ConflictException.userAlreadyExistsEn ||
                messageEn.contains('phone or email already exists') ||
                messageEn.contains('already exists'))) ||
        (messageAr != null &&
            (messageAr == ConflictException.userAlreadyExistsAr ||
                messageAr.contains('موجود بالفعل') ||
                messageAr.contains('مستخدم بالفعل')));
  }

  Map<String, List<String>>? _extractValidationErrors(dynamic data) {
    if (data is! Map) return null;

    final rawErrors = data['errors'];
    if (rawErrors is! Map<String, dynamic>) return null;

    return rawErrors.map(
      (key, value) => MapEntry(key, List<String>.from(value as List)),
    );
  }
}
