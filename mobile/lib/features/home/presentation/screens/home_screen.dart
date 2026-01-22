// Home Screen - Main dashboard with banners, categories, products

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/widgets.dart';
import '../cubit/home_cubit.dart';
import '../cubit/home_state.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../promotions/presentation/widgets/promotions_banner.dart';
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

  Widget _buildContent(HomeLoaded state) {
    return ListView(
      padding: EdgeInsets.only(bottom: 24.h),
      children: [
        // Banner Slider
        if (state.banners.isNotEmpty)
          BannerSlider(banners: state.banners, controller: _bannerController),

        SizedBox(height: 16.h),

        // Promotions Banner
        const PromotionsBanner(),

        SizedBox(height: 24.h),

        // Categories
        if (state.categories.isNotEmpty)
          CategoriesSection(categories: state.categories),

        SizedBox(height: 24.h),

        // Brands
        if (state.brands.isNotEmpty) BrandsSection(brands: state.brands),

        SizedBox(height: 24.h),

        // Featured Products
        if (state.featuredProducts.isNotEmpty)
          ProductsSection(
            title: AppLocalizations.of(context)!.featuredProducts,
            products: state.featuredProducts,
            onSeeAll: () => context.push('/products?isFeatured=true'),
          ),

        SizedBox(height: 24.h),

        // New Arrivals
        if (state.newArrivals.isNotEmpty)
          ProductsSection(
            title: AppLocalizations.of(context)!.newArrivals,
            products: state.newArrivals,
            onSeeAll: () => context.push('/products?sort=newest'),
          ),

        SizedBox(height: 24.h),

        // Best Sellers
        if (state.bestSellers.isNotEmpty)
          ProductsSection(
            title: AppLocalizations.of(context)!.bestSellers,
            products: state.bestSellers,
            onSeeAll: () => context.push('/products?sort=bestselling'),
          ),

        // Extra space for floating bottom nav bar
        SizedBox(height: 100.h),
      ],
    );
  }
}
