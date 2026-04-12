import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../../../../core/config/theme/app_colors.dart';
import '../../../domain/entities/order_entity.dart';
import 'section_card.dart';
import 'section_title.dart';
import 'timeline_step_data.dart';

class OrderStatusTimelineSection extends StatelessWidget {
  final bool isDark;
  final OrderEntity order;
  final List<TimelineStepData> steps;
  final int currentIndex;
  final VoidCallback? onOpenShippingLabel;

  const OrderStatusTimelineSection({
    super.key,
    required this.isDark,
    required this.order,
    required this.steps,
    required this.currentIndex,
    required this.onOpenShippingLabel,
  });

  @override
  Widget build(BuildContext context) {
    if (order.isCancelled || order.status == OrderStatus.refunded) {
      return _CancelledBanner(order: order, isDark: isDark);
    }

    return SectionCard(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(title: 'تتبع الطلب', icon: Iconsax.location),
          SizedBox(height: 20.h),
          ...steps.asMap().entries.map((entry) {
            final idx = entry.key;
            final step = entry.value;

            return _TimelineRow(
              step: step,
              isDark: isDark,
              isCompleted: idx < currentIndex,
              isCurrent: idx == currentIndex,
              isPending: idx > currentIndex,
              isLast: idx == steps.length - 1,
              onOpenShippingLabel: onOpenShippingLabel,
            );
          }),
        ],
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  final TimelineStepData step;
  final bool isDark;
  final bool isCompleted;
  final bool isCurrent;
  final bool isPending;
  final bool isLast;
  final VoidCallback? onOpenShippingLabel;

  const _TimelineRow({
    required this.step,
    required this.isDark,
    required this.isCompleted,
    required this.isCurrent,
    required this.isPending,
    required this.isLast,
    required this.onOpenShippingLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dotColor = isCompleted
        ? AppColors.success
        : isCurrent
        ? AppColors.primary
        : (isDark ? AppColors.dividerDark : AppColors.dividerLight);
    final lineColor = isCompleted
        ? AppColors.success
        : (isDark ? AppColors.dividerDark : AppColors.dividerLight);
    final iconColor = isCompleted || isCurrent
        ? Colors.white
        : (isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 44.w,
            child: Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: isCurrent ? 40.w : 32.w,
                  height: isCurrent ? 40.w : 32.w,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                    boxShadow: isCurrent
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.35),
                              blurRadius: 12,
                              spreadRadius: 3,
                            ),
                          ]
                        : isCompleted
                        ? [
                            BoxShadow(
                              color: AppColors.success.withValues(alpha: 0.25),
                              blurRadius: 6,
                              spreadRadius: 1,
                            ),
                          ]
                        : null,
                    border: isPending
                        ? Border.all(
                            color: isDark
                                ? AppColors.dividerDark
                                : AppColors.dividerLight,
                            width: 2,
                          )
                        : null,
                  ),
                  child: Icon(
                    isCompleted ? Iconsax.tick_circle5 : step.icon,
                    size: isCurrent ? 20.sp : 16.sp,
                    color: iconColor,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2.5,
                      margin: EdgeInsets.symmetric(vertical: 4.h),
                      decoration: BoxDecoration(
                        gradient: isCompleted
                            ? LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  AppColors.success,
                                  AppColors.success.withValues(alpha: 0.4),
                                ],
                              )
                            : null,
                        color: isCompleted ? null : lineColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: isLast ? 0 : 20.h,
                top: isCurrent ? 8.h : 4.h,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          step.label,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: isCurrent || isCompleted
                                ? FontWeight.w700
                                : FontWeight.w400,
                            color: isPending
                                ? (isDark
                                      ? AppColors.textTertiaryDark
                                      : AppColors.textTertiaryLight)
                                : null,
                          ),
                        ),
                      ),
                      if (isCurrent)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 3.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20.r),
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            'الحالة الحالية',
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (step.subtitle != null) ...[
                    SizedBox(height: 3.h),
                    Text(
                      step.subtitle!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isCompleted
                            ? AppColors.success.withValues(alpha: 0.8)
                            : AppColors.textTertiaryLight,
                        fontSize: 11.sp,
                      ),
                    ),
                  ] else if (isPending) ...[
                    SizedBox(height: 3.h),
                    Text(
                      'في الانتظار',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: isDark
                            ? AppColors.textTertiaryDark
                            : AppColors.textTertiaryLight,
                      ),
                    ),
                  ],
                  if (step.actionLabel != null &&
                      step.actionUrl != null &&
                      isCompleted) ...[
                    SizedBox(height: 6.h),
                    GestureDetector(
                      onTap: onOpenShippingLabel,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6.r),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Iconsax.document,
                              size: 12.sp,
                              color: AppColors.primary,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              step.actionLabel!,
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CancelledBanner extends StatelessWidget {
  final OrderEntity order;
  final bool isDark;

  const _CancelledBanner({required this.order, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCancelled = order.isCancelled;
    final color = isCancelled ? AppColors.error : Colors.grey;
    final label = isCancelled ? 'تم إلغاء الطلب' : 'تم استرجاع الطلب';

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isCancelled ? Iconsax.close_circle : Iconsax.money_recive,
                  color: color,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                    if (order.cancelledAt != null)
                      Text(
                        DateFormat(
                          'dd/MM/yyyy - hh:mm a',
                          'ar',
                        ).format(order.cancelledAt!),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textTertiaryLight,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          if (order.cancellationReason != null) ...[
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Iconsax.info_circle, size: 14.sp, color: color),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      order.cancellationReason!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondaryLight,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
