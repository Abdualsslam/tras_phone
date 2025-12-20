/// Order Details Screen - Full order information
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/config/theme/app_colors.dart';

class OrderDetailsScreen extends StatelessWidget {
  final int orderId;

  const OrderDetailsScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('تفاصيل الطلب'),
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_right_3),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.document_download),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Header
            _buildOrderHeader(theme, isDark),
            SizedBox(height: 16.h),

            // Status Timeline
            _buildStatusTimeline(theme, isDark),
            SizedBox(height: 16.h),

            // Products
            _buildProductsSection(theme, isDark),
            SizedBox(height: 16.h),

            // Shipping Address
            _buildShippingAddress(theme, isDark),
            SizedBox(height: 16.h),

            // Payment Summary
            _buildPaymentSummary(theme, isDark),
            SizedBox(height: 24.h),

            // Actions
            _buildActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderHeader(ThemeData theme, bool isDark) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ORD-2024-001',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '15 ديسمبر 2024، 10:30 ص',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textTertiaryLight,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: Colors.teal.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Row(
              children: [
                Icon(Iconsax.truck, size: 14.sp, color: Colors.teal),
                SizedBox(width: 4.w),
                Text(
                  'تم الشحن',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.teal,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTimeline(ThemeData theme, bool isDark) {
    final steps = [
      _TimelineStep(
        'تم الطلب',
        true,
        DateTime.now().subtract(const Duration(days: 2)),
      ),
      _TimelineStep(
        'تم التأكيد',
        true,
        DateTime.now().subtract(const Duration(days: 2)),
      ),
      _TimelineStep(
        'قيد التجهيز',
        true,
        DateTime.now().subtract(const Duration(days: 1)),
      ),
      _TimelineStep('تم الشحن', true, DateTime.now()),
      _TimelineStep('تم التوصيل', false, null),
    ];

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'حالة الطلب',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 16.h),
          ...steps.asMap().entries.map((entry) {
            final isLast = entry.key == steps.length - 1;
            return _buildTimelineItem(theme, entry.value, isLast);
          }),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(ThemeData theme, _TimelineStep step, bool isLast) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 24.w,
              height: 24.w,
              decoration: BoxDecoration(
                color: step.isCompleted
                    ? AppColors.success
                    : AppColors.dividerLight,
                shape: BoxShape.circle,
              ),
              child: step.isCompleted
                  ? Icon(Iconsax.tick_circle5, size: 16.sp, color: Colors.white)
                  : null,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 30.h,
                color: step.isCompleted
                    ? AppColors.success
                    : AppColors.dividerLight,
              ),
          ],
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: step.isCompleted
                        ? FontWeight.w600
                        : FontWeight.w400,
                    color: step.isCompleted
                        ? null
                        : AppColors.textTertiaryLight,
                  ),
                ),
                if (step.date != null)
                  Text(
                    '${step.date!.day}/${step.date!.month} - ${step.date!.hour}:${step.date!.minute.toString().padLeft(2, '0')}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textTertiaryLight,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductsSection(ThemeData theme, bool isDark) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'المنتجات (3)',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 12.h),
          _buildProductItem(theme, isDark, 'شاشة آيفون 14 برو ماكس', 2, 450),
          Divider(height: 24.h),
          _buildProductItem(theme, isDark, 'بطارية آيفون 13', 5, 85),
        ],
      ),
    );
  }

  Widget _buildProductItem(
    ThemeData theme,
    bool isDark,
    String name,
    int qty,
    double price,
  ) {
    return Row(
      children: [
        Container(
          width: 50.w,
          height: 50.w,
          decoration: BoxDecoration(
            color: AppColors.backgroundLight,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(Iconsax.image, color: AppColors.textTertiaryLight),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '$qty × $price ر.س',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textTertiaryLight,
                ),
              ),
            ],
          ),
        ),
        Text(
          '${(qty * price).toStringAsFixed(0)} ر.س',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildShippingAddress(ThemeData theme, bool isDark) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'عنوان التوصيل',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'الرياض - حي الملز - شارع الأمير سلطان',
            style: theme.textTheme.bodyMedium,
          ),
          Text(
            '0555123456',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textTertiaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSummary(ThemeData theme, bool isDark) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          _buildSummaryRow(theme, 'المجموع الفرعي', '1,325 ر.س'),
          SizedBox(height: 8.h),
          _buildSummaryRow(theme, 'الشحن', '50 ر.س'),
          SizedBox(height: 8.h),
          _buildSummaryRow(
            theme,
            'الخصم (TRAS10)',
            '-132.5 ر.س',
            valueColor: AppColors.success,
          ),
          Divider(height: 24.h),
          _buildSummaryRow(theme, 'الإجمالي', '1,242.5 ر.س', isTotal: true),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    ThemeData theme,
    String label,
    String value, {
    Color? valueColor,
    bool isTotal = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isTotal
              ? theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                )
              : theme.textTheme.bodyMedium,
        ),
        Text(
          value,
          style: isTotal
              ? TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                )
              : theme.textTheme.bodyMedium?.copyWith(color: valueColor),
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => HapticFeedback.selectionClick(),
            icon: const Icon(Iconsax.refresh),
            label: const Text('إعادة الطلب'),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => HapticFeedback.mediumImpact(),
            icon: const Icon(Iconsax.message),
            label: const Text('تواصل معنا'),
          ),
        ),
      ],
    );
  }
}

class _TimelineStep {
  final String title;
  final bool isCompleted;
  final DateTime? date;

  _TimelineStep(this.title, this.isCompleted, this.date);
}
