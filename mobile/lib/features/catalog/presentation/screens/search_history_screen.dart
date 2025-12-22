/// Search History Screen - Recent and suggested searches
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/config/theme/app_colors.dart';

class SearchHistoryScreen extends StatefulWidget {
  const SearchHistoryScreen({super.key});

  @override
  State<SearchHistoryScreen> createState() => _SearchHistoryScreenState();
}

class _SearchHistoryScreenState extends State<SearchHistoryScreen> {
  final List<String> _recentSearches = [
    'شاشة iPhone 15',
    'بطارية Samsung',
    'غطاء خلفي',
    'شاحن أصلي',
    'كابل شحن',
    'سماعات',
  ];

  final List<String> _popularSearches = [
    'iPhone 15 Pro Max',
    'Samsung S24 Ultra',
    'شاشة أصلية',
    'بطارية أصلية',
    'قطع غيار هواوي',
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('سجل البحث'),
        actions: [
          if (_recentSearches.isNotEmpty)
            TextButton(
              onPressed: _clearHistory,
              child: Text('مسح الكل', style: TextStyle(color: AppColors.error)),
            ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          // Recent Searches
          if (_recentSearches.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'عمليات البحث الأخيرة',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Icon(
                  Iconsax.clock,
                  size: 18.sp,
                  color: AppColors.textSecondaryLight,
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: _recentSearches
                  .map((search) => _buildSearchChip(search, true, isDark))
                  .toList(),
            ),
            SizedBox(height: 24.h),
          ],

          // Popular Searches
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'الأكثر بحثاً',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
              ),
              Icon(Iconsax.trend_up, size: 18.sp, color: AppColors.primary),
            ],
          ),
          SizedBox(height: 12.h),
          ...List.generate(_popularSearches.length, (index) {
            return _buildPopularItem(
              _popularSearches[index],
              index + 1,
              isDark,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSearchChip(String query, bool canDelete, bool isDark) {
    return GestureDetector(
      onTap: () => context.push('/search?q=$query'),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.backgroundLight,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(query, style: TextStyle(fontSize: 13.sp)),
            if (canDelete) ...[
              SizedBox(width: 6.w),
              GestureDetector(
                onTap: () => setState(() => _recentSearches.remove(query)),
                child: Icon(
                  Icons.close,
                  size: 16.sp,
                  color: AppColors.textSecondaryLight,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPopularItem(String query, int rank, bool isDark) {
    return GestureDetector(
      onTap: () => context.push('/search?q=$query'),
      child: Container(
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.cardLight,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Row(
          children: [
            Container(
              width: 28.w,
              height: 28.w,
              decoration: BoxDecoration(
                color: rank <= 3
                    ? AppColors.primary
                    : AppColors.textTertiaryLight.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$rank',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: rank <= 3
                        ? Colors.white
                        : AppColors.textSecondaryLight,
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(query, style: TextStyle(fontSize: 14.sp)),
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

  void _clearHistory() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('مسح السجل'),
        content: const Text('هل تريد مسح سجل البحث بالكامل؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _recentSearches.clear());
            },
            child: Text('مسح', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
