/// My Reviews Screen - User's submitted reviews
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/config/theme/app_colors.dart';

class MyReviewsScreen extends StatelessWidget {
  const MyReviewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final reviews = [
      {
        'id': '1',
        'product': 'شاشة iPhone 15 Pro Max',
        'rating': 5,
        'comment': 'منتج ممتاز وجودة عالية',
        'date': '2024-12-18',
      },
      {
        'id': '2',
        'product': 'بطارية Samsung S24',
        'rating': 4,
        'comment': 'جيدة جداً، التوصيل سريع',
        'date': '2024-12-15',
      },
      {
        'id': '3',
        'product': 'غطاء خلفي iPhone 14',
        'rating': 5,
        'comment': 'مطابق للأصلي تماماً',
        'date': '2024-12-10',
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('تقييماتي')),
      body: reviews.isEmpty
          ? _buildEmptyState(isDark)
          : ListView.separated(
              padding: EdgeInsets.all(16.w),
              itemCount: reviews.length,
              separatorBuilder: (_, __) => SizedBox(height: 12.h),
              itemBuilder: (context, index) =>
                  _buildReviewCard(reviews[index], isDark, context),
            ),
    );
  }

  Widget _buildReviewCard(
    Map<String, dynamic> review,
    bool isDark,
    BuildContext context,
  ) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  review['product'] as String,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => _showEditDeleteMenu(context),
                icon: Icon(Iconsax.more, size: 20.sp),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: List.generate(
              5,
              (i) => Icon(
                i < (review['rating'] as int)
                    ? Iconsax.star_15
                    : Iconsax.star_1,
                size: 16.sp,
                color: AppColors.warning,
              ),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            review['comment'] as String,
            style: TextStyle(
              fontSize: 13.sp,
              color: AppColors.textSecondaryLight,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            review['date'] as String,
            style: TextStyle(
              fontSize: 11.sp,
              color: AppColors.textTertiaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.star, size: 80.sp, color: AppColors.textTertiaryLight),
          SizedBox(height: 16.h),
          Text(
            'لا توجد تقييمات',
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 8.h),
          Text(
            'لم تقم بتقييم أي منتج بعد',
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  void _showEditDeleteMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Iconsax.edit),
              title: const Text('تعديل'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: Icon(Iconsax.trash, color: AppColors.error),
              title: Text('حذف', style: TextStyle(color: AppColors.error)),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
