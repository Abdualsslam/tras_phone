/// Product Reviews Screen - Show reviews for a product
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/config/theme/app_colors.dart';

class ProductReviewsScreen extends StatelessWidget {
  final int productId;

  const ProductReviewsScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final reviews = [
      _Review(
        id: 1,
        userName: 'أحمد محمد',
        rating: 5,
        comment: 'منتج ممتاز، جودة عالية وسعر مناسب. أنصح به بشدة',
        date: DateTime.now().subtract(const Duration(days: 2)),
        isVerified: true,
      ),
      _Review(
        id: 2,
        userName: 'خالد علي',
        rating: 4,
        comment: 'منتج جيد، التوصيل سريع',
        date: DateTime.now().subtract(const Duration(days: 5)),
        isVerified: true,
      ),
      _Review(
        id: 3,
        userName: 'محمد سعيد',
        rating: 3,
        comment: 'منتج مقبول، لكن التغليف يحتاج تحسين',
        date: DateTime.now().subtract(const Duration(days: 10)),
        isVerified: false,
      ),
    ];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('التقييمات')),
      body: Column(
        children: [
          // Rating Summary
          _buildRatingSummary(theme, isDark),
          Divider(height: 1, color: AppColors.dividerLight),

          // Reviews List
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.all(16.w),
              itemCount: reviews.length,
              separatorBuilder: (_, __) => SizedBox(height: 16.h),
              itemBuilder: (context, index) {
                return _buildReviewCard(theme, isDark, reviews[index]);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Iconsax.edit),
        label: const Text('أضف تقييم'),
      ),
    );
  }

  Widget _buildRatingSummary(ThemeData theme, bool isDark) {
    return Container(
      padding: EdgeInsets.all(20.w),
      color: isDark ? AppColors.cardDark : AppColors.cardLight,
      child: Row(
        children: [
          // Average Rating
          Column(
            children: [
              Text(
                '4.2',
                style: TextStyle(
                  fontSize: 48.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < 4 ? Iconsax.star5 : Iconsax.star,
                    size: 16.sp,
                    color: Colors.amber,
                  );
                }),
              ),
              SizedBox(height: 4.h),
              Text(
                '125 تقييم',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textTertiaryLight,
                ),
              ),
            ],
          ),
          SizedBox(width: 32.w),

          // Rating Bars
          Expanded(
            child: Column(
              children: [
                _buildRatingBar(theme, 5, 0.7),
                SizedBox(height: 6.h),
                _buildRatingBar(theme, 4, 0.2),
                SizedBox(height: 6.h),
                _buildRatingBar(theme, 3, 0.05),
                SizedBox(height: 6.h),
                _buildRatingBar(theme, 2, 0.03),
                SizedBox(height: 6.h),
                _buildRatingBar(theme, 1, 0.02),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingBar(ThemeData theme, int stars, double percentage) {
    return Row(
      children: [
        Text('$stars', style: theme.textTheme.bodySmall),
        SizedBox(width: 4.w),
        Icon(Iconsax.star5, size: 12.sp, color: Colors.amber),
        SizedBox(width: 8.w),
        Expanded(
          child: Container(
            height: 6.h,
            decoration: BoxDecoration(
              color: AppColors.dividerLight,
              borderRadius: BorderRadius.circular(3.r),
            ),
            child: FractionallySizedBox(
              widthFactor: percentage,
              alignment: Alignment.centerRight,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(3.r),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewCard(ThemeData theme, bool isDark, _Review review) {
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
                  review.userName[0],
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
                        Text(
                          review.userName,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (review.isVerified) ...[
                          SizedBox(width: 8.w),
                          Icon(
                            Iconsax.verify5,
                            size: 16.sp,
                            color: AppColors.success,
                          ),
                        ],
                      ],
                    ),
                    Text(
                      _formatDate(review.date),
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
          SizedBox(height: 12.h),
          Text(review.comment, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays == 0) return 'اليوم';
    if (diff.inDays == 1) return 'أمس';
    if (diff.inDays < 7) return 'منذ ${diff.inDays} أيام';
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _Review {
  final int id;
  final String userName;
  final int rating;
  final String comment;
  final DateTime date;
  final bool isVerified;

  _Review({
    required this.id,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.date,
    required this.isVerified,
  });
}
