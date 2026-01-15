/// Locations State
import 'package:equatable/equatable.dart';
import '../../data/models/country_model.dart';
import '../../data/models/city_model.dart';
import '../../data/models/market_model.dart';
import '../../data/models/shipping_calculation_model.dart';

enum LocationsStatus { initial, loading, success, failure }

class LocationsState extends Equatable {
  final LocationsStatus status;
  final List<CountryModel> countries;
  final List<CityModel> cities;
  final List<MarketModel> markets;
  final CountryModel? selectedCountry;
  final CityModel? selectedCity;
  final MarketModel? selectedMarket;
  final ShippingCalculationModel? shippingCalculation;
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
    List<CountryModel>? countries,
    List<CityModel>? cities,
    List<MarketModel>? markets,
    CountryModel? selectedCountry,
    CityModel? selectedCity,
    MarketModel? selectedMarket,
    ShippingCalculationModel? shippingCalculation,
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
