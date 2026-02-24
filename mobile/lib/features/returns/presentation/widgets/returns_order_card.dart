import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../../../orders/domain/entities/order_entity.dart';

/// بطاقة الطلب مع المنتجات
class ReturnsOrderCard extends StatelessWidget {
  final OrderEntity order;
  final Map<String, int> selectedItems;
  final Function(String, int) onItemQuantityChanged;

  const ReturnsOrderCard({
    super.key,
    required this.order,
    required this.selectedItems,
    required this.onItemQuantityChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final returnableItems = order.items
        .where((i) => i.returnableQuantity > 0)
        .toList();
    final fullyReturnedItems = order.items
        .where((i) => i.isFullyReturned)
        .toList();

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: ExpansionTile(
        title: Text(
          'طلب ${order.orderNumber}',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          returnableItems.isNotEmpty
              ? '${returnableItems.length} منتج قابل للإرجاع${fullyReturnedItems.isNotEmpty ? ' • ${fullyReturnedItems.length} مرتجع بالكامل' : ''}'
              : fullyReturnedItems.isNotEmpty
              ? '${fullyReturnedItems.length} منتج مرتجع بالكامل'
              : 'لا يوجد منتجات للإرجاع',
        ),
        children: [
          ...returnableItems.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final orderItemId = (item.id != null && item.id!.isNotEmpty)
                ? item.id!
                : '${order.id}_${item.productId}_${item.variantId ?? ''}_$index';
            final returnableQty = item.returnableQuantity;
            final selectedQty = selectedItems[orderItemId] ?? 0;

            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: Row(
                children: [
                  if (item.image != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.r),
                      child: CachedNetworkImage(
                        imageUrl: item.image!,
                        width: 50.w,
                        height: 50.w,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          width: 50.w,
                          height: 50.w,
                          color: Colors.grey[300],
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          width: 50.w,
                          height: 50.w,
                          color: Colors.grey[300],
                          child: Icon(Icons.image, color: Colors.grey[600]),
                        ),
                      ),
                    )
                  else
                    Container(
                      width: 50.w,
                      height: 50.w,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Icon(Icons.image, color: Colors.grey[600]),
                    ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.getName('ar'),
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'السعر: ${item.unitPrice.toStringAsFixed(2)} ر.س',
                          style: theme.textTheme.bodySmall,
                        ),
                        Text(
                          item.isPartiallyReturned
                              ? 'تم استرجاع ${item.returnedQuantity}، المتبقي للإرجاع: $returnableQty من ${item.quantity}'
                              : 'القابلة للإرجاع: $returnableQty من ${item.quantity}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: item.isPartiallyReturned
                                ? AppColors.warning
                                : AppColors.textTertiaryLight,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Row(
                          children: [
                            IconButton.filled(
                              onPressed: selectedQty <= 0
                                  ? null
                                  : () => onItemQuantityChanged(
                                      orderItemId,
                                      selectedQty <= 0 ? 0 : selectedQty - 1,
                                    ),
                              icon: Icon(Icons.remove, size: 18.sp),
                              style: IconButton.styleFrom(
                                padding: EdgeInsets.all(8.w),
                                minimumSize: Size(36.w, 36.h),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12.w),
                              child: Text(
                                selectedQty > 0 ? '$selectedQty' : '0',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton.filled(
                              onPressed: selectedQty >= returnableQty
                                  ? null
                                  : () => onItemQuantityChanged(
                                      orderItemId,
                                      selectedQty + 1,
                                    ),
                              icon: Icon(Icons.add, size: 18.sp),
                              style: IconButton.styleFrom(
                                padding: EdgeInsets.all(8.w),
                                minimumSize: Size(36.w, 36.h),
                              ),
                            ),
                            if (selectedQty <= 0) ...[
                              SizedBox(width: 8.w),
                              TextButton(
                                onPressed: () =>
                                    onItemQuantityChanged(orderItemId, 1),
                                child: const Text('إرجاع'),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
          ...fullyReturnedItems.map((item) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: Opacity(
                opacity: 0.7,
                child: Row(
                  children: [
                    if (item.image != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.r),
                        child: CachedNetworkImage(
                          imageUrl: item.image!,
                          width: 50.w,
                          height: 50.w,
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                              Container(color: Colors.grey[300]),
                          errorWidget: (context, url, e) =>
                              Icon(Iconsax.image, color: Colors.grey[600]),
                        ),
                      )
                    else
                      Container(
                        width: 50.w,
                        height: 50.w,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Icon(Icons.image, color: Colors.grey[600]),
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
                                  item.getName('ar'),
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    decoration: TextDecoration.lineThrough,
                                    decorationColor:
                                        AppColors.textTertiaryLight,
                                    color: AppColors.textTertiaryLight,
                                  ),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8.w,
                                  vertical: 4.h,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.textTertiaryLight.withValues(
                                    alpha: 0.2,
                                  ),
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Text(
                                  'مرتجع بالكامل',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontSize: 11.sp,
                                    color: AppColors.textTertiaryLight,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'تم استرجاع ${item.quantity} من ${item.quantity}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.textTertiaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
