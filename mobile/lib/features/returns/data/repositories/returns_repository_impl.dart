/// Returns Repository Implementation
library;

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/errors/repository_guard.dart';
import '../../domain/entities/return_entity.dart';
import '../../domain/repositories/returns_repository.dart';
import '../datasources/returns_remote_datasource.dart';
import '../models/return_model.dart';

class ReturnsRepositoryImpl implements ReturnsRepository {
  final ReturnsRemoteDataSource _remoteDataSource;
  final RepositoryGuard _repositoryGuard;

  ReturnsRepositoryImpl({
    required ReturnsRemoteDataSource remoteDataSource,
    required RepositoryGuard repositoryGuard,
  }) : _remoteDataSource = remoteDataSource,
       _repositoryGuard = repositoryGuard;

  @override
  Future<Either<Failure, List<ReturnEntity>>> getMyReturns({
    ReturnStatus? status,
    int page = 1,
    int limit = 20,
  }) async {
    final result = await _repositoryGuard.guardEither(
      () => _remoteDataSource.getMyReturns(
        status: status,
        page: page,
        limit: limit,
      ),
      source: 'ReturnsRepository.getMyReturns',
    );

    return result.fold(
      Left.new,
      (returns) => Right(returns.map((model) => model.toEntity()).toList()),
    );
  }

  @override
  Future<Either<Failure, ReturnEntity>> getReturnById(String id) async {
    final result = await _repositoryGuard.guardEither(
      () => _remoteDataSource.getReturnById(id),
      source: 'ReturnsRepository.getReturnById',
    );

    return result.fold(
      Left.new,
      (returnModel) => Right(returnModel.toEntity()),
    );
  }

  @override
  Future<Either<Failure, ReturnEntity>> createReturn(
    CreateReturnRequest request,
  ) async {
    final result = await _repositoryGuard.guardEither(
      () => _remoteDataSource.createReturn(request),
      source: 'ReturnsRepository.createReturn',
    );

    return result.fold(
      Left.new,
      (returnModel) => Right(returnModel.toEntity()),
    );
  }

  @override
  Future<Either<Failure, bool>> cancelReturn(String id) =>
      _repositoryGuard.guardEither(
        () => _remoteDataSource.cancelReturn(id),
        source: 'ReturnsRepository.cancelReturn',
      );

  @override
  Future<Either<Failure, List<ReturnReasonEntity>>> getReturnReasons() async {
    final result = await _repositoryGuard.guardEither(
      _remoteDataSource.getReturnReasons,
      source: 'ReturnsRepository.getReturnReasons',
    );

    return result.fold(
      Left.new,
      (reasons) => Right(reasons.map((model) => model.toEntity()).toList()),
    );
  }

  @override
  Future<Either<Failure, List<String>>> uploadReturnImages(
    List<String> imagePaths,
  ) => _repositoryGuard.guardEither(
    () => _remoteDataSource.uploadReturnImages(imagePaths),
    source: 'ReturnsRepository.uploadReturnImages',
  );

  @override
  Future<Either<Failure, Map<String, dynamic>>> getReturnPolicy() =>
      _repositoryGuard.guardEither(
        _remoteDataSource.getReturnPolicy,
        source: 'ReturnsRepository.getReturnPolicy',
      );
}
