/// Brand Details Screen - Brand info and products
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/entities/brand_entity.dart';
import '../../domain/entities/product_entity.dart';
import '../../data/datasources/catalog_remote_datasource.dart';

class BrandDetailsScreen extends StatefulWidget {
  final String brandId;
  final BrandEntity? brand;

  const BrandDetailsScreen({super.key, required this.brandId, this.brand});

  @override
  State<BrandDetailsScreen> createState() => _BrandDetailsScreenState();
}

class _BrandDetailsScreenState extends State<BrandDetailsScreen> {
  final _dataSource = getIt<CatalogRemoteDataSource>();
  BrandEntity? _brand;
  List<ProductEntity> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _brand = widget.brand;
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      if (_brand == null) {
        final brands = await _dataSource.getBrands();
        _brand = brands.firstWhere(
          (b) => b.id.toString() == widget.brandId,
          orElse: () => brands.first,
        );
      }
      final products = await _dataSource.getProducts(brandId: widget.brandId);
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
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
                          '${_products.length} منتج',
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
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
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
                          }, childCount: _products.length),
                        ),
                      ),

                // Bottom padding
                SliverToBoxAdapter(child: SizedBox(height: 100.h)),
              ],
            ),
    );
  }

  Widget _buildSliverAppBar(bool isDark) {
    final brandName = _brand?.name ?? '';
    final brandLogoUrl = _getBrandLogoUrl(brandName);

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
                    child: brandLogoUrl != null
                        ? Padding(
                            padding: EdgeInsets.all(20.w),
                            child: SvgPicture.asset(
                              brandLogoUrl,
                              fit: BoxFit.contain,
                            ),
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
                  '${_products.length} منتج',
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

  String? _getBrandLogoUrl(String brandName) {
    final brandLogos = {
      'Apple': 'assets/images/brands/apple-13.svg',
      'Samsung': 'assets/images/brands/samsung-8.svg',
      'Huawei': 'assets/images/brands/huawei-pure-.svg',
      'Xiaomi': 'assets/images/brands/xiaomi-3.svg',
    };
    return brandLogos[brandName];
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
