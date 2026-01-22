/// Banner Widget
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/config/theme/app_theme.dart';
import '../../domain/entities/banner_entity.dart';
import '../cubit/banners_cubit.dart';
import '../helpers/banner_navigation_helper.dart';

class BannerWidget extends StatelessWidget {
  final BannerEntity banner;
  final String locale;
  final bool isMobile;
  final VoidCallback? onTap;

  const BannerWidget({
    super.key,
    required this.banner,
    required this.locale,
    required this.isMobile,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = banner.media.getImage(
      locale: locale,
      isMobile: isMobile,
    );

    return BlocProvider.value(
      value: context.read<BannersCubit>(),
      child: GestureDetector(
        onTap: () {
          if (banner.action.isClickable) {
            context.read<BannersCubit>().trackClick(banner.id);
            BannerNavigationHelper.handleBannerTap(context, banner);
            onTap?.call();
          }
        },
        child: _BannerContent(
          banner: banner,
          imageUrl: imageUrl,
          locale: locale,
        ),
      ),
    );
  }
}

class _BannerContent extends StatefulWidget {
  final BannerEntity banner;
  final String imageUrl;
  final String locale;

  const _BannerContent({
    required this.banner,
    required this.imageUrl,
    required this.locale,
  });

  @override
  State<_BannerContent> createState() => _BannerContentState();
}

class _BannerContentState extends State<_BannerContent> {
  bool _hasTrackedImpression = false;

  @override
  void initState() {
    super.initState();
    // Track impression when widget is first displayed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_hasTrackedImpression) {
        context.read<BannersCubit>().trackImpression(widget.banner.id);
        _hasTrackedImpression = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        borderRadius: AppTheme.radiusLg,
        boxShadow: AppTheme.shadowMd,
      ),
      child: ClipRRect(
        borderRadius: AppTheme.radiusLg,
        child: Stack(
          children: [
            // Banner Image
            Image.network(
              widget.imageUrl,
              width: double.infinity,
              height: 200.h,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 200.h,
                  color: Colors.grey.shade300,
                  child: const Icon(Icons.image, size: 64),
                );
              },
            ),

            // Overlay
            if (widget.banner.content.overlayColor != null)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: widget.banner.content
                        .getOverlayColor()
                        ?.withOpacity(
                          widget.banner.content.overlayOpacity ?? 0.3,
                        ),
                    borderRadius: AppTheme.radiusLg,
                  ),
                ),
              ),

            // Content
            if (widget.banner.content.getHeading(widget.locale) != null ||
                widget.banner.content.getSubheading(widget.locale) != null ||
                widget.banner.content.getButtonText(widget.locale) != null)
              Positioned.fill(
                child: Container(
                  padding: EdgeInsets.all(24.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.banner.content.getHeading(widget.locale) !=
                          null)
                        Text(
                          widget.banner.content.getHeading(widget.locale)!,
                          style: TextStyle(
                            fontSize: 28.sp,
                            fontWeight: FontWeight.bold,
                            color: widget.banner.content.getTextColor() ??
                                Colors.white,
                          ),
                        ),
                      if (widget.banner.content.getSubheading(widget.locale) !=
                          null) ...[
                        SizedBox(height: 8.h),
                        Text(
                          widget.banner.content.getSubheading(widget.locale)!,
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: widget.banner.content.getTextColor() ??
                                Colors.white,
                          ),
                        ),
                      ],
                      if (widget.banner.content.getButtonText(widget.locale) !=
                          null) ...[
                        SizedBox(height: 16.h),
                        ElevatedButton(
                          onPressed: () {
                            context
                                .read<BannersCubit>()
                                .trackClick(widget.banner.id);
                            BannerNavigationHelper.handleBannerTap(
                              context,
                              widget.banner,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.blue,
                          ),
                          child: Text(
                            widget.banner.content.getButtonText(widget.locale)!,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
