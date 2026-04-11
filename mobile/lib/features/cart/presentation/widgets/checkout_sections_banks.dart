part of 'checkout_sections.dart';

class CheckoutSupportedBanksPanel extends StatelessWidget {
  final bool isDark;
  final bool isLoading;
  final List<BankAccountEntity> bankAccounts;
  final String? selectedBankAccountId;
  final ValueChanged<String> onSelectBankAccount;
  final void Function(String value, String label) onCopyValue;

  const CheckoutSupportedBanksPanel({
    super.key,
    required this.isDark,
    required this.isLoading,
    required this.bankAccounts,
    required this.selectedBankAccountId,
    required this.onSelectBankAccount,
    required this.onCopyValue,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final accountNumberLabel = locale == 'ar'
        ? 'Ã˜Â±Ã™â€šÃ™â€¦ Ã˜Â§Ã™â€žÃ˜Â­Ã˜Â³Ã˜Â§Ã˜Â¨'
        : 'Account Number';

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ã˜Â§Ã™â€žÃ˜Â¨Ã™â€ Ã™Ë†Ã™Æ’ Ã˜Â§Ã™â€žÃ™â€¦Ã˜Â¯Ã˜Â¹Ã™Ë†Ã™â€¦Ã˜Â©',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Ã˜Â§Ã˜Â®Ã˜ÂªÃ˜Â± Ã˜Â§Ã™â€žÃ˜Â¨Ã™â€ Ã™Æ’ Ã˜Â§Ã™â€žÃ˜Â°Ã™Å  Ã™â€šÃ™â€¦Ã˜Âª Ã˜Â¨Ã˜Â§Ã™â€žÃ˜ÂªÃ˜Â­Ã™Ë†Ã™Å Ã™â€ž Ã˜Â¥Ã™â€žÃ™Å Ã™â€¡',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondaryLight,
            ),
          ),
          SizedBox(height: 8.h),
          if (isLoading)
            const Center(child: CircularProgressIndicator())
          else if (bankAccounts.isEmpty)
            Text(
              'Ã™â€žÃ˜Â§ Ã˜ÂªÃ™Ë†Ã˜Â¬Ã˜Â¯ Ã˜Â­Ã˜Â³Ã˜Â§Ã˜Â¨Ã˜Â§Ã˜Âª Ã˜Â¨Ã™â€ Ã™Æ’Ã™Å Ã˜Â© Ã™â€¦Ã˜ÂªÃ˜Â§Ã˜Â­Ã˜Â© Ã˜Â­Ã˜Â§Ã™â€žÃ™Å Ã˜Â§Ã™â€¹',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondaryLight,
              ),
            )
          else
            ...bankAccounts.map((account) {
              final isSelected = selectedBankAccountId == account.id;
              return GestureDetector(
                onTap: () => onSelectBankAccount(account.id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  margin: EdgeInsets.only(bottom: 8.h),
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.cardDark
                        : (isSelected
                              ? AppColors.primary.withValues(alpha: 0.05)
                              : AppColors.cardLight),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : (isDark
                                ? AppColors.dividerDark
                                : AppColors.dividerLight),
                      width: isSelected ? 1.4 : 1,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 34.w,
                        height: 34.w,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: account.logo != null && account.logo!.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8.r),
                                child: Image.network(
                                  account.logo!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Icon(
                                        Iconsax.bank,
                                        size: 16.sp,
                                        color: AppColors.primary,
                                      ),
                                ),
                              )
                            : Icon(
                                Iconsax.bank,
                                size: 16.sp,
                                color: AppColors.primary,
                              ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    account.getDisplayName(locale),
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                if (account.isDefault)
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 6.w,
                                      vertical: 2.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.success.withValues(
                                        alpha: 0.12,
                                      ),
                                      borderRadius: BorderRadius.circular(4.r),
                                    ),
                                    child: Text(
                                      'Ã˜Â§Ã™ÂÃ˜ÂªÃ˜Â±Ã˜Â§Ã˜Â¶Ã™Å ',
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            fontSize: 10.sp,
                                            color: AppColors.success,
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                  ),
                              ],
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              'Ã˜Â§Ã˜Â³Ã™â€¦ Ã˜Â§Ã™â€žÃ˜Â­Ã˜Â³Ã˜Â§Ã˜Â¨: ${account.getAccountName(locale)}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondaryLight,
                              ),
                            ),
                            _CopyableBankField(
                              label: accountNumberLabel,
                              value: account.accountNumber,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondaryLight,
                              ),
                              onCopyValue: onCopyValue,
                            ),
                            if (account.iban != null &&
                                account.iban!.isNotEmpty)
                              _CopyableBankField(
                                label: 'IBAN',
                                value: account.iban!,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppColors.textSecondaryLight,
                                ),
                                onCopyValue: onCopyValue,
                              ),
                          ],
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Icon(
                        isSelected ? Iconsax.tick_circle5 : Iconsax.tick_circle,
                        size: 22.sp,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textTertiaryLight,
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

class _CopyableBankField extends StatelessWidget {
  final String label;
  final String value;
  final TextStyle? style;
  final void Function(String value, String label) onCopyValue;

  const _CopyableBankField({
    required this.label,
    required this.value,
    required this.style,
    required this.onCopyValue,
  });

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Row(
      children: [
        Expanded(child: Text('$label: $value', style: style)),
        Tooltip(
          message: isArabic ? 'Ã™â€ Ã˜Â³Ã˜Â® $label' : 'Copy $label',
          child: InkWell(
            onTap: () => onCopyValue(value, label),
            borderRadius: BorderRadius.circular(8.r),
            child: Container(
              padding: EdgeInsets.all(6.w),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(Iconsax.copy, size: 16.sp, color: AppColors.primary),
            ),
          ),
        ),
      ],
    );
  }
}
