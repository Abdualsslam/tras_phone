/// Products On Offer Cubit - Manages products on offer state
library;

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/catalog_repository.dart';
import 'products_on_offer_state.dart';

/// Cubit for managing products on offer
class ProductsOnOfferCubit extends Cubit<ProductsOnOfferState> {
  final CatalogRepository _repository;

  int _currentPage = 1;
  final int _limit = 20;
  bool _hasMore = true;
  List<ProductEntity> _products = [];

  // Filters
  String _sortBy = 'discount';
  String _sortOrder = 'desc';
  double? _minDiscount;
  double? _maxDiscount;
  String? _categoryId;
  String? _brandId;

  ProductsOnOfferCubit({required CatalogRepository repository})
      : _repository = repository,
        super(const ProductsOnOfferInitial());

  /// Get current products list
  List<ProductEntity> get products => _products;

  /// Get current filters
  String get sortBy => _sortBy;
  String get sortOrder => _sortOrder;
  double? get minDiscount => _minDiscount;
  double? get maxDiscount => _maxDiscount;
  String? get categoryId => _categoryId;
  String? get brandId => _brandId;
  bool get hasMore => _hasMore;
  int get currentPage => _currentPage;

  /// Load products on offer
  Future<void> loadProducts({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _products.clear();
      _hasMore = true;
    }

    if (!_hasMore && !refresh) return;

    if (_currentPage == 1) {
      emit(const ProductsOnOfferLoading());
    }

    try {
      final result = await _repository.getProductsOnOffer(
        page: _currentPage,
        limit: _limit,
        sortBy: _sortBy,
        sortOrder: _sortOrder,
        minDiscount: _minDiscount,
        maxDiscount: _maxDiscount,
        categoryId: _categoryId,
        brandId: _brandId,
      );

      result.fold(
        (failure) => emit(ProductsOnOfferError(failure.message)),
        (response) {
          _products.addAll(response.toEntities());
          _hasMore = _currentPage < response.pages;
          _currentPage++;

          emit(ProductsOnOfferLoaded(
            products: List.from(_products),
            hasMore: _hasMore,
            currentPage: _currentPage - 1,
            totalPages: response.pages,
          ));
        },
      );
    } catch (e) {
      emit(ProductsOnOfferError(e.toString()));
    }
  }

  /// Update filters and reload products
  void updateFilters({
    String? sortBy,
    String? sortOrder,
    double? minDiscount,
    double? maxDiscount,
    String? categoryId,
    String? brandId,
  }) {
    _sortBy = sortBy ?? _sortBy;
    _sortOrder = sortOrder ?? _sortOrder;
    _minDiscount = minDiscount;
    _maxDiscount = maxDiscount;
    _categoryId = categoryId;
    _brandId = brandId;
    loadProducts(refresh: true);
  }

  /// Reset filters
  void resetFilters() {
    _sortBy = 'discount';
    _sortOrder = 'desc';
    _minDiscount = null;
    _maxDiscount = null;
    _categoryId = null;
    _brandId = null;
    loadProducts(refresh: true);
  }
}
