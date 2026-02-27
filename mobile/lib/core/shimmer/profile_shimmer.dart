/// Profile Shimmer - Loading placeholder for profile screen
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../config/theme/app_colors.dart';
import '../widgets/loading/shimmer_widgets.dart';

/// Shimmer for profile screen (header + stats + info cards + actions)
class ProfileShimmer extends StatelessWidget {
  const ProfileShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          const _ShimmerProfileHeader(),
          SizedBox(height: 24.h),
          const _ShimmerSectionTitle(),
          SizedBox(height: 12.h),
          const _ShimmerStatsGrid(),
          SizedBox(height: 12.h),
          const _ShimmerSectionTitle(),
          SizedBox(height: 12.h),
          const _ShimmerBusinessCard(),
          SizedBox(height: 12.h),
          const _ShimmerSectionTitle(),
          SizedBox(height: 12.h),
          const _ShimmerAddressCard(),
          SizedBox(height: 24.h),
          const _ShimmerSectionTitle(),
          SizedBox(height: 12.h),
          const _ShimmerWalletCard(),
          SizedBox(height: 12.h),
          const _ShimmerActionCard(),
          SizedBox(height: 12.h),
          const _ShimmerActionCard(),
          SizedBox(height: 12.h),
          const _ShimmerActionCard(),
          SizedBox(height: 24.h),
          ShimmerCard(
            height: 56,
            borderRadius: BorderRadius.circular(14.r),
          ),
          SizedBox(height: 88.h),
        ],
      ),
    );
  }
}

class _ShimmerProfileHeader extends StatelessWidget {
  const _ShimmerProfileHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        children: [
          ShimmerCard(
            height: 70,
            width: 70,
            borderRadius: BorderRadius.circular(35.r),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerCard(
                  height: 18,
                  width: 160,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                SizedBox(height: 8.h),
                ShimmerCard(
                  height: 14,
                  width: 120,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                SizedBox(height: 8.h),
                ShimmerCard(
                  height: 22,
                  width: 90,
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          ShimmerCard(
            height: 40,
            width: 40,
            borderRadius: BorderRadius.circular(12.r),
          ),
        ],
      ),
    );
  }
}

class _ShimmerSectionTitle extends StatelessWidget {
  const _ShimmerSectionTitle();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: ShimmerCard(
        height: 16,
        width: 130,
        borderRadius: BorderRadius.circular(10.r),
      ),
    );
  }
}

class _ShimmerStatsGrid extends StatelessWidget {
  const _ShimmerStatsGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: 4,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
        childAspectRatio: 1.7,
      ),
      itemBuilder: (context, index) {
        return ShimmerCard(
          height: 110,
          borderRadius: BorderRadius.circular(18.r),
        );
      },
    );
  }
}

class _ShimmerBusinessCard extends StatelessWidget {
  const _ShimmerBusinessCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: Column(
        children: [
          const _ShimmerInfoRow(),
          SizedBox(height: 12.h),
          const _ShimmerInfoRow(),
          SizedBox(height: 12.h),
          const _ShimmerInfoRow(),
        ],
      ),
    );
  }
}

class _ShimmerAddressCard extends StatelessWidget {
  const _ShimmerAddressCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: Column(
        children: [
          const _ShimmerInfoRow(),
          SizedBox(height: 12.h),
          const _ShimmerInfoRow(),
        ],
      ),
    );
  }
}

class _ShimmerInfoRow extends StatelessWidget {
  const _ShimmerInfoRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ShimmerCard(
          height: 42,
          width: 42,
          borderRadius: BorderRadius.circular(12.r),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShimmerCard(
                height: 12,
                width: 90,
                borderRadius: BorderRadius.circular(10.r),
              ),
              SizedBox(height: 6.h),
              ShimmerCard(
                height: 16,
                width: double.infinity,
                borderRadius: BorderRadius.circular(10.r),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ShimmerWalletCard extends StatelessWidget {
  const _ShimmerWalletCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerCard(
            height: 12,
            width: 100,
            borderRadius: BorderRadius.circular(10.r),
          ),
          SizedBox(height: 8.h),
          ShimmerCard(
            height: 28,
            width: 140,
            borderRadius: BorderRadius.circular(10.r),
          ),
          SizedBox(height: 16.h),
          ShimmerCard(
            height: 1,
            width: double.infinity,
            borderRadius: BorderRadius.circular(2.r),
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: ShimmerCard(
                  height: 36,
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: ShimmerCard(
                  height: 36,
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          ShimmerCard(
            height: 8,
            width: double.infinity,
            borderRadius: BorderRadius.circular(8.r),
          ),
          SizedBox(height: 10.h),
          ShimmerCard(
            height: 12,
            width: 180,
            borderRadius: BorderRadius.circular(10.r),
          ),
        ],
      ),
    );
  }
}

class _ShimmerActionCard extends StatelessWidget {
  const _ShimmerActionCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: Row(
        children: [
          ShimmerCard(
            height: 42,
            width: 42,
            borderRadius: BorderRadius.circular(12.r),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerCard(
                  height: 14,
                  width: 100,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                SizedBox(height: 6.h),
                ShimmerCard(
                  height: 12,
                  width: 160,
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ],
            ),
          ),
          ShimmerCard(
            height: 20,
            width: 20,
            borderRadius: BorderRadius.circular(8.r),
          ),
        ],
      ),
    );
  }
}
