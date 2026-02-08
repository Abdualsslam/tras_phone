/// Returns Shimmer - Loading placeholder for returns list screen
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widgets/loading/shimmer_widgets.dart';

/// Shimmer for returns list screen (similar to orders - return request cards)
class ReturnsListShimmer extends StatelessWidget {
  const ReturnsListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.fromLTRB(16.w, 16.w, 16.w, 100.h),
      itemCount: 5,
      separatorBuilder: (context, index) => SizedBox(height: 12.h),
      itemBuilder: (context, index) => _ShimmerReturnCard(),
    );
  }
}

class _ShimmerReturnCard extends StatelessWidget {
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
                width: 80,
                borderRadius: BorderRadius.circular(20.r),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          ShimmerCard(height: 1, width: double.infinity),
          SizedBox(height: 12.h),
          ShimmerCard(height: 14, width: 100),
          SizedBox(height: 8.h),
          ShimmerCard(height: 16, width: 120),
        ],
      ),
    );
  }
}
