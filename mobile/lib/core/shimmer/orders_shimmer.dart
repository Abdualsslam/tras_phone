/// Orders Shimmer - Loading placeholder for order screens
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widgets/loading/shimmer_widgets.dart';
import 'shimmer_base.dart';

/// Shimmer for orders list screen
class OrdersListShimmer extends StatelessWidget {
  const OrdersListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.fromLTRB(16.w, 16.w, 16.w, 100.h),
      itemCount: 5,
      separatorBuilder: (context, index) => SizedBox(height: 12.h),
      itemBuilder: (context, index) => const ShimmerOrderCard(),
    );
  }
}

/// Shimmer for order details screen
class OrderDetailsShimmer extends StatelessWidget {
  const OrderDetailsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ShimmerOrderHeader(),
          SizedBox(height: 16.h),
          _ShimmerStatusTimeline(),
          SizedBox(height: 16.h),
          _ShimmerProductsSection(),
          SizedBox(height: 16.h),
          _ShimmerAddressSection(),
          SizedBox(height: 16.h),
          _ShimmerPaymentSummary(),
          SizedBox(height: 24.h),
          _ShimmerActions(),
        ],
      ),
    );
  }
}

class _ShimmerOrderHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
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
    );
  }
}

class _ShimmerStatusTimeline extends StatelessWidget {
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
          SizedBox(height: 16.h),
          ShimmerCard(height: 4, width: double.infinity),
          SizedBox(height: 8.h),
          ShimmerCard(height: 14, width: 120),
          SizedBox(height: 8.h),
          ShimmerCard(height: 14, width: 100),
        ],
      ),
    );
  }
}

class _ShimmerProductsSection extends StatelessWidget {
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
          ShimmerCard(height: 18, width: 80),
          SizedBox(height: 12.h),
          ShimmerCard(height: 60, width: double.infinity),
          SizedBox(height: 8.h),
          ShimmerCard(height: 60, width: double.infinity),
        ],
      ),
    );
  }
}

class _ShimmerAddressSection extends StatelessWidget {
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
          SizedBox(height: 8.h),
          ShimmerCard(height: 14, width: double.infinity),
          SizedBox(height: 4.h),
          ShimmerCard(height: 14, width: 180),
        ],
      ),
    );
  }
}

class _ShimmerPaymentSummary extends StatelessWidget {
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
          SizedBox(height: 12.h),
          ShimmerCard(height: 20, width: 80),
        ],
      ),
    );
  }
}

class _ShimmerActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ShimmerCard(
            height: 48,
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: ShimmerCard(
            height: 48,
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
      ],
    );
  }
}
