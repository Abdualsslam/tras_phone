import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/config/theme/app_colors.dart';
import '../../domain/entities/cart_sync_result_entity.dart';

class CartSyncIssuesDialog extends StatelessWidget {
  final CartSyncResultEntity result;
  final String Function(String reason) getRemovalReason;
  final VoidCallback onCancel;
  final VoidCallback onContinue;

  const CartSyncIssuesDialog({
    super.key,
    required this.result,
    required this.getRemovalReason,
    required this.onCancel,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text('تحديثات السلة'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (result.removedItems.isNotEmpty) ...[
              Text(
                'تم حذف المنتجات التالية:',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8.h),
              ...result.removedItems.map(
                (item) => ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    item.productNameAr ?? item.productId,
                    style: theme.textTheme.bodyMedium,
                  ),
                  subtitle: Text(
                    getRemovalReason(item.reason),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
            ],
            if (result.priceChangedItems.isNotEmpty) ...[
              Text(
                'تغيرت أسعار المنتجات التالية:',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8.h),
              ...result.priceChangedItems.map(
                (item) => ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    item.productNameAr ?? item.productId,
                    style: theme.textTheme.bodyMedium,
                  ),
                  subtitle: Text(
                    '${item.oldPrice.toStringAsFixed(0)} → ${item.newPrice.toStringAsFixed(0)} ر.س',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
            ],
            if (result.quantityAdjustedItems.isNotEmpty) ...[
              Text(
                'تم تعديل كميات المنتجات التالية:',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8.h),
              ...result.quantityAdjustedItems.map(
                (item) => ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    item.productNameAr ?? item.productId,
                    style: theme.textTheme.bodyMedium,
                  ),
                  subtitle: Text(
                    'الكمية المطلوبة: ${item.requestedQuantity}\n'
                    'الكمية المتاحة: ${item.availableQuantity}\n'
                    'الكمية النهائية: ${item.finalQuantity}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: onCancel, child: const Text('إلغاء')),
        ElevatedButton(
          onPressed: onContinue,
          child: const Text('موافق والمتابعة'),
        ),
      ],
    );
  }
}
