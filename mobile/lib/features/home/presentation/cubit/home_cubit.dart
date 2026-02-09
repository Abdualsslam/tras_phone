/// Home Cubit - Manages home screen state
library;

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../catalog/data/datasources/catalog_remote_datasource.dart';
import '../../../catalog/domain/entities/brand_entity.dart';
import '../../../catalog/domain/entities/category_entity.dart';
import '../../../catalog/domain/entities/product_entity.dart';
import '../../data/services/home_cache_service.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final CatalogRemoteDataSource _dataSource;
  final HomeCacheService _cacheService;

  HomeCubit({
    required CatalogRemoteDataSource dataSource,
    required HomeCacheService cacheService,
  })  : _dataSource = dataSource,
        _cacheService = cacheService,
        super(const HomeInitial());

  /// Load home data - tries cache first, then API
  Future<void> loadHomeData() async {
    emit(const HomeLoading());

    try {
      // Try to get from cache first
      final cachedData = await _cacheService.getHomeData();
      if (cachedData != null && await _cacheService.isCacheValid()) {
        final entities = cachedData.toEntities();
        emit(
          HomeLoadedFromCache(
            categories: entities.categories,
            brands: entities.brands,
            featuredProducts: entities.featuredProducts,
            newArrivals: entities.newArrivals,
            bestSellers: entities.bestSellers,
          ),
        );
        // Load fresh data in background and update cache
        _loadAndUpdateCache();
        return;
      }

      // If no cache or expired, load from API
      await _loadFromApi();
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }

  /// Refresh - loads from API in background, keeps current data visible
  /// Avoids full UI replacement; only updates when new data arrives
  Future<void> refresh() async {
    final hadData = state is HomeLoaded || state is HomeLoadedFromCache;
    await _loadFromApi(silentFail: hadData);
  }

  /// Load data from API and save to cache
  /// [silentFail] when true, don't emit HomeError on failure (keeps current data)
  Future<void> _loadFromApi({bool silentFail = false}) async {
    try {
      // Load all data in parallel
      final results = await Future.wait([
        _dataSource.getCategories(),
        _dataSource.getBrands(featured: true),
        _dataSource.getFeaturedProducts(),
        _dataSource.getNewArrivals(),
        _dataSource.getBestSellers(),
      ]);

      final categories = results[0] as List<CategoryEntity>;
      final brands = results[1] as List<BrandEntity>;
      final featuredProducts = results[2] as List<ProductEntity>;
      final newArrivals = results[3] as List<ProductEntity>;
      final bestSellers = results[4] as List<ProductEntity>;

      // Save to cache
      await _cacheService.saveHomeData(
        categories: categories,
        brands: brands,
        featuredProducts: featuredProducts,
        newArrivals: newArrivals,
        bestSellers: bestSellers,
      );

      emit(
        HomeLoaded(
          categories: categories,
          brands: brands,
          featuredProducts: featuredProducts,
          newArrivals: newArrivals,
          bestSellers: bestSellers,
        ),
      );
    } catch (e) {
      if (!silentFail) emit(HomeError(e.toString()));
    }
  }

  /// Load from API in background and update cache (non-blocking)
  Future<void> _loadAndUpdateCache() async {
    try {
      final results = await Future.wait([
        _dataSource.getCategories(),
        _dataSource.getBrands(featured: true),
        _dataSource.getFeaturedProducts(),
        _dataSource.getNewArrivals(),
        _dataSource.getBestSellers(),
      ]);

      final categories = results[0] as List<CategoryEntity>;
      final brands = results[1] as List<BrandEntity>;
      final featuredProducts = results[2] as List<ProductEntity>;
      final newArrivals = results[3] as List<ProductEntity>;
      final bestSellers = results[4] as List<ProductEntity>;

      // Update cache silently
      await _cacheService.saveHomeData(
        categories: categories,
        brands: brands,
        featuredProducts: featuredProducts,
        newArrivals: newArrivals,
        bestSellers: bestSellers,
      );

      // If still in cache state, update to fresh data
      if (state is HomeLoadedFromCache) {
        emit(
          HomeLoaded(
            categories: categories,
            brands: brands,
            featuredProducts: featuredProducts,
            newArrivals: newArrivals,
            bestSellers: bestSellers,
          ),
        );
      }
    } catch (e) {
      // Ignore background update errors - don't break the UI
    }
  }
}
