/// Devices List Shimmer - Loading placeholder for devices selection screen
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widgets/loading/shimmer_widgets.dart';

/// Full-page shimmer for devices list screen.
class DevicesListShimmer extends StatelessWidget {
  const DevicesListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(16.w),
          child: ShimmerCard(
            height: 54,
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        SizedBox(
          height: 50.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            itemCount: 5,
            separatorBuilder: (context, index) => SizedBox(width: 8.w),
            itemBuilder: (context, index) => ShimmerCard(
              height: 42,
              width: 90,
              borderRadius: BorderRadius.circular(24.r),
            ),
          ),
        ),
        SizedBox(height: 8.h),
        const Expanded(child: DeviceItemsShimmer()),
      ],
    );
  }
}

/// Shimmer for devices list area only.
class DeviceItemsShimmer extends StatelessWidget {
  const DeviceItemsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.all(16.w),
      itemCount: 6,
      separatorBuilder: (context, index) => SizedBox(height: 8.h),
      itemBuilder: (context, index) {
        return Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Row(
            children: [
              ShimmerCard(
                height: 48,
                width: 48,
                borderRadius: BorderRadius.circular(12.r),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerCard(
                      height: 14,
                      width: 140,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    SizedBox(height: 6.h),
                    ShimmerCard(
                      height: 12,
                      width: 90,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ],
                ),
              ),
              ShimmerCard(
                height: 24,
                width: 24,
                borderRadius: BorderRadius.circular(8.r),
              ),
            ],
          ),
        );
      },
    );
  }
}
