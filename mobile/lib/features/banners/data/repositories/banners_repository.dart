/// Banners Repository
library;

import '../../domain/entities/banner_entity.dart';
import '../../domain/enums/banner_position.dart';
import '../datasources/banners_remote_datasource.dart';

/// Abstract interface for banners repository
abstract class BannersRepository {
  Future<List<BannerEntity>> getBanners({BannerPosition? placement});
  Future<void> recordImpression(String bannerId);
  Future<void> recordClick(String bannerId);
}

/// Implementation of BannersRepository
class BannersRepositoryImpl implements BannersRepository {
  final BannersRemoteDataSource _remoteDataSource;

  BannersRepositoryImpl({required BannersRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<List<BannerEntity>> getBanners({BannerPosition? placement}) async {
    return await _remoteDataSource.getBanners(placement: placement);
  }

  @override
  Future<void> recordImpression(String bannerId) async {
    return await _remoteDataSource.recordImpression(bannerId);
  }

  @override
  Future<void> recordClick(String bannerId) async {
    return await _remoteDataSource.recordClick(bannerId);
  }
}
