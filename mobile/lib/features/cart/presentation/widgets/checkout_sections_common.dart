part of 'checkout_sections.dart';

class CheckoutSectionTitle extends StatelessWidget {
  final String title;

  const CheckoutSectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
    );
  }
}

class CheckoutWalletUsageCard extends StatelessWidget {
  final bool isDark;
  final double walletBalance;
  final double orderTotal;
  final bool isWalletMethodSelected;
  final double walletAutoUse;
  final double creditAutoUse;
  final double remainingAfterWalletAndCredit;

  const CheckoutWalletUsageCard({
    super.key,
    required this.isDark,
    required this.walletBalance,
    required this.orderTotal,
    required this.isWalletMethodSelected,
    required this.walletAutoUse,
    required this.creditAutoUse,
    required this.remainingAfterWalletAndCredit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return _CheckoutSectionContainer(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Iconsax.wallet_money, size: 20.sp, color: AppColors.primary),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  'Ø§Ø³ØªØ®Ø¯Ø§Ù… Ø±ØµÙŠØ¯ Ø§Ù„Ù…Ø­ÙØ¸Ø©',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '${walletBalance.toStringAsFixed(2)} ${AppLocalizations.of(context)!.currency}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondaryLight,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          if (isWalletMethodSelected)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ØªÙ… Ø§Ø®ØªÙŠØ§Ø± Ø§Ù„Ø¯ÙØ¹ Ø¨Ø§Ù„Ù…Ø­ÙØ¸Ø©ØŒ Ø³ÙŠØªÙ… Ø§Ù„Ø®ØµÙ… Ù…Ù† Ø§Ù„Ù…Ø­ÙØ¸Ø© Ø£ÙˆÙ„Ø§Ù‹ Ø«Ù… Ù…Ù† Ø­Ø¯ Ø§Ù„Ø§Ø¦ØªÙ…Ø§Ù† ØªÙ„Ù‚Ø§Ø¦ÙŠØ§Ù‹.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondaryLight,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Ù…Ù† Ø§Ù„Ù…Ø­ÙØ¸Ø©: ${walletAutoUse.toStringAsFixed(2)} ${AppLocalizations.of(context)!.currency}',
                  style: theme.textTheme.bodySmall,
                ),
                Text(
                  'Ù…Ù† Ø§Ù„Ø§Ø¦ØªÙ…Ø§Ù†: ${creditAutoUse.toStringAsFixed(2)} ${AppLocalizations.of(context)!.currency}',
                  style: theme.textTheme.bodySmall,
                ),
                if (remainingAfterWalletAndCredit > 0)
                  Text(
                    'Ø§Ù„Ù…ØªØ¨Ù‚ÙŠ Ø¨Ø¹Ø¯ Ø§Ù„Ù…Ø­ÙØ¸Ø© ÙˆØ§Ù„Ø§Ø¦ØªÙ…Ø§Ù†: ${remainingAfterWalletAndCredit.toStringAsFixed(2)} ${AppLocalizations.of(context)!.currency}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            )
          else ...[
            Text(
              'Ø³ÙŠØªÙ… Ø§Ù„Ø®ØµÙ… ØªÙ„Ù‚Ø§Ø¦ÙŠØ§Ù‹ Ù…Ù† Ø§Ù„Ù…Ø­ÙØ¸Ø© Ø£ÙˆÙ„Ø§Ù‹ ÙÙŠ Ø¬Ù…ÙŠØ¹ Ø§Ù„Ø·Ù„Ø¨Ø§Øª.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondaryLight,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Ø§Ù„Ù…Ø®ØµÙˆÙ… ØªÙ„Ù‚Ø§Ø¦ÙŠØ§Ù‹: ${walletAutoUse.toStringAsFixed(2)} ${AppLocalizations.of(context)!.currency}',
              style: theme.textTheme.bodySmall,
            ),
            Text(
              'Ø§Ù„Ù…ØªØ¨Ù‚ÙŠ Ø¨Ø¹Ø¯ Ø§Ù„Ù…Ø­ÙØ¸Ø©: ${(orderTotal - walletAutoUse).clamp(0, orderTotal).toStringAsFixed(2)} ${AppLocalizations.of(context)!.currency}',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }
}

class _CheckoutSectionContainer extends StatelessWidget {
  final bool isDark;
  final Widget child;

  const _CheckoutSectionContainer({required this.isDark, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
          width: 1,
        ),
      ),
      child: child,
    );
  }
}
