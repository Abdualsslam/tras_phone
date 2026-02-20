/// Wishlist Empty Screen - Empty wishlist state
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';

class WishlistEmptyScreen extends StatelessWidget {
  const WishlistEmptyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.favorites)),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(32.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Empty Icon
              Container(
                width: 120.w,
                height: 120.w,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Iconsax.heart,
                  size: 60.sp,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(height: 32.h),

              // Title
              Text(
                AppLocalizations.of(context)!.emptyWishlist,
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12.h),

              // Description
              Text(
                AppLocalizations.of(context)!.emptyWishlistDescription,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 40.h),

              // Action Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => context.go('/home'),
                  icon: Icon(Iconsax.shop, size: 20.sp),
                  label: Text(
                    AppLocalizations.of(context)!.browseProducts,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                  ),
                ),
              ),
              SizedBox(height: 16.h),

              // Secondary Action
              TextButton.icon(
                onPressed: () => context.push('/stock-alerts'),
                icon: Icon(Iconsax.notification, size: 18.sp),
                label: Text(AppLocalizations.of(context)!.viewStockAlerts),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
