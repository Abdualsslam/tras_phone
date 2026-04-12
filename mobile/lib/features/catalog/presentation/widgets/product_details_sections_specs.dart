import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/config/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/product_entity.dart';
import 'product_details_sections_header.dart';

class ProductSpecsCard extends StatelessWidget {
  final ProductEntity product;

  const ProductSpecsCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final hasCategory =
        product.categoryNameAr != null || product.categoryName != null;
    final hasQuality =
        product.qualityTypeNameAr != null || product.qualityTypeName != null;

    if (!hasCategory && !hasQuality) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.specifications,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 12.h),
          if (hasCategory)
            _ProductSpecRow(
              label: localizedProductLabel(
                context,
                ar: 'القسم:',
                en: 'Category:',
              ),
              value: product.categoryNameAr ?? product.categoryName ?? '',
            ),
          if (hasCategory && hasQuality)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 4.h),
              child: Divider(
                color: isDark ? AppColors.glassBorder : Colors.grey[200],
              ),
            ),
          if (hasQuality)
            _ProductSpecRow(
              label: localizedProductLabel(
                context,
                ar: 'درجة الجودة:',
                en: 'Quality:',
              ),
              value: product.qualityTypeNameAr ?? product.qualityTypeName ?? '',
              highlight: true,
            ),
        ],
      ),
    );
  }
}

class _ProductSpecRow extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;

  const _ProductSpecRow({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondaryLight,
          ),
        ),
        Container(
          padding: highlight
              ? EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h)
              : null,
          decoration: highlight
              ? BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6.r),
                )
              : null,
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: highlight ? FontWeight.w600 : FontWeight.w500,
              color: highlight ? AppColors.primary : null,
            ),
          ),
        ),
      ],
    );
  }
}

class ProductCompatibleDevicesCard extends StatelessWidget {
  final ProductEntity product;
  final bool isLoading;

  const ProductCompatibleDevicesCard({
    super.key,
    required this.product,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final locale = Localizations.localeOf(context).languageCode;
    final devices = locale == 'ar'
        ? (product.compatibleDeviceNamesAr.isNotEmpty
              ? product.compatibleDeviceNamesAr
              : product.compatibleDeviceNames)
        : (product.compatibleDeviceNames.isNotEmpty
              ? product.compatibleDeviceNames
              : product.compatibleDeviceNamesAr);

    if (devices.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                localizedProductLabel(
                  context,
                  ar: 'الأجهزة المتوافقة',
                  en: 'Compatible devices',
                ),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (isLoading) ...[
                SizedBox(width: 8.w),
                SizedBox(
                  width: 14.w,
                  height: 14.h,
                  child: const CircularProgressIndicator(strokeWidth: 2),
                ),
              ],
            ],
          ),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: devices
                .map(
                  (device) => Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(999.r),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Text(
                      device,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class ProductStockStatusCard extends StatelessWidget {
  final ProductEntity product;

  const ProductStockStatusCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isInStock = product.isInStock;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: (isInStock ? AppColors.success : AppColors.error).withValues(
          alpha: 0.1,
        ),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: (isInStock ? AppColors.success : AppColors.error).withValues(
            alpha: 0.3,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            isInStock ? Iconsax.tick_circle : Iconsax.close_circle,
            color: isInStock ? AppColors.success : AppColors.error,
            size: 24.sp,
          ),
          SizedBox(width: 12.w),
          Text(
            isInStock
                ? AppLocalizations.of(context)!.inStock
                : AppLocalizations.of(context)!.outOfStock,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: isInStock ? AppColors.success : AppColors.error,
            ),
          ),
        ],
      ),
    );
  }
}
