import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/config/theme/app_colors.dart';
import '../../domain/entities/order_entity.dart';

class InvoiceTotalsSection extends StatelessWidget {
  final OrderEntity order;
  final bool isDark;

  const InvoiceTotalsSection({
    super.key,
    required this.order,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InvoiceTotalRow(
          label: 'المجموع الفرعي',
          value: '${order.subtotal.toStringAsFixed(2)} ر.س',
          isDark: isDark,
        ),
        if (order.taxAmount > 0)
          InvoiceTotalRow(
            label: 'الضريبة',
            value: '${order.taxAmount.toStringAsFixed(2)} ر.س',
            isDark: isDark,
          ),
        if (order.shippingCost > 0)
          InvoiceTotalRow(
            label: 'الشحن',
            value: '${order.shippingCost.toStringAsFixed(2)} ر.س',
            isDark: isDark,
          ),
        if (order.discount > 0 || order.couponDiscount > 0)
          InvoiceTotalRow(
            label: 'الخصم',
            value:
                '-${(order.discount + order.couponDiscount).toStringAsFixed(2)} ر.س',
            isDark: isDark,
            valueColor: AppColors.success,
          ),
        Divider(height: 16.h),
        InvoiceTotalRow(
          label: 'الإجمالي',
          value: '${order.total.toStringAsFixed(2)} ر.س',
          isDark: isDark,
          isBold: true,
        ),
      ],
    );
  }
}

class InvoiceTotalRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;
  final bool isBold;
  final Color? valueColor;

  const InvoiceTotalRow({
    super.key,
    required this.label,
    required this.value,
    required this.isDark,
    this.isBold = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isBold ? 14.sp : 13.sp,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isBold ? 16.sp : 13.sp,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
              color: valueColor ?? (isBold ? AppColors.primary : null),
            ),
          ),
        ],
      ),
    );
  }
}

class InvoicePaymentInfoCard extends StatelessWidget {
  final OrderEntity order;

  const InvoicePaymentInfoCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final isPaid = order.paymentStatus == PaymentStatus.paid;
    final tone = isPaid ? AppColors.success : AppColors.warning;

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          Icon(
            isPaid ? Iconsax.tick_circle : Iconsax.clock,
            size: 20.sp,
            color: tone,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.paymentStatus.displayNameAr,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: tone,
                  ),
                ),
                Text(
                  'طريقة الدفع: ${order.paymentMethod?.displayNameAr ?? '-'}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
