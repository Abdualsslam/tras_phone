/// Products List Screen - Products with filters (featured, sort, etc.)
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/entities/product_entity.dart';
import '../../data/datasources/catalog_remote_datasource.dart';
import '../../data/models/product_filter_query.dart';
import '../../../favorite/data/datasources/favorite_remote_datasource.dart';
import '../../../../l10n/app_localizations.dart';

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

class _ProductsListScreenState extends State<ProductsListScreen> {
  final _dataSource = getIt<CatalogRemoteDataSource>();
  late final FavoriteRemoteDataSource _favoriteDataSource;
  final ScrollController _scrollController = ScrollController();

  List<ProductEntity> _products = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _currentPage = 1;
  final int _limit = 20;
  String _sortBy = 'createdAt';
  String _sortOrder = 'desc';
  bool _isGridView = true;
  final Set<String> _favoriteProductIds = {};

  bool get _isStrictCategoryDeviceFlow =>
      (widget.categoryId?.isNotEmpty ?? false) &&
      (widget.deviceId?.isNotEmpty ?? false);

  Future<({List<ProductEntity> products, int resolvedPage, int totalPages})>
  _loadStrictCategoryDevicePage({required int startPage}) async {
    final categoryId = widget.categoryId!;
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
          .where((p) => p.categoryId == categoryId)
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

  @override
  void initState() {
    super.initState();
    _favoriteDataSource = getIt<FavoriteRemoteDataSource>();
    // Initialize sort from widget parameter or defaults
    if (widget.sortBy == 'newest') {
      _sortBy = 'createdAt';
      _sortOrder = 'desc';
    } else if (widget.sortBy != null) {
      _sortBy = widget.sortBy!;
    }

    _scrollController.addListener(_onScroll);
    _loadProducts();
    _loadFavoriteIds();
  }

  Future<void> _loadFavoriteIds() async {
    try {
      final favoriteIds = await _favoriteDataSource.getFavoriteProductIds();
      setState(() {
        _favoriteProductIds.clear();
        _favoriteProductIds.addAll(favoriteIds);
      });
    } catch (e) {
      // Silently fail - favorite check is optional
    }
  }

  Future<void> _toggleFavorite(String productId) async {
    final isFavorite = _favoriteProductIds.contains(productId);

    setState(() {
      if (isFavorite) {
        _favoriteProductIds.remove(productId);
      } else {
        _favoriteProductIds.add(productId);
      }
    });

    try {
      HapticFeedback.lightImpact();
      await _favoriteDataSource.toggleFavorite(productId, isFavorite);
    } catch (e) {
      // Revert on error
      setState(() {
        if (isFavorite) {
          _favoriteProductIds.add(productId);
        } else {
          _favoriteProductIds.remove(productId);
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل تحديث المفضلة: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
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

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _currentPage = 1;
      _products.clear();
      _hasMore = true;
    });

    try {
      if (_isStrictCategoryDeviceFlow) {
        final strictResult = await _loadStrictCategoryDevicePage(startPage: 1);

        setState(() {
          _products = strictResult.products;
          _currentPage = strictResult.resolvedPage;
          _hasMore = _currentPage < strictResult.totalPages;
          _isLoading = false;
        });
        return;
      }

      final sortByEnum = _getSortByEnum();
      final sortOrderEnum = _sortOrder == 'asc'
          ? SortOrder.asc
          : SortOrder.desc;

      final filter = ProductFilterQuery(
        categoryId: widget.categoryId,
        brandId: widget.brandId,
        deviceId: widget.deviceId,
        isFeatured: widget.isFeatured,
        sortBy: sortByEnum,
        sortOrder: sortOrderEnum,
        page: _currentPage,
        limit: _limit,
      );

      final response = await _dataSource.getProductsWithFilter(filter);

      setState(() {
        _products = response.toEntities();
        _hasMore = _currentPage < response.pages;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('حدث خطأ: $e')));
      }
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

  Future<void> _loadMoreProducts() async {
    if (_isLoadingMore || !_hasMore) return;

    setState(() => _isLoadingMore = true);
    final nextPage = _currentPage + 1;

    try {
      if (_isStrictCategoryDeviceFlow) {
        final strictResult = await _loadStrictCategoryDevicePage(
          startPage: nextPage,
        );

        setState(() {
          _products.addAll(strictResult.products);
          _currentPage = strictResult.resolvedPage;
          _hasMore = _currentPage < strictResult.totalPages;
          _isLoadingMore = false;
        });
        return;
      }

      final sortByEnum = _getSortByEnum();
      final sortOrderEnum = _sortOrder == 'asc'
          ? SortOrder.asc
          : SortOrder.desc;

      final filter = ProductFilterQuery(
        categoryId: widget.categoryId,
        brandId: widget.brandId,
        deviceId: widget.deviceId,
        isFeatured: widget.isFeatured,
        sortBy: sortByEnum,
        sortOrder: sortOrderEnum,
        page: nextPage,
        limit: _limit,
      );

      final response = await _dataSource.getProductsWithFilter(filter);

      setState(() {
        _products.addAll(response.toEntities());
        _currentPage = nextPage;
        _hasMore = _currentPage < response.pages;
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    String resolvedTitle;
    if (widget.title != null && widget.title!.isNotEmpty) {
      resolvedTitle = widget.title!;
    } else if (widget.deviceName != null && widget.deviceName!.isNotEmpty) {
      resolvedTitle = 'منتجات ${widget.deviceName!}';
    } else if (widget.brandName != null && widget.brandName!.isNotEmpty) {
      resolvedTitle = 'منتجات ${widget.brandName!}';
    } else if (widget.categoryName != null && widget.categoryName!.isNotEmpty) {
      resolvedTitle = 'منتجات ${widget.categoryName!}';
    } else {
      resolvedTitle = widget.isFeatured == true
          ? AppLocalizations.of(context)!.featuredProducts
          : AppLocalizations.of(context)!.products;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(resolvedTitle),
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
            // Sort & View Options
            _buildSortBar(isDark),

            // Products Grid/List
            Expanded(
              child: _isLoading
                  ? const ProductsGridShimmer()
                  : _products.isEmpty
                  ? _buildEmptyState(isDark)
                  : _isGridView
                  ? _buildProductsGrid()
                  : _buildProductsList(),
            ),
          ],
        ),
      ),
    );
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
          // Results count
          Text(
            '${_products.length} منتج',
            style: TextStyle(
              fontSize: 14.sp,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
          const Spacer(),

          // Sort dropdown
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

          // View toggle
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

  Widget _buildProductsGrid() {
    return GridView.builder(
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
        if (index < _products.length) {
          final product = _products[index];
          return ProductCard(
            id: product.id.toString(),
            name: product.name,
            nameAr: product.nameAr,
            imageUrl: product.imageUrl,
            price: product.price,
            originalPrice: product.originalPrice,
            stockQuantity: product.stockQuantity,
            isFavorite: _favoriteProductIds.contains(product.id),
            onTap: () => context.push('/product/${product.id}', extra: product),
            onToggleFavorite: () => _toggleFavorite(product.id),
          );
        } else if (_isLoadingMore) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  Widget _buildProductsList() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView.separated(
      controller: _scrollController,
      padding: EdgeInsets.all(16.w),
      itemCount: _products.length + (_isLoadingMore ? 1 : 0),
      separatorBuilder: (_, _) => SizedBox(height: 12.h),
      itemBuilder: (context, index) {
        if (index < _products.length) {
          final product = _products[index];
          return GestureDetector(
            onTap: () => context.push('/product/${product.id}', extra: product),
            child: Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : AppColors.cardLight,
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.r),
                    child: Image.asset(
                      (product.imageUrl ?? '').startsWith('assets/')
                          ? product.imageUrl ??
                                'assets/images/products/phone_screen.png'
                          : 'assets/images/products/phone_screen.png',
                      width: 80.w,
                      height: 80.w,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        width: 80.w,
                        height: 80.w,
                        color: AppColors.backgroundLight,
                        child: Icon(Iconsax.image, size: 30.sp),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),

                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.nameAr,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimaryLight,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4.h),
                        if (product.originalPrice != null &&
                            product.originalPrice! > product.price) ...[
                          Text(
                            '${product.originalPrice!.toStringAsFixed(0)} ر.س',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: AppColors.textTertiaryLight,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ],
                        Text(
                          '${product.price.toStringAsFixed(0)} ر.س',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Icon(
                    Iconsax.arrow_left_2,
                    size: 20.sp,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ],
              ),
            ),
          );
        } else if (_isLoadingMore) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  Widget _buildEmptyState(bool isDark) {
    final strictCategoryMessage = _isStrictCategoryDeviceFlow;

    return Center(
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
        _loadProducts(); // Reload with new sort
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
        initialChildSize: 0.7,
        minChildSize: 0.5,
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
                      'إعادة ضبط',
                      style: TextStyle(color: AppColors.primary),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              Text(
                'نطاق السعر',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
              SizedBox(height: 12.h),
              RangeSlider(
                values: const RangeValues(0, 1000),
                min: 0,
                max: 2000,
                divisions: 20,
                activeColor: AppColors.primary,
                onChanged: (values) {},
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('تطبيق', style: TextStyle(fontSize: 16.sp)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
