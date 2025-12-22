/// Home Screen - Main dashboard with banners, categories, products
library;

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../../../../core/config/theme/app_theme.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/widgets/app_error.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/product_card.dart';
import '../../../catalog/domain/entities/banner_entity.dart';
import '../../../catalog/domain/entities/brand_entity.dart';
import '../../../catalog/domain/entities/category_entity.dart';
import '../../../catalog/domain/entities/product_entity.dart';
import '../cubit/home_cubit.dart';
import '../cubit/home_state.dart';
import '../../../../l10n/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _bannerController = PageController();

  @override
  void initState() {
    super.initState();
    context.read<HomeCubit>().loadHomeData();
  }

  @override
  void dispose() {
    _bannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          if (state is HomeLoading) {
            return const AppLoading();
          }
          if (state is HomeError) {
            return AppError(
              message: state.message,
              onRetry: () => context.read<HomeCubit>().loadHomeData(),
            );
          }
          if (state is HomeLoaded) {
            return RefreshIndicator(
              onRefresh: () => context.read<HomeCubit>().refresh(),
              child: _buildContent(state),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppBar(
      title: Row(
        children: [
          Image.asset(
            isDark ? 'assets/images/logo_dark.png' : 'assets/images/logo.png',
            width: 36.w,
            height: 36.w,
            fit: BoxFit.contain,
          ),
          SizedBox(width: 10.w),
          Text(
            AppLocalizations.of(context)!.appName,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () => context.push('/search'),
          icon: Icon(Iconsax.search_normal, size: 24.sp),
        ),
        IconButton(
          onPressed: () => context.push('/notifications'),
          icon: Stack(
            children: [
              Icon(Iconsax.notification, size: 24.sp),
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 8.w,
                  height: 8.w,
                  decoration: const BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 8.w),
      ],
    );
  }

  Widget _buildContent(HomeLoaded state) {
    return ListView(
      padding: EdgeInsets.only(bottom: 24.h),
      children: [
        // Banner Slider
        if (state.banners.isNotEmpty) _buildBannerSlider(state.banners),

        SizedBox(height: 24.h),

        // Categories
        if (state.categories.isNotEmpty)
          _buildCategoriesSection(state.categories),

        SizedBox(height: 24.h),

        // Brands
        if (state.brands.isNotEmpty) _buildBrandsSection(state.brands),

        SizedBox(height: 24.h),

        // Featured Products
        if (state.featuredProducts.isNotEmpty)
          _buildProductsSection(
            title: AppLocalizations.of(context)!.featuredProducts,
            products: state.featuredProducts,
            onSeeAll: () => context.push('/products?featured=true'),
          ),

        SizedBox(height: 24.h),

        // New Arrivals
        if (state.newArrivals.isNotEmpty)
          _buildProductsSection(
            title: AppLocalizations.of(context)!.newArrivals,
            products: state.newArrivals,
            onSeeAll: () => context.push('/products?sort=newest'),
          ),

        SizedBox(height: 24.h),

        // Best Sellers
        if (state.bestSellers.isNotEmpty)
          _buildProductsSection(
            title: AppLocalizations.of(context)!.bestSellers,
            products: state.bestSellers,
            onSeeAll: () => context.push('/products?sort=bestselling'),
          ),

        // Extra space for floating bottom nav bar
        SizedBox(height: 100.h),
      ],
    );
  }

  Widget _buildBannerSlider(List<BannerEntity> banners) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        SizedBox(
          height: 180.h,
          child: PageView.builder(
            controller: _bannerController,
            itemCount: banners.length,
            itemBuilder: (context, index) {
              final banner = banners[index];
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: GestureDetector(
                  onTap: () {
                    // Handle banner tap
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: AppTheme.radiusLg,
                      gradient: LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryDark],
                      ),
                      boxShadow: AppTheme.shadowMd,
                    ),
                    child: Stack(
                      children: [
                        // Background pattern
                        Positioned(
                          right: -30.w,
                          top: -30.h,
                          child: Container(
                            width: 150.w,
                            height: 150.w,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        // Content
                        Padding(
                          padding: EdgeInsets.all(24.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                banner.titleAr ?? banner.title,
                                style: TextStyle(
                                  fontSize: 24.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                banner.subtitleAr ?? banner.subtitle ?? '',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  color: Colors.white.withValues(alpha: 0.9),
                                ),
                              ),
                              SizedBox(height: 16.h),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16.w,
                                  vertical: 8.h,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: AppTheme.radiusSm,
                                ),
                                child: Text(
                                  AppLocalizations.of(context)!.shopNow,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(height: 12.h),
        SmoothPageIndicator(
          controller: _bannerController,
          count: banners.length,
          effect: WormEffect(
            dotWidth: 8.w,
            dotHeight: 8.w,
            spacing: 6.w,
            activeDotColor: AppColors.primary,
            dotColor: isDark ? AppColors.dividerDark : AppColors.dividerLight,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoriesSection(List<CategoryEntity> categories) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        _buildSectionHeader(
          title: AppLocalizations.of(context)!.categories,
          onSeeAll: () => context.push('/categories'),
        ),
        SizedBox(height: 12.h),
        SizedBox(
          height: 110.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            itemCount: categories.length,
            separatorBuilder: (_, __) => SizedBox(width: 12.w),
            itemBuilder: (context, index) {
              final category = categories[index];
              return GestureDetector(
                onTap: () => context.push('/category/${category.id}'),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18.r),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      width: 80.w,
                      padding: EdgeInsets.symmetric(
                        vertical: 12.h,
                        horizontal: 8.w,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: isDark
                              ? [
                                  Colors.white.withValues(alpha: 0.1),
                                  Colors.white.withValues(alpha: 0.05),
                                ]
                              : [
                                  Colors.white.withValues(alpha: 0.9),
                                  Colors.white.withValues(alpha: 0.7),
                                ],
                        ),
                        borderRadius: BorderRadius.circular(18.r),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.15)
                              : AppColors.primary.withValues(alpha: 0.15),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 48.w,
                            height: 48.w,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppColors.primary.withValues(alpha: 0.2),
                                  AppColors.primaryLight.withValues(alpha: 0.1),
                                ],
                              ),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.primary.withValues(alpha: 0.3),
                                width: 1.5,
                              ),
                            ),
                            child: Icon(
                              _getCategoryIcon(category.slug),
                              size: 24.sp,
                              color: AppColors.primary,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            category.nameAr ?? category.name,
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimaryLight,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBrandsSection(List<BrandEntity> brands) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        _buildSectionHeader(
          title: AppLocalizations.of(context)!.brands,
          onSeeAll: () => context.push('/brands'),
        ),
        SizedBox(height: 12.h),
        SizedBox(
          height: 55.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            itemCount: brands.length,
            separatorBuilder: (_, __) => SizedBox(width: 12.w),
            itemBuilder: (context, index) {
              final brand = brands[index];
              return GestureDetector(
                onTap: () => context.push('/brand/${brand.id}'),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14.r),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 22.w,
                        vertical: 10.h,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: isDark
                              ? [
                                  Colors.white.withValues(alpha: 0.1),
                                  Colors.white.withValues(alpha: 0.05),
                                ]
                              : [
                                  Colors.white.withValues(alpha: 0.9),
                                  Colors.white.withValues(alpha: 0.7),
                                ],
                        ),
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.12)
                              : AppColors.primary.withValues(alpha: 0.12),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: _getBrandLogo(brand.slug) != null
                            ? SvgPicture.asset(
                                _getBrandLogo(brand.slug)!,
                                width: 80.w,
                                height: 30.h,
                                colorFilter: ColorFilter.mode(
                                  isDark
                                      ? AppColors.textPrimaryDark
                                      : AppColors.textPrimaryLight,
                                  BlendMode.srcIn,
                                ),
                              )
                            : Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 28.w,
                                    height: 28.w,
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withValues(
                                        alpha: 0.1,
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Iconsax.tag,
                                      size: 14.sp,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  SizedBox(width: 10.w),
                                  Text(
                                    brand.nameAr ?? brand.name,
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w600,
                                      color: isDark
                                          ? AppColors.textPrimaryDark
                                          : AppColors.textPrimaryLight,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProductsSection({
    required String title,
    required List<ProductEntity> products,
    VoidCallback? onSeeAll,
  }) {
    return Column(
      children: [
        _buildSectionHeader(title: title, onSeeAll: onSeeAll),
        SizedBox(height: 12.h),
        SizedBox(
          height: 290.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 10.h),
            clipBehavior: Clip.none,
            itemCount: products.length,
            separatorBuilder: (_, __) => SizedBox(width: 12.w),
            itemBuilder: (context, index) {
              final product = products[index];
              return SizedBox(
                width: 170.w,
                child: ProductCard(
                  id: product.id.toString(),
                  name: product.name,
                  nameAr: product.nameAr,
                  imageUrl: product.imageUrl,
                  price: product.price,
                  originalPrice: product.originalPrice,
                  stockQuantity: product.stockQuantity,
                  onTap: () =>
                      context.push('/product/${product.id}', extra: product),
                  onAddToCart: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '${AppLocalizations.of(context)!.addedToCart}: ${product.nameAr ?? product.name}',
                        ),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader({required String title, VoidCallback? onSeeAll}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (onSeeAll != null)
            TextButton(
              onPressed: onSeeAll,
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 8.w),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    AppLocalizations.of(context)!.viewAll,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Icon(
                    Iconsax.arrow_left_2,
                    size: 16.sp,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String slug) {
    switch (slug) {
      case 'screens':
        return Iconsax.mobile;
      case 'batteries':
        return Iconsax.battery_charging;
      case 'charging-ports':
        return Iconsax.flash_1;
      case 'back-covers':
        return Iconsax.back_square;
      case 'cameras':
        return Iconsax.camera;
      case 'speakers':
        return Iconsax.volume_high;
      default:
        return Iconsax.cpu;
    }
  }

  String? _getBrandLogo(String slug) {
    final brandLogos = {
      'apple': 'assets/images/brands/apple-13.svg',
      'samsung': 'assets/images/brands/samsung-8.svg',
      'huawei': 'assets/images/brands/huawei-pure-.svg',
      'xiaomi': 'assets/images/brands/xiaomi-3.svg',
    };
    return brandLogos[slug.toLowerCase()];
  }
}
