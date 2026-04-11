/// Products List Screen - Products with filters (featured, sort, etc.)
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/config/theme/app_colors.dart';
import '../../../../core/mixins/product_favorites_mixin.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/datasources/catalog_remote_datasource.dart';
import '../../data/models/product_filter_query.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/product_entity.dart';
import '../widgets/products_list_sections.dart';

class ProductsListScreen extends StatefulWidget {
  final bool? isFeatured;
  final String? sortBy;
  final String? title;
  final String? categoryId;
  final String? categoryName;
  final String? brandId;
  final String? brandName;
  final String? deviceId;
  final String? deviceName;

  const ProductsListScreen({
    super.key,
    this.isFeatured,
    this.sortBy,
    this.title,
    this.categoryId,
    this.categoryName,
    this.brandId,
    this.brandName,
    this.deviceId,
    this.deviceName,
  });

  @override
  State<ProductsListScreen> createState() => _ProductsListScreenState();
}

class _ProductsListScreenState extends State<ProductsListScreen>
    with ProductFavoritesMixin<ProductsListScreen> {
  late final CatalogRemoteDataSource _dataSource;
  final ScrollController _scrollController = ScrollController();

  List<ProductEntity> _products = [];
  List<CategoryEntity> _availableCategories = const [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasLoadedOnce = false;
  bool _hasMore = true;
  bool _isGridView = true;
  bool _isLoadingCategories = false;
  int _currentPage = 1;
  final int _limit = 20;
  String _sortBy = 'createdAt';
  String _sortOrder = 'desc';
  String? _selectedCategoryId;
  String? _selectedCategoryName;
  String? _errorMessage;

  String? get _fixedCategoryId {
    final value = widget.categoryId?.trim();
    if (value == null || value.isEmpty) return null;
    return value;
  }

  bool get _hasFixedCategoryFilter => _fixedCategoryId != null;

  bool get _canSelectCategoryFilter =>
      !_hasFixedCategoryFilter && (widget.deviceId?.isNotEmpty ?? false);

  String? get _activeCategoryId => _fixedCategoryId ?? _selectedCategoryId;

  bool get _hasCategoryFilter => _activeCategoryId?.isNotEmpty ?? false;

  bool get _isStrictCategoryDeviceFlow =>
      (_activeCategoryId?.isNotEmpty ?? false) &&
      (widget.deviceId?.isNotEmpty ?? false);

  String get _activeCategoryName {
    final fixedValue = widget.categoryName?.trim();
    if (_hasFixedCategoryFilter &&
        fixedValue != null &&
        fixedValue.isNotEmpty) {
      return fixedValue;
    }

    final selectedValue = _selectedCategoryName?.trim();
    if (selectedValue != null && selectedValue.isNotEmpty) {
      return selectedValue;
    }

    final activeId = _activeCategoryId;
    if (activeId != null) {
      final match = _availableCategories.where((item) => item.id == activeId);
      if (match.isNotEmpty) {
        return match.first.nameAr;
      }
    }

    return 'الفئة المختارة';
  }

  String get _resolvedTitle {
    if (widget.title != null && widget.title!.isNotEmpty) {
      return widget.title!;
    }
    if (widget.deviceName != null && widget.deviceName!.isNotEmpty) {
      return 'منتجات ${widget.deviceName!}';
    }
    if (widget.brandName != null && widget.brandName!.isNotEmpty) {
      return 'منتجات ${widget.brandName!}';
    }
    if (widget.categoryName != null && widget.categoryName!.isNotEmpty) {
      return 'منتجات ${widget.categoryName!}';
    }
    return widget.isFeatured == true
        ? AppLocalizations.of(context)!.featuredProducts
        : AppLocalizations.of(context)!.products;
  }

  @override
  void initState() {
    super.initState();
    _dataSource = context.read<CatalogRemoteDataSource>();
    _selectedCategoryId = _fixedCategoryId;
    _selectedCategoryName = widget.categoryName?.trim();

    if (widget.sortBy == 'newest') {
      _sortBy = 'createdAt';
      _sortOrder = 'desc';
    } else if (widget.sortBy != null) {
      _sortBy = widget.sortBy!;
    }

    _scrollController.addListener(_onScroll);
    _loadProducts();
    loadFavoriteProductIds();
    if (_canSelectCategoryFilter) {
      _loadCategoriesForFilter();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreProducts();
    }
  }

  Future<void> _loadCategoriesForFilter() async {
    setState(() => _isLoadingCategories = true);
    try {
      final categories = await _dataSource.getCategories();
      if (!mounted) return;

      setState(() {
        _availableCategories = categories;
        _isLoadingCategories = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoadingCategories = false);
    }
  }

  Future<void> _onCategoryFilterChanged({
    required String? categoryId,
    required String? categoryName,
  }) async {
    if (_hasFixedCategoryFilter || _selectedCategoryId == categoryId) return;

    setState(() {
      _selectedCategoryId = categoryId;
      _selectedCategoryName = categoryName;
      _products.clear();
      _hasLoadedOnce = false;
      _errorMessage = null;
    });

    await _loadProducts();
  }

  Future<({List<ProductEntity> products, int resolvedPage, int totalPages})>
  _loadStrictCategoryDevicePage({required int startPage}) async {
    final categoryId = _activeCategoryId!;
    final deviceId = widget.deviceId!;
    final sortByEnum = _getSortByEnum();
    final sortOrderEnum = _sortOrder == 'asc' ? SortOrder.asc : SortOrder.desc;

    var page = startPage;
    var totalPages = startPage;
    var matchedProducts = <ProductEntity>[];

    while (true) {
      final response = await _dataSource.getProductsWithFilter(
        ProductFilterQuery(
          deviceId: deviceId,
          sortBy: sortByEnum,
          sortOrder: sortOrderEnum,
          page: page,
          limit: _limit,
        ),
      );

      final pageProducts = response.toEntities();
      totalPages = response.pages < 1 ? 1 : response.pages;
      matchedProducts = pageProducts
          .where((product) => product.categoryId == categoryId)
          .toList();

      if (matchedProducts.isNotEmpty || page >= totalPages) {
        break;
      }

      page++;
    }

    return (
      products: matchedProducts,
      resolvedPage: page,
      totalPages: totalPages,
    );
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _currentPage = 1;
      _errorMessage = null;
      if (!_hasLoadedOnce) {
        _products.clear();
      }
      _hasMore = true;
    });

    try {
      if (_isStrictCategoryDeviceFlow) {
        final strictResult = await _loadStrictCategoryDevicePage(startPage: 1);
        if (!mounted) return;

        setState(() {
          _products = strictResult.products;
          _currentPage = strictResult.resolvedPage;
          _hasMore = _currentPage < strictResult.totalPages;
          _hasLoadedOnce = true;
          _isLoading = false;
        });
        return;
      }

      final response = await _dataSource.getProductsWithFilter(
        ProductFilterQuery(
          categoryId: _activeCategoryId,
          brandId: widget.brandId,
          deviceId: widget.deviceId,
          isFeatured: widget.isFeatured,
          sortBy: _getSortByEnum(),
          sortOrder: _sortOrder == 'asc' ? SortOrder.asc : SortOrder.desc,
          page: _currentPage,
          limit: _limit,
        ),
      );

      if (!mounted) return;

      setState(() {
        _products = response.toEntities();
        _hasMore = _currentPage < response.pages;
        _hasLoadedOnce = true;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = error.toString();
      });

      if (_hasLoadedOnce && _products.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تعذر تحديث المنتجات في الوقت الحالي'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _loadMoreProducts() async {
    if (_isLoadingMore || !_hasMore) return;

    setState(() => _isLoadingMore = true);
    final nextPage = _currentPage + 1;

    try {
      if (_isStrictCategoryDeviceFlow) {
        final strictResult = await _loadStrictCategoryDevicePage(
          startPage: nextPage,
        );
        if (!mounted) return;

        setState(() {
          _products.addAll(strictResult.products);
          _currentPage = strictResult.resolvedPage;
          _hasMore = _currentPage < strictResult.totalPages;
          _isLoadingMore = false;
        });
        return;
      }

      final response = await _dataSource.getProductsWithFilter(
        ProductFilterQuery(
          categoryId: _activeCategoryId,
          brandId: widget.brandId,
          deviceId: widget.deviceId,
          isFeatured: widget.isFeatured,
          sortBy: _getSortByEnum(),
          sortOrder: _sortOrder == 'asc' ? SortOrder.asc : SortOrder.desc,
          page: nextPage,
          limit: _limit,
        ),
      );

      if (!mounted) return;

      setState(() {
        _products.addAll(response.toEntities());
        _currentPage = nextPage;
        _hasMore = _currentPage < response.pages;
        _isLoadingMore = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoadingMore = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تعذر تحميل المزيد من المنتجات'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  ProductSortBy? _getSortByEnum() {
    switch (_sortBy) {
      case 'createdAt':
        return ProductSortBy.createdAt;
      case 'price':
        return ProductSortBy.price;
      case 'name':
        return ProductSortBy.name;
      case 'salesCount':
        return ProductSortBy.salesCount;
      default:
        return ProductSortBy.createdAt;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_resolvedTitle),
        actions: [
          IconButton(
            onPressed: () => context.push('/search'),
            icon: Icon(Iconsax.search_normal, size: 22.sp),
          ),
          IconButton(
            onPressed: _showFilterSheet,
            icon: Icon(Iconsax.filter, size: 22.sp),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadProducts,
        child: Column(
          children: [
            ProductsListTopBar(
              productsCount: _products.length,
              isLoading: _isLoading && _hasLoadedOnce,
              sortLabel: _getSortLabel(),
              isGridView: _isGridView,
              onSortTap: _showSortOptions,
              onLayoutToggle: () => setState(() => _isGridView = !_isGridView),
            ),
            if (_hasFixedCategoryFilter)
              ActiveCategoryFilterBar(categoryName: _activeCategoryName),
            if (_canSelectCategoryFilter)
              SelectableCategoryFilterBar(
                isLoadingCategories: _isLoadingCategories,
                activeCategoryId: _activeCategoryId,
                categories: _availableCategories,
                onCategorySelected: (category) => _onCategoryFilterChanged(
                  categoryId: category?.id,
                  categoryName: category?.nameAr,
                ),
              ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: _buildBody(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading && !_hasLoadedOnce) {
      return const ProductsGridShimmer();
    }

    if (_errorMessage != null && _products.isEmpty) {
      return ProductsErrorState(onRetry: _loadProducts);
    }

    if (_products.isEmpty) {
      return ProductsEmptyState(
        isStrictCategoryDeviceFlow: _isStrictCategoryDeviceFlow,
      );
    }

    if (_isGridView) {
      return ProductsGridSection(
        scrollController: _scrollController,
        products: _products,
        isLoadingMore: _isLoadingMore,
        isProductFavorite: isProductFavorite,
        onProductTap: _openProductDetails,
        onToggleFavorite: _toggleProductFavorite,
      );
    }

    return ProductsListSection(
      scrollController: _scrollController,
      products: _products,
      isLoadingMore: _isLoadingMore,
      isProductFavorite: isProductFavorite,
      onProductTap: _openProductDetails,
      onToggleFavorite: _toggleProductFavorite,
    );
  }

  void _openProductDetails(ProductEntity product) {
    context.push('/product/${product.id}', extra: product);
  }

  void _toggleProductFavorite(ProductEntity product) {
    toggleFavoriteProduct(product.id);
  }

  String _getSortLabel() {
    switch (_sortBy) {
      case 'createdAt':
        return _sortOrder == 'desc' ? 'الأحدث' : 'الأقدم';
      case 'price':
        return _sortOrder == 'asc' ? 'السعر: الأقل' : 'السعر: الأعلى';
      case 'name':
        return 'الاسم';
      case 'salesCount':
        return 'الأكثر مبيعاً';
      default:
        return 'ترتيب';
    }
  }

  void _showSortOptions() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (sheetContext) => ProductsSortSheet(
        activeSortBy: _sortBy,
        activeSortOrder: _sortOrder,
        onSortSelected: (sortBy, sortOrder) {
          setState(() {
            _sortBy = sortBy;
            _sortOrder = sortOrder;
          });
          Navigator.pop(sheetContext);
          _loadProducts();
        },
      ),
    );
  }

  void _showFilterSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (sheetContext) => DraggableScrollableSheet(
        initialChildSize: 0.65,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: ProductsFilterSheet(
            hasCategoryFilter: _hasCategoryFilter,
            activeCategoryName: _activeCategoryName,
            activeSortLabel: _getSortLabel(),
            onClose: () => Navigator.pop(sheetContext),
          ),
        ),
      ),
    );
  }
}
