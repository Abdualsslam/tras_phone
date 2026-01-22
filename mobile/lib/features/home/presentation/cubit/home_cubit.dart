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
      // Load all data in parallel (banners are now handled by BannersCubit)
      final results = await Future.wait([
        _dataSource.getCategories(),
        _dataSource.getBrands(featured: true),
        _dataSource.getFeaturedProducts(),
        _dataSource.getNewArrivals(),
        _dataSource.getBestSellers(),
      ]);

      emit(
        HomeLoaded(
          categories: results[0] as dynamic,
          brands: results[1] as dynamic,
          featuredProducts: results[2] as dynamic,
          newArrivals: results[3] as dynamic,
          bestSellers: results[4] as dynamic,
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
