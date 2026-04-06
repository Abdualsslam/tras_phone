// Home Screen - Main dashboard with banners, categories, products

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/cache/image_cache_config.dart';
import '../../../../core/mixins/product_favorites_mixin.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../banners/domain/enums/banner_position.dart';
import '../../../banners/domain/enums/banner_type.dart';
import '../../../banners/presentation/cubit/banners_cubit.dart';
import '../../../banners/presentation/cubit/banners_state.dart';
import '../../../banners/presentation/widgets/popup_banner_widget.dart';
import '../../../catalog/domain/entities/brand_entity.dart';
import '../../../catalog/domain/entities/category_entity.dart';
import '../../../catalog/domain/entities/product_entity.dart';
import '../../../promotions/presentation/widgets/promotions_banner.dart';
import '../cubit/home_cubit.dart';
import '../cubit/home_state.dart';
import '../widgets/banner_slider.dart';
import '../widgets/brands_section.dart';
import '../widgets/categories_section.dart';
import '../widgets/home_app_bar.dart';
import '../widgets/products_section.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with ProductFavoritesMixin<HomeScreen> {
  final _bannerController = PageController();
  final Set<String> _prefetchedImageUrls = <String>{};

  @override
  void initState() {
    super.initState();
    context.read<HomeCubit>().loadHomeData();
    context.read<BannersCubit>().loadBanners(placement: BannerPosition.homeTop);
    loadFavoriteProductIds();
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
      body: BlocConsumer<HomeCubit, HomeState>(
        listener: (context, state) {
          final data = _HomeViewData.fromState(state);
          if (data != null) {
            _prefetchHomeImages(data);
          }
        },
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

          final data = _HomeViewData.fromState(state);
          if (data == null) {
            return const SizedBox.shrink();
          }

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
              await loadFavoriteProductIds();
            },
            child: _HomeContent(
              bannerController: _bannerController,
              data: data,
              favoriteProductIds: favoriteProductIds,
              onToggleFavorite: toggleFavoriteProduct,
            ),
          );
        },
      ),
    );
  }

  void _prefetchHomeImages(_HomeViewData data) {
    final imageUrls = <String>[
      ...data.categories
          .take(4)
          .map((category) => category.image?.trim() ?? '')
          .where((image) => image.isNotEmpty),
      ...data.brands
          .take(4)
          .map((brand) => brand.logo?.trim() ?? '')
          .where((image) => image.isNotEmpty),
      ...data.featuredProducts
          .take(4)
          .map((product) => product.imageUrl?.trim() ?? '')
          .where((image) => image.isNotEmpty),
      ...data.newArrivals
          .take(2)
          .map((product) => product.imageUrl?.trim() ?? '')
          .where((image) => image.isNotEmpty),
    ];

    final urlsToPrefetch = imageUrls
        .where((url) => !_prefetchedImageUrls.contains(url))
        .toList(growable: false);

    if (urlsToPrefetch.isEmpty) return;

    _prefetchedImageUrls.addAll(urlsToPrefetch);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (final imageUrl in urlsToPrefetch) {
        precacheImage(
          CachedNetworkImageProvider(
            imageUrl,
            cacheKey: imageCacheKey(imageUrl),
          ),
          context,
        );
      }
    });
  }
}

class _HomeContent extends StatelessWidget {
  final PageController bannerController;
  final _HomeViewData data;
  final Set<String> favoriteProductIds;
  final ValueChanged<String> onToggleFavorite;

  const _HomeContent({
    required this.bannerController,
    required this.data,
    required this.favoriteProductIds,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ListView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      padding: EdgeInsets.only(top: 8.h, bottom: 24.h),
      children: [
        _HomeBannerArea(controller: bannerController),
        SizedBox(height: 20.h),
        const PromotionsBanner(),
        SizedBox(height: 24.h),
        if (data.categories.isNotEmpty)
          CategoriesSection(categories: data.categories),
        SizedBox(height: 28.h),
        if (data.brands.isNotEmpty) BrandsSection(brands: data.brands),
        SizedBox(height: 28.h),
        if (data.featuredProducts.isNotEmpty)
          ProductsSection(
            title: l10n.featuredProducts,
            icon: Iconsax.star_1,
            products: data.featuredProducts,
            favoriteProductIds: favoriteProductIds,
            onToggleFavorite: onToggleFavorite,
            onSeeAll: () => context.push('/products?isFeatured=true'),
          ),
        SizedBox(height: 28.h),
        if (data.newArrivals.isNotEmpty)
          ProductsSection(
            title: l10n.newArrivals,
            icon: Iconsax.flash_1,
            products: data.newArrivals,
            favoriteProductIds: favoriteProductIds,
            onToggleFavorite: onToggleFavorite,
            onSeeAll: () => context.push('/products?sort=newest'),
          ),
        SizedBox(height: 28.h),
        if (data.bestSellers.isNotEmpty)
          ProductsSection(
            title: l10n.bestSellers,
            icon: Iconsax.chart,
            products: data.bestSellers,
            favoriteProductIds: favoriteProductIds,
            onToggleFavorite: onToggleFavorite,
            onSeeAll: () => context.push('/products?sort=bestselling'),
          ),
        SizedBox(height: 100.h),
      ],
    );
  }
}

class _HomeBannerArea extends StatelessWidget {
  final PageController controller;

  const _HomeBannerArea({required this.controller});

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final isMobile = MediaQuery.of(context).size.width < 600;

    return BlocBuilder<BannersCubit, BannersState>(
      buildWhen: (previous, current) => previous != current,
      builder: (context, bannersState) {
        if (bannersState is BannersLoading || bannersState is BannersInitial) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: ShimmerCard(
              height: 180,
              borderRadius: BorderRadius.circular(16.r),
            ),
          );
        }

        if (bannersState is! BannersLoaded || bannersState.banners.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          children: [
            BannerSlider(
              banners: bannersState.banners,
              controller: controller,
            ),
            ...bannersState.banners
                .where((banner) => banner.type == BannerType.popup)
                .where((banner) => banner.isCurrentlyActive)
                .map(
                  (banner) => Padding(
                    padding: EdgeInsets.only(top: 12.h),
                    child: PopupBannerWidget(
                      key: ValueKey('popup_banner_${banner.id}'),
                      banner: banner,
                      locale: locale,
                      isMobile: isMobile,
                    ),
                  ),
                ),
          ],
        );
      },
    );
  }
}

class _HomeViewData {
  final List<CategoryEntity> categories;
  final List<BrandEntity> brands;
  final List<ProductEntity> featuredProducts;
  final List<ProductEntity> newArrivals;
  final List<ProductEntity> bestSellers;

  const _HomeViewData({
    required this.categories,
    required this.brands,
    required this.featuredProducts,
    required this.newArrivals,
    required this.bestSellers,
  });

  static _HomeViewData? fromState(HomeState state) {
    if (state is HomeLoaded) {
      return _HomeViewData(
        categories: state.categories,
        brands: state.brands,
        featuredProducts: state.featuredProducts,
        newArrivals: state.newArrivals,
        bestSellers: state.bestSellers,
      );
    }

    if (state is HomeLoadedFromCache) {
      return _HomeViewData(
        categories: state.categories,
        brands: state.brands,
        featuredProducts: state.featuredProducts,
        newArrivals: state.newArrivals,
        bestSellers: state.bestSellers,
      );
    }

    return null;
  }
}
