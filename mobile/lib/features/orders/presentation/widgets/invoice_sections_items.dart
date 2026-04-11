import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/config/theme/app_colors.dart';
import '../../domain/entities/order_entity.dart';

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
