part of 'checkout_sections.dart';

class CheckoutWalletInfoPanel extends StatelessWidget {
  final bool isDark;
  final double walletBalance;
  final double orderTotal;

  const CheckoutWalletInfoPanel({
    super.key,
    required this.isDark,
    required this.walletBalance,
    required this.orderTotal,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSufficient = walletBalance >= orderTotal;
    final usageRatio = walletBalance > 0 && orderTotal > 0
        ? (orderTotal / walletBalance).clamp(0.0, 1.0)
        : 0.0;
    final statusColor = isSufficient ? AppColors.success : Colors.orange;

    return Container(
      margin: EdgeInsets.only(top: 8.h),
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.surfaceDark.withValues(alpha: 0.5)
            : AppColors.primary.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: isDark
              ? AppColors.dividerDark
              : AppColors.primary.withValues(alpha: 0.1),
          width: 0.5,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Iconsax.wallet_money, size: 14.sp, color: statusColor),
                  SizedBox(width: 6.w),
                  Text(
                    'Ã˜Â§Ã™â€žÃ˜Â±Ã˜ÂµÃ™Å Ã˜Â¯ Ã˜Â§Ã™â€žÃ™â€¦Ã˜ÂªÃ˜Â§Ã˜Â­',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 12.sp,
                      color: isDark
                          ? Colors.white70
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
              Text(
                '${walletBalance.toStringAsFixed(2)} ${AppLocalizations.of(context)!.currency}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: statusColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(4.r),
            child: LinearProgressIndicator(
              value: usageRatio,
              minHeight: 5.h,
              backgroundColor: isDark ? Colors.white12 : AppColors.dividerLight,
              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Ã˜Â§Ã™â€žÃ™â€¦Ã˜Â·Ã™â€žÃ™Ë†Ã˜Â¨: ',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 11.sp,
                      color: isDark
                          ? Colors.white54
                          : AppColors.textTertiaryLight,
                    ),
                  ),
                  Text(
                    '${orderTotal.toStringAsFixed(2)} ${AppLocalizations.of(context)!.currency}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? Colors.white70
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Ã˜Â§Ã™â€žÃ™â€¦Ã˜ÂªÃ˜Â¨Ã™â€šÃ™Å : ',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 11.sp,
                      color: isDark
                          ? Colors.white54
                          : AppColors.textTertiaryLight,
                    ),
                  ),
                  Text(
                    '${(walletBalance - orderTotal).clamp(0, double.infinity).toStringAsFixed(2)} ${AppLocalizations.of(context)!.currency}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? Colors.white70
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (!isSufficient) ...[
            SizedBox(height: 8.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Row(
                children: [
                  Icon(Iconsax.warning_2, size: 14.sp, color: Colors.orange),
                  SizedBox(width: 6.w),
                  Expanded(
                    child: Text(
                      'Ã˜Â§Ã™â€žÃ˜Â±Ã˜ÂµÃ™Å Ã˜Â¯ Ã˜ÂºÃ™Å Ã˜Â± Ã™Æ’Ã˜Â§Ã™ÂÃ™Â. Ã™Å Ã™â€ Ã™â€šÃ˜ÂµÃ™Æ’ ${(orderTotal - walletBalance).toStringAsFixed(2)} ${AppLocalizations.of(context)!.currency}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 11.sp,
                        color: Colors.orange.shade800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
