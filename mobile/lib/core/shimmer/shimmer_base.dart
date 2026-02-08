/// Shimmer Base - Shared components for page shimmers
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widgets/loading/shimmer_widgets.dart';

/// Shimmer section header - mimics SectionHeader with title and "View All"
class ShimmerSectionHeader extends StatelessWidget {
  const ShimmerSectionHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          Expanded(
            child: ShimmerCard(height: 20, width: 140),
          ),
          ShimmerCard(
            height: 16,
            width: 60,
            borderRadius: BorderRadius.circular(4.r),
          ),
        ],
      ),
    );
  }
}

/// Shimmer order card - mimics order list item
class ShimmerOrderCard extends StatelessWidget {
  const ShimmerOrderCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerCard(height: 18, width: 100),
                    SizedBox(height: 8.h),
                    ShimmerCard(height: 14, width: 80),
                  ],
                ),
              ),
              ShimmerCard(
                height: 28,
                width: 70,
                borderRadius: BorderRadius.circular(20.r),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          ShimmerCard(height: 1, width: double.infinity),
          SizedBox(height: 16.h),
          ShimmerCard(height: 14, width: 60),
          SizedBox(height: 8.h),
          ShimmerCard(height: 16, width: 120),
          SizedBox(height: 4.h),
          ShimmerCard(height: 12, width: 80),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ShimmerCard(height: 14, width: 40),
              ShimmerCard(height: 18, width: 60),
            ],
          ),
        ],
      ),
    );
  }
}

/// Shimmer notification tile - mimics notification list item
class ShimmerNotificationTile extends StatelessWidget {
  const ShimmerNotificationTile({super.key});

  @override
  Widget build(BuildContext context) {
    return const ShimmerListTile(hasLeading: true, hasTrailing: false);
  }
}

/// Shimmer address card - mimics address selection item
class ShimmerAddressCard extends StatelessWidget {
  const ShimmerAddressCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerCard(height: 18, width: 100),
          SizedBox(height: 8.h),
          ShimmerCard(height: 14, width: double.infinity),
          SizedBox(height: 4.h),
          ShimmerCard(height: 14, width: 180),
        ],
      ),
    );
  }
}
