/// Brands Cubit - Manages brands state
library;

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/catalog_repository.dart';
import 'brands_state.dart';

/// Cubit for managing brands list
class BrandsCubit extends Cubit<BrandsState> {
  final CatalogRepository _repository;

  BrandsCubit({required CatalogRepository repository})
      : _repository = repository,
        super(const BrandsInitial());

  /// Load all brands
  Future<void> loadBrands({bool? featured}) async {
    emit(const BrandsLoading());

    final result = await _repository.getBrands(featured: featured);

    result.fold(
      (failure) => emit(BrandsError(failure.message)),
      (brands) => emit(BrandsLoaded(brands)),
    );
  }

  /// Load featured brands only
  Future<void> loadFeaturedBrands() async {
    await loadBrands(featured: true);
  }
}

/// Cubit for managing single brand details
class BrandDetailsCubit extends Cubit<BrandDetailsState> {
  final CatalogRepository _repository;

  BrandDetailsCubit({required CatalogRepository repository})
      : _repository = repository,
        super(const BrandDetailsInitial());

  /// Load brand by slug
  Future<void> loadBrand(String slug) async {
    emit(const BrandDetailsLoading());

    final result = await _repository.getBrandBySlug(slug);

    result.fold(
      (failure) => emit(BrandDetailsError(failure.message)),
      (brand) => emit(BrandDetailsLoaded(brand)),
    );
  }
}
