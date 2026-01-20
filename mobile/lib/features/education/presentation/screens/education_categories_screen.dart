/// Education Categories Screen - Educational content categories
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../domain/entities/educational_category_entity.dart';
import '../cubit/education_categories_cubit.dart';
import '../cubit/education_categories_state.dart';

class EducationCategoriesScreen extends StatelessWidget {
  const EducationCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<EducationCategoriesCubit>()..loadCategories(activeOnly: true),
      child: const _EducationCategoriesView(),
    );
  }
}

class _EducationCategoriesView extends StatelessWidget {
  const _EducationCategoriesView();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('المحتوى التعليمي')),
      body: BlocBuilder<EducationCategoriesCubit, EducationCategoriesState>(
        builder: (context, state) {
          if (state is EducationCategoriesLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is EducationCategoriesError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Iconsax.info_circle, size: 64.sp, color: Colors.red),
                  SizedBox(height: 16.h),
                  Text(
                    'حدث خطأ في تحميل البيانات',
                    style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    state.message,
                    style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondaryLight),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 24.h),
                  ElevatedButton.icon(
                    onPressed: () => context.read<EducationCategoriesCubit>().loadCategories(activeOnly: true),
                    icon: const Icon(Iconsax.refresh),
                    label: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          }

          if (state is EducationCategoriesLoaded) {
            final categories = state.categories;

            if (categories.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Iconsax.book, size: 64.sp, color: AppColors.textSecondaryLight),
                    SizedBox(height: 16.h),
                    Text(
                      'لا توجد فئات متاحة حالياً',
                      style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () => context.read<EducationCategoriesCubit>().refreshCategories(activeOnly: true),
              child: ListView(
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
                      final category = categories[index];
                      return _buildCategoryCard(category, isDark, context);
                    },
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildCategoryCard(
    EducationalCategoryEntity category,
    bool isDark,
    BuildContext context,
  ) {
    // Map icon name to IconData
    IconData getIcon(String? iconName) {
      switch (iconName?.toLowerCase()) {
        case 'mobile':
          return Iconsax.mobile;
        case 'battery':
          return Iconsax.battery_charging;
        case 'code':
          return Iconsax.code;
        case 'search':
          return Iconsax.search_status;
        case 'setting':
          return Iconsax.setting_2;
        case 'lamp':
          return Iconsax.lamp_on;
        default:
          return Iconsax.book;
      }
    }

    return GestureDetector(
      onTap: () => context.push('/education/list/${category.slug}'),
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
                getIcon(category.icon),
                size: 24.sp,
                color: AppColors.primary,
              ),
            ),
            const Spacer(),
            Text(
              category.nameAr ?? category.name,
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 2.h),
            Text(
              '${category.contentCount} مقال',
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
