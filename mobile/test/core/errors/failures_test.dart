import 'package:flutter_test/flutter_test.dart';
import 'package:tras_phone/core/errors/failures.dart';

void main() {
  group('ServerFailure', () {
    test('should have correct message and code', () {
      const failure = ServerFailure(message: 'Server error', code: '500');
      expect(failure.message, 'Server error');
      expect(failure.code, '500');
    });

    test('two instances with same props should be equal', () {
      const f1 = ServerFailure(message: 'err', code: '500');
      const f2 = ServerFailure(message: 'err', code: '500');
      expect(f1, equals(f2));
    });

    test('two instances with different props should not be equal', () {
      const f1 = ServerFailure(message: 'err1');
      const f2 = ServerFailure(message: 'err2');
      expect(f1, isNot(equals(f2)));
    });
  });

  group('NetworkFailure', () {
    test('should have default message and code', () {
      const failure = NetworkFailure();
      expect(failure.message, 'لا يوجد اتصال بالإنترنت');
      expect(failure.code, 'NETWORK_ERROR');
    });

    test('two default instances should be equal', () {
      const f1 = NetworkFailure();
      const f2 = NetworkFailure();
      expect(f1, equals(f2));
    });
  });

  group('CacheFailure', () {
    test('should have default message and code', () {
      const failure = CacheFailure();
      expect(failure.message, 'خطأ في تحميل البيانات المحفوظة');
      expect(failure.code, 'CACHE_ERROR');
    });
  });

  group('AuthFailure', () {
    test('should have correct message and default code', () {
      const failure = AuthFailure(message: 'Invalid credentials');
      expect(failure.message, 'Invalid credentials');
      expect(failure.code, 'AUTH_ERROR');
    });

    test('should accept custom code', () {
      const failure = AuthFailure(message: 'err', code: 'CUSTOM');
      expect(failure.code, 'CUSTOM');
    });
  });

  group('ValidationFailure', () {
    test('should have default message and code', () {
      const failure = ValidationFailure();
      expect(failure.message, 'بيانات غير صحيحة');
      expect(failure.code, 'VALIDATION_ERROR');
    });

    test('should include errors in props', () {
      const f1 = ValidationFailure(errors: {'field': ['required']});
      const f2 = ValidationFailure(errors: {'field': ['required']});
      expect(f1, equals(f2));
    });

    test('different errors should not be equal', () {
      const f1 = ValidationFailure(errors: {'a': ['1']});
      const f2 = ValidationFailure(errors: {'b': ['2']});
      expect(f1, isNot(equals(f2)));
    });
  });

  group('NotFoundFailure', () {
    test('should have default message and code', () {
      const failure = NotFoundFailure();
      expect(failure.message, 'العنصر المطلوب غير موجود');
      expect(failure.code, 'NOT_FOUND');
    });
  });

  group('TimeoutFailure', () {
    test('should have default message and code', () {
      const failure = TimeoutFailure();
      expect(failure.message, 'انتهت مهلة الاتصال');
      expect(failure.code, 'TIMEOUT');
    });
  });

  group('UnknownFailure', () {
    test('should have default message and code', () {
      const failure = UnknownFailure();
      expect(failure.message, 'حدث خطأ غير متوقع');
      expect(failure.code, 'UNKNOWN');
    });
  });

  group('Failure equality across types', () {
    test('different failure types with same message should not be equal', () {
      const server = ServerFailure(message: 'err');
      const auth = AuthFailure(message: 'err');
      expect(server, isNot(equals(auth)));
    });
  });
}
