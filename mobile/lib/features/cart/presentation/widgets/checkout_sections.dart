library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/config/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/checkout_session_entity.dart';
import '../../../orders/domain/entities/bank_account_entity.dart';
import '../../../profile/domain/entities/address_entity.dart';

class CheckoutAddressCard extends StatelessWidget {
  final AddressEntity address;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const CheckoutAddressCard({
    super.key,
    required this.address,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 4.h),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
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
        child: Row(
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                Iconsax.location,
                color: AppColors.primary,
                size: 22.sp,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text(
                        address.label,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 14.sp,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (address.isDefault) ...[
                        SizedBox(width: 6.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text(
                            'افتراضي',
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    address.addressLine,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondaryLight,
                      fontSize: 12.sp,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (address.cityName != null || address.phone != null) ...[
                    SizedBox(height: 2.h),
                    Text(
                      [
                        if (address.cityName != null) address.cityName!,
                        if (address.phone != null) address.phone!,
                      ].join(' • '),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textTertiaryLight,
                        fontSize: 11.sp,
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
                    'المتاح',
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
                    'الحد: ',
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
                    'المستخدم: ',
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
    final accountNumberLabel = locale == 'ar' ? 'رقم الحساب' : 'Account Number';

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
            'البنوك المدعومة',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'اختر البنك الذي قمت بالتحويل إليه',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondaryLight,
            ),
          ),
          SizedBox(height: 8.h),
          if (isLoading)
            const Center(child: CircularProgressIndicator())
          else if (bankAccounts.isEmpty)
            Text(
              'لا توجد حسابات بنكية متاحة حالياً',
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
                                      'افتراضي',
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
                              'اسم الحساب: ${account.getAccountName(locale)}',
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
          message: isArabic ? 'نسخ $label' : 'Copy $label',
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
                    'الرصيد المتاح',
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
                    'المطلوب: ',
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
                    'المتبقي: ',
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
                      'الرصيد غير كافٍ. ينقصك ${(orderTotal - walletBalance).toStringAsFixed(2)} ${AppLocalizations.of(context)!.currency}',
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

class CheckoutTransferReceiptSection extends StatelessWidget {
  final bool isDark;
  final String? receiptImagePath;
  final TextEditingController transferNotesController;
  final VoidCallback onPickImage;
  final VoidCallback onClearImage;

  const CheckoutTransferReceiptSection({
    super.key,
    required this.isDark,
    required this.receiptImagePath,
    required this.transferNotesController,
    required this.onPickImage,
    required this.onClearImage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'إيصال التحويل (مطلوب)',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 8.h),
          GestureDetector(
            onTap: onPickImage,
            child: Container(
              height: 170.h,
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : AppColors.cardLight,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: receiptImagePath != null
                      ? AppColors.primary
                      : (isDark
                            ? AppColors.dividerDark
                            : AppColors.dividerLight),
                ),
              ),
              child: receiptImagePath == null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Iconsax.gallery_add,
                          size: 36.sp,
                          color: AppColors.textTertiaryLight,
                        ),
                        SizedBox(height: 10.h),
                        Text(
                          'اضغط لاختيار صورة الإيصال',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondaryLight,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'PNG, JPG حتى 10 MB',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.textTertiaryLight,
                          ),
                        ),
                      ],
                    )
                  : Stack(
                      fit: StackFit.expand,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10.r),
                          child: Image.file(
                            File(receiptImagePath!),
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 8.h,
                          left: 8.w,
                          child: GestureDetector(
                            onTap: onClearImage,
                            child: Container(
                              padding: EdgeInsets.all(6.w),
                              decoration: const BoxDecoration(
                                color: AppColors.error,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.close,
                                size: 14.sp,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          SizedBox(height: 14.h),
          TextField(
            controller: transferNotesController,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'ملاحظات التحويل (اختياري)',
              hintText: 'أي تفاصيل إضافية عن عملية التحويل',
            ),
          ),
          SizedBox(height: 14.h),
          Text(
            'ستجد البنوك المدعومة تحت خيار "تحويل بنكي" بالأعلى.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }
}

class CheckoutOrderSummaryCard extends StatelessWidget {
  final CheckoutSessionEntity session;
  final double couponDiscount;
  final double total;
  final double walletAmountToUse;
  final double payableNow;

  const CheckoutOrderSummaryCard({
    super.key,
    required this.session,
    required this.couponDiscount,
    required this.total,
    required this.walletAmountToUse,
    required this.payableNow,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cart = session.cart;
    final promotionDiscount = cart.discount;
    final subtotal = cart.subtotal;
    final shippingCost = cart.shippingCost;
    final taxAmount = cart.taxAmount;
    final itemsCount = cart.itemsCount;
    final locale = Localizations.localeOf(context).languageCode;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.products,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 12.h),
          if (cart.items.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              child: Text(
                'لا توجد منتجات',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondaryLight,
                ),
              ),
            )
          else ...[
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'المنتج',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                ),
                SizedBox(
                  width: 40.w,
                  child: Text(
                    'الكمية',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                ),
                SizedBox(
                  width: 56.w,
                  child: Text(
                    'السعر',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                ),
                SizedBox(
                  width: 56.w,
                  child: Text(
                    'الإجمالي',
                    textAlign: TextAlign.end,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Divider(
              height: 1,
              color: AppColors.dividerLight.withValues(alpha: 0.5),
            ),
            SizedBox(height: 8.h),
            ...cart.items.map((item) {
              return Padding(
                padding: EdgeInsets.only(bottom: 10.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        item.getProductName(locale),
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(
                      width: 40.w,
                      child: Text(
                        '${item.quantity}',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                    SizedBox(
                      width: 56.w,
                      child: Text(
                        item.unitPrice.toStringAsFixed(0),
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                    SizedBox(
                      width: 56.w,
                      child: Text(
                        item.totalPrice.toStringAsFixed(0),
                        textAlign: TextAlign.end,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
            Divider(height: 20.h, color: AppColors.dividerLight),
          ],
          Text(
            AppLocalizations.of(context)!.subtotal,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 12.h),
          _CheckoutSummaryRow(
            label:
                'المجموع الفرعي ($itemsCount ${itemsCount == 1 ? 'منتج' : 'منتجات'})',
            value:
                '${subtotal.toStringAsFixed(0)} ${AppLocalizations.of(context)!.currency}',
          ),
          SizedBox(height: 8.h),
          _CheckoutSummaryRow(
            label: 'الشحن',
            value:
                '${shippingCost.toStringAsFixed(0)} ${AppLocalizations.of(context)!.currency}',
          ),
          if (promotionDiscount > 0) ...[
            SizedBox(height: 8.h),
            _CheckoutSummaryRow(
              label: 'خصم العروض',
              value:
                  '-${promotionDiscount.toStringAsFixed(0)} ${AppLocalizations.of(context)!.currency}',
              valueColor: AppColors.success,
            ),
          ],
          if (couponDiscount > 0) ...[
            SizedBox(height: 8.h),
            _CheckoutSummaryRow(
              label: 'خصم الكوبون',
              value:
                  '-${couponDiscount.toStringAsFixed(0)} ${AppLocalizations.of(context)!.currency}',
              valueColor: AppColors.success,
            ),
          ],
          if (taxAmount > 0) ...[
            SizedBox(height: 8.h),
            _CheckoutSummaryRow(
              label: 'الضريبة',
              value:
                  '${taxAmount.toStringAsFixed(0)} ${AppLocalizations.of(context)!.currency}',
            ),
          ],
          Divider(height: 24.h),
          if (walletAmountToUse > 0) ...[
            _CheckoutSummaryRow(
              label: 'المخصوم من المحفظة',
              value:
                  '-${walletAmountToUse.toStringAsFixed(0)} ${AppLocalizations.of(context)!.currency}',
              valueColor: AppColors.success,
            ),
            SizedBox(height: 8.h),
            _CheckoutSummaryRow(
              label: 'المتبقي للدفع الآن',
              value:
                  '${payableNow.toStringAsFixed(0)} ${AppLocalizations.of(context)!.currency}',
            ),
            Divider(height: 24.h),
          ],
          _CheckoutSummaryRow(
            label: 'الإجمالي',
            value:
                '${total.toStringAsFixed(0)} ${AppLocalizations.of(context)!.currency}',
            isTotal: true,
          ),
        ],
      ),
    );
  }
}

class _CheckoutSummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool isTotal;

  const _CheckoutSummaryRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isTotal
              ? theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                )
              : theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondaryLight,
                ),
        ),
        Text(
          value,
          style: isTotal
              ? TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                )
              : theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: valueColor,
                ),
        ),
      ],
    );
  }
}

class CheckoutPlaceOrderBar extends StatelessWidget {
  final bool isDark;
  final bool canPlaceOrder;
  final double payableNow;
  final VoidCallback? onPlaceOrder;

  const CheckoutPlaceOrderBar({
    super.key,
    required this.isDark,
    required this.canPlaceOrder,
    required this.payableNow,
    required this.onPlaceOrder,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Opacity(
          opacity: canPlaceOrder ? 1.0 : 0.5,
          child: ElevatedButton(
            onPressed: canPlaceOrder ? onPlaceOrder : null,
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14.r),
              ),
            ),
            child: Text(
              '${AppLocalizations.of(context)!.confirm} • ${payableNow.toStringAsFixed(0)} ${AppLocalizations.of(context)!.currency}',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }
}
