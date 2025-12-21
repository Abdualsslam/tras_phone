/// Admin Orders Screen - Manage orders (admin mode)
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/config/theme/app_colors.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _orders = [
    {
      'id': 'ORD-001',
      'customer': 'أحمد محمد',
      'total': 1250.0,
      'status': 'pending',
      'date': '2024-12-20',
    },
    {
      'id': 'ORD-002',
      'customer': 'سعد العتيبي',
      'total': 850.0,
      'status': 'processing',
      'date': '2024-12-20',
    },
    {
      'id': 'ORD-003',
      'customer': 'خالد الشهري',
      'total': 2100.0,
      'status': 'shipped',
      'date': '2024-12-19',
    },
    {
      'id': 'ORD-004',
      'customer': 'محمد القحطاني',
      'total': 560.0,
      'status': 'delivered',
      'date': '2024-12-18',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة الطلبات'),
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
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: const [
            Tab(text: 'الكل'),
            Tab(text: 'جديدة'),
            Tab(text: 'قيد التجهيز'),
            Tab(text: 'تم الشحن'),
            Tab(text: 'مكتملة'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: List.generate(5, (index) => _buildOrdersList(index, isDark)),
      ),
    );
  }

  Widget _buildOrdersList(int tabIndex, bool isDark) {
    final statuses = ['all', 'pending', 'processing', 'shipped', 'delivered'];
    final status = statuses[tabIndex];
    final filtered = status == 'all'
        ? _orders
        : _orders.where((o) => o['status'] == status).toList();

    if (filtered.isEmpty) {
      return Center(
        child: Text(
          'لا توجد طلبات',
          style: TextStyle(color: AppColors.textSecondaryLight),
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.all(16.w),
      itemCount: filtered.length,
      separatorBuilder: (_, __) => SizedBox(height: 12.h),
      itemBuilder: (context, index) => _buildOrderCard(filtered[index], isDark),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order, bool isDark) {
    final statusInfo = _getStatusInfo(order['status'] as String);
    return GestureDetector(
      onTap: () => context.push('/admin/order/${order['id']}'),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.cardLight,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '#${order['id']}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: (statusInfo['color'] as Color).withValues(
                      alpha: 0.1,
                    ),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    statusInfo['label'] as String,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: statusInfo['color'] as Color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Icon(
                  Iconsax.user,
                  size: 16.sp,
                  color: AppColors.textSecondaryLight,
                ),
                SizedBox(width: 6.w),
                Text(
                  order['customer'] as String,
                  style: TextStyle(fontSize: 13.sp),
                ),
                const Spacer(),
                Text(
                  '${(order['total'] as double).toStringAsFixed(0)} ر.س',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                Icon(
                  Iconsax.calendar,
                  size: 14.sp,
                  color: AppColors.textTertiaryLight,
                ),
                SizedBox(width: 6.w),
                Text(
                  order['date'] as String,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
                const Spacer(),
                Icon(
                  Iconsax.arrow_left_2,
                  size: 16.sp,
                  color: AppColors.textSecondaryLight,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _getStatusInfo(String status) {
    switch (status) {
      case 'pending':
        return {'label': 'جديد', 'color': AppColors.warning};
      case 'processing':
        return {'label': 'قيد التجهيز', 'color': AppColors.info};
      case 'shipped':
        return {'label': 'تم الشحن', 'color': AppColors.primary};
      case 'delivered':
        return {'label': 'تم التوصيل', 'color': AppColors.success};
      default:
        return {'label': 'غير معروف', 'color': AppColors.textSecondaryLight};
    }
  }
}
