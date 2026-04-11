import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/config/theme/app_colors.dart';
import '../../domain/entities/order_entity.dart';
import 'invoice_sections_items.dart';
import 'invoice_sections_meta.dart';
import 'invoice_sections_totals.dart';

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
