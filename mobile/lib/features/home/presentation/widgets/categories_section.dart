import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/cache/image_cache_config.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../catalog/domain/entities/category_entity.dart';
import 'package:iconsax/iconsax.dart';
import 'home_helpers.dart';
import 'section_header.dart';

class CategoriesSection extends StatelessWidget {
  final List<CategoryEntity> categories;

  const CategoriesSection({
    super.key,
    required this.categories,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        SectionHeader(
          title: AppLocalizations.of(context)!.categories,
          icon: Iconsax.category,
          onSeeAll: () => context.push('/categories'),
        ),
        SizedBox(height: 14.h),
        SizedBox(
          height: 100.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            itemCount: categories.length,
            separatorBuilder: (_, _) => SizedBox(width: 14.w),
            itemBuilder: (context, index) {
              final category = categories[index];
              return _CategoryChip(
                category: category,
                isDark: isDark,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final CategoryEntity category;
  final bool isDark;

  const _CategoryChip({
    required this.category,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/category/${category.id}'),
      child: SizedBox(
        width: 74.w,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon circle
            Container(
              width: 56.w,
              height: 56.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark
                    ? AppColors.cardDark
                    : Colors.white,
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  width: 1.5,
                ),
                boxShadow: [
                  if (!isDark)
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                ],
              ),
              child: ClipOval(
                child: category.image != null && category.image!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: category.image!,
                        cacheKey: imageCacheKey(category.image!),
                        cacheManager: imageCacheManager,
                        fit: BoxFit.cover,
                        width: 56.w,
                        height: 56.w,
                        placeholder: (_, _) => _buildIconFallback(),
                        errorWidget: (_, _, _) => _buildIconFallback(),
                      )
                    : _buildIconFallback(),
              ),
            ),
            SizedBox(height: 8.h),
            // Label
            Text(
              category.nameAr,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
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

  Widget _buildIconFallback() {
    return Container(
      color: AppColors.primary.withValues(alpha: 0.06),
      child: Center(
        child: Icon(
          HomeHelpers.getCategoryIcon(category.slug),
          size: 24.sp,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
