/// Locations Repository Implementation
library;

import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/city_entity.dart';
import '../../domain/entities/country_entity.dart';
import '../../domain/entities/market_entity.dart';
import '../../domain/entities/shipping_calculation_entity.dart';
import '../../domain/repositories/locations_repository.dart';
import '../datasources/locations_remote_datasource.dart';

class LocationsRepositoryImpl implements LocationsRepository {
  final LocationsRemoteDataSource _dataSource;

  LocationsRepositoryImpl({required LocationsRemoteDataSource dataSource})
      : _dataSource = dataSource;

  @override
  Future<Either<Failure, List<CountryEntity>>> getCountries() async {
    try {
      final models = await _dataSource.getCountries();
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CityEntity>>> getCities({
    String? countryId,
  }) async {
    try {
      final models = await _dataSource.getCities(countryId: countryId);
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, CityEntity>> getCityById(String cityId) async {
    try {
      final model = await _dataSource.getCityById(cityId);
      return Right(model.toEntity());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<MarketEntity>>> getMarketsByCity(
    String cityId,
  ) async {
    try {
      final models = await _dataSource.getMarketsByCity(cityId);
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ShippingCalculationEntity>> calculateShipping({
    required String cityId,
    double? weight,
    double? orderTotal,
  }) async {
    try {
      final model = await _dataSource.calculateShipping(
        cityId: cityId,
        weight: weight,
        orderTotal: orderTotal,
      );
      return Right(model.toEntity());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
