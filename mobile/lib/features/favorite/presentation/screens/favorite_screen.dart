/// Favorite Screen - Saved products list
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../../../../core/shimmer/index.dart';
import '../../../../core/di/injection.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/datasources/favorite_remote_datasource.dart';
import '../cubit/favorite_cubit.dart';
import '../cubit/favorite_state.dart';

class FavoriteScreen extends StatefulWidget {
  final bool isActive;

  const FavoriteScreen({super.key, this.isActive = true});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  late final FavoriteCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = FavoriteCubit(
      dataSource: getIt<FavoriteRemoteDataSource>(),
    );
    if (widget.isActive) {
      _cubit.loadFavorites();
    }
  }

  @override
  void didUpdateWidget(covariant FavoriteScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.isActive && widget.isActive) {
      _cubit.loadFavorites();
    }
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  Future<void> _removeFromFavorites(String productId) async {
    await _cubit.removeFromFavorites(productId);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.removedFromFavorites)),
      );
    }
  }

  Future<void> _clearFavorites() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.clearFavorites),
        content: Text(l10n.clearFavoritesConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.delete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _cubit.clearFavorites();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.favoritesCleared)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: BlocBuilder<FavoriteCubit, FavoriteState>(
            bloc: _cubit,
            builder: (context, state) {
              final count = state is FavoriteLoaded ? state.items.length : 0;
              return Text(
                '${AppLocalizations.of(context)!.favorites} ($count)',
              );
            },
          ),
          actions: [
            BlocBuilder<FavoriteCubit, FavoriteState>(
              bloc: _cubit,
              builder: (context, state) {
                if (state is FavoriteLoaded && state.items.isNotEmpty) {
                  return TextButton(
                    onPressed: _clearFavorites,
                    child: Text(AppLocalizations.of(context)!.clearAll),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
        body: BlocBuilder<FavoriteCubit, FavoriteState>(
          bloc: _cubit,
          builder: (context, state) {
            if (state is FavoriteLoading) {
              return const FavoriteShimmer();
            }

            if (state is FavoriteError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Iconsax.danger,
                      size: 64.sp,
                      color: AppColors.error,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      state.message,
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    ElevatedButton(
                      onPressed: () => _cubit.loadFavorites(),
                      child: Text(AppLocalizations.of(context)!.retryAction),
                    ),
                  ],
                ),
              );
            }

            if (state is FavoriteLoaded) {
              if (state.items.isEmpty) {
                return _buildEmptyState(theme, isDark);
              }

              return RefreshIndicator(
                onRefresh: () => _cubit.loadFavorites(),
                child: ListView.separated(
                  padding: EdgeInsets.fromLTRB(16.w, 16.w, 16.w, 100.h),
                  itemCount: state.items.length,
                  separatorBuilder: (_, __) => SizedBox(height: 12.h),
                  itemBuilder: (context, index) {
                    return _buildFavoriteCard(
                      context,
                      theme,
                      isDark,
                      state.items[index],
                    );
                  },
                ),
              );
            }

            return _buildEmptyState(theme, isDark);
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Iconsax.heart,
            size: 80.sp,
            color: AppColors.textTertiaryLight,
          ),
          SizedBox(height: 24.h),
          Text(
            AppLocalizations.of(context)!.emptyFavorites,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            AppLocalizations.of(context)!.emptyFavoritesHint,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textTertiaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteCard(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    item,
  ) {
    final product = item.product;
    if (product == null) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          // Product Image
          GestureDetector(
            onTap: () => context.push('/product/${product.id}', extra: product),
            child: Container(
              width: 80.w,
              height: 80.w,
              decoration: BoxDecoration(
                color: isDark ? AppColors.backgroundDark : Colors.grey[100],
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: product.mainImage != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12.r),
                      child: Image.network(
                        product.mainImage!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(
                          Iconsax.image,
                          size: 32.sp,
                          color: AppColors.textTertiaryLight,
                        ),
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                      ),
                    )
                  : Icon(
                      Iconsax.image,
                      size: 32.sp,
                      color: AppColors.textTertiaryLight,
                    ),
            ),
          ),
          SizedBox(width: 12.w),

          // Product Details
          Expanded(
            child: GestureDetector(
              onTap: () => context.push('/product/${product.id}', extra: product),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.nameAr,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Text(
                        '${item.currentPrice ?? product.basePrice} ${AppLocalizations.of(context)!.currency}',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                      if (item.originalPrice != null && item.priceDropped) ...[
                        SizedBox(width: 8.w),
                        Text(
                          '${item.originalPrice} ${AppLocalizations.of(context)!.currency}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.textTertiaryLight,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        if (item.discountPercentage != null) ...[
                          SizedBox(width: 8.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.error,
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Text(
                              '-${item.discountPercentage!.toStringAsFixed(0)}%',
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Icon(
                        item.isInStock ? Iconsax.tick_circle : Iconsax.close_circle,
                        size: 14.sp,
                        color: item.isInStock ? AppColors.success : AppColors.error,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        item.isInStock
                            ? AppLocalizations.of(context)!.inStock
                            : AppLocalizations.of(context)!.outOfStock,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: item.isInStock ? AppColors.success : AppColors.error,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Actions
          Column(
            children: [
              IconButton(
                icon: Icon(Iconsax.trash, color: AppColors.error, size: 20.sp),
                onPressed: () => _removeFromFavorites(product.id),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
