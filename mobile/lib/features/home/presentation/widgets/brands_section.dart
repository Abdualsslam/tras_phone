import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../catalog/domain/entities/brand_entity.dart';
import 'home_helpers.dart';
import 'section_header.dart';

class BrandsSection extends StatelessWidget {
  final List<BrandEntity> brands;

  const BrandsSection({
    super.key,
    required this.brands,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        SectionHeader(
          title: AppLocalizations.of(context)!.brands,
          onSeeAll: () => context.push('/brands'),
        ),
        SizedBox(height: 12.h),
        SizedBox(
          height: 55.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            itemCount: brands.length,
            separatorBuilder: (_, __) => SizedBox(width: 12.w),
            itemBuilder: (context, index) {
              final brand = brands[index];
              return GestureDetector(
                onTap: () => context.push('/brand/${brand.slug}'),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14.r),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 22.w,
                        vertical: 10.h,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: isDark
                              ? [
                                  Colors.white.withValues(alpha: 0.1),
                                  Colors.white.withValues(alpha: 0.05),
                                ]
                              : [
                                  Colors.white.withValues(alpha: 0.9),
                                  Colors.white.withValues(alpha: 0.7),
                                ],
                        ),
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.12)
                              : AppColors.primary.withValues(alpha: 0.12),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: HomeHelpers.getBrandLogo(brand.slug) != null
                            ? SvgPicture.asset(
                                HomeHelpers.getBrandLogo(brand.slug)!,
                                width: 80.w,
                                height: 30.h,
                                colorFilter: ColorFilter.mode(
                                  isDark
                                      ? AppColors.textPrimaryDark
                                      : AppColors.textPrimaryLight,
                                  BlendMode.srcIn,
                                ),
                              )
                            : Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 28.w,
                                    height: 28.w,
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withValues(
                                        alpha: 0.1,
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Iconsax.tag,
                                      size: 14.sp,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  SizedBox(width: 10.w),
                                  Text(
                                    brand.nameAr,
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w600,
                                      color: isDark
                                          ? AppColors.textPrimaryDark
                                          : AppColors.textPrimaryLight,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
