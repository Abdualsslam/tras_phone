import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/config/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/domain/entities/customer_entity.dart';

class ProfileBusinessInfoCard extends StatelessWidget {
  final bool isDark;
  final CustomerEntity customer;

  const ProfileBusinessInfoCard({
    super.key,
    required this.isDark,
    required this.customer,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ClipRRect(
      borderRadius: BorderRadius.circular(18.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      Colors.white.withValues(alpha: 0.08),
                      Colors.white.withValues(alpha: 0.04),
                    ]
                  : [
                      Colors.white.withValues(alpha: 0.9),
                      Colors.white.withValues(alpha: 0.75),
                    ],
            ),
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : AppColors.primary.withValues(alpha: 0.1),
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              _ProfileInfoTile(
                isDark: isDark,
                icon: Iconsax.shop,
                title: l10n.shopName,
                value: customer.getShopName('ar'),
              ),
              _ProfileDivider(isDark: isDark),
              _ProfileInfoTile(
                isDark: isDark,
                icon: Iconsax.user,
                title: l10n.responsiblePerson,
                value: customer.responsiblePersonName,
              ),
              _ProfileDivider(isDark: isDark),
              _ProfileInfoTile(
                isDark: isDark,
                icon: Iconsax.category,
                title: l10n.businessType,
                value: customer.businessType.displayName,
              ),
              _ProfileDivider(isDark: isDark),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileInfoTile extends StatelessWidget {
  final bool isDark;
  final IconData icon;
  final String title;
  final String value;

  const _ProfileInfoTile({
    required this.isDark,
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Container(
        width: 42.w,
        height: 42.w,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary.withValues(alpha: 0.15),
              AppColors.primaryLight.withValues(alpha: 0.08),
            ],
          ),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Icon(icon, size: 20.sp, color: AppColors.primary),
      ),
      title: Text(
        title,
        style: theme.textTheme.bodySmall?.copyWith(
          color: isDark
              ? AppColors.textSecondaryDark
              : AppColors.textSecondaryLight,
        ),
      ),
      subtitle: Text(
        value,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w500,
          color: isDark
              ? AppColors.textPrimaryDark
              : AppColors.textPrimaryLight,
        ),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
    );
  }
}

class _ProfileDivider extends StatelessWidget {
  final bool isDark;

  const _ProfileDivider({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      indent: 56.w,
      color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
    );
  }
}
