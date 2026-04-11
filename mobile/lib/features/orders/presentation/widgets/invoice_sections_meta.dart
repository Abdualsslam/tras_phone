import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../core/config/theme/app_colors.dart';
import '../../domain/entities/order_entity.dart';

class InvoiceHeaderSection extends StatelessWidget {
  const InvoiceHeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'تفاصيل الطلب',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            Text(
              'TAX INVOICE',
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Text(
            'تراس فون',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}

class InvoiceMetaSection extends StatelessWidget {
  final OrderEntity order;
  final bool isDark;

  const InvoiceMetaSection({
    super.key,
    required this.order,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMMM yyyy', 'ar');

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        InvoiceInfoColumn(
          label: 'رقم الفاتورة',
          value: order.orderNumber,
          isDark: isDark,
        ),
        InvoiceInfoColumn(
          label: 'التاريخ',
          value: dateFormat.format(order.createdAt),
          isDark: isDark,
        ),
        InvoiceInfoColumn(
          label: 'الحالة',
          value: order.paymentStatus.displayNameAr,
          isDark: isDark,
          valueColor: order.paymentStatus == PaymentStatus.paid
              ? AppColors.success
              : null,
        ),
      ],
    );
  }
}

class InvoiceInfoColumn extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;
  final Color? valueColor;

  const InvoiceInfoColumn({
    super.key,
    required this.label,
    required this.value,
    required this.isDark,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
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
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color:
                valueColor ??
                (isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight),
          ),
        ),
      ],
    );
  }
}

class InvoiceCustomerSection extends StatelessWidget {
  final OrderEntity order;
  final bool isDark;

  const InvoiceCustomerSection({
    super.key,
    required this.order,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final address = order.shippingAddress;
    if (address == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'بيانات العميل',
            style: TextStyle(
              fontSize: 12.sp,
              color: AppColors.textSecondaryLight,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            address.fullName,
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
          ),
          Text(
            address.formattedAddress,
            style: TextStyle(
              fontSize: 12.sp,
              color: AppColors.textSecondaryLight,
            ),
          ),
          Text(
            address.phone,
            style: TextStyle(
              fontSize: 12.sp,
              color: AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }
}

class InvoiceFooterSection extends StatelessWidget {
  const InvoiceFooterSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Text(
            'شكراً لتعاملكم معنا',
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 4.h),
          Text(
            'www.trasphone.com',
            style: TextStyle(fontSize: 12.sp, color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}
