/// Stock Alerts Screen - Product availability notifications
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/config/theme/app_colors.dart';

class StockAlertsScreen extends StatelessWidget {
  const StockAlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final alerts = [
      {
        'id': '1',
        'product': 'شاشة iPhone 14 Pro',
        'status': 'available',
        'addedAt': '2024-12-15',
      },
      {
        'id': '2',
        'product': 'بطارية Huawei P60',
        'status': 'waiting',
        'addedAt': '2024-12-18',
      },
      {
        'id': '3',
        'product': 'كاميرا Samsung S23',
        'status': 'waiting',
        'addedAt': '2024-12-20',
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('تنبيهات المخزون')),
      body: alerts.isEmpty
          ? _buildEmptyState(isDark)
          : ListView(
              padding: EdgeInsets.all(16.w),
              children: [
                // Info Card
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: AppColors.info.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Iconsax.info_circle,
                        size: 20.sp,
                        color: AppColors.info,
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Text(
                          'سنخبرك فور توفر المنتج مجدداً',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.info,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),
                ...alerts.map((a) => _buildAlertCard(a, isDark)),
              ],
            ),
    );
  }

  Widget _buildAlertCard(Map<String, dynamic> alert, bool isDark) {
    final isAvailable = alert['status'] == 'available';
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
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
              Iconsax.box,
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
                  alert['product'] as String,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: (isAvailable ? AppColors.success : AppColors.warning)
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    isAvailable ? 'متوفر الآن!' : 'في انتظار التوفر',
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: isAvailable
                          ? AppColors.success
                          : AppColors.warning,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(Iconsax.trash, size: 20.sp, color: AppColors.error),
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
          Icon(
            Iconsax.notification,
            size: 80.sp,
            color: AppColors.textTertiaryLight,
          ),
          SizedBox(height: 16.h),
          Text(
            'لا توجد تنبيهات',
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 8.h),
          Text(
            'أضف منتجات لتنبيهك عند توفرها',
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }
}
