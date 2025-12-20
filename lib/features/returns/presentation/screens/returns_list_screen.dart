/// Returns List Screen - List of return requests
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/config/theme/app_colors.dart';

enum ReturnStatus { pending, approved, rejected, completed }

class ReturnsListScreen extends StatelessWidget {
  const ReturnsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final returns = [
      _Return(
        id: 1,
        orderNumber: 'ORD-2024-001',
        productName: 'شاشة آيفون 14 برو ماكس',
        reason: 'منتج معيب',
        status: ReturnStatus.approved,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      _Return(
        id: 2,
        orderNumber: 'ORD-2024-002',
        productName: 'بطارية سامسونج S23',
        reason: 'منتج خاطئ',
        status: ReturnStatus.pending,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('طلبات الإرجاع')),
      body: returns.isEmpty
          ? _buildEmptyState(theme)
          : ListView.separated(
              padding: EdgeInsets.all(16.w),
              itemCount: returns.length,
              separatorBuilder: (_, __) => SizedBox(height: 12.h),
              itemBuilder: (context, index) {
                return _buildReturnCard(theme, isDark, returns[index]);
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Iconsax.add),
        label: const Text('طلب إرجاع'),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Iconsax.rotate_left,
            size: 80.sp,
            color: AppColors.textTertiaryLight,
          ),
          SizedBox(height: 24.h),
          Text(
            'لا توجد طلبات إرجاع',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReturnCard(ThemeData theme, bool isDark, _Return returnItem) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                returnItem.orderNumber,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              _buildStatusBadge(returnItem.status),
            ],
          ),
          SizedBox(height: 12.h),
          Text(returnItem.productName, style: theme.textTheme.bodyMedium),
          SizedBox(height: 4.h),
          Text(
            'السبب: ${returnItem.reason}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textTertiaryLight,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            _formatDate(returnItem.createdAt),
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textTertiaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(ReturnStatus status) {
    Color color;
    String text;
    switch (status) {
      case ReturnStatus.pending:
        color = Colors.orange;
        text = 'قيد المراجعة';
        break;
      case ReturnStatus.approved:
        color = AppColors.success;
        text = 'تمت الموافقة';
        break;
      case ReturnStatus.rejected:
        color = AppColors.error;
        text = 'مرفوض';
        break;
      case ReturnStatus.completed:
        color = Colors.blue;
        text = 'مكتمل';
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _Return {
  final int id;
  final String orderNumber;
  final String productName;
  final String reason;
  final ReturnStatus status;
  final DateTime createdAt;

  _Return({
    required this.id,
    required this.orderNumber,
    required this.productName,
    required this.reason,
    required this.status,
    required this.createdAt,
  });
}
