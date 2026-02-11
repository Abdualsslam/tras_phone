/// Rating Bar Row - Single row for star distribution (e.g. "5 ★ ████")
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/config/theme/app_colors.dart';

/// One row in the rating summary: star count, star icon, and progress bar.
class RatingBarRow extends StatelessWidget {
  final ThemeData theme;
  final int stars;
  final double percentage;

  const RatingBarRow({
    super.key,
    required this.theme,
    required this.stars,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    final pct = percentage.clamp(0.0, 1.0);
    return Row(
      children: [
        Text('$stars', style: theme.textTheme.bodySmall),
        SizedBox(width: 4.w),
        Icon(Iconsax.star5, size: 12.sp, color: Colors.amber),
        SizedBox(width: 8.w),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final w = constraints.maxWidth * pct;
              return Stack(
                alignment: Alignment.centerRight,
                children: [
                  Container(
                    height: 6.h,
                    decoration: BoxDecoration(
                      color: AppColors.dividerLight,
                      borderRadius: BorderRadius.circular(3.r),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    width: w,
                    height: 6.h,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(3.r),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
