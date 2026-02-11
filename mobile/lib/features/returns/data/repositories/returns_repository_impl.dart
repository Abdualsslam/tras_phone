/// Returns Repository Implementation
library;

import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/return_entity.dart';
import '../../domain/repositories/returns_repository.dart';
import '../datasources/returns_remote_datasource.dart';
import '../models/return_model.dart';

/// Implementation of ReturnsRepository using remote data source
class ReturnsRepositoryImpl implements ReturnsRepository {
  final ReturnsRemoteDataSource _remoteDataSource;

  ReturnsRepositoryImpl({required ReturnsRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  @override
  Future<Either<Failure, List<ReturnEntity>>> getMyReturns({
    ReturnStatus? status,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final returns = await _remoteDataSource.getMyReturns(
        status: status,
        page: page,
        limit: limit,
      );
      return Right(returns.map((model) => model.toEntity()).toList());
    } on AppException catch (e) {
      return Left(_mapExceptionToFailure(e));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ReturnEntity>> getReturnById(String id) async {
    try {
      final returnModel = await _remoteDataSource.getReturnById(id);
      return Right(returnModel.toEntity());
    } on AppException catch (e) {
      return Left(_mapExceptionToFailure(e));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ReturnEntity>> createReturn(
    CreateReturnRequest request,
  ) async {
    try {
      final returnModel = await _remoteDataSource.createReturn(request);
      return Right(returnModel.toEntity());
    } on AppException catch (e) {
      return Left(_mapExceptionToFailure(e));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> cancelReturn(String id) async {
    try {
      final result = await _remoteDataSource.cancelReturn(id);
      return Right(result);
    } on AppException catch (e) {
      return Left(_mapExceptionToFailure(e));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ReturnReasonEntity>>> getReturnReasons() async {
    try {
      final reasons = await _remoteDataSource.getReturnReasons();
      return Right(reasons.map((model) => model.toEntity()).toList());
    } on AppException catch (e) {
      return Left(_mapExceptionToFailure(e));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<String>>> uploadReturnImages(
    List<String> imagePaths,
  ) async {
    try {
      final urls = await _remoteDataSource.uploadReturnImages(imagePaths);
      return Right(urls);
    } on AppException catch (e) {
      return Left(_mapExceptionToFailure(e));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getReturnPolicy() async {
    try {
      final policy = await _remoteDataSource.getReturnPolicy();
      return Right(policy);
    } on AppException catch (e) {
      return Left(_mapExceptionToFailure(e));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  /// Map AppException to Failure
  Failure _mapExceptionToFailure(AppException exception) {
    if (exception is ServerException) {
      return ServerFailure(message: exception.message);
    } else if (exception is NetworkException) {
      return const NetworkFailure();
    } else if (exception is TimeoutException) {
      return const TimeoutFailure();
    } else if (exception is UnauthorizedException) {
      return AuthFailure(message: exception.message);
    } else if (exception is ValidationException) {
      return ValidationFailure(
        message: exception.message,
        errors: exception.errors,
      );
    } else if (exception is NotFoundException) {
      return NotFoundFailure(message: exception.message);
    } else {
      return UnknownFailure(message: exception.message);
    }
  }
}
