/// Education Categories Screen - Educational content categories
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/config/theme/app_colors.dart';

class EducationCategoriesScreen extends StatelessWidget {
  const EducationCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final categories = [
      {
        'id': '1',
        'title': 'صيانة الشاشات',
        'icon': Iconsax.mobile,
        'count': 15,
      },
      {
        'id': '2',
        'title': 'البطاريات والشحن',
        'icon': Iconsax.battery_charging,
        'count': 12,
      },
      {'id': '3', 'title': 'البرمجيات', 'icon': Iconsax.code, 'count': 8},
      {
        'id': '4',
        'title': 'تشخيص الأعطال',
        'icon': Iconsax.search_status,
        'count': 20,
      },
      {
        'id': '5',
        'title': 'أدوات الصيانة',
        'icon': Iconsax.setting_2,
        'count': 10,
      },
      {
        'id': '6',
        'title': 'نصائح للمبتدئين',
        'icon': Iconsax.lamp_on,
        'count': 18,
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('المحتوى التعليمي')),
      body: ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          // Featured Banner
          Container(
            height: 150.h,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Stack(
              children: [
                Positioned(
                  left: 16.w,
                  bottom: 16.h,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'تعلم صيانة الهواتف',
                        style: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'دورات ومقالات مجانية',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.white70,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 8.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Text(
                          'ابدأ الآن',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: 16.w,
                  top: 16.h,
                  child: Icon(
                    Iconsax.book,
                    size: 80.sp,
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),

          // Categories Grid
          Text(
            'التصنيفات',
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 12.h),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12.h,
              crossAxisSpacing: 12.w,
              childAspectRatio: 1.3,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
              return _buildCategoryCard(cat, isDark, context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(
    Map<String, dynamic> category,
    bool isDark,
    BuildContext context,
  ) {
    return GestureDetector(
      onTap: () => context.push('/education/list/${category['id']}'),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.cardLight,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                category['icon'] as IconData,
                size: 24.sp,
                color: AppColors.primary,
              ),
            ),
            const Spacer(),
            Text(
              category['title'] as String,
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 2.h),
            Text(
              '${category['count']} مقال',
              style: TextStyle(
                fontSize: 11.sp,
                color: AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
