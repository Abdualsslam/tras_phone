/// Device Products Screen - Spare parts for specific device
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/shimmer/index.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/catalog_repository.dart';

class DeviceProductsScreen extends StatefulWidget {
  final String deviceId;
  final String? deviceName;

  const DeviceProductsScreen({
    super.key,
    required this.deviceId,
    this.deviceName,
  });

  @override
  State<DeviceProductsScreen> createState() => _DeviceProductsScreenState();
}

class _DeviceProductsScreenState extends State<DeviceProductsScreen> {
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
      final result = await _repository.getDeviceProducts(
        widget.deviceId,
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
      final result = await _repository.getDeviceProducts(
        widget.deviceId,
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
        title: Text(widget.deviceName ?? 'قطع الغيار'),
        actions: [
          IconButton(
            onPressed: () => context.push('/search'),
            icon: Icon(Iconsax.search_normal, size: 22.sp),
          ),
          IconButton(
            onPressed: _showSortOptions,
            icon: Icon(Iconsax.sort, size: 22.sp),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadProducts,
        child: Column(
          children: [
            // Products count
            if (!_isLoading && _products.isNotEmpty)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                  border: Border(
                    bottom: BorderSide(
                      color: isDark
                          ? AppColors.dividerDark
                          : AppColors.dividerLight,
                    ),
                  ),
                ),
                child: Row(
                  children: [
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
                  ],
                ),
              ),

            // Products Grid
            Expanded(
              child: _isLoading
                  ? const ProductsGridShimmer()
                  : _products.isEmpty
                  ? _buildEmptyState(isDark)
                  : _buildProductsGrid(),
            ),
          ],
        ),
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
        childAspectRatio: 0.65,
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
            'لا توجد قطع غيار',
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
            'لا توجد قطع غيار لهذا الجهاز حالياً',
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
}
