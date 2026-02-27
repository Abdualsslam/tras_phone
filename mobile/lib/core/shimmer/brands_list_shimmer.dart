/// Brands List Shimmer - Loading placeholder for brands screen
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widgets/loading/shimmer_widgets.dart';

/// Shimmer for brands list screen (3-column brands grid)
class BrandsListShimmer extends StatelessWidget {
  const BrandsListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: 9,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.8,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
      ),
      itemBuilder: (context, index) => const _ShimmerBrandCard(),
    );
  }
}

class _ShimmerBrandCard extends StatelessWidget {
  const _ShimmerBrandCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ShimmerCard(
            height: 58,
            width: 58,
            borderRadius: BorderRadius.circular(16.r),
          ),
          SizedBox(height: 10.h),
          ShimmerCard(
            height: 12,
            width: 60,
            borderRadius: BorderRadius.circular(10.r),
          ),
        ],
      ),
    );
  }
}
