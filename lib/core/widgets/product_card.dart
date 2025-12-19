/// ProductCard - Reusable product card widget with iOS aesthetics
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import '../config/theme/app_colors.dart';
import '../config/theme/app_theme.dart';
import '../utils/formatters.dart';
import 'app_image.dart';

class ProductCard extends StatelessWidget {
  final String id;
  final String name;
  final String? nameAr;
  final String? imageUrl;
  final double price;
  final double? originalPrice;
  final int? stockQuantity;
  final bool isInWishlist;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCart;
  final VoidCallback? onToggleWishlist;

  const ProductCard({
    super.key,
    required this.id,
    required this.name,
    this.nameAr,
    this.imageUrl,
    required this.price,
    this.originalPrice,
    this.stockQuantity,
    this.isInWishlist = false,
    this.onTap,
    this.onAddToCart,
    this.onToggleWishlist,
  });

  bool get hasDiscount => originalPrice != null && originalPrice! > price;
  bool get isOutOfStock => stockQuantity != null && stockQuantity! <= 0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.cardLight,
          borderRadius: AppTheme.radiusLg,
          boxShadow: AppTheme.shadowSm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            Stack(
              children: [
                // Product Image
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16.r),
                    topRight: Radius.circular(16.r),
                  ),
                  child: AppImage(
                    imageUrl: imageUrl,
                    width: double.infinity,
                    height: 140,
                    fit: BoxFit.cover,
                    placeholderIcon: Iconsax.mobile,
                  ),
                ),

                // Discount Badge
                if (hasDiscount)
                  Positioned(
                    top: 8.h,
                    left: 8.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius: AppTheme.radiusSm,
                      ),
                      child: Text(
                        '${(((originalPrice! - price) / originalPrice!) * 100).toStringAsFixed(0)}%-',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                // Wishlist Button
                Positioned(
                  top: 8.h,
                  right: 8.w,
                  child: GestureDetector(
                    onTap: onToggleWishlist,
                    child: Container(
                      width: 32.w,
                      height: 32.w,
                      decoration: BoxDecoration(
                        color: (isDark ? AppColors.cardDark : Colors.white)
                            .withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isInWishlist ? Iconsax.heart5 : Iconsax.heart,
                        size: 16.sp,
                        color: isInWishlist
                            ? AppColors.error
                            : (isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight),
                      ),
                    ),
                  ),
                ),

                // Out of Stock Overlay
                if (isOutOfStock)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16.r),
                          topRight: Radius.circular(16.r),
                        ),
                      ),
                      child: Center(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 6.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: AppTheme.radiusSm,
                          ),
                          child: Text(
                            'نفذت الكمية',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimaryLight,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            // Content Section
            Padding(
              padding: EdgeInsets.all(12.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name
                  Text(
                    nameAr ?? name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                      height: 1.3,
                    ),
                  ),
                  SizedBox(height: 8.h),

                  // Price Row
                  Row(
                    children: [
                      // Current Price
                      Text(
                        Formatters.currency(price),
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),

                      // Original Price (if discounted)
                      if (hasDiscount) ...[
                        SizedBox(width: 6.w),
                        Text(
                          Formatters.currency(originalPrice!),
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w400,
                            color: isDark
                                ? AppColors.textTertiaryDark
                                : AppColors.textTertiaryLight,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ],
                  ),

                  // Stock Quantity
                  if (stockQuantity != null &&
                      stockQuantity! > 0 &&
                      stockQuantity! <= 10) ...[
                    SizedBox(height: 4.h),
                    Text(
                      'متبقي $stockQuantity فقط',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.warning,
                      ),
                    ),
                  ],

                  // Add to Cart Button
                  if (onAddToCart != null && !isOutOfStock) ...[
                    SizedBox(height: 12.h),
                    GestureDetector(
                      onTap: onAddToCart,
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: 10.h),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: AppTheme.radiusMd,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Iconsax.shopping_cart,
                              size: 16.sp,
                              color: Colors.white,
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              'أضف للسلة',
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
