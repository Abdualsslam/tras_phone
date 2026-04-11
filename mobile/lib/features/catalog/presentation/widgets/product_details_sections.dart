library;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/config/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../education/domain/entities/educational_content_entity.dart';
import '../../data/models/product_review_model.dart';
import '../../domain/entities/product_entity.dart';
import 'product_review_card.dart';
import 'rating_bar_row.dart';

String _localizedLabel(
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

class ProductBrandSkuRow extends StatelessWidget {
  final ProductEntity product;

  const ProductBrandSkuRow({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brandName = product.brandNameAr ?? product.brandName;

    return Row(
      children: [
        if (brandName != null && brandName.isNotEmpty)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Text(
              brandName,
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        const Spacer(),
        Text(
          'SKU: ${product.sku}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.textTertiaryLight,
          ),
        ),
      ],
    );
  }
}

class ProductPriceSection extends StatelessWidget {
  final ProductEntity product;

  const ProductPriceSection({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '${product.price.toStringAsFixed(0)} ${l10n.currency}',
          style: TextStyle(
            fontSize: 28.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
        if (product.hasDiscount) ...[
          SizedBox(width: 12.w),
          Text(
            '${product.originalPrice!.toStringAsFixed(0)} ${l10n.currency}',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textTertiaryLight,
              decoration: TextDecoration.lineThrough,
            ),
          ),
        ],
      ],
    );
  }
}

class ProductDescriptionCard extends StatelessWidget {
  final ProductEntity product;

  const ProductDescriptionCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final description = product.descriptionAr ?? product.description ?? '';

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.description,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondaryLight,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

class ProductSpecsCard extends StatelessWidget {
  final ProductEntity product;

  const ProductSpecsCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final hasCategory =
        product.categoryNameAr != null || product.categoryName != null;
    final hasQuality =
        product.qualityTypeNameAr != null || product.qualityTypeName != null;

    if (!hasCategory && !hasQuality) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.specifications,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 12.h),
          if (hasCategory)
            _ProductSpecRow(
              label: _localizedLabel(
                context,
                ar: 'Ø§Ù„Ù‚Ø³Ù…:',
                en: 'Category:',
              ),
              value: product.categoryNameAr ?? product.categoryName ?? '',
            ),
          if (hasCategory && hasQuality)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 4.h),
              child: Divider(
                color: isDark ? AppColors.glassBorder : Colors.grey[200],
              ),
            ),
          if (hasQuality)
            _ProductSpecRow(
              label: _localizedLabel(
                context,
                ar: 'Ø¯Ø±Ø¬Ø© Ø§Ù„Ø¬ÙˆØ¯Ø©:',
                en: 'Quality:',
              ),
              value: product.qualityTypeNameAr ?? product.qualityTypeName ?? '',
              highlight: true,
            ),
        ],
      ),
    );
  }
}

class _ProductSpecRow extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;

  const _ProductSpecRow({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondaryLight,
          ),
        ),
        Container(
          padding: highlight
              ? EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h)
              : null,
          decoration: highlight
              ? BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6.r),
                )
              : null,
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: highlight ? FontWeight.w600 : FontWeight.w500,
              color: highlight ? AppColors.primary : null,
            ),
          ),
        ),
      ],
    );
  }
}

class ProductCompatibleDevicesCard extends StatelessWidget {
  final ProductEntity product;
  final bool isLoading;

  const ProductCompatibleDevicesCard({
    super.key,
    required this.product,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final locale = Localizations.localeOf(context).languageCode;
    final devices = locale == 'ar'
        ? (product.compatibleDeviceNamesAr.isNotEmpty
              ? product.compatibleDeviceNamesAr
              : product.compatibleDeviceNames)
        : (product.compatibleDeviceNames.isNotEmpty
              ? product.compatibleDeviceNames
              : product.compatibleDeviceNamesAr);

    if (devices.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                _localizedLabel(
                  context,
                  ar: 'الأجهزة المتوافقة',
                  en: 'Compatible devices',
                ),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (isLoading) ...[
                SizedBox(width: 8.w),
                SizedBox(
                  width: 14.w,
                  height: 14.h,
                  child: const CircularProgressIndicator(strokeWidth: 2),
                ),
              ],
            ],
          ),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: devices
                .map(
                  (device) => Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(999.r),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Text(
                      device,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class ProductStockStatusCard extends StatelessWidget {
  final ProductEntity product;

  const ProductStockStatusCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isInStock = product.isInStock;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: (isInStock ? AppColors.success : AppColors.error).withValues(
          alpha: 0.1,
        ),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: (isInStock ? AppColors.success : AppColors.error).withValues(
            alpha: 0.3,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            isInStock ? Iconsax.tick_circle : Iconsax.close_circle,
            color: isInStock ? AppColors.success : AppColors.error,
            size: 24.sp,
          ),
          SizedBox(width: 12.w),
          Text(
            isInStock
                ? AppLocalizations.of(context)!.inStock
                : AppLocalizations.of(context)!.outOfStock,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: isInStock ? AppColors.success : AppColors.error,
            ),
          ),
        ],
      ),
    );
  }
}

class ProductReviewsSection extends StatelessWidget {
  final List<ProductReviewModel> reviews;
  final bool isLoading;
  final String? error;
  final double averageRating;
  final int reviewsCount;
  final VoidCallback onRetry;
  final VoidCallback onAddReview;

  const ProductReviewsSection({
    super.key,
    required this.reviews,
    required this.isLoading,
    required this.error,
    required this.averageRating,
    required this.reviewsCount,
    required this.onRetry,
    required this.onAddReview,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.reviews,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 16.h),
        if (isLoading)
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 24.h),
              child: SizedBox(
                width: 32.w,
                height: 32.h,
                child: const CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          )
        else if (error != null)
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowLight,
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(Iconsax.warning_2, color: AppColors.error, size: 32.sp),
                SizedBox(height: 8.h),
                Text(
                  error!,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium,
                ),
                SizedBox(height: 12.h),
                TextButton(onPressed: onRetry, child: Text(l10n.retryAction)),
              ],
            ),
          )
        else if (reviews.isEmpty)
          Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : AppColors.cardLight,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowLight,
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(
                  Iconsax.message_question,
                  size: 48.sp,
                  color: AppColors.textTertiaryLight,
                ),
                SizedBox(height: 12.h),
                Text(
                  _localizedLabel(
                    context,
                    ar: 'Ù„Ø§ ØªÙˆØ¬Ø¯ ØªÙ‚ÙŠÙŠÙ…Ø§Øª Ø¨Ø¹Ø¯',
                    en: 'No reviews yet',
                  ),
                  style: theme.textTheme.titleMedium,
                ),
                SizedBox(height: 8.h),
                Text(
                  _localizedLabel(
                    context,
                    ar: 'ÙƒÙ† Ø£ÙˆÙ„ Ù…Ù† ÙŠÙ‚ÙŠÙ‘Ù… Ù‡Ø°Ø§ Ø§Ù„Ù…Ù†ØªØ¬',
                    en: 'Be the first to review this product',
                  ),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textTertiaryLight,
                  ),
                ),
                SizedBox(height: 16.h),
                FilledButton.icon(
                  onPressed: onAddReview,
                  icon: const Icon(Iconsax.edit, size: 20),
                  label: Text(l10n.addReview),
                ),
              ],
            ),
          )
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : AppColors.cardLight,
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadowLight,
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Column(
                      children: [
                        Text(
                          averageRating.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 32.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                        Row(
                          children: List.generate(5, (index) {
                            return Icon(
                              index < averageRating.floor()
                                  ? Iconsax.star5
                                  : Iconsax.star,
                              size: 14.sp,
                              color: Colors.amber,
                            );
                          }),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          _localizedLabel(
                            context,
                            ar: '$reviewsCount ØªÙ‚ÙŠÙŠÙ…',
                            en: '$reviewsCount reviews',
                          ),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.textTertiaryLight,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: 24.w),
                    Expanded(
                      child: Column(
                        children: List.generate(5, (i) {
                          final star = 5 - i;
                          final count = reviews
                              .where((review) => review.rating == star)
                              .length;
                          final percentage = reviews.isEmpty
                              ? 0.0
                              : count / reviews.length;

                          return Padding(
                            padding: EdgeInsets.only(bottom: 6.h),
                            child: RatingBarRow(
                              theme: theme,
                              stars: star,
                              percentage: percentage,
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),
              ...reviews.map(
                (review) => Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: ProductReviewCard(
                    theme: theme,
                    isDark: isDark,
                    review: review,
                  ),
                ),
              ),
              SizedBox(height: 8.h),
              OutlinedButton.icon(
                onPressed: onAddReview,
                icon: const Icon(Iconsax.edit, size: 20),
                label: Text(l10n.addReview),
              ),
            ],
          ),
      ],
    );
  }
}

class ProductEducationSection extends StatelessWidget {
  final List<EducationalContentEntity> relatedContent;
  final bool isLoading;
  final String? error;
  final bool hasMore;
  final VoidCallback onRetry;
  final VoidCallback onOpenAll;

  const ProductEducationSection({
    super.key,
    required this.relatedContent,
    required this.isLoading,
    required this.error,
    required this.hasMore,
    required this.onRetry,
    required this.onOpenAll,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _localizedLabel(
            context,
            ar: 'Ø§Ù„Ù…Ø­ØªÙˆÙ‰ Ø§Ù„ØªØ¹Ù„ÙŠÙ…ÙŠ Ø§Ù„Ø®Ø§Øµ Ø¨Ø§Ù„Ù…Ù†ØªØ¬',
            en: 'Educational content for this product',
          ),
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 12.h),
        if (isLoading)
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : AppColors.cardLight,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          )
        else if (error != null)
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: AppColors.error.withValues(alpha: 0.25),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  error!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8.h),
                TextButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Iconsax.refresh),
                  label: Text(l10n.retryAction),
                ),
              ],
            ),
          )
        else if (relatedContent.isEmpty)
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : AppColors.cardLight,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _localizedLabel(
                    context,
                    ar: 'Ù„Ø§ ÙŠÙˆØ¬Ø¯ Ù…Ø­ØªÙˆÙ‰ ØªØ¹Ù„ÙŠÙ…ÙŠ Ù…Ø±ØªØ¨Ø· Ø¨Ù‡Ø°Ø§ Ø§Ù„Ù…Ù†ØªØ¬ Ø­Ø§Ù„ÙŠØ§Ù‹',
                    en: 'No related educational content is available yet',
                  ),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondaryLight,
                  ),
                ),
                SizedBox(height: 10.h),
                FilledButton.tonalIcon(
                  onPressed: () => context.push('/education'),
                  icon: const Icon(Iconsax.book_1),
                  label: Text(l10n.education),
                ),
              ],
            ),
          )
        else
          Column(
            children: relatedContent
                .map(
                  (content) => Padding(
                    padding: EdgeInsets.only(bottom: 10.h),
                    child: _EducationalContentCard(content: content),
                  ),
                )
                .toList(),
          ),
        if (!isLoading && error == null && relatedContent.isNotEmpty) ...[
          SizedBox(height: 8.h),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onOpenAll,
              icon: Icon(
                hasMore ? Iconsax.arrow_left_2 : Iconsax.book,
                size: 18.sp,
              ),
              label: Text(
                _localizedLabel(
                  context,
                  ar: 'Ø¹Ø±Ø¶ ÙƒÙ„ Ø§Ù„Ù…Ø­ØªÙˆÙ‰ Ø§Ù„ØªØ¹Ù„ÙŠÙ…ÙŠ',
                  en: 'View all educational content',
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _EducationalContentCard extends StatelessWidget {
  final EducationalContentEntity content;

  const _EducationalContentCard({required this.content});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final locale = Localizations.localeOf(context).languageCode;

    return InkWell(
      borderRadius: BorderRadius.circular(12.r),
      onTap: () => context.push('/education/details/${content.slug}'),
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.cardLight,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowLight,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (content.featuredImage != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: CachedNetworkImage(
                  imageUrl: content.featuredImage!,
                  width: 72.w,
                  height: 72.h,
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) => Container(
                    width: 72.w,
                    height: 72.h,
                    color: AppColors.inputBackgroundLight,
                    child: Icon(
                      Iconsax.book,
                      size: 20.sp,
                      color: AppColors.textTertiaryLight,
                    ),
                  ),
                ),
              )
            else
              Container(
                width: 72.w,
                height: 72.h,
                decoration: BoxDecoration(
                  color: AppColors.inputBackgroundLight,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Iconsax.book,
                  size: 20.sp,
                  color: AppColors.textTertiaryLight,
                ),
              ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    content.getTitle(locale),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    content.type.getName(locale),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (content.getExcerpt(locale) != null)
                    Padding(
                      padding: EdgeInsets.only(top: 4.h),
                      child: Text(
                        content.getExcerpt(locale)!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Icon(
              Iconsax.arrow_left_2,
              size: 16.sp,
              color: AppColors.textTertiaryLight,
            ),
          ],
        ),
      ),
    );
  }
}

class ProductDetailsBottomBar extends StatelessWidget {
  final ProductEntity product;
  final int quantity;
  final VoidCallback? onDecrease;
  final VoidCallback? onIncrease;
  final VoidCallback onAddToCart;

  const ProductDetailsBottomBar({
    super.key,
    required this.product,
    required this.quantity,
    required this.onDecrease,
    required this.onIncrease,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 10,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.total,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textTertiaryLight,
                    ),
                  ),
                  Text(
                    '${(product.price * quantity).toStringAsFixed(0)} ${l10n.currency}',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.backgroundDark
                    : AppColors.inputBackgroundLight,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _QuantityButton(icon: Iconsax.minus, onPressed: onDecrease),
                  SizedBox(
                    width: 36.w,
                    child: Text(
                      '$quantity',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  _QuantityButton(icon: Iconsax.add, onPressed: onIncrease),
                ],
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              flex: 2,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: product.isInStock
                      ? () {
                          HapticFeedback.mediumImpact();
                          onAddToCart();
                        }
                      : null,
                  borderRadius: BorderRadius.circular(14.r),
                  child: Container(
                    height: 48.h,
                    decoration: BoxDecoration(
                      gradient: product.isInStock
                          ? AppColors.primaryGradient
                          : null,
                      color: product.isInStock
                          ? null
                          : AppColors.textTertiaryLight.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(14.r),
                      boxShadow: product.isInStock
                          ? [
                              BoxShadow(
                                color: AppColors.shadowPrimary,
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Iconsax.shopping_cart,
                          size: 20.sp,
                          color: Colors.white,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          l10n.addToCart,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14.sp,
                          ),
                        ),
                      ],
                    ),
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

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const _QuantityButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          onPressed?.call();
          HapticFeedback.selectionClick();
        },
        borderRadius: BorderRadius.circular(10.r),
        child: SizedBox(
          width: 36.w,
          height: 36.h,
          child: Icon(
            icon,
            size: 18.sp,
            color: onPressed == null ? AppColors.textTertiaryLight : null,
          ),
        ),
      ),
    );
  }
}
