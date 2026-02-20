/// Locations Cubit
library;

import 'dart:developer' as developer;
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/city_entity.dart';
import '../../domain/entities/country_entity.dart';
import '../../domain/entities/market_entity.dart';
import '../../domain/repositories/locations_repository.dart';
import 'locations_state.dart';

class LocationsCubit extends Cubit<LocationsState> {
  final LocationsRepository _repository;

  LocationsCubit({required LocationsRepository repository})
      : _repository = repository,
        super(const LocationsState());

  /// تحميل الدول
  Future<void> loadCountries() async {
    emit(state.copyWith(status: LocationsStatus.loading));

    final result = await _repository.getCountries();

    result.fold(
      (failure) {
        developer.log('Error loading countries: ${failure.message}',
            name: 'LocationsCubit');
        emit(state.copyWith(
          status: LocationsStatus.failure,
          errorMessage: failure.message,
        ));
      },
      (countries) async {
        developer.log('Loaded ${countries.length} countries',
            name: 'LocationsCubit');

        if (countries.isEmpty) {
          emit(state.copyWith(
              status: LocationsStatus.success, countries: countries));
          return;
        }

        final defaultCountry = countries.firstWhere(
          (c) => c.isDefault,
          orElse: () => countries.first,
        );

        emit(state.copyWith(
          status: LocationsStatus.success,
          countries: countries,
          selectedCountry: defaultCountry,
        ));

        await loadCities(countryId: defaultCountry.id);
      },
    );
  }

  /// تحميل المدن
  Future<void> loadCities({String? countryId}) async {
    final result = await _repository.getCities(countryId: countryId);

    result.fold(
      (failure) {
        developer.log('Error loading cities: ${failure.message}',
            name: 'LocationsCubit');
        emit(state.copyWith(
          status: LocationsStatus.failure,
          errorMessage: failure.message,
        ));
      },
      (cities) {
        developer.log('Loaded ${cities.length} cities', name: 'LocationsCubit');
        emit(state.copyWith(status: LocationsStatus.success, cities: cities));
      },
    );
  }

  /// تحديد الدولة
  void selectCountry(CountryEntity country) {
    emit(state.copyWith(
      selectedCountry: country,
      selectedCity: null,
      selectedMarket: null,
      markets: [],
    ));
    loadCities(countryId: country.id);
  }

  /// تحديد المدينة
  Future<void> selectCity(CityEntity city) async {
    emit(state.copyWith(selectedCity: city, selectedMarket: null));
    await loadMarkets(city.id);
  }

  /// تحميل الأسواق
  Future<void> loadMarkets(String cityId) async {
    final result = await _repository.getMarketsByCity(cityId);
    result.fold(
      (_) => emit(state.copyWith(markets: [])),
      (markets) => emit(state.copyWith(markets: markets)),
    );
  }

  /// تحديد السوق
  void selectMarket(MarketEntity market) {
    emit(state.copyWith(selectedMarket: market));
  }

  /// حساب تكلفة الشحن
  Future<void> calculateShipping({
    required String cityId,
    double? weight,
    double? orderTotal,
  }) async {
    final result = await _repository.calculateShipping(
      cityId: cityId,
      weight: weight,
      orderTotal: orderTotal,
    );
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (calculation) => emit(state.copyWith(shippingCalculation: calculation)),
    );
  }

  /// إعادة تعيين الحالة
  void reset() => emit(const LocationsState());
}
