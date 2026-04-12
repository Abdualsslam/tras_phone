import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../core/config/theme/app_colors.dart';
import 'quick_action.dart';

class OrderQuickActionsRow extends StatelessWidget {
  final bool isDark;
  final List<OrderQuickAction> actions;

  const OrderQuickActionsRow({
    super.key,
    required this.isDark,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    if (actions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Row(
      children: actions.asMap().entries.map((entry) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              left: entry.key < actions.length - 1 ? 8.w : 0,
            ),
            child: _QuickActionCard(isDark: isDark, action: entry.value),
          ),
        );
      }).toList(),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final bool isDark;
  final OrderQuickAction action;

  const _QuickActionCard({required this.isDark, required this.action});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isDark ? AppColors.cardDark : AppColors.cardLight,
      borderRadius: BorderRadius.circular(14.r),
      child: InkWell(
        onTap: action.onTap,
        borderRadius: BorderRadius.circular(14.r),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 12.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: action.color.withValues(alpha: 0.15)),
          ),
          child: Column(
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: action.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(action.icon, size: 20.sp, color: action.color),
              ),
              SizedBox(height: 8.h),
              Text(
                action.label,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OrderBottomActionsRow extends StatelessWidget {
  final bool canCancel;
  final VoidCallback onCancel;
  final VoidCallback onContactSupport;

  const OrderBottomActionsRow({
    super.key,
    required this.canCancel,
    required this.onCancel,
    required this.onContactSupport,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (canCancel) ...[
          Expanded(
            child: SizedBox(
              height: 48.h,
              child: OutlinedButton.icon(
                onPressed: onCancel,
                icon: Icon(
                  Iconsax.close_circle,
                  color: AppColors.error,
                  size: 18.sp,
                ),
                label: Text(
                  'إلغاء الطلب',
                  style: TextStyle(color: AppColors.error, fontSize: 14.sp),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: AppColors.error.withValues(alpha: 0.4),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
        ],
        Expanded(
          child: SizedBox(
            height: 48.h,
            child: ElevatedButton.icon(
              onPressed: onContactSupport,
              icon: Icon(Iconsax.message, size: 18.sp),
              label: Text('تواصل معنا', style: TextStyle(fontSize: 14.sp)),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
