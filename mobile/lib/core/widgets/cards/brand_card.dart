/// GlassBrandCard - Glass card for brand items
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../config/theme/app_colors.dart';
import 'glass_card.dart';

/// A glass card specifically designed for brand items
class GlassBrandCard extends StatelessWidget {
  final String name;
  final String? logoUrl;
  final VoidCallback? onTap;

  const GlassBrandCard({
    super.key,
    required this.name,
    this.logoUrl,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    return GlassCard(
      onTap: onTap,
      borderRadius: 16,
      blur: 12,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Logo Container
          Container(
            width: 55.w,
            height: 55.w,
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.15),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: logoUrl != null
                ? Image.network(
                    logoUrl!,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.business_rounded,
                      size: 26.sp,
                      color: AppColors.primary,
                    ),
                  )
                : Icon(
                    Icons.business_rounded,
                    size: 26.sp,
                    color: AppColors.primary,
                  ),
          ),
          SizedBox(height: 10.h),

          // Brand Name
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 6.w),
            child: Text(
              name,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
