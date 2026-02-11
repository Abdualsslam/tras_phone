/// Brand Details Screen - Brand info and products
library;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/entities/brand_entity.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/catalog_repository.dart';

class BrandDetailsScreen extends StatefulWidget {
  final String brandSlug;
  final BrandEntity? brand;

  const BrandDetailsScreen({super.key, required this.brandSlug, this.brand});

  @override
  State<BrandDetailsScreen> createState() => _BrandDetailsScreenState();
}

class _BrandDetailsScreenState extends State<BrandDetailsScreen> {
  final _repository = getIt<CatalogRepository>();
  final ScrollController _scrollController = ScrollController();

  BrandEntity? _brand;
  List<ProductEntity> _products = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _currentPage = 1;
  final int _limit = 20;
  Map<String, dynamic>? _pagination;

  @override
  void initState() {
    super.initState();
    _brand = widget.brand;
    _scrollController.addListener(_onScroll);
    _loadData();
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

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _currentPage = 1;
      _products.clear();
      _hasMore = true;
    });

    try {
      // Load brand if not provided (required to get brand.id)
      if (_brand == null) {
        final brandResult = await _repository.getBrandBySlug(widget.brandSlug);
        brandResult.fold((failure) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(failure.message)));
          return; // Exit if brand not found
        }, (brand) => _brand = brand);
      }

      // Ensure we have brand with ID before loading products
      if (_brand == null) {
        setState(() => _isLoading = false);
        return;
      }

      // Load products using brand.id (not slug)
      final result = await _repository.getBrandProducts(
        _brand!.id,
        page: _currentPage,
        limit: _limit,
      );

      result.fold(
        (failure) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(failure.message)));
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('حدث خطأ: $e')));
      }
    }
  }

  Future<void> _loadMoreProducts() async {
    if (_isLoadingMore || !_hasMore || _brand == null) return;

    setState(() => _isLoadingMore = true);
    _currentPage++;

    try {
      // Use brand.id (not slug) for API call
      final result = await _repository.getBrandProducts(
        _brand!.id,
        page: _currentPage,
        limit: _limit,
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
      body: _isLoading
          ? const BrandDetailShimmer()
          : RefreshIndicator(
              onRefresh: _loadData,
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  // App Bar with Brand Banner
                  _buildSliverAppBar(isDark),

                  // Products Header
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 12.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'منتجات ${_brand?.nameAr ?? _brand?.name ?? ""}',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimaryLight,
                            ),
                          ),
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
                  ),

                  // Products Grid
                  _products.isEmpty
                      ? SliverFillRemaining(child: _buildEmptyState(isDark))
                      : SliverPadding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          sliver: SliverGrid(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  mainAxisSpacing: 12.h,
                                  crossAxisSpacing: 12.w,
                                  childAspectRatio: 0.58,
                                ),
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
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
                                    onTap: () => context.push(
                                      '/product/${product.id}',
                                      extra: product,
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
                              childCount:
                                  _products.length + (_isLoadingMore ? 1 : 0),
                            ),
                          ),
                        ),

                  // Bottom padding
                  SliverToBoxAdapter(child: SizedBox(height: 100.h)),
                ],
              ),
            ),
    );
  }

  Widget _buildSliverAppBar(bool isDark) {
    final brandName = _brand?.name ?? '';
    final brandLogoUrl = _brand?.logo;

    return SliverAppBar(
      expandedHeight: 200.h,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.primary, AppColors.primaryDark],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 50.h),
                Container(
                  width: 100.w,
                  height: 100.w,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20.r),
                    child: brandLogoUrl != null && brandLogoUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: brandLogoUrl,
                            fit: BoxFit.contain,
                            placeholder: (context, url) => Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            errorWidget: (context, url, error) =>
                                _buildBrandInitial(brandName),
                          )
                        : _buildBrandInitial(brandName),
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  _brand?.nameAr ?? _brand?.name ?? '',
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  _pagination != null
                      ? '${_pagination!['total'] ?? _products.length} منتج'
                      : '${_products.length} منتج',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          onPressed: () => context.push('/search'),
          icon: Icon(Iconsax.search_normal, size: 22.sp, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildBrandInitial(String brandName) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(16.w),
      child: Center(
        child: Icon(Iconsax.shop, size: 48.sp, color: AppColors.primary),
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
            'لا توجد منتجات',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
        ],
      ),
    );
  }
}
