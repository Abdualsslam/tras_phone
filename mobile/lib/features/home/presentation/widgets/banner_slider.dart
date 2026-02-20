import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!mounted || !widget.controller.hasClients) return;

      if (_lastUserInteraction != null &&
          DateTime.now().difference(_lastUserInteraction!) <
              const Duration(seconds: 4)) {
        return;
      }

      final bannerList = _getDisplayBanners();
      if (bannerList.length <= 1) return;

      final nextPage = (_currentPage + 1) % bannerList.length;
      widget.controller.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  void _stopAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = null;
  }

  List<BannerEntity> _getDisplayBanners() {
    final promotional = widget.banners
        .where((b) => b.type == BannerType.promotional)
        .toList();
    final hero = widget.banners
        .where((b) => b.type == BannerType.hero)
        .toList();
    return promotional.isNotEmpty ? promotional : hero;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final locale = Localizations.localeOf(context).languageCode;
    final isMobile = MediaQuery.of(context).size.width < 600;
    final bannerList = _getDisplayBanners();
    final itemCount = bannerList.length;

    return Column(
      children: [
        // Banner with rounded corners and margin
        Container(
          height: 180.h,
          margin: EdgeInsets.symmetric(horizontal: 16.w),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16.r),
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
                return BannerWidget(
                  key: ValueKey('banner_${bannerList[index].id}'),
                  banner: bannerList[index],
                  locale: locale,
                  isMobile: isMobile,
                );
              },
            ),
          ),
        ),
        if (itemCount > 1) ...[
          SizedBox(height: 12.h),
          // Modern pill indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(itemCount, (index) {
              final isActive = index == _currentPage;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                margin: EdgeInsets.symmetric(horizontal: 3.w),
                width: isActive ? 24.w : 8.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.primary
                      : (isDark ? AppColors.dividerDark : AppColors.dividerLight),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              );
            }),
          ),
        ],
      ],
    );
  }
}
