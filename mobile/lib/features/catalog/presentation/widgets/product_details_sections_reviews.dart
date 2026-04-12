import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/config/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/models/product_review_model.dart';
import 'product_details_sections_header.dart';
import 'product_review_card.dart';
import 'rating_bar_row.dart';

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
                  localizedProductLabel(
                    context,
                    ar: 'لا توجد تقييمات بعد',
                    en: 'No reviews yet',
                  ),
                  style: theme.textTheme.titleMedium,
                ),
                SizedBox(height: 8.h),
                Text(
                  localizedProductLabel(
                    context,
                    ar: 'كن أول من يقيّم هذا المنتج',
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
                          localizedProductLabel(
                            context,
                            ar: '$reviewsCount تقييم',
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
