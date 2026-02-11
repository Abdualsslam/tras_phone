/// Product Search Results Screen - Display search results
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

class ProductSearchResultsScreen extends StatefulWidget {
  final Map<String, dynamic>? filters;

  const ProductSearchResultsScreen({super.key, this.filters});

  @override
  State<ProductSearchResultsScreen> createState() =>
      _ProductSearchResultsScreenState();
}

class _ProductSearchResultsScreenState
    extends State<ProductSearchResultsScreen> {
  final _dataSource = getIt<CatalogRemoteDataSource>();
  List<ProductEntity> _products = [];
  bool _isLoading = true;
  String _sortBy = 'relevance';

  @override
  void initState() {
    super.initState();
    _loadResults();
  }

  Future<void> _loadResults() async {
    setState(() => _isLoading = true);
    try {
      final query = widget.filters?['query'] as String? ?? '';
      final tags = widget.filters?['tags'] as List<String>?;

      if (query.isNotEmpty || (tags != null && tags.isNotEmpty)) {
        // Use advanced search
        final products = await _dataSource.advancedSearch(
          query: query,
          tags: tags,
          tagMode: widget.filters?['tagMode'] as String?,
          fuzzy: widget.filters?['fuzzy'] as bool? ?? false,
          sortBy: _getSortByForApi(),
          sortOrder: _getSortOrderForApi(),
          minPrice: widget.filters?['minPrice'] as double?,
          maxPrice: widget.filters?['maxPrice'] as double?,
          brandId: widget.filters?['brandId'] as String?,
          categoryId: widget.filters?['categoryId'] as String?,
          page: 1,
          limit: 50,
        );

        setState(() {
          _products = products;
          _isLoading = false;
        });
      } else {
        // Use regular search with filters
        final products = await _dataSource.getProducts(
          search: query,
          page: 1,
          limit: 50,
        );

        var filtered = products.where((p) {
          if (widget.filters?['inStock'] == true && p.stockQuantity <= 0) {
            return false;
          }
          if (widget.filters?['onSale'] == true && p.originalPrice == null) {
            return false;
          }
          if (widget.filters?['minPrice'] != null &&
              p.price < widget.filters!['minPrice']) {
            return false;
          }
          if (widget.filters?['maxPrice'] != null &&
              p.price > widget.filters!['maxPrice']) {
            return false;
          }
          return true;
        }).toList();

        setState(() {
          _products = filtered;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  String _getSortByForApi() {
    switch (_sortBy) {
      case 'price_low':
      case 'price_high':
        return 'price';
      case 'newest':
        return 'createdAt';
      default:
        return 'relevance';
    }
  }

  String _getSortOrderForApi() {
    switch (_sortBy) {
      case 'price_low':
        return 'asc';
      case 'price_high':
        return 'desc';
      case 'newest':
        return 'desc';
      default:
        return 'desc';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final query = widget.filters?['query'] as String? ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text(query.isNotEmpty ? 'نتائج: $query' : 'نتائج البحث'),
        actions: [
          IconButton(
            onPressed: () => context.push('/advanced-search'),
            icon: Icon(Iconsax.filter, size: 22.sp),
          ),
        ],
      ),
      body: Column(
        children: [
          // Results Header
          _buildResultsHeader(isDark),

          // Results
          Expanded(
            child: _isLoading
                ? const ProductsGridShimmer()
                : _products.isEmpty
                ? _buildEmptyState(isDark)
                : _buildResultsGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsHeader(bool isDark) {
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
            '${_products.length} نتيجة',
            style: TextStyle(
              fontSize: 14.sp,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: _showSortOptions,
            child: Row(
              children: [
                Icon(Iconsax.sort, size: 18.sp, color: AppColors.primary),
                SizedBox(width: 4.w),
                Text(
                  _getSortLabel(),
                  style: TextStyle(fontSize: 12.sp, color: AppColors.primary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsGrid() {
    return GridView.builder(
      padding: EdgeInsets.all(16.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12.h,
        crossAxisSpacing: 12.w,
        childAspectRatio: 0.58,
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

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Iconsax.search_status,
            size: 80.sp,
            color: isDark
                ? AppColors.textTertiaryDark
                : AppColors.textTertiaryLight,
          ),
          SizedBox(height: 16.h),
          Text(
            'لا توجد نتائج',
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
            'جرب تغيير كلمات البحث أو الفلاتر',
            style: TextStyle(
              fontSize: 14.sp,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
          SizedBox(height: 24.h),
          ElevatedButton.icon(
            onPressed: () => context.push('/advanced-search'),
            icon: Icon(Iconsax.filter, size: 18.sp),
            label: const Text('تعديل البحث'),
          ),
        ],
      ),
    );
  }

  String _getSortLabel() {
    switch (_sortBy) {
      case 'price_low':
        return 'السعر: الأقل';
      case 'price_high':
        return 'السعر: الأعلى';
      case 'newest':
        return 'الأحدث';
      default:
        return 'الأكثر صلة';
    }
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(_sortBy == 'relevance' ? Icons.check : null),
              title: const Text('الأكثر صلة'),
              onTap: () => _updateSort('relevance'),
            ),
            ListTile(
              leading: Icon(_sortBy == 'price_low' ? Icons.check : null),
              title: const Text('السعر: من الأقل'),
              onTap: () => _updateSort('price_low'),
            ),
            ListTile(
              leading: Icon(_sortBy == 'price_high' ? Icons.check : null),
              title: const Text('السعر: من الأعلى'),
              onTap: () => _updateSort('price_high'),
            ),
            ListTile(
              leading: Icon(_sortBy == 'newest' ? Icons.check : null),
              title: const Text('الأحدث'),
              onTap: () => _updateSort('newest'),
            ),
          ],
        ),
      ),
    );
  }

  void _updateSort(String sort) {
    Navigator.pop(context);
    setState(() {
      _sortBy = sort;
      switch (sort) {
        case 'price_low':
          _products.sort((a, b) => a.price.compareTo(b.price));
          break;
        case 'price_high':
          _products.sort((a, b) => b.price.compareTo(a.price));
          break;
        default:
          break;
      }
    });
  }
}
