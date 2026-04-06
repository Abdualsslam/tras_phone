/// ProductCard - Reusable product card widget with iOS aesthetics
library;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';

import '../../cache/image_cache_config.dart';
import '../../config/theme/app_colors.dart';

class ProductCard extends StatelessWidget {
  final String id;
  final String name;
  final String? nameAr;
  final String? imageUrl;
  final double price;
  final double? originalPrice;
  final int? stockQuantity;
  final bool isFavorite;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCart;
  final VoidCallback? onToggleFavorite;

  const ProductCard({
    super.key,
    required this.id,
    required this.name,
    this.nameAr,
    this.imageUrl,
    required this.price,
    this.originalPrice,
    this.stockQuantity,
    this.isFavorite = false,
    this.onTap,
    this.onAddToCart,
    this.onToggleFavorite,
  });

  bool get hasDiscount => originalPrice != null && originalPrice! > price;

  bool get isOutOfStock => stockQuantity != null && stockQuantity! <= 0;

  int get discountPercent {
    if (!hasDiscount) return 0;
    return (((originalPrice! - price) / originalPrice!) * 100).round();
  }

  void _handleFavoriteTap() {
    if (onToggleFavorite == null) return;
    HapticFeedback.lightImpact();
    onToggleFavorite?.call();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final hasBoundedHeight = constraints.maxHeight.isFinite;
          final cardWidth = constraints.maxWidth.isFinite
              ? constraints.maxWidth
              : 165.w;
          final imageHeight = hasBoundedHeight
              ? (constraints.maxHeight * 0.48).clamp(110.r, cardWidth * 0.82)
              : cardWidth;

          return Container(
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
            child: hasBoundedHeight
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: imageHeight,
                        width: double.infinity,
                        child: _buildImageSection(isDark),
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.all(12.r),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                nameAr ?? name,
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
                              Expanded(
                                child: Align(
                                  alignment: Alignment.bottomLeft,
                                  child: _buildPriceSection(isDark),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: imageHeight,
                        width: double.infinity,
                        child: _buildImageSection(isDark),
                      ),
                      Padding(
                        padding: EdgeInsets.all(12.r),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              nameAr ?? name,
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
                            _buildPriceSection(isDark),
                          ],
                        ),
                      ),
                    ],
                  ),
          );
        },
      ),
    );
  }

  Widget _buildImageSection(bool isDark) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.r),
            topRight: Radius.circular(16.r),
          ),
          child: Container(
            width: double.infinity,
            color: isDark ? AppColors.surfaceDark : Colors.grey[100],
            child: _buildImage(),
          ),
        ),
        if (hasDiscount)
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
                '-$discountPercent%',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        if (onToggleFavorite != null)
          Positioned(
            top: 8.h,
            right: 8.w,
            child: GestureDetector(
              onTap: _handleFavoriteTap,
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
        if (isOutOfStock)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
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
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    'نفذت الكمية',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimaryLight,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildImage() {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return const _ProductImageFallback();
    }

    if (imageUrl!.startsWith('assets/')) {
      return Image.asset(
        imageUrl!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) =>
            const _ProductImageFallback(),
      );
    }

    return CachedNetworkImage(
      imageUrl: imageUrl!,
      cacheKey: imageCacheKey(imageUrl!),
      cacheManager: imageCacheManager,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      fadeInDuration: const Duration(milliseconds: 140),
      placeholder: (context, url) => const _ProductImagePlaceholder(),
      errorWidget: (context, url, error) => const _ProductImageFallback(),
    );
  }

  Widget _buildPriceSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                '${price.toStringAsFixed(0)} ر.س',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        if (hasDiscount) ...[
          SizedBox(height: 2.h),
          Text(
            '${originalPrice!.toStringAsFixed(0)} ر.س',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w400,
              color: isDark
                  ? AppColors.textTertiaryDark
                  : AppColors.textTertiaryLight,
              decoration: TextDecoration.lineThrough,
              decorationColor: isDark
                  ? AppColors.textTertiaryDark
                  : AppColors.textTertiaryLight,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }
}

class _ProductImagePlaceholder extends StatelessWidget {
  const _ProductImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.08),
            AppColors.primary.withValues(alpha: 0.16),
          ],
        ),
      ),
      child: Center(
        child: Container(
          width: 38.w,
          height: 38.w,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.5),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Iconsax.gallery,
            size: 18.sp,
            color: AppColors.primary.withValues(alpha: 0.7),
          ),
        ),
      ),
    );
  }
}

class _ProductImageFallback extends StatelessWidget {
  const _ProductImageFallback();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.05),
            AppColors.primary.withValues(alpha: 0.12),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Iconsax.mobile,
          size: 40.sp,
          color: AppColors.primary.withValues(alpha: 0.72),
        ),
      ),
    );
  }
}
