/// Banners Repository Interface - Domain layer contract
library;

import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/banner_entity.dart';
import '../enums/banner_position.dart';

abstract class BannersRepository {
  Future<Either<Failure, List<BannerEntity>>> getBanners({
    BannerPosition? placement,
    bool forceRefresh = false,
  });

  Future<void> recordImpression(String bannerId);

  Future<void> recordClick(String bannerId);
}
