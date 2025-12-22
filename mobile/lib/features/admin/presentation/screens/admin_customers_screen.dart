/// Admin Customers Screen - Manage customers (admin mode)
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/config/theme/app_colors.dart';

class AdminCustomersScreen extends StatelessWidget {
  const AdminCustomersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final customers = [
      {
        'id': '1',
        'name': 'مؤسسة الصيانة الذكية',
        'phone': '0551234567',
        'orders': 45,
        'total': 25000.0,
        'tier': 'gold',
      },
      {
        'id': '2',
        'name': 'محل التقنية الحديثة',
        'phone': '0559876543',
        'orders': 32,
        'total': 18500.0,
        'tier': 'silver',
      },
      {
        'id': '3',
        'name': 'ورشة الفني المحترف',
        'phone': '0551112233',
        'orders': 12,
        'total': 6200.0,
        'tier': 'bronze',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة العملاء'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Iconsax.search_normal, size: 22.sp),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(Iconsax.filter, size: 22.sp),
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          // Stats Row
          Row(
            children: [
              _buildStatCard('إجمالي العملاء', '156', Iconsax.people, isDark),
              SizedBox(width: 12.w),
              _buildStatCard('عملاء جدد', '12', Iconsax.user_add, isDark),
              SizedBox(width: 12.w),
              _buildStatCard('نشطون', '89', Iconsax.user_tick, isDark),
            ],
          ),
          SizedBox(height: 24.h),
          Text(
            'قائمة العملاء',
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 12.h),
          ...customers.map((c) => _buildCustomerCard(c, isDark)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppColors.primary,
        child: Icon(Iconsax.user_add, size: 24.sp, color: Colors.white),
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    bool isDark,
  ) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.cardLight,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Column(
          children: [
            Icon(icon, size: 22.sp, color: AppColors.primary),
            SizedBox(height: 8.h),
            Text(
              value,
              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w700),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 10.sp,
                color: AppColors.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerCard(Map<String, dynamic> customer, bool isDark) {
    final tierColors = {
      'gold': AppColors.warning,
      'silver': Colors.grey,
      'bronze': Colors.brown,
    };
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24.r,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: Text(
                  (customer['name'] as String)[0],
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
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
                          customer['name'] as String,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: tierColors[customer['tier']]!.withValues(
                              alpha: 0.15,
                            ),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text(
                            customer['tier'] as String,
                            style: TextStyle(
                              fontSize: 9.sp,
                              color: tierColors[customer['tier']],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      customer['phone'] as String,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(Iconsax.more, size: 20.sp),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              _buildCustomerStat('الطلبات', '${customer['orders']}'),
              SizedBox(width: 24.w),
              _buildCustomerStat(
                'إجمالي المشتريات',
                '${(customer['total'] as double).toStringAsFixed(0)} ر.س',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11.sp,
            color: AppColors.textSecondaryLight,
          ),
        ),
        Text(
          value,
          style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
