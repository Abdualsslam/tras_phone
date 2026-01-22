/// Return Item Card - Widget to display return item with inspection status
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../domain/entities/return_entity.dart';
import '../../domain/enums/return_enums.dart';
import '../../../../core/config/theme/app_colors.dart';

class ReturnItemCard extends StatelessWidget {
  final ReturnItemEntity item;

  const ReturnItemCard({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          // Product Image
          if (item.productImage != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: CachedNetworkImage(
                imageUrl: item.productImage!,
                width: 60.w,
                height: 60.w,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  width: 60.w,
                  height: 60.w,
                  color: Colors.grey[300],
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  width: 60.w,
                  height: 60.w,
                  color: Colors.grey[300],
                  child: Icon(Icons.image, color: Colors.grey[600]),
                ),
              ),
            )
          else
            Container(
              width: 60.w,
              height: 60.w,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(Icons.image, color: Colors.grey[600]),
            ),
          SizedBox(width: 12.w),

          // Product Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Text(
                  'SKU: ${item.productSku}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textTertiaryLight,
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Text(
                      'الكمية: ${item.quantity}',
                      style: theme.textTheme.bodySmall,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      '•',
                      style: theme.textTheme.bodySmall,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      '${item.unitPrice.toStringAsFixed(2)} ر.س',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                _buildInspectionStatus(item.inspectionStatus),
              ],
            ),
          ),

          // Total Value
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${item.totalValue.toStringAsFixed(2)} ر.س',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              if (item.approvedQuantity > 0 || item.rejectedQuantity > 0) ...[
                SizedBox(height: 4.h),
                Text(
                  'مقبول: ${item.approvedQuantity}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.green,
                  ),
                ),
                if (item.rejectedQuantity > 0)
                  Text(
                    'مرفوض: ${item.rejectedQuantity}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.red,
                    ),
                  ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInspectionStatus(InspectionStatus status) {
    Color color;
    String text;
    switch (status) {
      case InspectionStatus.pending:
        color = Colors.orange;
        text = 'في الانتظار';
        break;
      case InspectionStatus.inspected:
        color = Colors.blue;
        text = 'تم الفحص';
        break;
      case InspectionStatus.approved:
        color = Colors.green;
        text = 'مقبول';
        break;
      case InspectionStatus.rejected:
        color = Colors.red;
        text = 'مرفوض';
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
