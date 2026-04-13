/// Locations Repository Implementation
library;

import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/repository_guard.dart';
import '../../domain/entities/city_entity.dart';
import '../../domain/entities/country_entity.dart';
import '../../domain/entities/market_entity.dart';
import '../../domain/entities/shipping_calculation_entity.dart';
import '../../domain/repositories/locations_repository.dart';
import '../datasources/locations_remote_datasource.dart';

class LocationsRepositoryImpl implements LocationsRepository {
  final LocationsRemoteDataSource _dataSource;
  final RepositoryGuard _repositoryGuard;

  LocationsRepositoryImpl({
    required LocationsRemoteDataSource dataSource,
    required RepositoryGuard repositoryGuard,
  }) : _dataSource = dataSource,
       _repositoryGuard = repositoryGuard;

  @override
  Future<Either<Failure, List<CountryEntity>>> getCountries() async {
    final result = await _repositoryGuard.guardEither(
      _dataSource.getCountries,
      source: 'LocationsRepository.getCountries',
    );
    return result.fold(
      Left.new,
      (models) => Right(models.map((m) => m.toEntity()).toList()),
    );
  }

  @override
  Future<Either<Failure, List<CityEntity>>> getCities({
    String? countryId,
  }) async {
    final result = await _repositoryGuard.guardEither(
      () => _dataSource.getCities(countryId: countryId),
      source: 'LocationsRepository.getCities',
    );
    return result.fold(
      Left.new,
      (models) => Right(models.map((m) => m.toEntity()).toList()),
    );
  }

  @override
  Future<Either<Failure, CityEntity>> getCityById(String cityId) async {
    final result = await _repositoryGuard.guardEither(
      () => _dataSource.getCityById(cityId),
      source: 'LocationsRepository.getCityById',
    );
    return result.fold(Left.new, (model) => Right(model.toEntity()));
  }

  @override
  Future<Either<Failure, List<MarketEntity>>> getMarketsByCity(
    String cityId,
  ) async {
    final result = await _repositoryGuard.guardEither(
      () => _dataSource.getMarketsByCity(cityId),
      source: 'LocationsRepository.getMarketsByCity',
    );
    return result.fold(
      Left.new,
      (models) => Right(models.map((m) => m.toEntity()).toList()),
    );
  }

  @override
  Future<Either<Failure, ShippingCalculationEntity>> calculateShipping({
    required String cityId,
    double? weight,
    double? orderTotal,
  }) async {
    final result = await _repositoryGuard.guardEither(
      () => _dataSource.calculateShipping(
        cityId: cityId,
        weight: weight,
        orderTotal: orderTotal,
      ),
      source: 'LocationsRepository.calculateShipping',
    );
    return result.fold(Left.new, (model) => Right(model.toEntity()));
  }
}
