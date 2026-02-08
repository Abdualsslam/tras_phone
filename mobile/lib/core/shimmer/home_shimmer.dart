/// Home Shimmer - Loading placeholder for home screen
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widgets/loading/shimmer_widgets.dart';
import 'shimmer_base.dart';

/// Shimmer loading state for the home screen.
/// Mirrors the layout of HomeScreen: banner, promotions, categories, brands, products.
class HomeShimmer extends StatelessWidget {
  const HomeShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.only(bottom: 24.h),
      children: [
        // Banner Slider shimmer
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: ShimmerCard(
            height: 180,
            borderRadius: BorderRadius.circular(16.r),
          ),
        ),
        SizedBox(height: 16.h),

        // Promotions Banner shimmer
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: ShimmerCard(
            height: 180,
            borderRadius: BorderRadius.circular(16.r),
          ),
        ),
        SizedBox(height: 24.h),

        // Categories section
        const ShimmerSectionHeader(),
        SizedBox(height: 12.h),
        SizedBox(
          height: 110.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            itemCount: 6,
            separatorBuilder: (context, index) => SizedBox(width: 12.w),
            itemBuilder: (context, index) => ShimmerCard(
              height: 110,
              width: 80,
              borderRadius: BorderRadius.circular(18.r),
            ),
          ),
        ),
        SizedBox(height: 24.h),

        // Brands section
        const ShimmerSectionHeader(),
        SizedBox(height: 12.h),
        SizedBox(
          height: 55.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            itemCount: 6,
            separatorBuilder: (context, index) => SizedBox(width: 12.w),
            itemBuilder: (context, index) => ShimmerCard(
              height: 55,
              width: 120,
              borderRadius: BorderRadius.circular(14.r),
            ),
          ),
        ),
        SizedBox(height: 24.h),

        // Featured Products section
        const ShimmerSectionHeader(),
        SizedBox(height: 12.h),
        _ProductsSectionShimmer(),
        SizedBox(height: 24.h),

        // New Arrivals section
        const ShimmerSectionHeader(),
        SizedBox(height: 12.h),
        _ProductsSectionShimmer(),
        SizedBox(height: 24.h),

        // Best Sellers section
        const ShimmerSectionHeader(),
        SizedBox(height: 12.h),
        _ProductsSectionShimmer(),
        SizedBox(height: 100.h),
      ],
    );
  }
}

class _ProductsSectionShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 290.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 10.h),
        clipBehavior: Clip.none,
        itemCount: 4,
        separatorBuilder: (context, index) => SizedBox(width: 12.w),
        itemBuilder: (context, index) => SizedBox(
          width: 170.w,
          child: const ShimmerProductCard(),
        ),
      ),
    );
  }
}
