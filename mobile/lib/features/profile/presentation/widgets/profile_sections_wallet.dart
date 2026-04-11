import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/config/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/domain/entities/customer_entity.dart';

class ProfileWalletCard extends StatelessWidget {
  final bool isDark;
  final CustomerEntity customer;
  final VoidCallback onOpenWallet;

  const ProfileWalletCard({
    super.key,
    required this.isDark,
    required this.customer,
    required this.onOpenWallet,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return ClipRRect(
      borderRadius: BorderRadius.circular(18.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary.withValues(alpha: 0.1),
                AppColors.primaryLight.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.2),
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.walletBalance,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                '${customer.walletBalance.toStringAsFixed(2)} ${l10n.currency}',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(height: 16.h),
              const Divider(),
              SizedBox(height: 16.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _WalletValue(
                    isDark: isDark,
                    title: l10n.creditLimit,
                    value:
                        '${customer.creditLimit.toStringAsFixed(2)} ${l10n.currency}',
                    alignment: CrossAxisAlignment.start,
                  ),
                  _WalletValue(
                    isDark: isDark,
                    title: l10n.creditUsed,
                    value:
                        '${customer.creditUsed.toStringAsFixed(2)} ${l10n.currency}',
                    alignment: CrossAxisAlignment.end,
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              LinearProgressIndicator(
                value: customer.creditLimit > 0
                    ? customer.creditUsed / customer.creditLimit
                    : 0,
                backgroundColor: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.grey.shade300,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.primary,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                l10n.creditAvailable(
                  customer.availableCredit.toStringAsFixed(2),
                ),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
              SizedBox(height: 14.h),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: onOpenWallet,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  icon: Icon(Iconsax.wallet_3, size: 18.sp),
                  label: Text(l10n.wallet),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WalletValue extends StatelessWidget {
  final bool isDark;
  final String title;
  final String value;
  final CrossAxisAlignment alignment;

  const _WalletValue({
    required this.isDark,
    required this.title,
    required this.value,
    required this.alignment,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: alignment,
      children: [
        Text(
          title,
          style: theme.textTheme.bodySmall?.copyWith(
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
