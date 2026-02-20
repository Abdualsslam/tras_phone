/// Locations State
library;

import 'package:equatable/equatable.dart';
import '../../domain/entities/city_entity.dart';
import '../../domain/entities/country_entity.dart';
import '../../domain/entities/market_entity.dart';
import '../../domain/entities/shipping_calculation_entity.dart';

enum LocationsStatus { initial, loading, success, failure }

class LocationsState extends Equatable {
  final LocationsStatus status;
  final List<CountryEntity> countries;
  final List<CityEntity> cities;
  final List<MarketEntity> markets;
  final CountryEntity? selectedCountry;
  final CityEntity? selectedCity;
  final MarketEntity? selectedMarket;
  final ShippingCalculationEntity? shippingCalculation;
  final String? errorMessage;

  const LocationsState({
    this.status = LocationsStatus.initial,
    this.countries = const [],
    this.cities = const [],
    this.markets = const [],
    this.selectedCountry,
    this.selectedCity,
    this.selectedMarket,
    this.shippingCalculation,
    this.errorMessage,
  });

  LocationsState copyWith({
    LocationsStatus? status,
    List<CountryEntity>? countries,
    List<CityEntity>? cities,
    List<MarketEntity>? markets,
    CountryEntity? selectedCountry,
    CityEntity? selectedCity,
    MarketEntity? selectedMarket,
    ShippingCalculationEntity? shippingCalculation,
    String? errorMessage,
  }) {
    return LocationsState(
      status: status ?? this.status,
      countries: countries ?? this.countries,
      cities: cities ?? this.cities,
      markets: markets ?? this.markets,
      selectedCountry: selectedCountry ?? this.selectedCountry,
      selectedCity: selectedCity ?? this.selectedCity,
      selectedMarket: selectedMarket ?? this.selectedMarket,
      shippingCalculation: shippingCalculation ?? this.shippingCalculation,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        countries,
        cities,
        markets,
        selectedCountry,
        selectedCity,
        selectedMarket,
        shippingCalculation,
        errorMessage,
      ];
}
