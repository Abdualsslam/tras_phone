import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../core/config/theme/app_colors.dart';
import '../../../domain/entities/order_entity.dart';
import 'section_card.dart';
import 'section_title.dart';

class OrderProductsSection extends StatelessWidget {
  final bool isDark;
  final OrderEntity order;

  const OrderProductsSection({
    super.key,
    required this.isDark,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SectionCard(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle(
            title: 'المنتجات',
            icon: Iconsax.shopping_bag,
            trailing: Text(
              '${order.items.length} منتج',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textTertiaryLight,
              ),
            ),
          ),
          SizedBox(height: 12.h),
          ...order.items.asMap().entries.map((entry) {
            final isLast = entry.key == order.items.length - 1;
            return Column(
              children: [
                _OrderProductItem(isDark: isDark, item: entry.value),
                if (!isLast)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    child: Divider(
                      height: 1,
                      color: isDark
                          ? AppColors.dividerDark
                          : AppColors.dividerLight,
                    ),
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _OrderProductItem extends StatelessWidget {
  final bool isDark;
  final OrderItemEntity item;

  const _OrderProductItem({required this.isDark, required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasReturn = item.returnedQuantity > 0;
    final displayQty = hasReturn ? item.effectiveQuantity : item.quantity;
    final displayTotal = hasReturn
        ? (item.effectiveQuantity * item.unitPrice)
        : item.total;

    return Container(
      padding: hasReturn
          ? EdgeInsets.all(10.w)
          : EdgeInsets.symmetric(vertical: 4.h),
      decoration: hasReturn
          ? BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: AppColors.warning.withValues(alpha: 0.25),
              ),
            )
          : null,
      child: Row(
        children: [
          Container(
            width: 56.w,
            height: 56.w,
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.backgroundLight,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: item.image != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12.r),
                    child: Image.network(
                      item.image!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Icon(
                        Iconsax.image,
                        color: AppColors.textTertiaryLight,
                        size: 22.sp,
                      ),
                    ),
                  )
                : Icon(
                    Iconsax.image,
                    color: AppColors.textTertiaryLight,
                    size: 22.sp,
                  ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.nameAr ?? item.name,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (hasReturn)
                      Container(
                        margin: EdgeInsets.only(right: 6.w),
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          item.isFullyReturned ? 'مرتجع' : 'مرتجع جزئياً',
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.warning,
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 4.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      hasReturn
                          ? '$displayQty × ${item.unitPrice.toStringAsFixed(0)} ر.س'
                          : '${item.quantity} × ${item.unitPrice.toStringAsFixed(0)} ر.س',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textTertiaryLight,
                      ),
                    ),
                    Text(
                      '${displayTotal.toStringAsFixed(0)} ر.س',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
