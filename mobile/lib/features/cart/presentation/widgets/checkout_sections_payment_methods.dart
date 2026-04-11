part of 'checkout_sections.dart';

class CheckoutPaymentMethodsSection extends StatelessWidget {
  final bool isDark;
  final List<PaymentMethodEntity> paymentMethods;
  final String? selectedPaymentMethodId;
  final bool isWalletCreditMerged;
  final PaymentMethodEntity? mergedCreditMethod;
  final void Function(PaymentMethodEntity method) onSelectMethod;
  final IconData Function(String type) getPaymentMethodIcon;
  final List<Widget> Function(PaymentMethodEntity method, bool isSelected)
  buildDetails;

  const CheckoutPaymentMethodsSection({
    super.key,
    required this.isDark,
    required this.paymentMethods,
    required this.selectedPaymentMethodId,
    required this.isWalletCreditMerged,
    required this.mergedCreditMethod,
    required this.onSelectMethod,
    required this.getPaymentMethodIcon,
    required this.buildDetails,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).languageCode;

    if (paymentMethods.isEmpty) {
      return _CheckoutSectionContainer(
        isDark: isDark,
        child: Column(
          children: [
            Icon(
              Iconsax.card,
              size: 48.sp,
              color: AppColors.textSecondaryLight,
            ),
            SizedBox(height: 8.h),
            Text(
              'Ù„Ø§ ØªÙˆØ¬Ø¯ Ø·Ø±Ù‚ Ø¯ÙØ¹ Ù…ØªØ§Ø­Ø©',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    return _CheckoutSectionContainer(
      isDark: isDark,
      child: Column(
        children: paymentMethods.map((method) {
          final isSelected = selectedPaymentMethodId == method.id;
          final displayName = isWalletCreditMerged && method.type == 'wallet'
              ? 'Wallet + Credit'
              : method.getName(locale);
          final displayDescription =
              isWalletCreditMerged && method.type == 'wallet'
              ? 'Wallet balance is used first, then available credit.'
              : method.getDescription(locale);

          return CheckoutPaymentCard(
            isDark: isDark,
            isSelected: isSelected,
            iconData: getPaymentMethodIcon(method.type),
            displayName: displayName,
            displayDescription: displayDescription,
            onTap: () => onSelectMethod(method),
            details: buildDetails(method, isSelected),
          );
        }).toList(),
      ),
    );
  }
}

class CheckoutPaymentCard extends StatelessWidget {
  final bool isDark;
  final bool isSelected;
  final IconData iconData;
  final String displayName;
  final String? displayDescription;
  final VoidCallback onTap;
  final List<Widget> details;

  const CheckoutPaymentCard({
    super.key,
    required this.isDark,
    required this.isSelected,
    required this.iconData,
    required this.displayName,
    required this.displayDescription,
    required this.onTap,
    this.details = const [],
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 4.h),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.cardDark
              : (isSelected
                    ? AppColors.primary.withValues(alpha: 0.04)
                    : AppColors.inputBackgroundLight),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isDark ? AppColors.dividerDark : AppColors.dividerLight),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(iconData, color: AppColors.primary, size: 22.sp),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        displayName,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 14.sp,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (displayDescription != null) ...[
                        SizedBox(height: 2.h),
                        Text(
                          displayDescription!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.textTertiaryLight,
                            fontSize: 12.sp,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                Container(
                  width: 22.w,
                  height: 22.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? AppColors.primary : Colors.transparent,
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textTertiaryLight,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? Center(
                          child: Container(
                            width: 8.w,
                            height: 8.w,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                        )
                      : null,
                ),
              ],
            ),
            ...details,
          ],
        ),
      ),
    );
  }
}
