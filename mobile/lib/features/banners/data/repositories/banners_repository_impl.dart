/// Banners Repository Implementation
library;

import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/banner_entity.dart';
import '../../domain/enums/banner_position.dart';
import '../../domain/repositories/banners_repository.dart';
import '../datasources/banners_remote_datasource.dart';

class BannersRepositoryImpl implements BannersRepository {
  final BannersRemoteDataSource _remoteDataSource;

  BannersRepositoryImpl({required BannersRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<Either<Failure, List<BannerEntity>>> getBanners({
    BannerPosition? placement,
    bool forceRefresh = false,
  }) async {
    try {
      final banners = await _remoteDataSource.getBanners(
        placement: placement,
        forceRefresh: forceRefresh,
      );
      return Right(banners);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<void> recordImpression(String bannerId) =>
      _remoteDataSource.recordImpression(bannerId);

  @override
  Future<void> recordClick(String bannerId) =>
      _remoteDataSource.recordClick(bannerId);
}
