import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/config/theme/app_colors.dart';
import '../../../domain/entities/order_stats_entity.dart';

class OrderStatsCard extends StatelessWidget {
  final OrderStatsEntity stats;
  final bool isDark;

  const OrderStatsCard({super.key, required this.stats, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'إحصائيات الطلبات',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: StatItem(
                  label: 'إجمالي الطلبات',
                  value: '${stats.total}',
                  theme: theme,
                ),
              ),
              Expanded(
                child: StatItem(
                  label: 'طلبات اليوم',
                  value: '${stats.todayOrders}',
                  theme: theme,
                ),
              ),
              Expanded(
                child: StatItem(
                  label: 'هذا الشهر',
                  value: '${stats.thisMonthOrders}',
                  theme: theme,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Divider(height: 24.h, color: AppColors.dividerLight),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'إيرادات اليوم',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondaryLight,
                ),
              ),
              Text(
                '${stats.todayRevenue.toStringAsFixed(0)} ر.س',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'إيرادات الشهر',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondaryLight,
                ),
              ),
              Text(
                '${stats.thisMonthRevenue.toStringAsFixed(0)} ر.س',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class StatItem extends StatelessWidget {
  final String label;
  final String value;
  final ThemeData theme;

  const StatItem({
    super.key,
    required this.label,
    required this.value,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondaryLight,
            fontSize: 11.sp,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
