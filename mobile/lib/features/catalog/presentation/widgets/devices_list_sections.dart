import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../../../../core/config/theme/app_theme.dart';
import '../../domain/entities/brand_entity.dart';
import '../../domain/entities/device_entity.dart';

class DevicesSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final bool isDark;
  final ValueChanged<String> onChanged;

  const DevicesSearchBar({
    super.key,
    required this.controller,
    required this.isDark,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: 'ابحث عن جهاز...',
          prefixIcon: Icon(Iconsax.search_normal, size: 20.sp),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: isDark ? AppColors.cardDark : AppColors.backgroundLight,
        ),
      ),
    );
  }
}

class DevicesBrandFilterBar extends StatelessWidget {
  final List<BrandEntity> brands;
  final String? selectedBrandId;
  final bool isDark;
  final ValueChanged<BrandEntity> onBrandSelected;

  const DevicesBrandFilterBar({
    super.key,
    required this.brands,
    required this.selectedBrandId,
    required this.isDark,
    required this.onBrandSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: brands.length,
        separatorBuilder: (_, _) => SizedBox(width: 8.w),
        itemBuilder: (context, index) {
          final brand = brands[index];
          final isSelected = selectedBrandId == brand.id;

          return GestureDetector(
            onTap: () => onBrandSelected(brand),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary
                    : (isDark ? AppColors.cardDark : AppColors.backgroundLight),
                borderRadius: BorderRadius.circular(25.r),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : (isDark
                            ? AppColors.dividerDark
                            : AppColors.dividerLight),
                ),
              ),
              child: Center(
                child: Text(
                  brand.nameAr,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: isSelected
                        ? Colors.white
                        : (isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class DevicesListContent extends StatelessWidget {
  final List<DeviceEntity> devices;
  final bool isDark;
  final ValueChanged<DeviceEntity> onDeviceTap;

  const DevicesListContent({
    super.key,
    required this.devices,
    required this.isDark,
    required this.onDeviceTap,
  });

  @override
  Widget build(BuildContext context) {
    if (devices.isEmpty) {
      return DevicesEmptyState(isDark: isDark);
    }

    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: devices.length,
      itemBuilder: (context, index) {
        return DeviceListCard(
          device: devices[index],
          isDark: isDark,
          onTap: () => onDeviceTap(devices[index]),
        );
      },
    );
  }
}

class DeviceListCard extends StatelessWidget {
  final DeviceEntity device;
  final bool isDark;
  final VoidCallback onTap;

  const DeviceListCard({
    super.key,
    required this.device,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.cardLight,
          borderRadius: AppTheme.radiusMd,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            DeviceThumbnail(imagePath: device.image),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    device.nameAr,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                  if (device.modelNumber case final modelNumber?)
                    Text(
                      modelNumber,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                ],
              ),
            ),
            if (device.productsCount > 0)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  '${device.productsCount}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            SizedBox(width: 8.w),
            Icon(
              Iconsax.arrow_left_2,
              size: 18.sp,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ],
        ),
      ),
    );
  }
}

class DeviceThumbnail extends StatelessWidget {
  final String? imagePath;

  const DeviceThumbnail({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    final imageUrl = _resolveDeviceImageUrl(imagePath);

    if (imageUrl == null || imageUrl.isEmpty) {
      return const DeviceThumbnailPlaceholder();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12.r),
      child: Image.network(
        imageUrl,
        width: 48.w,
        height: 48.w,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => const DeviceThumbnailPlaceholder(),
      ),
    );
  }

  String? _resolveDeviceImageUrl(String? rawImage) {
    if (rawImage == null || rawImage.trim().isEmpty) return null;

    final value = rawImage.trim();
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }

    final base = Uri.parse(AppConfig.baseUrl);
    final host =
        '${base.scheme}://${base.host}${base.hasPort ? ':${base.port}' : ''}';
    if (value.startsWith('/')) {
      return '$host$value';
    }

    return '$host/$value';
  }
}

class DeviceThumbnailPlaceholder extends StatelessWidget {
  const DeviceThumbnailPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48.w,
      height: 48.w,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Icon(Iconsax.mobile, size: 24.sp, color: AppColors.primary),
    );
  }
}

class DevicesEmptyState extends StatelessWidget {
  final bool isDark;

  const DevicesEmptyState({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Iconsax.mobile,
            size: 80.sp,
            color: isDark
                ? AppColors.textTertiaryDark
                : AppColors.textTertiaryLight,
          ),
          SizedBox(height: 16.h),
          Text(
            'لا توجد أجهزة',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
        ],
      ),
    );
  }
}
