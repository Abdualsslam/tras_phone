import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/config/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/domain/entities/customer_entity.dart';

class ProfileSectionTitle extends StatelessWidget {
  final String title;
  final bool isDark;

  const ProfileSectionTitle({
    super.key,
    required this.title,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(right: 4.w),
      child: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: isDark
              ? AppColors.textSecondaryDark
              : AppColors.textSecondaryLight,
        ),
      ),
    );
  }
}

class ProfileHeaderCard extends StatelessWidget {
  final CustomerEntity customer;
  final VoidCallback onEditPressed;

  const ProfileHeaderCard({
    super.key,
    required this.customer,
    required this.onEditPressed,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        children: [
          Container(
            width: 70.w,
            height: 70.h,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(Iconsax.user, size: 35.sp, color: Colors.white),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  customer.responsiblePersonName,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  customer.getShopName('ar'),
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
                SizedBox(height: 4.h),
                if (customer.isApproved)
                  Container(
                    margin: EdgeInsets.only(left: 8.w),
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      '✓ ${l10n.verified}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            onPressed: onEditPressed,
            icon: const Icon(Iconsax.edit, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class ProfileStatsGrid extends StatelessWidget {
  final bool isDark;
  final CustomerEntity customer;

  const ProfileStatsGrid({
    super.key,
    required this.isDark,
    required this.customer,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      crossAxisSpacing: 12.w,
      mainAxisSpacing: 12.h,
      childAspectRatio: 1.7,
      children: [
        _ProfileStatCard(
          isDark: isDark,
          title: l10n.totalOrders,
          value: customer.totalOrders.toString(),
          icon: Iconsax.shopping_bag,
          color: Colors.blue,
        ),
        _ProfileStatCard(
          isDark: isDark,
          title: l10n.totalSpent,
          value: '${customer.totalSpent.toStringAsFixed(2)} ${l10n.currency}',
          icon: Iconsax.wallet_money,
          color: Colors.green,
        ),
        _ProfileStatCard(
          isDark: isDark,
          title: l10n.averageOrderValue,
          value:
              '${customer.averageOrderValue.toStringAsFixed(2)} ${l10n.currency}',
          icon: Iconsax.trend_up,
          color: Colors.orange,
        ),
        _ProfileStatCard(
          isDark: isDark,
          title: l10n.loyaltyPoints,
          value: customer.loyaltyPoints.toString(),
          icon: Iconsax.medal_star,
          color: Colors.purple,
        ),
      ],
    );
  }
}

class _ProfileStatCard extends StatelessWidget {
  final bool isDark;
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _ProfileStatCard({
    required this.isDark,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: EdgeInsets.all(10.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      Colors.white.withValues(alpha: 0.1),
                      Colors.white.withValues(alpha: 0.05),
                    ]
                  : [
                      Colors.white.withValues(alpha: 0.9),
                      Colors.white.withValues(alpha: 0.7),
                    ],
            ),
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.12)
                  : color.withValues(alpha: 0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.15),
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Icon(icon, color: color, size: 24.sp),
              ),
              SizedBox(height: 4.h),
              Flexible(
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(height: 2.h),
              Flexible(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileUnauthenticatedContent extends StatelessWidget {
  final VoidCallback onLogin;

  const ProfileUnauthenticatedContent({super.key, required this.onLogin});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Iconsax.user_remove,
            size: 80.sp,
            color: AppColors.textTertiaryLight,
          ),
          SizedBox(height: 24.h),
          Text(
            l10n.notLoggedIn,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            l10n.loginToAccess,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textTertiaryLight,
            ),
          ),
          SizedBox(height: 32.h),
          ElevatedButton(
            onPressed: onLogin,
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 48.w, vertical: 16.h),
            ),
            child: Text(l10n.login),
          ),
        ],
      ),
    );
  }
}
