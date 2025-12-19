/// AppImage - Cached network image with placeholder and error handling
library;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import '../config/theme/app_colors.dart';

class AppImage extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Color? placeholderColor;
  final IconData? placeholderIcon;

  const AppImage({
    super.key,
    this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholderColor,
    this.placeholderIcon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor =
        placeholderColor ??
        (isDark ? AppColors.cardDark : AppColors.backgroundLight);

    Widget placeholder = Container(
      width: width?.w,
      height: height?.h,
      color: bgColor,
      child: Center(
        child: Icon(
          placeholderIcon ?? Iconsax.image,
          size: 24.sp,
          color: isDark
              ? AppColors.textTertiaryDark
              : AppColors.textTertiaryLight,
        ),
      ),
    );

    if (imageUrl == null || imageUrl!.isEmpty) {
      return ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.zero,
        child: placeholder,
      );
    }

    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: CachedNetworkImage(
        imageUrl: imageUrl!,
        width: width?.w,
        height: height?.h,
        fit: fit,
        placeholder: (context, url) => Container(
          width: width?.w,
          height: height?.h,
          color: bgColor,
          child: Center(
            child: SizedBox(
              width: 20.w,
              height: 20.w,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
            ),
          ),
        ),
        errorWidget: (context, url, error) => placeholder,
      ),
    );
  }
}

/// Avatar image with initials fallback
class AppAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? name;
  final double size;
  final Color? backgroundColor;

  const AppAvatar({
    super.key,
    this.imageUrl,
    this.name,
    this.size = 48,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return ClipOval(
        child: AppImage(
          imageUrl: imageUrl,
          width: size,
          height: size,
          fit: BoxFit.cover,
        ),
      );
    }

    // Show initials
    String initials = '';
    if (name != null && name!.isNotEmpty) {
      final words = name!.trim().split(' ');
      if (words.length >= 2) {
        initials = '${words[0][0]}${words[1][0]}'.toUpperCase();
      } else {
        initials = words[0][0].toUpperCase();
      }
    }

    return Container(
      width: size.w,
      height: size.w,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.primary.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            fontSize: (size / 2.5).sp,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textPrimaryDark : AppColors.primary,
          ),
        ),
      ),
    );
  }
}
