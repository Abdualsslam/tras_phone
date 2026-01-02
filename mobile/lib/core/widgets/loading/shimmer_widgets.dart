/// Shimmer Widgets - Loading placeholder components
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import '../../config/theme/app_colors.dart';

/// Shimmer loading card
class ShimmerCard extends StatelessWidget {
  final double height;
  final double? width;
  final BorderRadius? borderRadius;

  const ShimmerCard({
    super.key,
    required this.height,
    this.width,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Shimmer.fromColors(
      baseColor: isDark ? AppColors.cardDark : Colors.grey[300]!,
      highlightColor: isDark ? AppColors.dividerDark : Colors.grey[100]!,
      child: Container(
        height: height.h,
        width: width?.w ?? double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: borderRadius ?? BorderRadius.circular(12.r),
        ),
      ),
    );
  }
}

/// Shimmer product card placeholder
class ShimmerProductCard extends StatelessWidget {
  const ShimmerProductCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ShimmerCard(height: 120),
          SizedBox(height: 12.h),
          const ShimmerCard(height: 16, width: 100),
          SizedBox(height: 8.h),
          const ShimmerCard(height: 14, width: 60),
          SizedBox(height: 8.h),
          const ShimmerCard(height: 20, width: 80),
        ],
      ),
    );
  }
}

/// Shimmer list placeholder
class ShimmerListTile extends StatelessWidget {
  final bool hasLeading;
  final bool hasTrailing;

  const ShimmerListTile({
    super.key,
    this.hasLeading = true,
    this.hasTrailing = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: [
          if (hasLeading) ...[
            ShimmerCard(
              height: 48,
              width: 48,
              borderRadius: BorderRadius.circular(8.r),
            ),
            SizedBox(width: 12.w),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ShimmerCard(height: 16, width: 120),
                SizedBox(height: 4.h),
                const ShimmerCard(height: 14, width: 80),
              ],
            ),
          ),
          if (hasTrailing)
            ShimmerCard(
              height: 24,
              width: 24,
              borderRadius: BorderRadius.circular(4.r),
            ),
        ],
      ),
    );
  }
}
