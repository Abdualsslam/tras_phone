/// Education Details Screen - Article or video content
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/config/theme/app_colors.dart';

class EducationDetailsScreen extends StatelessWidget {
  final String contentId;

  const EducationDetailsScreen({super.key, required this.contentId});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Iconsax.heart, size: 22.sp),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(Iconsax.share, size: 22.sp),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Video/Image Header
            Container(
              height: 220.h,
              width: double.infinity,
              color: AppColors.primary.withValues(alpha: 0.1),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    Iconsax.video,
                    size: 60.sp,
                    color: AppColors.primary.withValues(alpha: 0.3),
                  ),
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.play_arrow,
                      size: 32.sp,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Meta
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          'فيديو',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.error,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Icon(
                        Iconsax.clock,
                        size: 14.sp,
                        color: AppColors.textSecondaryLight,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        '15 دقيقة',
                        style: TextStyle(
                          fontSize: 12.sp,
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
                        '1,250 مشاهدة',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),

                  // Title
                  Text(
                    'كيفية تركيب شاشة iPhone 15 Pro Max',
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Author
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 20.r,
                        backgroundColor: AppColors.primary.withValues(
                          alpha: 0.1,
                        ),
                        child: Text(
                          'ت',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'فريق تراس فون',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '20 ديسمبر 2024',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),

                  // Content
                  Text(
                    'الوصف',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'في هذا الدرس سنتعلم خطوة بخطوة كيفية فك وتركيب شاشة iPhone 15 Pro Max بشكل احترافي. سنغطي الأدوات المطلوبة، احتياطات السلامة، وأفضل الممارسات لضمان نتيجة مثالية.\n\nالنقاط الرئيسية:\n• الأدوات المطلوبة للعملية\n• خطوات فك الشاشة القديمة\n• تركيب الشاشة الجديدة\n• اختبار الشاشة بعد التركيب\n• نصائح لتجنب الأخطاء الشائعة',
                    style: TextStyle(
                      fontSize: 14.sp,
                      height: 1.8,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // Related Products
                  Text(
                    'منتجات ذات صلة',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.cardDark : AppColors.cardLight,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 60.w,
                          height: 60.w,
                          decoration: BoxDecoration(
                            color: AppColors.backgroundLight,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Icon(
                            Iconsax.mobile,
                            size: 28.sp,
                            color: AppColors.textSecondaryLight,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'شاشة iPhone 15 Pro Max أصلية',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                '850 ر.س',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
