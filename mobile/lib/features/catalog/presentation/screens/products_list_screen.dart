/// Products List Screen - Products with filters (featured, sort, etc.)
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/config/theme/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/mixins/product_favorites_mixin.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/datasources/catalog_remote_datasource.dart';
import '../../data/models/product_filter_query.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/product_entity.dart';

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
  final _dataSource = getIt<CatalogRemoteDataSource>();
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
            _buildSortBar(isDark),
            if (_hasFixedCategoryFilter) _buildCategoryFilterBar(isDark),
            if (_canSelectCategoryFilter)
              _buildSelectableCategoryFilterBar(isDark),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: _buildBody(isDark),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(bool isDark) {
    if (_isLoading && !_hasLoadedOnce) {
      return const ProductsGridShimmer();
    }

    if (_errorMessage != null && _products.isEmpty) {
      return _buildErrorState(isDark);
    }

    if (_products.isEmpty) {
      return _buildEmptyState(isDark);
    }

    return _isGridView ? _buildProductsGrid() : _buildProductsList();
  }

  Widget _buildSortBar(bool isDark) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
          ),
        ),
      ),
      child: Row(
        children: [
          Text(
            '${_products.length} منتج',
            style: TextStyle(
              fontSize: 14.sp,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
          if (_isLoading && _hasLoadedOnce) ...[
            SizedBox(width: 10.w),
            SizedBox(
              width: 14.w,
              height: 14.w,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            ),
          ],
          const Spacer(),
          GestureDetector(
            onTap: _showSortOptions,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : AppColors.backgroundLight,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                children: [
                  Icon(Iconsax.sort, size: 16.sp, color: AppColors.primary),
                  SizedBox(width: 6.w),
                  Text(
                    _getSortLabel(),
                    style: TextStyle(fontSize: 12.sp, color: AppColors.primary),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 8.w),
          GestureDetector(
            onTap: () => setState(() => _isGridView = !_isGridView),
            child: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : AppColors.backgroundLight,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                _isGridView ? Iconsax.menu_1 : Iconsax.element_3,
                size: 18.sp,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilterBar(bool isDark) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 10.h),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(Iconsax.filter, size: 14.sp, color: AppColors.primary),
          SizedBox(width: 8.w),
          Text(
            'فلتر الفئة:',
            style: TextStyle(
              fontSize: 12.sp,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Iconsax.category,
                      size: 12.sp,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      _activeCategoryName,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectableCategoryFilterBar(bool isDark) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 10.h),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Iconsax.filter, size: 14.sp, color: AppColors.primary),
              SizedBox(width: 8.w),
              Text(
                'اختر الفئة:',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
              if (_isLoadingCategories) ...[
                SizedBox(width: 8.w),
                SizedBox(
                  width: 12.w,
                  height: 12.w,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: 8.h),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildCategoryChoiceChip(
                  label: 'كل الفئات',
                  isSelected: _activeCategoryId == null,
                  isDark: isDark,
                  onTap: () => _onCategoryFilterChanged(
                    categoryId: null,
                    categoryName: null,
                  ),
                ),
                for (final category in _availableCategories) ...[
                  SizedBox(width: 8.w),
                  _buildCategoryChoiceChip(
                    label: category.nameAr,
                    isSelected: _activeCategoryId == category.id,
                    isDark: isDark,
                    onTap: () => _onCategoryFilterChanged(
                      categoryId: category.id,
                      categoryName: category.nameAr,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChoiceChip({
    required String label,
    required bool isSelected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.12)
              : (isDark ? AppColors.cardDark : AppColors.backgroundLight),
          borderRadius: BorderRadius.circular(999.r),
          border: Border.all(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.4)
                : (isDark ? AppColors.dividerDark : AppColors.dividerLight),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected) ...[
              Icon(Iconsax.category, size: 12.sp, color: AppColors.primary),
              SizedBox(width: 6.w),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? AppColors.primary
                    : (isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductsGrid() {
    return GridView.builder(
      key: const ValueKey('products-grid'),
      controller: _scrollController,
      padding: EdgeInsets.all(16.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12.h,
        crossAxisSpacing: 12.w,
        childAspectRatio: 0.60,
      ),
      itemCount: _products.length + (_isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= _products.length) {
          return const _LoadMoreProductsIndicator();
        }

        final product = _products[index];
        return ProductCard(
          id: product.id.toString(),
          name: product.name,
          nameAr: product.nameAr,
          imageUrl: product.imageUrl,
          price: product.price,
          originalPrice: product.originalPrice,
          stockQuantity: product.stockQuantity,
          isFavorite: isProductFavorite(product.id),
          onTap: () => context.push('/product/${product.id}', extra: product),
          onToggleFavorite: () => toggleFavoriteProduct(product.id),
        );
      },
    );
  }

  Widget _buildProductsList() {
    return ListView.separated(
      key: const ValueKey('products-list'),
      controller: _scrollController,
      padding: EdgeInsets.all(16.w),
      itemCount: _products.length + (_isLoadingMore ? 1 : 0),
      separatorBuilder: (context, index) => SizedBox(height: 12.h),
      itemBuilder: (context, index) {
        if (index >= _products.length) {
          return const _LoadMoreProductsIndicator();
        }

        final product = _products[index];
        return ProductListItem(
          id: product.id,
          title: product.nameAr,
          imageUrl: product.imageUrl,
          price: product.price,
          originalPrice: product.originalPrice,
          isFavorite: isProductFavorite(product.id),
          onTap: () => context.push('/product/${product.id}', extra: product),
          onToggleFavorite: () => toggleFavoriteProduct(product.id),
        );
      },
    );
  }

  Widget _buildEmptyState(bool isDark) {
    final strictCategoryMessage = _isStrictCategoryDeviceFlow;

    return Center(
      key: const ValueKey('products-empty-state'),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Iconsax.box_1,
              size: 80.sp,
              color: isDark
                  ? AppColors.textTertiaryDark
                  : AppColors.textTertiaryLight,
            ),
            SizedBox(height: 16.h),
            Text(
              'لا توجد منتجات',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              strictCategoryMessage
                  ? 'لا توجد منتجات لهذا الجهاز ضمن الفئة المختارة'
                  : 'لا توجد منتجات حالياً',
              style: TextStyle(
                fontSize: 14.sp,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(bool isDark) {
    return Center(
      key: const ValueKey('products-error-state'),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 28.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Iconsax.warning_2, size: 72.sp, color: AppColors.error),
            SizedBox(height: 16.h),
            Text(
              'تعذر تحميل المنتجات',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'تحقق من الاتصال ثم أعد المحاولة.',
              style: TextStyle(
                fontSize: 14.sp,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 18.h),
            FilledButton.tonal(
              onPressed: _loadProducts,
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
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
      builder: (context) => Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ترتيب حسب',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            ),
            SizedBox(height: 16.h),
            _buildSortOption('createdAt', 'desc', 'الأحدث', isDark),
            _buildSortOption('createdAt', 'asc', 'الأقدم', isDark),
            _buildSortOption('price', 'asc', 'السعر: من الأقل للأعلى', isDark),
            _buildSortOption('price', 'desc', 'السعر: من الأعلى للأقل', isDark),
            _buildSortOption('salesCount', 'desc', 'الأكثر مبيعاً', isDark),
            _buildSortOption('name', 'asc', 'الاسم: أ-ي', isDark),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOption(
    String sortBy,
    String sortOrder,
    String label,
    bool isDark,
  ) {
    final isSelected = _sortBy == sortBy && _sortOrder == sortOrder;

    return ListTile(
      onTap: () {
        setState(() {
          _sortBy = sortBy;
          _sortOrder = sortOrder;
        });
        Navigator.pop(context);
        _loadProducts();
      },
      leading: Icon(
        isSelected ? Iconsax.tick_circle5 : Iconsax.tick_circle,
        color: isSelected ? AppColors.primary : AppColors.textTertiaryLight,
      ),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          color: isSelected
              ? AppColors.primary
              : (isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight),
        ),
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
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.65,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'تصفية النتائج',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'إغلاق',
                      style: TextStyle(color: AppColors.primary),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              if (_hasCategoryFilter) ...[
                Text(
                  'الفئة المطبقة',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                ),
                SizedBox(height: 10.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 10.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Iconsax.category,
                        size: 16.sp,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          _activeCategoryName,
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),
              ],
              Text(
                'الترتيب الحالي',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
              SizedBox(height: 10.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : AppColors.backgroundLight,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  _getSortLabel(),
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('تم', style: TextStyle(fontSize: 16.sp)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoadMoreProductsIndicator extends StatelessWidget {
  const _LoadMoreProductsIndicator();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.cardDark
            : AppColors.cardLight,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.dividerDark
              : AppColors.dividerLight,
        ),
      ),
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: SizedBox(
            width: 26.w,
            height: 26.w,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              color: AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }
}
