/// Locations Cubit
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/locations_remote_datasource.dart';
import '../../data/models/city_model.dart';
import '../../data/models/country_model.dart';
import '../../data/models/market_model.dart';
import 'locations_state.dart';

class LocationsCubit extends Cubit<LocationsState> {
  final LocationsRemoteDataSource _dataSource;

  LocationsCubit({required LocationsRemoteDataSource dataSource})
      : _dataSource = dataSource,
        super(const LocationsState());

  /// تحميل الدول
  Future<void> loadCountries() async {
    emit(state.copyWith(status: LocationsStatus.loading));
    try {
      final countries = await _dataSource.getCountries();
      final defaultCountry = countries.firstWhere(
        (c) => c.isDefault,
        orElse: () => countries.first,
      );
      emit(state.copyWith(
        status: LocationsStatus.success,
        countries: countries,
        selectedCountry: defaultCountry,
      ));
      // تحميل مدن الدولة الافتراضية
      await loadCities(countryId: defaultCountry.id);
    } catch (e) {
      emit(state.copyWith(
        status: LocationsStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  /// تحميل المدن
  Future<void> loadCities({String? countryId}) async {
    try {
      final cities = await _dataSource.getCities(countryId: countryId);
      emit(state.copyWith(
        status: LocationsStatus.success,
        cities: cities,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: LocationsStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  /// تحديد الدولة
  void selectCountry(CountryModel country) {
    emit(state.copyWith(
      selectedCountry: country,
      selectedCity: null,
      selectedMarket: null,
      markets: [],
    ));
    loadCities(countryId: country.id);
  }

  /// تحديد المدينة
  Future<void> selectCity(CityModel city) async {
    emit(state.copyWith(
      selectedCity: city,
      selectedMarket: null,
    ));
    // تحميل الأسواق
    await loadMarkets(city.id);
  }

  /// تحميل الأسواق
  Future<void> loadMarkets(String cityId) async {
    try {
      final markets = await _dataSource.getMarketsByCity(cityId);
      emit(state.copyWith(markets: markets));
    } catch (e) {
      emit(state.copyWith(markets: []));
    }
  }

  /// تحديد السوق
  void selectMarket(MarketModel market) {
    emit(state.copyWith(selectedMarket: market));
  }

  /// حساب تكلفة الشحن
  Future<void> calculateShipping({
    required String cityId,
    double? weight,
    double? orderTotal,
  }) async {
    try {
      final calculation = await _dataSource.calculateShipping(
        cityId: cityId,
        weight: weight,
        orderTotal: orderTotal,
      );
      emit(state.copyWith(shippingCalculation: calculation));
    } catch (e) {
      emit(state.copyWith(
        errorMessage: e.toString(),
      ));
    }
  }

  /// إعادة تعيين الحالة
  void reset() {
    emit(const LocationsState());
  }
}
