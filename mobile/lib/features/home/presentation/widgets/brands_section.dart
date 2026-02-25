import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/cache/image_cache_config.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../catalog/domain/entities/brand_entity.dart';
import 'section_header.dart';

class BrandsSection extends StatelessWidget {
  final List<BrandEntity> brands;

  const BrandsSection({super.key, required this.brands});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        SectionHeader(
          title: AppLocalizations.of(context)!.brands,
          icon: Iconsax.tag,
          onSeeAll: () => context.push('/brands'),
        ),
        SizedBox(height: 14.h),
        SizedBox(
          height: 115.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            itemCount: brands.length,
            separatorBuilder: (_, _) => SizedBox(width: 12.w),
            itemBuilder: (context, index) {
              final brand = brands[index];
              return _BrandCard(brand: brand, isDark: isDark);
            },
          ),
        ),
      ],
    );
  }
}

class _BrandCard extends StatelessWidget {
  final BrandEntity brand;
  final bool isDark;

  const _BrandCard({required this.brand, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final route = Uri(
          path: '/devices',
          queryParameters: {
            'flow': '1',
            'brandId': brand.id,
            'brandName': brand.nameAr,
          },
        ).toString();
        context.push(route);
      },
      child: SizedBox(
        width: 100.w,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100.w,
              height: 64.h,
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  width: 1.5,
                ),
                boxShadow: [
                  if (!isDark)
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.r),
                child: Padding(
                  padding: EdgeInsets.all(8.w),
                  child: brand.logo != null && brand.logo!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: brand.logo!,
                          cacheKey: imageCacheKey(brand.logo!),
                          cacheManager: imageCacheManager,
                          fit: BoxFit.contain,
                          placeholder: (_, _) => _buildFallback(),
                          errorWidget: (_, _, _) => _buildFallback(),
                        )
                      : _buildFallback(),
                ),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              brand.nameAr,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallback() {
    return Center(
      child: Icon(
        Iconsax.tag,
        size: 24.sp,
        color: AppColors.primary.withValues(alpha: 0.5),
      ),
    );
  }
}

