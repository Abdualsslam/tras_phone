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
import '../../data/datasources/catalog_remote_datasource.dart';
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
  final _dataSource = getIt<CatalogRemoteDataSource>();
  List<ProductEntity> _products = [];
  bool _isLoading = true;
  String _sortBy = 'newest';
  bool _isGridView = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    try {
      final products = await _dataSource.getProducts(
        categoryId: widget.categoryId,
      );
      setState(() {
        _products = products;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
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
      body: Column(
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
      padding: EdgeInsets.all(16.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12.h,
        crossAxisSpacing: 12.w,
        childAspectRatio: 0.60,
      ),
      itemCount: _products.length,
      itemBuilder: (context, index) {
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
      },
    );
  }

  Widget _buildProductsList() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView.separated(
      padding: EdgeInsets.all(16.w),
      itemCount: _products.length,
      separatorBuilder: (_, __) => SizedBox(height: 12.h),
      itemBuilder: (context, index) {
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
                    errorBuilder: (_, __, ___) => Container(
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
      case 'newest':
        return 'الأحدث';
      case 'price_low':
        return 'السعر: الأقل';
      case 'price_high':
        return 'السعر: الأعلى';
      case 'bestselling':
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
            _buildSortOption('newest', 'الأحدث', isDark),
            _buildSortOption('price_low', 'السعر: من الأقل للأعلى', isDark),
            _buildSortOption('price_high', 'السعر: من الأعلى للأقل', isDark),
            _buildSortOption('bestselling', 'الأكثر مبيعاً', isDark),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOption(String value, String label, bool isDark) {
    final isSelected = _sortBy == value;

    return ListTile(
      onTap: () {
        setState(() => _sortBy = value);
        Navigator.pop(context);
        _sortProducts();
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

  void _sortProducts() {
    setState(() {
      switch (_sortBy) {
        case 'price_low':
          _products.sort((a, b) => a.price.compareTo(b.price));
          break;
        case 'price_high':
          _products.sort((a, b) => b.price.compareTo(a.price));
          break;
        case 'bestselling':
        case 'newest':
        default:
          // Keep original order for mock data
          break;
      }
    });
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
