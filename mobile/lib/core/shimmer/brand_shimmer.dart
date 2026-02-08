/// Brand Shimmer - Loading placeholder for brand details screen
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../config/theme/app_colors.dart';
import '../widgets/loading/shimmer_widgets.dart';

/// Shimmer for brand details screen (header + products grid)
class BrandDetailShimmer extends StatelessWidget {
  const BrandDetailShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        _ShimmerSliverAppBar(),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 12.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ShimmerCard(height: 20, width: 120),
                ShimmerCard(height: 16, width: 60),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12.h,
              crossAxisSpacing: 12.w,
              childAspectRatio: 0.58,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) => const ShimmerProductCard(),
              childCount: 6,
            ),
          ),
        ),
        SliverToBoxAdapter(child: SizedBox(height: 100.h)),
      ],
    );
  }
}

class _ShimmerSliverAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 200.h,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.primary, AppColors.primaryDark],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 50.h),
                ShimmerCard(
                  height: 100,
                  width: 100,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                SizedBox(height: 16.h),
                ShimmerCard(
                  height: 24,
                  width: 150,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                SizedBox(height: 8.h),
                ShimmerCard(
                  height: 14,
                  width: 80,
                  borderRadius: BorderRadius.circular(6.r),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
