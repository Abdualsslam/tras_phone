/// Wishlist Screen - Saved products list
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
import '../../data/datasources/wishlist_remote_datasource.dart';
import '../cubit/wishlist_cubit.dart';
import '../cubit/wishlist_state.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  late final WishlistCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = WishlistCubit(
      dataSource: getIt<WishlistRemoteDataSource>(),
    );
    _cubit.loadWishlist();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  Future<void> _removeFromWishlist(String productId) async {
    await _cubit.removeFromWishlist(productId);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم الإزالة من المفضلة')),
      );
    }
  }

  Future<void> _moveToCart(String productId) async {
    await _cubit.moveToCart(productId);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم نقل المنتج للسلة')),
      );
    }
  }

  Future<void> _clearWishlist() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('مسح المفضلة'),
        content: const Text('هل أنت متأكد من مسح جميع المنتجات من المفضلة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('مسح', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _cubit.clearWishlist();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم مسح المفضلة')),
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
          title: BlocBuilder<WishlistCubit, WishlistState>(
            bloc: _cubit,
            builder: (context, state) {
              final count = state is WishlistLoaded ? state.items.length : 0;
              return Text(
                '${AppLocalizations.of(context)!.favorites} ($count)',
              );
            },
          ),
          actions: [
            BlocBuilder<WishlistCubit, WishlistState>(
              bloc: _cubit,
              builder: (context, state) {
                if (state is WishlistLoaded && state.items.isNotEmpty) {
                  return TextButton(
                    onPressed: _clearWishlist,
                    child: const Text('مسح الكل'),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
        body: BlocBuilder<WishlistCubit, WishlistState>(
          bloc: _cubit,
          builder: (context, state) {
            if (state is WishlistLoading) {
              return const WishlistShimmer();
            }

            if (state is WishlistError) {
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
                      onPressed: () => _cubit.loadWishlist(),
                      child: const Text('إعادة المحاولة'),
                    ),
                  ],
                ),
              );
            }

            if (state is WishlistLoaded) {
              if (state.items.isEmpty) {
                return _buildEmptyState(theme, isDark);
              }

              return RefreshIndicator(
                onRefresh: () => _cubit.loadWishlist(),
                child: ListView.separated(
                  padding: EdgeInsets.fromLTRB(16.w, 16.w, 16.w, 100.h),
                  itemCount: state.items.length,
                  separatorBuilder: (_, __) => SizedBox(height: 12.h),
                  itemBuilder: (context, index) {
                    return _buildWishlistCard(
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
            'قائمة المفضلة فارغة',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'أضف المنتجات التي تعجبك للوصول إليها لاحقاً',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textTertiaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWishlistCard(
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
                onPressed: () => _removeFromWishlist(product.id),
              ),
              if (item.isInStock)
                IconButton(
                  icon: Icon(
                    Iconsax.shopping_cart,
                    color: AppColors.primary,
                    size: 20.sp,
                  ),
                  onPressed: () => _moveToCart(product.id),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
