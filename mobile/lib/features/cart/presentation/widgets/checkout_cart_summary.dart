import 'package:flutter/material.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';

/// Compact version for showing total without expand
class CheckoutCartSummary extends StatelessWidget {
  final int itemsCount;
  final double subtotal;
  final String locale;

  const CheckoutCartSummary({
    super.key,
    required this.itemsCount,
    required this.subtotal,
    this.locale = 'ar',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$itemsCount ${itemsCount == 1 ? 'منتج' : 'منتجات'}',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondaryLight,
          ),
        ),
        Text(
          '${subtotal.toStringAsFixed(0)} ${AppLocalizations.of(context)!.currency}',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
