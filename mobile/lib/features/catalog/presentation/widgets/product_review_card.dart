/// Product Review Card - Shared widget for displaying a single review
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../../data/models/product_review_model.dart';

/// Formats review date for display (e.g. اليوم، أمس، منذ X أيام).
String formatReviewDate(DateTime date) {
  final diff = DateTime.now().difference(date);
  if (diff.inDays == 0) return 'اليوم';
  if (diff.inDays == 1) return 'أمس';
  if (diff.inDays < 7) return 'منذ ${diff.inDays} أيام';
  return '${date.day}/${date.month}/${date.year}';
}

/// Card widget for a single product review.
class ProductReviewCard extends StatelessWidget {
  final ThemeData theme;
  final bool isDark;
  final ProductReviewModel review;

  const ProductReviewCard({
    super.key,
    required this.theme,
    required this.isDark,
    required this.review,
  });

  @override
  Widget build(BuildContext context) {
    final displayName =
        review.customerName ?? review.customerShopName ?? 'مستخدم';
    final subTitle = review.customerShopName != null &&
            review.customerName != null
        ? review.customerShopName
        : null;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20.r,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: Text(
                  displayName.isNotEmpty ? displayName[0] : '?',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            displayName,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (review.isVerifiedPurchase) ...[
                          SizedBox(width: 8.w),
                          Icon(
                            Iconsax.verify5,
                            size: 16.sp,
                            color: AppColors.success,
                          ),
                        ],
                      ],
                    ),
                    if (subTitle != null)
                      Text(
                        subTitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textTertiaryLight,
                        ),
                      ),
                    Text(
                      formatReviewDate(review.createdAt),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textTertiaryLight,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < review.rating ? Iconsax.star5 : Iconsax.star,
                    size: 14.sp,
                    color: Colors.amber,
                  );
                }),
              ),
            ],
          ),
          if (review.title != null && review.title!.isNotEmpty) ...[
            SizedBox(height: 8.h),
            Text(
              review.title!,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          if (review.comment != null && review.comment!.isNotEmpty) ...[
            SizedBox(height: 8.h),
            Text(review.comment!, style: theme.textTheme.bodyMedium),
          ],
        ],
      ),
    );
  }
}
