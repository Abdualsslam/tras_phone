/// Brands List Screen - Displays all product brands
library;

import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../domain/entities/brand_entity.dart';
import '../../domain/repositories/catalog_repository.dart';
import '../cubit/brands_cubit.dart';
import '../cubit/brands_state.dart';
import '../../../../l10n/app_localizations.dart';

class BrandsListScreen extends StatelessWidget {
  const BrandsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => BrandsCubit(
        repository: getIt<CatalogRepository>(),
      )..loadBrands(),
      child: const _BrandsListView(),
    );
  }
}

class _BrandsListView extends StatelessWidget {
  const _BrandsListView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.brands),
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_right_3),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocBuilder<BrandsCubit, BrandsState>(
        builder: (context, state) {
          if (state is BrandsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is BrandsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<BrandsCubit>().loadBrands(),
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          }

          if (state is BrandsLoaded) {
            return RefreshIndicator(
              onRefresh: () => context.read<BrandsCubit>().loadBrands(),
              child: GridView.builder(
                padding: EdgeInsets.all(16.w),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 0.8,
                  crossAxisSpacing: 12.w,
                  mainAxisSpacing: 12.h,
                ),
                itemCount: state.brands.length,
                itemBuilder: (context, index) {
                  final brand = state.brands[index];
                  return _BrandCard(
                    brand: brand,
                    isDark: isDark,
                    onTap: () {
                      context.push('/brand/${brand.slug}');
                    },
                  );
                },
              ),
            );
          }

          return const SizedBox.shrink();
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
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
                    ? Colors.white.withValues(alpha: 0.12)
                    : AppColors.primary.withValues(alpha: 0.12),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Brand Logo with glassmorphism container
                Container(
                  width: 58.w,
                  height: 58.w,
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: brand.logo != null
                      ? CachedNetworkImage(
                          imageUrl: brand.logo!,
                          fit: BoxFit.contain,
                          placeholder: (context, url) => Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          ),
                          errorWidget: (context, url, error) => Icon(
                            Iconsax.tag,
                            size: 28.sp,
                            color: AppColors.primary,
                          ),
                        )
                      : Icon(
                          Iconsax.tag,
                          size: 28.sp,
                          color: AppColors.primary,
                        ),
                ),
                SizedBox(height: 10.h),

                // Brand Name
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6.w),
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
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
