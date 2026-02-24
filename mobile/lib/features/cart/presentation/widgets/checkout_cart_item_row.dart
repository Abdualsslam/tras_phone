import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/checkout_session_entity.dart';

class CheckoutCartItemRow extends StatelessWidget {
  final CheckoutCartItemEntity item;
  final String locale;

  const CheckoutCartItemRow({
    super.key,
    required this.item,
    required this.locale,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasIssue = item.hasStockIssue || item.isProductInactive;

    return Opacity(
      opacity: hasIssue ? 0.6 : 1.0,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product image
          ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: SizedBox(
              width: 56.w,
              height: 56.w,
              child:
                  item.product.image != null && item.product.image!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: item.product.image!,
                      fit: BoxFit.cover,
                      placeholder: (_, _) => Container(
                        color: AppColors.surfaceLight,
                        child: Icon(
                          Iconsax.box,
                          size: 24.sp,
                          color: AppColors.textTertiaryLight,
                        ),
                      ),
                      errorWidget: (_, _, _) => Container(
                        color: AppColors.surfaceLight,
                        child: Icon(
                          Iconsax.box,
                          size: 24.sp,
                          color: AppColors.textTertiaryLight,
                        ),
                      ),
                    )
                  : Container(
                      color: AppColors.surfaceLight,
                      child: Icon(
                        Iconsax.box,
                        size: 24.sp,
                        color: AppColors.textTertiaryLight,
                      ),
                    ),
            ),
          ),
          SizedBox(width: 12.w),

          // Product details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.getProductName(locale),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Text(
                      '${item.unitPrice.toStringAsFixed(0)} ${AppLocalizations.of(context)!.currency}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                    Text(
                      ' × ${item.quantity}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
                if (hasIssue) ...[
                  SizedBox(height: 4.h),
                  _buildIssueLabel(context),
                ],
              ],
            ),
          ),

          // Total price
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                item.totalPrice.toStringAsFixed(0),
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              Text(
                AppLocalizations.of(context)!.currency,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondaryLight,
                  fontSize: 10.sp,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIssueLabel(BuildContext context) {
    String text;
    Color color;

    if (item.isProductInactive) {
      text = 'المنتج غير متوفر';
      color = AppColors.error;
    } else if (item.hasStockIssue) {
      text = 'الكمية المتوفرة: ${item.product.stockQuantity}';
      color = AppColors.warning;
    } else {
      return const SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10.sp,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
