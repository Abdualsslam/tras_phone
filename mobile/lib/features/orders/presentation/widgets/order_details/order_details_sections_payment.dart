import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../core/config/theme/app_colors.dart';
import '../../../domain/entities/order_entity.dart';
import 'section_card.dart';
import 'section_title.dart';

class OrderPaymentSummarySection extends StatelessWidget {
  final bool isDark;
  final OrderEntity order;
  final String Function(String?) transferStatusLabel;
  final Color Function(String?) transferStatusColor;

  const OrderPaymentSummarySection({
    super.key,
    required this.isDark,
    required this.order,
    required this.transferStatusLabel,
    required this.transferStatusColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SectionCard(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(title: 'ملخص الدفع', icon: Iconsax.receipt_item),
          SizedBox(height: 12.h),
          _OrderSummaryRow(
            label: 'المجموع الفرعي',
            value: '${order.subtotal.toStringAsFixed(2)} ر.س',
          ),
          SizedBox(height: 8.h),
          if (order.shippingCost > 0) ...[
            _OrderSummaryRow(
              label: 'الشحن',
              value: '${order.shippingCost.toStringAsFixed(2)} ر.س',
            ),
            SizedBox(height: 8.h),
          ],
          if (order.taxAmount > 0) ...[
            _OrderSummaryRow(
              label: 'الضريبة',
              value: '${order.taxAmount.toStringAsFixed(2)} ر.س',
            ),
            SizedBox(height: 8.h),
          ],
          if (order.discount > 0 || order.couponDiscount > 0) ...[
            _OrderSummaryRow(
              label: order.couponCode != null
                  ? 'الخصم (${order.couponCode})'
                  : 'الخصم',
              value:
                  '-${(order.discount + order.couponDiscount).toStringAsFixed(2)} ر.س',
              valueColor: AppColors.success,
              valueIcon: Iconsax.discount_shape,
            ),
            SizedBox(height: 8.h),
          ],
          if (order.walletAmountUsed > 0) ...[
            _OrderSummaryRow(
              label: 'رصيد المحفظة قبل الخصم',
              value: '${order.walletBalanceBefore.toStringAsFixed(2)} ر.س',
            ),
            SizedBox(height: 8.h),
            _OrderSummaryRow(
              label: 'المحفظة',
              value: '-${order.walletAmountUsed.toStringAsFixed(2)} ر.س',
              valueColor: AppColors.success,
            ),
            SizedBox(height: 8.h),
            _OrderSummaryRow(
              label: 'رصيد المحفظة بعد الخصم',
              value: '${order.walletBalanceAfter.toStringAsFixed(2)} ر.س',
              valueColor: AppColors.textSecondaryLight,
            ),
            SizedBox(height: 8.h),
          ],
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8.h),
            child: Divider(
              height: 1,
              color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'الإجمالي',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '${order.total.toStringAsFixed(2)} ر.س',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          if (order.paidAmount > 0) ...[
            SizedBox(height: 10.h),
            _OrderSummaryRow(
              label: 'المدفوع',
              value: '${order.paidAmount.toStringAsFixed(2)} ر.س',
              valueColor: AppColors.success,
            ),
          ],
          if (order.remainingAmount > 0) ...[
            SizedBox(height: 8.h),
            _OrderSummaryRow(
              label: 'المتبقي',
              value: '${order.remainingAmount.toStringAsFixed(2)} ر.س',
              valueColor: AppColors.error,
            ),
          ],
          if (order.paymentMethod != null) ...[
            SizedBox(height: 12.h),
            Divider(
              height: 1,
              color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Icon(
                  order.paymentMethod!.icon,
                  size: 18.sp,
                  color: AppColors.textSecondaryLight,
                ),
                SizedBox(width: 8.w),
                Text('طريقة الدفع', style: theme.textTheme.bodySmall),
                const Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.surfaceDark
                        : AppColors.backgroundLight,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    order.paymentMethod!.displayNameAr,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                Icon(
                  Iconsax.money_recive,
                  size: 18.sp,
                  color: AppColors.textSecondaryLight,
                ),
                SizedBox(width: 8.w),
                Text('حالة الدفع', style: theme.textTheme.bodySmall),
                const Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: order.paymentStatus.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    order.paymentStatus.displayNameAr,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: order.paymentStatus.color,
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (order.paymentMethod == OrderPaymentMethod.bankTransfer) ...[
            SizedBox(height: 8.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('حالة التحويل', style: theme.textTheme.bodySmall),
                Text(
                  transferStatusLabel(order.transferStatus),
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: transferStatusColor(order.transferStatus),
                  ),
                ),
              ],
            ),
            if (order.paymentRejectionReason != null &&
                order.paymentRejectionReason!.isNotEmpty) ...[
              SizedBox(height: 8.h),
              _OrderSummaryRow(
                label: 'سبب الرفض',
                value: order.paymentRejectionReason!,
                valueColor: AppColors.error,
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _OrderSummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final IconData? valueIcon;

  const _OrderSummaryRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.valueIcon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            if (valueIcon != null) ...[
              Icon(
                valueIcon,
                size: 14.sp,
                color: valueColor ?? AppColors.textSecondaryLight,
              ),
              SizedBox(width: 6.w),
            ],
            Text(label, style: theme.textTheme.bodyMedium),
          ],
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: valueColor,
            fontWeight: valueColor != null ? FontWeight.w600 : null,
          ),
        ),
      ],
    );
  }
}
