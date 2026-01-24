/// Popup Banner Widget
library;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/config/theme/app_theme.dart';
import '../../domain/entities/banner_entity.dart';
import '../cubit/banners_cubit.dart';
import '../helpers/banner_navigation_helper.dart';

class PopupBannerWidget extends StatelessWidget {
  final BannerEntity banner;
  final String locale;
  final bool isMobile;

  const PopupBannerWidget({
    super.key,
    required this.banner,
    required this.locale,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    if (!banner.isPopup) return const SizedBox();

    return BlocProvider.value(
      value: context.read<BannersCubit>(),
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: AppTheme.radiusLg,
        ),
        child: _PopupBannerContent(
          banner: banner,
          locale: locale,
          isMobile: isMobile,
        ),
      ),
    );
  }
}

class _PopupBannerContent extends StatefulWidget {
  final BannerEntity banner;
  final String locale;
  final bool isMobile;

  const _PopupBannerContent({
    required this.banner,
    required this.locale,
    required this.isMobile,
  });

  @override
  State<_PopupBannerContent> createState() => _PopupBannerContentState();
}

class _PopupBannerContentState extends State<_PopupBannerContent> {
  bool _hasTrackedImpression = false;

  @override
  void initState() {
    super.initState();
    // Track impression when popup is shown
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_hasTrackedImpression) {
        context.read<BannersCubit>().trackImpression(widget.banner.id);
        _hasTrackedImpression = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = widget.banner.media.getImage(
      locale: widget.locale,
      isMobile: widget.isMobile,
    );

    return Stack(
      children: [
        // Banner Image
        ClipRRect(
          borderRadius: AppTheme.radiusLg,
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              height: 300.h,
              color: Colors.grey.shade300,
              child: const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              ),
            ),
            errorWidget: (context, url, error) {
              return Container(
                height: 300.h,
                color: Colors.grey.shade300,
                child: const Icon(Icons.image, size: 64),
              );
            },
          ),
        ),

        // Close Button
        Positioned(
          top: 8.h,
          right: 8.w,
          child: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),

        // Content
        if (widget.banner.content.getHeading(widget.locale) != null ||
            widget.banner.content.getButtonText(widget.locale) != null)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.banner.content.getHeading(widget.locale) != null)
                    Text(
                      widget.banner.content.getHeading(widget.locale)!,
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  if (widget.banner.content.getButtonText(widget.locale) !=
                      null) ...[
                    SizedBox(height: 12.h),
                    ElevatedButton(
                      onPressed: () {
                        context
                            .read<BannersCubit>()
                            .trackClick(widget.banner.id);
                        Navigator.pop(context);
                        BannerNavigationHelper.handleBannerTap(
                          context,
                          widget.banner,
                        );
                      },
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
    );
  }
}
