/// Education Shimmer - Loading placeholder for education screens
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widgets/loading/shimmer_widgets.dart';

/// Shimmer for education favorites/list screens
class EducationListShimmer extends StatelessWidget {
  const EducationListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.all(16.w),
      itemCount: 5,
      separatorBuilder: (context, index) => SizedBox(height: 12.h),
      itemBuilder: (context, index) => _ShimmerEducationCard(),
    );
  }
}

class _ShimmerEducationCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          ShimmerCard(
            height: 80,
            width: 80,
            borderRadius: BorderRadius.circular(12.r),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerCard(height: 16, width: double.infinity),
                SizedBox(height: 8.h),
                ShimmerCard(height: 14, width: 120),
                SizedBox(height: 8.h),
                ShimmerCard(height: 12, width: 80),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
