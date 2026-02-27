/// Brands List Screen - Displays all product brands
library;

import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/cache/image_cache_config.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/shimmer/index.dart';
import '../../domain/entities/brand_entity.dart';
import '../../domain/repositories/catalog_repository.dart';
import '../cubit/brands_cubit.dart';
import '../cubit/brands_state.dart';
import '../../../../l10n/app_localizations.dart';

class BrandsListScreen extends StatelessWidget {
  final bool flowMode;
  final String? categoryId;
  final String? categoryName;

  const BrandsListScreen({
    super.key,
    this.flowMode = true,
    this.categoryId,
    this.categoryName,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          BrandsCubit(repository: getIt<CatalogRepository>())..loadBrands(),
      child: _BrandsListView(
        flowMode: flowMode,
        categoryId: categoryId,
        categoryName: categoryName,
      ),
    );
  }
}

class _BrandsListView extends StatefulWidget {
  final bool flowMode;
  final String? categoryId;
  final String? categoryName;

  const _BrandsListView({
    required this.flowMode,
    this.categoryId,
    this.categoryName,
  });

  @override
  State<_BrandsListView> createState() => _BrandsListViewState();
}

class _BrandsListViewState extends State<_BrandsListView> {
  List<BrandEntity> _cachedBrands = const [];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          widget.flowMode
              ? 'اختر الماركة'
              : AppLocalizations.of(context)!.brands,
        ),
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_right_3),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocBuilder<BrandsCubit, BrandsState>(
        builder: (context, state) {
          if (state is BrandsLoaded) {
            _cachedBrands = state.brands;
            return _buildBrandsGrid(context, isDark, state.brands);
          }

          if (state is BrandsLoading) {
            if (_cachedBrands.isEmpty) {
              return const BrandsListShimmer();
            }

            return _buildBrandsGrid(context, isDark, _cachedBrands);
          }

          if (state is BrandsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: () => context.read<BrandsCubit>().loadBrands(),
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          }

          return const BrandsListShimmer();
        },
      ),
    );
  }

  Widget _buildBrandsGrid(
    BuildContext context,
    bool isDark,
    List<BrandEntity> brands,
  ) {
    return RefreshIndicator(
      onRefresh: () => context.read<BrandsCubit>().loadBrands(),
      child: GridView.builder(
        padding: EdgeInsets.all(16.w),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.4,
          crossAxisSpacing: 12.w,
          mainAxisSpacing: 12.h,
        ),
        itemCount: brands.length,
        itemBuilder: (context, index) {
          final brand = brands[index];
          return _BrandCard(
            brand: brand,
            isDark: isDark,
            onTap: () {
              if (widget.flowMode) {
                final route = Uri(
                  path: '/devices',
                  queryParameters: {
                    'flow': '1',
                    'brandId': brand.id,
                    'brandName': brand.nameAr,
                    if (widget.categoryId != null &&
                        widget.categoryId!.isNotEmpty)
                      'categoryId': widget.categoryId!,
                    if (widget.categoryName != null &&
                        widget.categoryName!.isNotEmpty)
                      'categoryName': widget.categoryName!,
                  },
                ).toString();
                context.push(route);
              } else {
                context.push('/brand/${brand.slug}');
              }
            },
          );
        },
      ),
    );
  }
}

class _BrandCard extends StatelessWidget {
  final BrandEntity brand;
  final bool isDark;
  final VoidCallback onTap;

  const _BrandCard({
    required this.brand,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : AppColors.primary.withValues(alpha: 0.1),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Brand Logo container
            Expanded(
              flex: 3,
              child: Padding(
                padding: EdgeInsets.all(12.w),
                child: brand.logo != null
                    ? CachedNetworkImage(
                        imageUrl: brand.logo!,
                        cacheKey: imageCacheKey(brand.logo!),
                        cacheManager: imageCacheManager,
                        fit: BoxFit.contain,
                        placeholder: (context, url) => Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        errorWidget: (context, url, error) => Icon(
                          Iconsax.tag,
                          size: 28.sp,
                          color: AppColors.primary.withValues(alpha: 0.5),
                        ),
                      )
                    : Icon(
                        Iconsax.tag,
                        size: 28.sp,
                        color: AppColors.primary.withValues(alpha: 0.5),
                      ),
              ),
            ),

            // Brand Name
            Expanded(
              flex: 1,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : AppColors.primary.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(18.r),
                    bottomRight: Radius.circular(18.r),
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  brand.nameAr,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                    fontSize: 12.sp,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
