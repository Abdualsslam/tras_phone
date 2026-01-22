import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../../../../core/config/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../catalog/domain/entities/banner_entity.dart';

class BannerSlider extends StatelessWidget {
  final List<BannerEntity> banners;
  final PageController controller;

  const BannerSlider({
    super.key,
    required this.banners,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        SizedBox(
          height: 180.h,
          child: PageView.builder(
            controller: controller,
            itemCount: banners.length,
            itemBuilder: (context, index) {
              final banner = banners[index];
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: GestureDetector(
                  onTap: () {
                    // Handle banner tap
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: AppTheme.radiusLg,
                      gradient: LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryDark],
                      ),
                      boxShadow: AppTheme.shadowMd,
                    ),
                    child: Stack(
                      children: [
                        // Background pattern
                        Positioned(
                          right: -30.w,
                          top: -30.h,
                          child: Container(
                            width: 150.w,
                            height: 150.w,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        // Content
                        Padding(
                          padding: EdgeInsets.all(24.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                banner.titleAr ?? banner.title,
                                style: TextStyle(
                                  fontSize: 24.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                banner.subtitleAr ?? banner.subtitle ?? '',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  color: Colors.white.withValues(alpha: 0.9),
                                ),
                              ),
                              SizedBox(height: 16.h),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16.w,
                                  vertical: 8.h,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: AppTheme.radiusSm,
                                ),
                                child: Text(
                                  AppLocalizations.of(context)!.shopNow,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(height: 12.h),
        SmoothPageIndicator(
          controller: controller,
          count: banners.length,
          effect: WormEffect(
            dotWidth: 8.w,
            dotHeight: 8.w,
            spacing: 6.w,
            activeDotColor: AppColors.primary,
            dotColor: isDark ? AppColors.dividerDark : AppColors.dividerLight,
          ),
        ),
      ],
    );
  }
}
