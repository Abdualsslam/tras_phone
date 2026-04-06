library;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';

import '../../cache/image_cache_config.dart';
import '../../config/theme/app_colors.dart';

class ProductListItem extends StatelessWidget {
  final String id;
  final String title;
  final String? imageUrl;
  final double price;
  final double? originalPrice;
  final bool isFavorite;
  final VoidCallback? onTap;
  final VoidCallback? onToggleFavorite;

  const ProductListItem({
    super.key,
    required this.id,
    required this.title,
    required this.price,
    this.imageUrl,
    this.originalPrice,
    this.isFavorite = false,
    this.onTap,
    this.onToggleFavorite,
  });

  bool get hasDiscount =>
      originalPrice != null && originalPrice! > price;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Ink(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : AppColors.cardLight,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.08 : 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              _ProductListImage(imageUrl: imageUrl),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                        height: 1.35,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    if (hasDiscount)
                      Text(
                        '${originalPrice!.toStringAsFixed(0)} ر.س',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: isDark
                              ? AppColors.textTertiaryDark
                              : AppColors.textTertiaryLight,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    Text(
                      '${price.toStringAsFixed(0)} ر.س',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 10.w),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (onToggleFavorite != null)
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        onToggleFavorite?.call();
                      },
                      child: Container(
                        width: 34.w,
                        height: 34.w,
                        decoration: BoxDecoration(
                          color: (isDark ? AppColors.surfaceDark : Colors.white)
                              .withValues(alpha: 0.96),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isFavorite
                                ? AppColors.error.withValues(alpha: 0.2)
                                : (isDark
                                      ? AppColors.dividerDark
                                      : AppColors.dividerLight),
                          ),
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
                    )
                  else
                    SizedBox(width: 34.w, height: 34.w),
                  SizedBox(height: 10.h),
                  Icon(
                    Iconsax.arrow_left_2,
                    size: 18.sp,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductListImage extends StatelessWidget {
  final String? imageUrl;

  const _ProductListImage({this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final image = imageUrl?.trim();

    return ClipRRect(
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        width: 82.w,
        height: 82.w,
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.surfaceDark
            : AppColors.backgroundLight,
        child: _buildImage(image),
      ),
    );
  }

  Widget _buildImage(String? image) {
    if (image == null || image.isEmpty) {
      return const _ProductListImageFallback();
    }

    if (image.startsWith('assets/')) {
      return Image.asset(
        image,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            const _ProductListImageFallback(),
      );
    }

    return CachedNetworkImage(
      imageUrl: image,
      cacheKey: imageCacheKey(image),
      cacheManager: imageCacheManager,
      fit: BoxFit.cover,
      fadeInDuration: const Duration(milliseconds: 160),
      placeholder: (context, url) => const _ProductListImagePlaceholder(),
      errorWidget: (context, url, error) => const _ProductListImageFallback(),
    );
  }
}

class _ProductListImagePlaceholder extends StatelessWidget {
  const _ProductListImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.08),
            AppColors.primary.withValues(alpha: 0.14),
          ],
        ),
      ),
      child: Center(
        child: Container(
          width: 34.w,
          height: 34.w,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.45),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Iconsax.gallery,
            size: 16.sp,
            color: AppColors.primary.withValues(alpha: 0.7),
          ),
        ),
      ),
    );
  }
}

class _ProductListImageFallback extends StatelessWidget {
  const _ProductListImageFallback();

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
          size: 26.sp,
          color: AppColors.primary.withValues(alpha: 0.7),
        ),
      ),
    );
  }
}
