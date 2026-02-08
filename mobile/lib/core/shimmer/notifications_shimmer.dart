/// Notifications Shimmer - Loading placeholder for notification screens
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widgets/loading/shimmer_widgets.dart';
import 'shimmer_base.dart';

/// Shimmer for notifications list screen
class NotificationsListShimmer extends StatelessWidget {
  const NotificationsListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      itemCount: 8,
      separatorBuilder: (context, index) => Divider(
        height: 1,
        indent: 72.w,
        color: Theme.of(context).dividerColor,
      ),
      itemBuilder: (context, index) => const ShimmerNotificationTile(),
    );
  }
}

/// Shimmer for notification details screen
class NotificationDetailsShimmer extends StatelessWidget {
  const NotificationDetailsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerCard(height: 24, width: 200),
          SizedBox(height: 16.h),
          ShimmerCard(height: 14, width: 120),
          SizedBox(height: 24.h),
          ShimmerCard(height: 14, width: double.infinity),
          SizedBox(height: 8.h),
          ShimmerCard(height: 14, width: double.infinity),
          SizedBox(height: 8.h),
          ShimmerCard(height: 14, width: 180),
        ],
      ),
    );
  }
}
