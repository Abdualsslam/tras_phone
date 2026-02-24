/// Education Shimmer - Loading placeholder for education screens
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widgets/loading/shimmer_widgets.dart';

/// Shimmer for education favorites/list screens
class EducationListShimmer extends StatelessWidget {
  const EducationListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.all(16.w),
      itemCount: 5,
      separatorBuilder: (context, index) => SizedBox(height: 12.h),
      itemBuilder: (context, index) => const EducationListItemShimmer(),
    );
  }
}

/// Shimmer placeholder for a single education list row.
class EducationListItemShimmer extends StatelessWidget {
  const EducationListItemShimmer({super.key});

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
                ShimmerCard(height: 14, width: 120),
                SizedBox(height: 8.h),
                ShimmerCard(height: 12, width: 80),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Shimmer for education categories screen.
class EducationCategoriesShimmer extends StatelessWidget {
  const EducationCategoriesShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(16.w),
      children: [
        ShimmerCard(
          height: 150,
          borderRadius: BorderRadius.circular(16.r),
        ),
        SizedBox(height: 24.h),
        ShimmerCard(
          height: 20,
          width: 120,
          borderRadius: BorderRadius.circular(8.r),
        ),
        SizedBox(height: 12.h),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12.h,
            crossAxisSpacing: 12.w,
            childAspectRatio: 1.3,
          ),
          itemCount: 6,
          itemBuilder: (context, index) {
            return ShimmerCard(
              height: 130,
              borderRadius: BorderRadius.circular(12.r),
            );
          },
        ),
      ],
    );
  }
}

/// Shimmer for education details page.
class EducationDetailsShimmer extends StatelessWidget {
  const EducationDetailsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ShimmerCard(height: 220),
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ShimmerCard(
                      height: 24,
                      width: 80,
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    SizedBox(width: 8.w),
                    ShimmerCard(
                      height: 24,
                      width: 70,
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    SizedBox(width: 12.w),
                    ShimmerCard(
                      height: 14,
                      width: 90,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                ShimmerCard(
                  height: 24,
                  width: double.infinity,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                SizedBox(height: 10.h),
                ShimmerCard(
                  height: 14,
                  width: double.infinity,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                SizedBox(height: 6.h),
                ShimmerCard(
                  height: 14,
                  width: 220,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                SizedBox(height: 20.h),
                Row(
                  children: [
                    ShimmerCard(
                      height: 18,
                      width: 70,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    SizedBox(width: 20.w),
                    ShimmerCard(
                      height: 18,
                      width: 70,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    SizedBox(width: 20.w),
                    ShimmerCard(
                      height: 18,
                      width: 70,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ],
                ),
                SizedBox(height: 24.h),
                ...List.generate(
                  6,
                  (index) => Padding(
                    padding: EdgeInsets.only(bottom: 10.h),
                    child: ShimmerCard(
                      height: 14,
                      width: double.infinity,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                ),
                SizedBox(height: 14.h),
                ShimmerCard(
                  height: 18,
                  width: 110,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                SizedBox(height: 12.h),
                const EducationRelatedProductsShimmer(itemCount: 3),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Shimmer for related products list in education details.
class EducationRelatedProductsShimmer extends StatelessWidget {
  final int itemCount;

  const EducationRelatedProductsShimmer({
    super.key,
    this.itemCount = 2,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      separatorBuilder: (context, index) => SizedBox(height: 8.h),
      itemBuilder: (context, index) {
        return Container(
          padding: EdgeInsets.all(10.w),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Row(
            children: [
              ShimmerCard(
                height: 48,
                width: 48,
                borderRadius: BorderRadius.circular(8.r),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: ShimmerCard(
                  height: 14,
                  width: double.infinity,
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              SizedBox(width: 10.w),
              ShimmerCard(
                height: 16,
                width: 16,
                borderRadius: BorderRadius.circular(6.r),
              ),
            ],
          ),
        );
      },
    );
  }
}
