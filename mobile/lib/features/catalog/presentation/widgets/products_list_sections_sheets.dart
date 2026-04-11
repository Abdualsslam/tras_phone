import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/config/theme/app_colors.dart';

class ProductsSortSheet extends StatelessWidget {
  final String activeSortBy;
  final String activeSortOrder;
  final void Function(String sortBy, String sortOrder) onSortSelected;

  const ProductsSortSheet({
    super.key,
    required this.activeSortBy,
    required this.activeSortOrder,
    required this.onSortSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.all(20.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ترتيب حسب',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
          SizedBox(height: 16.h),
          _ProductsSortOptionTile(
            label: 'الأحدث',
            isSelected:
                activeSortBy == 'createdAt' && activeSortOrder == 'desc',
            isDark: isDark,
            onTap: () => onSortSelected('createdAt', 'desc'),
          ),
          _ProductsSortOptionTile(
            label: 'الأقدم',
            isSelected: activeSortBy == 'createdAt' && activeSortOrder == 'asc',
            isDark: isDark,
            onTap: () => onSortSelected('createdAt', 'asc'),
          ),
          _ProductsSortOptionTile(
            label: 'السعر: من الأقل للأعلى',
            isSelected: activeSortBy == 'price' && activeSortOrder == 'asc',
            isDark: isDark,
            onTap: () => onSortSelected('price', 'asc'),
          ),
          _ProductsSortOptionTile(
            label: 'السعر: من الأعلى للأقل',
            isSelected: activeSortBy == 'price' && activeSortOrder == 'desc',
            isDark: isDark,
            onTap: () => onSortSelected('price', 'desc'),
          ),
          _ProductsSortOptionTile(
            label: 'الأكثر مبيعاً',
            isSelected:
                activeSortBy == 'salesCount' && activeSortOrder == 'desc',
            isDark: isDark,
            onTap: () => onSortSelected('salesCount', 'desc'),
          ),
          _ProductsSortOptionTile(
            label: 'الاسم: أ-ي',
            isSelected: activeSortBy == 'name' && activeSortOrder == 'asc',
            isDark: isDark,
            onTap: () => onSortSelected('name', 'asc'),
          ),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }
}

class _ProductsSortOptionTile extends StatelessWidget {
  final String label;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _ProductsSortOptionTile({
    required this.label,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(
        isSelected ? Iconsax.tick_circle5 : Iconsax.tick_circle,
        color: isSelected ? AppColors.primary : AppColors.textTertiaryLight,
      ),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          color: isSelected
              ? AppColors.primary
              : (isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight),
        ),
      ),
    );
  }
}

class ProductsFilterSheet extends StatelessWidget {
  final bool hasCategoryFilter;
  final String activeCategoryName;
  final String activeSortLabel;
  final VoidCallback onClose;

  const ProductsFilterSheet({
    super.key,
    required this.hasCategoryFilter,
    required this.activeCategoryName,
    required this.activeSortLabel,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'تصفية النتائج',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
              TextButton(
                onPressed: onClose,
                child: const Text(
                  'إغلاق',
                  style: TextStyle(color: AppColors.primary),
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          if (hasCategoryFilter) ...[
            Text(
              'الفئة المطبقة',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            ),
            SizedBox(height: 10.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Row(
                children: [
                  Icon(Iconsax.category, size: 16.sp, color: AppColors.primary),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      activeCategoryName,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),
          ],
          Text(
            'الترتيب الحالي',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
          SizedBox(height: 10.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : AppColors.backgroundLight,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              activeSortLabel,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
          SizedBox(height: 20.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onClose,
              child: Text('تم', style: TextStyle(fontSize: 16.sp)),
            ),
          ),
        ],
      ),
    );
  }
}
