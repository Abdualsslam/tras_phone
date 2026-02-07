/// Category Products Screen - Products filtered by category
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/catalog_repository.dart';
import '../../../../l10n/app_localizations.dart';

class CategoryProductsScreen extends StatefulWidget {
  final String categoryId;
  final String? categoryName;

  const CategoryProductsScreen({
    super.key,
    required this.categoryId,
    this.categoryName,
  });

  @override
  State<CategoryProductsScreen> createState() => _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends State<CategoryProductsScreen> {
  final _repository = getIt<CatalogRepository>();
  final ScrollController _scrollController = ScrollController();
  
  List<ProductEntity> _products = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _currentPage = 1;
  final int _limit = 20;
  Map<String, dynamic>? _pagination;
  String _sortBy = 'createdAt';
  String _sortOrder = 'desc';
  bool _isGridView = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadProducts();
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
      final result = await _repository.getCategoryProducts(
        widget.categoryId,
        page: _currentPage,
        limit: _limit,
        sortBy: _sortBy,
        sortOrder: _sortOrder,
      );

      result.fold(
        (failure) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(failure.message)),
          );
        },
        (data) {
          final products = data['products'] as List<ProductEntity>;
          final pagination = data['pagination'] as Map<String, dynamic>?;

          setState(() {
            _products = products;
            _pagination = pagination;
            _hasMore = _currentPage < (pagination?['pages'] ?? 1);
            _isLoading = false;
          });
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ: $e')),
        );
      }
    }
  }

  Future<void> _loadMoreProducts() async {
    if (_isLoadingMore || !_hasMore) return;

    setState(() => _isLoadingMore = true);
    _currentPage++;

    try {
      final result = await _repository.getCategoryProducts(
        widget.categoryId,
        page: _currentPage,
        limit: _limit,
        sortBy: _sortBy,
        sortOrder: _sortOrder,
      );

      result.fold(
        (failure) {
          setState(() {
            _isLoadingMore = false;
            _currentPage--; // Revert page on error
          });
        },
        (data) {
          final products = data['products'] as List<ProductEntity>;
          final pagination = data['pagination'] as Map<String, dynamic>?;

          setState(() {
            _products.addAll(products);
            _pagination = pagination;
            _hasMore = _currentPage < (pagination?['pages'] ?? 1);
            _isLoadingMore = false;
          });
        },
      );
    } catch (e) {
      setState(() {
        _isLoadingMore = false;
        _currentPage--; // Revert page on error
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.categoryName ?? AppLocalizations.of(context)!.products,
        ),
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
                  ? const Center(child: CircularProgressIndicator())
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
            _pagination != null
                ? '${_pagination!['total'] ?? _products.length} منتج'
                : '${_products.length} منتج',
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
            onTap: () => context.push('/product/${product.id}', extra: product),
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
      separatorBuilder: (context, index) => SizedBox(height: 12.h),
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
                    errorBuilder: (context, url, error) => Container(
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
            'لا توجد منتجات في هذا القسم حالياً',
            style: TextStyle(
              fontSize: 14.sp,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
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
      case 'ordersCount':
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
            _buildSortOption('ordersCount', 'desc', 'الأكثر مبيعاً', isDark),
            _buildSortOption('name', 'asc', 'الاسم: أ-ي', isDark),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOption(String sortBy, String sortOrder, String label, bool isDark) {
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
