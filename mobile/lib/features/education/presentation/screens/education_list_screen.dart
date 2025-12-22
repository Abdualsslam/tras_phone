/// Education List Screen - Articles list by category
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/config/theme/app_colors.dart';

class EducationListScreen extends StatelessWidget {
  final String categoryId;

  const EducationListScreen({super.key, required this.categoryId});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final articles = [
      {
        'id': '1',
        'title': 'كيفية تركيب شاشة iPhone 15',
        'type': 'video',
        'duration': '15 دقيقة',
        'views': 1250,
      },
      {
        'id': '2',
        'title': 'أخطاء شائعة عند تبديل البطارية',
        'type': 'article',
        'duration': '5 دقائق قراءة',
        'views': 890,
      },
      {
        'id': '3',
        'title': 'أدوات الصيانة الأساسية',
        'type': 'article',
        'duration': '8 دقائق قراءة',
        'views': 2100,
      },
      {
        'id': '4',
        'title': 'تشخيص مشاكل الشحن',
        'type': 'video',
        'duration': '12 دقيقة',
        'views': 1560,
      },
      {
        'id': '5',
        'title': 'فك وتركيب الإطار الخلفي',
        'type': 'video',
        'duration': '10 دقائق',
        'views': 980,
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('صيانة الشاشات')),
      body: ListView.separated(
        padding: EdgeInsets.all(16.w),
        itemCount: articles.length,
        separatorBuilder: (_, __) => SizedBox(height: 12.h),
        itemBuilder: (context, index) =>
            _buildArticleCard(articles[index], isDark, context),
      ),
    );
  }

  Widget _buildArticleCard(
    Map<String, dynamic> article,
    bool isDark,
    BuildContext context,
  ) {
    final isVideo = article['type'] == 'video';
    return GestureDetector(
      onTap: () => context.push('/education/details/${article['id']}'),
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.cardLight,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Container(
              width: 80.w,
              height: 80.w,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    isVideo ? Iconsax.video : Iconsax.document_text,
                    size: 32.sp,
                    color: AppColors.primary,
                  ),
                  if (isVideo)
                    Container(
                      padding: EdgeInsets.all(6.w),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.play_arrow,
                        size: 16.sp,
                        color: Colors.white,
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 2.h,
                    ),
                    decoration: BoxDecoration(
                      color: (isVideo ? AppColors.error : AppColors.info)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      isVideo ? 'فيديو' : 'مقال',
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: isVideo ? AppColors.error : AppColors.info,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    article['title'] as String,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      Icon(
                        Iconsax.clock,
                        size: 14.sp,
                        color: AppColors.textSecondaryLight,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        article['duration'] as String,
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Icon(
                        Iconsax.eye,
                        size: 14.sp,
                        color: AppColors.textSecondaryLight,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        '${article['views']}',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(
              Iconsax.arrow_left_2,
              size: 18.sp,
              color: AppColors.textSecondaryLight,
            ),
          ],
        ),
      ),
    );
  }
}
