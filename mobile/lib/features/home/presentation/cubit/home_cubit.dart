/// Home Cubit - Manages home screen state
library;

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../catalog/data/datasources/catalog_remote_datasource.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final CatalogRemoteDataSource _dataSource;

  HomeCubit({required CatalogRemoteDataSource dataSource})
    : _dataSource = dataSource,
      super(const HomeInitial());

  Future<void> loadHomeData() async {
    emit(const HomeLoading());

    try {
      // Load all data in parallel
      final results = await Future.wait([
        _dataSource.getBanners(placement: 'home_slider'),
        _dataSource.getCategories(),
        _dataSource.getBrands(featured: true),
        _dataSource.getFeaturedProducts(),
        _dataSource.getNewArrivals(),
        _dataSource.getBestSellers(),
      ]);

      emit(
        HomeLoaded(
          banners: results[0] as dynamic,
          categories: results[1] as dynamic,
          brands: results[2] as dynamic,
          featuredProducts: results[3] as dynamic,
          newArrivals: results[4] as dynamic,
          bestSellers: results[5] as dynamic,
        ),
      );
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }

  Future<void> refresh() async {
    await loadHomeData();
  }
}
