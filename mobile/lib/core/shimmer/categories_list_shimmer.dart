/// Categories List Shimmer - Loading placeholder for categories screen
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widgets/loading/shimmer_widgets.dart';

/// Shimmer for categories list screen (2-column categories grid)
class CategoriesListShimmer extends StatelessWidget {
  const CategoriesListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: 6,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85,
        crossAxisSpacing: 14.w,
        mainAxisSpacing: 14.h,
      ),
      itemBuilder: (context, index) => const _ShimmerCategoryCard(),
    );
  }
}

class _ShimmerCategoryCard extends StatelessWidget {
  const _ShimmerCategoryCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(22.r),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ShimmerCard(
            height: 75,
            width: 75,
            borderRadius: BorderRadius.circular(37.5.r),
          ),
          SizedBox(height: 14.h),
          ShimmerCard(
            height: 14,
            width: 100,
            borderRadius: BorderRadius.circular(10.r),
          ),
          SizedBox(height: 8.h),
          ShimmerCard(
            height: 22,
            width: 70,
            borderRadius: BorderRadius.circular(14.r),
          ),
        ],
      ),
    );
  }
}
