import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../../../core/config/theme/app_colors.dart';
import '../../domain/entities/order_entity.dart';

class InvoiceDocumentView extends StatelessWidget {
  final OrderEntity order;
  final bool isDark;

  const InvoiceDocumentView({
    super.key,
    required this.order,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const InvoiceHeaderSection(),
            Divider(height: 32.h),
            InvoiceMetaSection(order: order, isDark: isDark),
            SizedBox(height: 24.h),
            if (order.shippingAddress != null) ...[
              InvoiceCustomerSection(order: order, isDark: isDark),
              SizedBox(height: 24.h),
            ],
            InvoiceItemsSection(order: order, isDark: isDark),
            Divider(height: 24.h),
            InvoiceTotalsSection(order: order, isDark: isDark),
            SizedBox(height: 24.h),
            InvoicePaymentInfoCard(order: order),
            SizedBox(height: 24.h),
            const InvoiceFooterSection(),
          ],
        ),
      ),
    );
  }
}

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

class InvoiceItemsSection extends StatelessWidget {
  final OrderEntity order;
  final bool isDark;

  const InvoiceItemsSection({
    super.key,
    required this.order,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 8.w),
          color: AppColors.primary.withValues(alpha: 0.1),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  'المنتج',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  'الكمية',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                child: Text(
                  'السعر',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                child: Text(
                  'المجموع',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
        ),
        ...order.items.map(
          (item) => InvoiceItemRow(
            name: item.nameAr ?? item.name,
            quantity: item.quantity,
            price: item.unitPrice,
            total: item.total,
            returnedQuantity: item.returnedQuantity,
            effectiveQuantity: item.effectiveQuantity,
            isPartiallyReturned: item.isPartiallyReturned,
            isFullyReturned: item.isFullyReturned,
          ),
        ),
      ],
    );
  }
}

class InvoiceItemRow extends StatelessWidget {
  final String name;
  final int quantity;
  final double price;
  final double total;
  final int returnedQuantity;
  final int? effectiveQuantity;
  final bool isPartiallyReturned;
  final bool isFullyReturned;

  const InvoiceItemRow({
    super.key,
    required this.name,
    required this.quantity,
    required this.price,
    required this.total,
    this.returnedQuantity = 0,
    this.effectiveQuantity,
    this.isPartiallyReturned = false,
    this.isFullyReturned = false,
  });

  @override
  Widget build(BuildContext context) {
    final effective = effectiveQuantity ?? (quantity - returnedQuantity);
    final displayQuantity = returnedQuantity > 0 ? effective : quantity;
    final displayTotal = returnedQuantity > 0 ? (effective * price) : total;

    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.dividerLight.withValues(alpha: 0.5),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(name, style: TextStyle(fontSize: 12.sp)),
                    ),
                    if (returnedQuantity > 0) ...[
                      SizedBox(width: 6.w),
                      Chip(
                        label: Text(
                          isFullyReturned ? 'مرتجع' : 'مرتجع جزئياً',
                          style: TextStyle(fontSize: 10.sp),
                        ),
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.w,
                          vertical: 2.h,
                        ),
                        backgroundColor: AppColors.warning.withValues(
                          alpha: 0.15,
                        ),
                      ),
                    ],
                  ],
                ),
                if ((isPartiallyReturned || isFullyReturned) &&
                    quantity > effective)
                  Padding(
                    padding: EdgeInsets.only(top: 4.h),
                    child: Text(
                      'الأصلية: $quantity، المرتجع: $returnedQuantity، المتبقي: $effective',
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Text(
              '$displayQuantity',
              style: TextStyle(fontSize: 12.sp),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              price.toStringAsFixed(0),
              style: TextStyle(fontSize: 12.sp),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              displayTotal.toStringAsFixed(0),
              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

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
