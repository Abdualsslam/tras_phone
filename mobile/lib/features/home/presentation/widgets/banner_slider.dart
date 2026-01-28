import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../../../banners/domain/entities/banner_entity.dart';
import '../../../banners/domain/enums/banner_type.dart';
import '../../../banners/presentation/widgets/banner_widget.dart';

class BannerSlider extends StatefulWidget {
  final List<BannerEntity> banners;
  final PageController controller;

  const BannerSlider({
    super.key,
    required this.banners,
    required this.controller,
  });

  @override
  State<BannerSlider> createState() => _BannerSliderState();
}

class _BannerSliderState extends State<BannerSlider> {
  Timer? _autoScrollTimer;
  int _currentPage = 0;
  DateTime? _lastUserInteraction;

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  @override
  void dispose() {
    _stopAutoScroll();
    super.dispose();
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (!mounted || !widget.controller.hasClients) {
        return;
      }

      // Don't auto-scroll if user interacted recently (within last 3 seconds)
      if (_lastUserInteraction != null &&
          DateTime.now().difference(_lastUserInteraction!) <
              const Duration(seconds: 3)) {
        return;
      }

      final heroBanners = widget.banners
          .where((b) => b.type == BannerType.hero)
          .toList();
      final promotionalBanners = widget.banners
          .where((b) => b.type == BannerType.promotional)
          .toList();

      final itemCount = promotionalBanners.isNotEmpty
          ? promotionalBanners.length
          : heroBanners.length;

      if (itemCount <= 1) return; // No need to scroll if only one item

      final nextPage = (_currentPage + 1) % itemCount;
      widget.controller.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  void _stopAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = null;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final locale = Localizations.localeOf(context).languageCode;
    final isMobile = MediaQuery.of(context).size.width < 600;

    // Filter banners by type
    final heroBanners = widget.banners
        .where((b) => b.type == BannerType.hero)
        .toList();
    final promotionalBanners = widget.banners
        .where((b) => b.type == BannerType.promotional)
        .toList();

    final bannerList = promotionalBanners.isNotEmpty
        ? promotionalBanners
        : heroBanners;
    final itemCount = bannerList.length;

    return Column(
      children: [
        SizedBox(
          height: 180.h,
          child: PageView.builder(
            controller: widget.controller,
            itemCount: itemCount,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
                _lastUserInteraction = DateTime.now();
              });
            },
            itemBuilder: (context, index) {
              final banner = bannerList[index];

              // Use new BannerWidget for better functionality
              return BannerWidget(
                key: ValueKey('banner_${banner.id}'),
                banner: banner,
                locale: locale,
                isMobile: isMobile,
              );
            },
          ),
        ),
        SizedBox(height: 12.h),
        if (itemCount > 1)
          SmoothPageIndicator(
            controller: widget.controller,
            count: itemCount,
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
