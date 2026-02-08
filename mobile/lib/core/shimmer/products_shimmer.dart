/// Products Shimmer - Loading placeholder for product list screens
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../config/theme/app_colors.dart';
import '../widgets/loading/shimmer_widgets.dart';

/// Shimmer for products list/grid screens (products_list, category_products, device_products, product_search_results)
class ProductsGridShimmer extends StatelessWidget {
  const ProductsGridShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        _ShimmerSortBar(isDark: isDark),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12.h,
                    crossAxisSpacing: 12.w,
                    childAspectRatio: 0.60,
                  ),
                  itemCount: 6,
                  itemBuilder: (context, index) => const ShimmerProductCard(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ShimmerSortBar extends StatelessWidget {
  final bool isDark;

  const _ShimmerSortBar({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
          ),
        ),
      ),
      child: Row(
        children: [
          ShimmerCard(height: 16, width: 70),
          const Spacer(),
          ShimmerCard(
            height: 28,
            width: 90,
            borderRadius: BorderRadius.circular(8.r),
          ),
          SizedBox(width: 8.w),
          ShimmerCard(
            height: 36,
            width: 36,
            borderRadius: BorderRadius.circular(8.r),
          ),
        ],
      ),
    );
  }
}
