/// Cart Shimmer - Loading placeholder for cart screen
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widgets/loading/shimmer_widgets.dart';

/// Shimmer for cart screen (cart items list + summary)
class CartShimmer extends StatelessWidget {
  const CartShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: EdgeInsets.all(16.w),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: _ShimmerCartItem(),
              ),
              childCount: 4,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: _ShimmerCheckoutSummary(),
          ),
        ),
        SliverToBoxAdapter(child: SizedBox(height: 100.h)),
      ],
    );
  }
}

class _ShimmerCartItem extends StatelessWidget {
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
                ShimmerCard(height: 14, width: 80),
                SizedBox(height: 8.h),
                ShimmerCard(height: 20, width: 60),
              ],
            ),
          ),
          Column(
            children: [
              ShimmerCard(
                height: 32,
                width: 32,
                borderRadius: BorderRadius.circular(8.r),
              ),
              SizedBox(height: 8.h),
              ShimmerCard(height: 24, width: 24),
            ],
          ),
        ],
      ),
    );
  }
}

class _ShimmerCheckoutSummary extends StatelessWidget {
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
          ShimmerCard(height: 18, width: 100),
          SizedBox(height: 12.h),
          ShimmerCard(height: 14, width: 120),
          SizedBox(height: 8.h),
          ShimmerCard(height: 14, width: 100),
          SizedBox(height: 16.h),
          ShimmerCard(
            height: 48,
            width: double.infinity,
            borderRadius: BorderRadius.circular(12.r),
          ),
        ],
      ),
    );
  }
}
