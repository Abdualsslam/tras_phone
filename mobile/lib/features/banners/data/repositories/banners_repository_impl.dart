/// Banners Repository Implementation
library;

import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/repository_guard.dart';
import '../../domain/entities/banner_entity.dart';
import '../../domain/enums/banner_position.dart';
import '../../domain/repositories/banners_repository.dart';
import '../datasources/banners_remote_datasource.dart';

class BannersRepositoryImpl implements BannersRepository {
  final BannersRemoteDataSource _remoteDataSource;
  final RepositoryGuard _repositoryGuard;

  BannersRepositoryImpl({
    required BannersRemoteDataSource remoteDataSource,
    required RepositoryGuard repositoryGuard,
  }) : _remoteDataSource = remoteDataSource,
       _repositoryGuard = repositoryGuard;

  @override
  Future<Either<Failure, List<BannerEntity>>> getBanners({
    BannerPosition? placement,
    bool forceRefresh = false,
  }) => _repositoryGuard.guardEither(
    () => _remoteDataSource.getBanners(
        placement: placement,
        forceRefresh: forceRefresh,
      ),
    source: 'BannersRepository.getBanners',
  );

  @override
  Future<void> recordImpression(String bannerId) =>
      _remoteDataSource.recordImpression(bannerId);

  @override
  Future<void> recordClick(String bannerId) =>
      _remoteDataSource.recordClick(bannerId);
}
