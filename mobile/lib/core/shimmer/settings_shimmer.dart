/// Settings Shimmer - Loading placeholder for settings screens
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widgets/loading/shimmer_widgets.dart';

/// Shimmer for notification settings screen
class SettingsListShimmer extends StatelessWidget {
  const SettingsListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(16.w),
      children: [
        ShimmerCard(
          height: 80,
          width: double.infinity,
          borderRadius: BorderRadius.circular(12.r),
        ),
        SizedBox(height: 16.h),
        ShimmerCard(
          height: 60,
          width: double.infinity,
          borderRadius: BorderRadius.circular(12.r),
        ),
        SizedBox(height: 8.h),
        ShimmerCard(
          height: 60,
          width: double.infinity,
          borderRadius: BorderRadius.circular(12.r),
        ),
        SizedBox(height: 8.h),
        ShimmerCard(
          height: 60,
          width: double.infinity,
          borderRadius: BorderRadius.circular(12.r),
        ),
        SizedBox(height: 8.h),
        ShimmerCard(
          height: 60,
          width: double.infinity,
          borderRadius: BorderRadius.circular(12.r),
        ),
        SizedBox(height: 8.h),
        ShimmerCard(
          height: 60,
          width: double.infinity,
          borderRadius: BorderRadius.circular(12.r),
        ),
      ],
    );
  }
}
