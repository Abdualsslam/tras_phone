library;

import 'package:dartz/dartz.dart';

import 'app_error_reporter.dart';
import 'app_failure_mapper.dart';
import 'exceptions.dart';
import 'failures.dart';

class RepositoryGuard {
  final AppFailureMapper mapper;
  final AppErrorReporter reporter;

  const RepositoryGuard({
    required this.mapper,
    required this.reporter,
  });

  Future<Either<Failure, T>> guardEither<T>(
    Future<T> Function() operation, {
    String source = 'RepositoryGuard',
  }) async {
    try {
      return Right(await operation());
    } catch (error, stackTrace) {
      if (error is! Failure && error is! AppException) {
        reporter.recordError(error, stackTrace, source: source);
      }
      return Left(mapper.map(error));
    }
  }
}
