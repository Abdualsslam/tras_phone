/// Favorite Shimmer - Loading placeholder for favorites screen
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widgets/loading/shimmer_widgets.dart';

/// Shimmer for favorites screen (product cards in list)
class FavoriteShimmer extends StatelessWidget {
  const FavoriteShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.fromLTRB(16.w, 16.w, 16.w, 100.h),
      itemCount: 5,
      separatorBuilder: (context, index) => SizedBox(height: 12.h),
      itemBuilder: (context, index) => _ShimmerFavoriteCard(),
    );
  }
}

class _ShimmerFavoriteCard extends StatelessWidget {
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
          ShimmerCard(
            height: 40,
            width: 40,
            borderRadius: BorderRadius.circular(8.r),
          ),
        ],
      ),
    );
  }
}
