/// Locations Repository Interface - Domain layer contract
library;

import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/city_entity.dart';
import '../entities/country_entity.dart';
import '../entities/market_entity.dart';
import '../entities/shipping_calculation_entity.dart';

abstract class LocationsRepository {
  Future<Either<Failure, List<CountryEntity>>> getCountries();

  Future<Either<Failure, List<CityEntity>>> getCities({String? countryId});

  Future<Either<Failure, CityEntity>> getCityById(String cityId);

  Future<Either<Failure, List<MarketEntity>>> getMarketsByCity(String cityId);

  Future<Either<Failure, ShippingCalculationEntity>> calculateShipping({
    required String cityId,
    double? weight,
    double? orderTotal,
  });
}
