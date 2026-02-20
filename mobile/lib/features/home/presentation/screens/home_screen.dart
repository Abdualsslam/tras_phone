// Home Screen - Main dashboard with banners, categories, products

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/widgets/widgets.dart';
import '../cubit/home_cubit.dart';
import '../cubit/home_state.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../promotions/presentation/widgets/promotions_banner.dart';
import '../../../banners/presentation/cubit/banners_cubit.dart';
import '../../../banners/presentation/cubit/banners_state.dart';
import '../../../banners/domain/enums/banner_position.dart';
import '../../../banners/domain/enums/banner_type.dart';
import '../../../banners/presentation/widgets/popup_banner_widget.dart';
import '../widgets/home_app_bar.dart';
import '../widgets/banner_slider.dart';
import '../widgets/categories_section.dart';
import '../widgets/brands_section.dart';
import '../widgets/products_section.dart';

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
    context.read<BannersCubit>().loadBanners(placement: BannerPosition.homeTop);
  }

  @override
  void dispose() {
    _bannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const HomeAppBar(),
      body: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          if (state is HomeLoading) {
            return const HomeShimmer();
          }
          if (state is HomeError) {
            return AppError(
              message: state.message,
              onRetry: () => context.read<HomeCubit>().loadHomeData(),
            );
          }
          if (state is HomeLoaded || state is HomeLoadedFromCache) {
            return RefreshIndicator(
              color: const Color(0xFFE85D3D),
              onRefresh: () async {
                await context.read<HomeCubit>().refresh();
                if (!context.mounted) return;
                await context.read<BannersCubit>().loadBanners(
                  placement: BannerPosition.homeTop,
                  refresh: true,
                  forceRefresh: true,
                );
              },
              child: _buildContent(state),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildContent(HomeState state) {
    final locale = Localizations.localeOf(context).languageCode;
    final isMobile = MediaQuery.of(context).size.width < 600;
    final l10n = AppLocalizations.of(context)!;

    final categories = state is HomeLoaded
        ? state.categories
        : (state as HomeLoadedFromCache).categories;
    final brands = state is HomeLoaded
        ? state.brands
        : (state as HomeLoadedFromCache).brands;
    final featuredProducts = state is HomeLoaded
        ? state.featuredProducts
        : (state as HomeLoadedFromCache).featuredProducts;
    final newArrivals = state is HomeLoaded
        ? state.newArrivals
        : (state as HomeLoadedFromCache).newArrivals;
    final bestSellers = state is HomeLoaded
        ? state.bestSellers
        : (state as HomeLoadedFromCache).bestSellers;

    return BlocBuilder<BannersCubit, BannersState>(
      builder: (context, bannersState) {
        return ListView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          padding: EdgeInsets.only(top: 8.h, bottom: 24.h),
          children: [
            // ─── Banner Slider ───
            if (bannersState is BannersLoaded &&
                bannersState.banners.isNotEmpty)
              BannerSlider(
                banners: bannersState.banners,
                controller: _bannerController,
              ),

            // ─── Popup Banners ───
            if (bannersState is BannersLoaded)
              ...bannersState.banners
                  .where(
                    (b) => b.type == BannerType.popup && b.isCurrentlyActive,
                  )
                  .map(
                    (banner) => PopupBannerWidget(
                      key: ValueKey('popup_banner_${banner.id}'),
                      banner: banner,
                      locale: locale,
                      isMobile: isMobile,
                    ),
                  ),

            SizedBox(height: 20.h),

            // ─── Promotions ───
            const PromotionsBanner(),

            SizedBox(height: 24.h),

            // ─── Categories ───
            if (categories.isNotEmpty)
              CategoriesSection(categories: categories),

            SizedBox(height: 28.h),

            // ─── Brands ───
            if (brands.isNotEmpty) BrandsSection(brands: brands),

            SizedBox(height: 28.h),

            // ─── Featured Products ───
            if (featuredProducts.isNotEmpty)
              ProductsSection(
                title: l10n.featuredProducts,
                icon: Iconsax.star_1,
                products: featuredProducts,
                onSeeAll: () => context.push('/products?isFeatured=true'),
              ),

            SizedBox(height: 28.h),

            // ─── New Arrivals ───
            if (newArrivals.isNotEmpty)
              ProductsSection(
                title: l10n.newArrivals,
                icon: Iconsax.flash_1,
                products: newArrivals,
                onSeeAll: () => context.push('/products?sort=newest'),
              ),

            SizedBox(height: 28.h),

            // ─── Best Sellers ───
            if (bestSellers.isNotEmpty)
              ProductsSection(
                title: l10n.bestSellers,
                icon: Iconsax.chart,
                products: bestSellers,
                onSeeAll: () => context.push('/products?sort=bestselling'),
              ),

            // Extra space for floating bottom nav bar
            SizedBox(height: 100.h),
          ],
        );
      },
    );
  }
}
