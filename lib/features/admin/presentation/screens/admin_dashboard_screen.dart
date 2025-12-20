/// Admin Dashboard Screen - Overview for admin users
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/config/theme/app_colors.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('لوحة التحكم'),
        actions: [
          IconButton(icon: const Icon(Iconsax.notification), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats Cards
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12.w,
              mainAxisSpacing: 12.h,
              childAspectRatio: 1.5,
              children: [
                _buildStatCard(
                  theme,
                  isDark,
                  'الطلبات الجديدة',
                  '24',
                  Iconsax.box,
                  Colors.blue,
                ),
                _buildStatCard(
                  theme,
                  isDark,
                  'قيد التجهيز',
                  '12',
                  Iconsax.clock,
                  Colors.orange,
                ),
                _buildStatCard(
                  theme,
                  isDark,
                  'مكتملة اليوم',
                  '8',
                  Iconsax.tick_circle,
                  AppColors.success,
                ),
                _buildStatCard(
                  theme,
                  isDark,
                  'الإيرادات',
                  '15,240',
                  Iconsax.wallet,
                  AppColors.primary,
                ),
              ],
            ),
            SizedBox(height: 24.h),

            // Quick Actions
            Text(
              'الإجراءات السريعة',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                  child: _buildActionCard(
                    theme,
                    isDark,
                    'الطلبات',
                    Iconsax.box,
                    () {},
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _buildActionCard(
                    theme,
                    isDark,
                    'العملاء',
                    Iconsax.people,
                    () {},
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _buildActionCard(
                    theme,
                    isDark,
                    'المنتجات',
                    Iconsax.shopping_bag,
                    () {},
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.h),

            // Recent Orders
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'آخر الطلبات',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextButton(onPressed: () {}, child: const Text('عرض الكل')),
              ],
            ),
            SizedBox(height: 8.h),
            _buildRecentOrders(theme, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    ThemeData theme,
    bool isDark,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, color: color, size: 20.sp),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
              Text(
                title,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textTertiaryLight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    ThemeData theme,
    bool isDark,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.cardLight,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 28.sp),
            SizedBox(height: 8.h),
            Text(
              title,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentOrders(ThemeData theme, bool isDark) {
    final orders = [
      _AdminOrder(
        'ORD-2024-005',
        'محمد أحمد',
        '1,240 ر.ي',
        'جديد',
        Colors.blue,
      ),
      _AdminOrder(
        'ORD-2024-004',
        'خالد سعيد',
        '850 ر.ي',
        'قيد التجهيز',
        Colors.orange,
      ),
      _AdminOrder(
        'ORD-2024-003',
        'علي محمد',
        '2,100 ر.ي',
        'تم الشحن',
        Colors.teal,
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: orders.asMap().entries.map((entry) {
          final isLast = entry.key == orders.length - 1;
          final order = entry.value;
          return Column(
            children: [
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  child: Text(
                    order.customer[0],
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                title: Text(
                  order.orderNumber,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(order.customer),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      order.total,
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: order.statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        order.status,
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: order.statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (!isLast) Divider(height: 1, indent: 16.w, endIndent: 16.w),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _AdminOrder {
  final String orderNumber;
  final String customer;
  final String total;
  final String status;
  final Color statusColor;

  _AdminOrder(
    this.orderNumber,
    this.customer,
    this.total,
    this.status,
    this.statusColor,
  );
}
