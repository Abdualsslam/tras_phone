/// Shimmer Base - Shared components for page shimmers
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widgets/loading/shimmer_widgets.dart';

/// Shimmer section header - mimics SectionHeader with title and "View All"
class ShimmerSectionHeader extends StatelessWidget {
  const ShimmerSectionHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          Expanded(
            child: ShimmerCard(height: 20, width: 140),
          ),
          ShimmerCard(
            height: 16,
            width: 60,
            borderRadius: BorderRadius.circular(4.r),
          ),
        ],
      ),
    );
  }
}
