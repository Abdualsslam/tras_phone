import 'package:flutter_test/flutter_test.dart';
import 'package:tras_phone/core/errors/exceptions.dart';

void main() {
  group('ServerException', () {
    test('should have correct message, code, and statusCode', () {
      const exception = ServerException(
        message: 'Internal Server Error',
        code: '500',
        statusCode: 500,
      );
      expect(exception.message, 'Internal Server Error');
      expect(exception.code, '500');
      expect(exception.statusCode, 500);
    });

    test('toString should contain message and code', () {
      const exception = ServerException(message: 'err', code: 'CODE');
      expect(exception.toString(), contains('err'));
    });
  });

  group('NetworkException', () {
    test('should have default message and code', () {
      const exception = NetworkException();
      expect(exception.message, 'لا يوجد اتصال بالإنترنت');
      expect(exception.code, 'NETWORK_ERROR');
    });

    test('should accept custom message', () {
      const exception = NetworkException(message: 'No wifi');
      expect(exception.message, 'No wifi');
    });
  });

  group('CacheException', () {
    test('should have default message and code', () {
      const exception = CacheException();
      expect(exception.message, 'خطأ في تحميل البيانات المحفوظة');
      expect(exception.code, 'CACHE_ERROR');
    });
  });

  group('AuthException', () {
    test('should have correct message and default code', () {
      const exception = AuthException(message: 'Unauthorized');
      expect(exception.message, 'Unauthorized');
      expect(exception.code, 'AUTH_ERROR');
    });
  });

  group('UnauthorizedException', () {
    test('should have default message and code', () {
      const exception = UnauthorizedException();
      expect(exception.message, 'غير مصرح لك بالوصول');
      expect(exception.code, 'UNAUTHORIZED');
    });

    test('should be an AuthException', () {
      const exception = UnauthorizedException();
      expect(exception, isA<AuthException>());
    });
  });

  group('AccountUnderReviewException', () {
    test('should have default message', () {
      const exception = AccountUnderReviewException();
      expect(exception.message, 'حسابك قيد المراجعة. يرجى انتظار التفعيل');
      expect(exception.code, 'ACCOUNT_UNDER_REVIEW');
    });

    test('should have static English and Arabic messages', () {
      expect(
        AccountUnderReviewException.englishMessage,
        'Your account is under review. Please wait for activation',
      );
      expect(
        AccountUnderReviewException.arabicMessage,
        'حسابك قيد المراجعة. يرجى انتظار التفعيل',
      );
    });
  });

  group('AccountRejectedException', () {
    test('should have default message', () {
      const exception = AccountRejectedException();
      expect(exception.message, 'تم رفض حسابك');
      expect(exception.code, 'ACCOUNT_REJECTED');
    });
  });

  group('ForbiddenException', () {
    test('should have default message and code', () {
      const exception = ForbiddenException();
      expect(exception.message, 'ليس لديك صلاحية لهذا الإجراء');
      expect(exception.code, 'FORBIDDEN');
    });
  });

  group('NotFoundException', () {
    test('should have default message and code', () {
      const exception = NotFoundException();
      expect(exception.message, 'العنصر المطلوب غير موجود');
      expect(exception.code, 'NOT_FOUND');
    });
  });

  group('ConflictException', () {
    test('should have default message and code', () {
      const exception = ConflictException();
      expect(exception.message, 'البيانات موجودة بالفعل');
      expect(exception.code, 'CONFLICT');
    });

    test('should have static messages for user already exists', () {
      expect(
        ConflictException.userAlreadyExistsEn,
        'User with this phone or email already exists',
      );
      expect(
        ConflictException.userAlreadyExistsAr,
        'المستخدم موجود بالفعل. رقم الجوال أو البريد الإلكتروني مستخدم',
      );
    });
  });

  group('ValidationException', () {
    test('should have default message and code', () {
      const exception = ValidationException();
      expect(exception.message, 'بيانات غير صحيحة');
      expect(exception.code, 'VALIDATION_ERROR');
    });

    test('should accept errors map', () {
      const exception = ValidationException(
        errors: {
          'phone': ['required'],
        },
      );
      expect(exception.errors, isNotNull);
      expect(exception.errors!['phone'], contains('required'));
    });
  });

  group('TimeoutException', () {
    test('should have default message and code', () {
      const exception = TimeoutException();
      expect(exception.message, 'انتهت مهلة الاتصال');
      expect(exception.code, 'TIMEOUT');
    });
  });

  group('UnknownException', () {
    test('should have default message and code', () {
      const exception = UnknownException();
      expect(exception.message, 'حدث خطأ غير متوقع');
      expect(exception.code, 'UNKNOWN');
    });
  });

  group('AppException toString', () {
    test('should format correctly', () {
      const exception = ServerException(message: 'test', code: 'TEST');
      // AppException.toString() => 'AppException: test (code: TEST)'
      expect(exception.toString(), 'AppException: test (code: TEST)');
    });
  });

  group('originalError', () {
    test('should store original error', () {
      final original = Exception('original');
      final exception = ServerException(
        message: 'wrapped',
        originalError: original,
      );
      expect(exception.originalError, original);
    });
  });
}
