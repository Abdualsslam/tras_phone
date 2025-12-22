/// Wishlist Screen - Saved products list
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final wishlistItems = [
      _WishlistItem(
        id: 1,
        name: 'شاشة آيفون 14 برو ماكس',
        price: 450,
        originalPrice: 500,
        imageUrl: null,
        inStock: true,
      ),
      _WishlistItem(
        id: 2,
        name: 'بطارية سامسونج S23 Ultra',
        price: 120,
        imageUrl: null,
        inStock: true,
      ),
      _WishlistItem(
        id: 3,
        name: 'شاشة هواوي P50 Pro',
        price: 380,
        imageUrl: null,
        inStock: false,
      ),
    ];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          '${AppLocalizations.of(context)!.favorites} (${wishlistItems.length})',
        ),
        actions: [
          if (wishlistItems.isNotEmpty)
            TextButton(onPressed: () {}, child: const Text('مسح الكل')),
        ],
      ),
      body: wishlistItems.isEmpty
          ? _buildEmptyState(theme)
          : ListView.separated(
              padding: EdgeInsets.fromLTRB(16.w, 16.w, 16.w, 100.h),
              itemCount: wishlistItems.length,
              separatorBuilder: (_, __) => SizedBox(height: 12.h),
              itemBuilder: (context, index) {
                return _buildWishlistCard(
                  context,
                  theme,
                  isDark,
                  wishlistItems[index],
                );
              },
            ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.heart, size: 80.sp, color: AppColors.textTertiaryLight),
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
    _WishlistItem item,
  ) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          // Image
          Container(
            width: 80.w,
            height: 80.w,
            decoration: BoxDecoration(
              color: isDark ? AppColors.backgroundDark : Colors.grey[100],
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              Iconsax.image,
              size: 32.sp,
              color: AppColors.textTertiaryLight,
            ),
          ),
          SizedBox(width: 12.w),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
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
                      '${item.price} ${AppLocalizations.of(context)!.currency}',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    if (item.originalPrice != null) ...[
                      SizedBox(width: 8.w),
                      Text(
                        '${item.originalPrice} ${AppLocalizations.of(context)!.currency}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.textTertiaryLight,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  item.inStock
                      ? AppLocalizations.of(context)!.inStock
                      : AppLocalizations.of(context)!.outOfStock,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: item.inStock ? AppColors.success : AppColors.error,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Actions
          Column(
            children: [
              IconButton(
                icon: const Icon(Iconsax.trash, color: AppColors.error),
                onPressed: () => HapticFeedback.selectionClick(),
              ),
              if (item.inStock)
                IconButton(
                  icon: const Icon(
                    Iconsax.shopping_cart,
                    color: AppColors.primary,
                  ),
                  onPressed: () => HapticFeedback.mediumImpact(),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WishlistItem {
  final int id;
  final String name;
  final double price;
  final double? originalPrice;
  final String? imageUrl;
  final bool inStock;

  _WishlistItem({
    required this.id,
    required this.name,
    required this.price,
    this.originalPrice,
    this.imageUrl,
    required this.inStock,
  });
}
