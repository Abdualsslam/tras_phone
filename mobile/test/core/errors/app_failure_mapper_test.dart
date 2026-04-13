import 'dart:async' as async;
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tras_phone/core/errors/app_failure_mapper.dart';
import 'package:tras_phone/core/errors/exceptions.dart';
import 'package:tras_phone/core/errors/failures.dart';

void main() {
  const mapper = AppFailureMapper();

  group('AppFailureMapper.map', () {
    test('maps NetworkException to NetworkFailure', () {
      final failure = mapper.map(const NetworkException());

      expect(failure, const NetworkFailure());
    });

    test('maps TimeoutException to TimeoutFailure', () {
      final failure = mapper.map(const TimeoutException());

      expect(failure, const TimeoutFailure());
    });

    test('maps UnauthorizedException to AuthFailure', () {
      final failure = mapper.map(const UnauthorizedException());

      expect(
        failure,
        const AuthFailure(
          message: 'غير مصرح لك بالوصول',
          code: 'UNAUTHORIZED',
        ),
      );
    });

    test('maps ValidationException preserving errors', () {
      const exception = ValidationException(
        message: 'Invalid payload',
        errors: {
          'phone': ['required'],
        },
      );

      final failure = mapper.map(exception);

      expect(
        failure,
        const ValidationFailure(
          message: 'Invalid payload',
          errors: {
            'phone': ['required'],
          },
        ),
      );
    });

    test('maps DioException badResponse 422 to ValidationFailure', () {
      final failure = mapper.map(
        DioException(
          requestOptions: RequestOptions(path: '/auth/login'),
          response: Response(
            requestOptions: RequestOptions(path: '/auth/login'),
            statusCode: 422,
            data: {
              'message': 'Validation failed',
              'errors': {
                'email': ['invalid'],
              },
            },
          ),
          type: DioExceptionType.badResponse,
        ),
      );

      expect(
        failure,
        const ValidationFailure(
          message: 'Validation failed',
          code: '422',
          errors: {
            'email': ['invalid'],
          },
        ),
      );
    });

    test('maps SocketException to NetworkFailure', () {
      final failure = mapper.map(const SocketException('Failed host lookup'));

      expect(failure, const NetworkFailure());
    });

    test('maps dart async timeout to TimeoutFailure', () {
      final failure = mapper.map(async.TimeoutException('too slow'));

      expect(failure, const TimeoutFailure());
    });

    test('maps unknown errors to UnknownFailure', () {
      final failure = mapper.map(StateError('boom'));

      expect(failure, isA<UnknownFailure>());
      expect(failure.message, contains('boom'));
    });
  });
}
