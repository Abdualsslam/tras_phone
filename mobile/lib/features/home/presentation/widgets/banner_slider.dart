import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../../../banners/domain/entities/banner_entity.dart';
import '../../../banners/domain/enums/banner_type.dart';
import '../../../banners/presentation/widgets/banner_widget.dart';

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
    final locale = Localizations.localeOf(context).languageCode;
    final isMobile = MediaQuery.of(context).size.width < 600;

    // Filter banners by type
    final heroBanners = banners.where((b) => b.type == BannerType.hero).toList();
    final promotionalBanners =
        banners.where((b) => b.type == BannerType.promotional).toList();

    return Column(
      children: [
        SizedBox(
          height: 180.h,
          child: PageView.builder(
            controller: controller,
            itemCount: promotionalBanners.isNotEmpty
                ? promotionalBanners.length
                : heroBanners.length,
            itemBuilder: (context, index) {
              final bannerList =
                  promotionalBanners.isNotEmpty ? promotionalBanners : heroBanners;
              final banner = bannerList[index];

              // Use new BannerWidget for better functionality
              return BannerWidget(
                banner: banner,
                locale: locale,
                isMobile: isMobile,
              );
            },
          ),
        ),
        SizedBox(height: 12.h),
        SmoothPageIndicator(
          controller: controller,
          count: promotionalBanners.isNotEmpty
              ? promotionalBanners.length
              : heroBanners.length,
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
