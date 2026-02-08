/// Wallet Shimmer - Loading placeholder for wallet screen
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../config/theme/app_colors.dart';
import '../widgets/loading/shimmer_widgets.dart';

/// Shimmer for wallet screen (balance card + quick actions + transactions)
class WalletShimmer extends StatelessWidget {
  const WalletShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          _ShimmerBalanceCard(),
          SizedBox(height: 24.h),
          _ShimmerQuickActions(),
          SizedBox(height: 24.h),
          _ShimmerTransactionHistory(),
        ],
      ),
    );
  }
}

class _ShimmerBalanceCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerCard(height: 20, width: 100),
          SizedBox(height: 16.h),
          ShimmerCard(height: 40, width: 150),
          SizedBox(height: 8.h),
          ShimmerCard(height: 14, width: 120),
        ],
      ),
    );
  }
}

class _ShimmerQuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ShimmerCard(
            height: 80,
            borderRadius: BorderRadius.circular(16.r),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: ShimmerCard(
            height: 80,
            borderRadius: BorderRadius.circular(16.r),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: ShimmerCard(
            height: 80,
            borderRadius: BorderRadius.circular(16.r),
          ),
        ),
      ],
    );
  }
}

class _ShimmerTransactionHistory extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShimmerCard(height: 20, width: 120),
        SizedBox(height: 16.h),
        ShimmerCard(
          height: 60,
          width: double.infinity,
          borderRadius: BorderRadius.circular(12.r),
        ),
        SizedBox(height: 8.h),
        ShimmerCard(
          height: 60,
          width: double.infinity,
          borderRadius: BorderRadius.circular(12.r),
        ),
        SizedBox(height: 8.h),
        ShimmerCard(
          height: 60,
          width: double.infinity,
          borderRadius: BorderRadius.circular(12.r),
        ),
      ],
    );
  }
}
