part of 'checkout_sections.dart';

class CheckoutCreditInfoPanel extends StatelessWidget {
  final bool isDark;
  final double creditLimit;
  final double creditUsed;
  final double availableCredit;

  const CheckoutCreditInfoPanel({
    super.key,
    required this.isDark,
    required this.creditLimit,
    required this.creditUsed,
    required this.availableCredit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final usageRatio = creditLimit > 0 ? creditUsed / creditLimit : 0.0;

    final Color progressColor;
    if (usageRatio < 0.5) {
      progressColor = AppColors.success;
    } else if (usageRatio < 0.8) {
      progressColor = Colors.orange;
    } else {
      progressColor = AppColors.error;
    }

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
                  Icon(Iconsax.wallet_check, size: 14.sp, color: progressColor),
                  SizedBox(width: 6.w),
                  Text(
                    'Ã˜Â§Ã™â€žÃ™â€¦Ã˜ÂªÃ˜Â§Ã˜Â­',
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
                '${availableCredit.toStringAsFixed(0)} ${AppLocalizations.of(context)!.currency}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: progressColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(4.r),
            child: LinearProgressIndicator(
              value: usageRatio.clamp(0.0, 1.0),
              minHeight: 5.h,
              backgroundColor: isDark ? Colors.white12 : AppColors.dividerLight,
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
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
                    'Ã˜Â§Ã™â€žÃ˜Â­Ã˜Â¯: ',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 11.sp,
                      color: isDark
                          ? Colors.white54
                          : AppColors.textTertiaryLight,
                    ),
                  ),
                  Text(
                    '${creditLimit.toStringAsFixed(0)} ${AppLocalizations.of(context)!.currency}',
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
                    'Ã˜Â§Ã™â€žÃ™â€¦Ã˜Â³Ã˜ÂªÃ˜Â®Ã˜Â¯Ã™â€¦: ',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 11.sp,
                      color: isDark
                          ? Colors.white54
                          : AppColors.textTertiaryLight,
                    ),
                  ),
                  Text(
                    '${creditUsed.toStringAsFixed(0)} ${AppLocalizations.of(context)!.currency}',
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
        ],
      ),
    );
  }
}
