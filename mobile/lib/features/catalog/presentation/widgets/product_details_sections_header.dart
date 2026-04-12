import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/config/theme/app_colors.dart';
import '../../domain/entities/product_entity.dart';

String localizedProductLabel(
  BuildContext context, {
  required String ar,
  required String en,
}) {
  return Localizations.localeOf(context).languageCode == 'ar' ? ar : en;
}

class ProductDetailsSliverAppBar extends StatelessWidget {
  final ProductEntity product;
  final PageController pageController;
  final int currentImageIndex;
  final ValueChanged<int> onPageChanged;
  final bool isFavorite;
  final bool isLoadingFavorite;
  final VoidCallback onToggleFavorite;
  final VoidCallback onShare;

  const ProductDetailsSliverAppBar({
    super.key,
    required this.product,
    required this.pageController,
    required this.currentImageIndex,
    required this.onPageChanged,
    required this.isFavorite,
    required this.isLoadingFavorite,
    required this.onToggleFavorite,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final images = product.images.isNotEmpty
        ? product.images
        : (product.imageUrl != null ? [product.imageUrl!] : <String>[]);

    return SliverAppBar(
      expandedHeight: 350.h,
      pinned: true,
      backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
      systemOverlayStyle: isDark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
      leading: Container(
        margin: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: isDark ? AppColors.glassDark : AppColors.glassLight,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.glassBorder, width: 1),
        ),
        child: IconButton(
          icon: const Icon(Iconsax.arrow_right_3),
          onPressed: () => context.pop(),
        ),
      ),
      actions: [
        Container(
          margin: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: isDark ? AppColors.glassDark : AppColors.glassLight,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.glassBorder, width: 1),
          ),
          child: IconButton(
            icon: isLoadingFavorite
                ? SizedBox(
                    width: 20.sp,
                    height: 20.sp,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isFavorite ? AppColors.error : AppColors.primary,
                      ),
                    ),
                  )
                : Icon(
                    isFavorite ? Iconsax.heart5 : Iconsax.heart,
                    color: isFavorite ? AppColors.error : null,
                  ),
            onPressed: onToggleFavorite,
          ),
        ),
        Container(
          margin: EdgeInsets.only(left: 8.w, top: 8.w, bottom: 8.w),
          decoration: BoxDecoration(
            color: isDark ? AppColors.glassDark : AppColors.glassLight,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.glassBorder, width: 1),
          ),
          child: IconButton(
            icon: const Icon(Iconsax.share),
            onPressed: onShare,
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            if (images.isNotEmpty)
              PageView.builder(
                controller: pageController,
                itemCount: images.length,
                onPageChanged: onPageChanged,
                itemBuilder: (context, index) {
                  final imageUrl = images[index];
                  final isLocalAsset = imageUrl.startsWith('assets/');

                  return Container(
                    color: isDark ? AppColors.surfaceDark : Colors.grey[100],
                    child: isLocalAsset
                        ? Image.asset(
                            imageUrl,
                            fit: BoxFit.contain,
                            errorBuilder: (_, _, _) => Center(
                              child: Icon(
                                Iconsax.image,
                                size: 80.sp,
                                color: AppColors.textTertiaryLight,
                              ),
                            ),
                          )
                        : CachedNetworkImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.contain,
                            placeholder: (context, url) => const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            errorWidget: (context, url, error) => Center(
                              child: Icon(
                                Iconsax.image,
                                size: 80.sp,
                                color: AppColors.textTertiaryLight,
                              ),
                            ),
                          ),
                  );
                },
              )
            else
              Container(
                color: isDark ? AppColors.surfaceDark : Colors.grey[100],
                child: Center(
                  child: Icon(
                    Iconsax.image,
                    size: 80.sp,
                    color: AppColors.textTertiaryLight,
                  ),
                ),
              ),
            if (images.length > 1)
              Positioned(
                bottom: 16.h,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    images.length,
                    (index) => Container(
                      width: currentImageIndex == index ? 24.w : 8.w,
                      height: 8.h,
                      margin: EdgeInsets.symmetric(horizontal: 4.w),
                      decoration: BoxDecoration(
                        color: currentImageIndex == index
                            ? AppColors.primary
                            : Colors.grey.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ),
                  ),
                ),
              ),
            if (product.hasDiscount)
              Positioned(
                top: 100.h,
                right: 16.w,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    '-${product.discountPercentage.toInt()}%',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
