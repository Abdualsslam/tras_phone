/// Product Offer Card - Card widget for products with offers
library;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/extensions/product_offer_extension.dart';

/// Card widget for displaying products with offers
class ProductOfferCard extends StatelessWidget {
  final ProductEntity product;
  final VoidCallback? onTap;
  final bool isFavorite;
  final VoidCallback? onToggleFavorite;

  const ProductOfferCard({
    super.key,
    required this.product,
    this.onTap,
    this.isFavorite = false,
    this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.cardLight,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowLight,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section with discount badge
            _buildImageSection(isDark),

            // Content Section
            Padding(
              padding: EdgeInsets.all(12.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name
                  Text(
                    product.nameAr,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                      height: 1.3,
                    ),
                  ),
                  SizedBox(height: 8.h),

                  // Price Section
                  _buildPriceSection(isDark),

                  // Saved Amount
                  if (product.hasDirectOffer) ...[
                    SizedBox(height: 4.h),
                    Text(
                      product.savedAmountText,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: AppColors.success,
                        fontWeight: FontWeight.w500,
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

  Widget _buildImageSection(bool isDark) {
    return Stack(
      children: [
        // Product Image
        ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.r),
            topRight: Radius.circular(16.r),
          ),
          child: AspectRatio(
            aspectRatio: 1,
            child: product.mainImage != null
                ? CachedNetworkImage(
                    imageUrl: product.mainImage!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    placeholder: (context, url) => Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    ),
                    errorWidget: (context, url, error) => Center(
                      child: Icon(
                        Iconsax.image,
                        size: 48.sp,
                        color: AppColors.textTertiaryLight,
                      ),
                    ),
                  )
                : Container(
                    color: isDark
                        ? AppColors.backgroundDark
                        : AppColors.backgroundLight,
                    child: Center(
                      child: Icon(
                        Iconsax.image,
                        size: 48.sp,
                        color: AppColors.textTertiaryLight,
                      ),
                    ),
                  ),
          ),
        ),

        // Discount Badge
        if (product.hasDirectOffer)
          Positioned(
            top: 8.h,
            left: 8.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: AppColors.error,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                product.discountText,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 11.sp,
                ),
              ),
            ),
          ),

        // Favorite Button
        if (onToggleFavorite != null)
          Positioned(
            top: 8.h,
            right: 8.w,
            child: GestureDetector(
              onTap: onToggleFavorite,
              child: Container(
                width: 32.w,
                height: 32.w,
                decoration: BoxDecoration(
                  color: (isDark ? AppColors.cardDark : Colors.white)
                      .withValues(alpha: 0.95),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  isFavorite ? Iconsax.heart5 : Iconsax.heart,
                  size: 16.sp,
                  color: isFavorite
                      ? AppColors.error
                      : (isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPriceSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Current Price
        Row(
          children: [
            Flexible(
              child: Text(
                '${product.currentPriceForOffer.toStringAsFixed(0)} ر.س',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.error,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),

        // Original Price (if discounted)
        if (product.hasDirectOffer && product.compareAtPrice != null) ...[
          SizedBox(height: 4.h),
          Text(
            '${product.originalPriceForOffer.toStringAsFixed(0)} ر.س',
            style: TextStyle(
              fontSize: 12.sp,
              decoration: TextDecoration.lineThrough,
              color: isDark
                  ? AppColors.textTertiaryDark
                  : AppColors.textTertiaryLight,
            ),
          ),
        ],
      ],
    );
  }
}
