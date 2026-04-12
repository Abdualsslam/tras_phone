import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/config/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../education/domain/entities/educational_content_entity.dart';
import 'product_details_sections_header.dart';

class ProductEducationSection extends StatelessWidget {
  final List<EducationalContentEntity> relatedContent;
  final bool isLoading;
  final String? error;
  final bool hasMore;
  final VoidCallback onRetry;
  final VoidCallback onOpenAll;

  const ProductEducationSection({
    super.key,
    required this.relatedContent,
    required this.isLoading,
    required this.error,
    required this.hasMore,
    required this.onRetry,
    required this.onOpenAll,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizedProductLabel(
            context,
            ar: 'المحتوى التعليمي الخاص بهذا المنتج',
            en: 'Educational content for this product',
          ),
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 12.h),
        if (isLoading)
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : AppColors.cardLight,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          )
        else if (error != null)
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: AppColors.error.withValues(alpha: 0.25),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  error!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8.h),
                TextButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Iconsax.refresh),
                  label: Text(l10n.retryAction),
                ),
              ],
            ),
          )
        else if (relatedContent.isEmpty)
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : AppColors.cardLight,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localizedProductLabel(
                    context,
                    ar: 'لا يوجد محتوى تعليمي مرتبط بهذا المنتج حالياً',
                    en: 'No related educational content is available yet',
                  ),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondaryLight,
                  ),
                ),
                SizedBox(height: 10.h),
                FilledButton.tonalIcon(
                  onPressed: () => context.push('/education'),
                  icon: const Icon(Iconsax.book_1),
                  label: Text(l10n.education),
                ),
              ],
            ),
          )
        else
          Column(
            children: relatedContent
                .map(
                  (content) => Padding(
                    padding: EdgeInsets.only(bottom: 10.h),
                    child: _EducationalContentCard(content: content),
                  ),
                )
                .toList(),
          ),
        if (!isLoading && error == null && relatedContent.isNotEmpty) ...[
          SizedBox(height: 8.h),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onOpenAll,
              icon: Icon(
                hasMore ? Iconsax.arrow_left_2 : Iconsax.book,
                size: 18.sp,
              ),
              label: Text(
                localizedProductLabel(
                  context,
                  ar: 'عرض كل المحتوى التعليمي',
                  en: 'View all educational content',
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _EducationalContentCard extends StatelessWidget {
  final EducationalContentEntity content;

  const _EducationalContentCard({required this.content});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final locale = Localizations.localeOf(context).languageCode;

    return InkWell(
      borderRadius: BorderRadius.circular(12.r),
      onTap: () => context.push('/education/details/${content.slug}'),
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.cardLight,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowLight,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (content.featuredImage != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: CachedNetworkImage(
                  imageUrl: content.featuredImage!,
                  width: 72.w,
                  height: 72.h,
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) => Container(
                    width: 72.w,
                    height: 72.h,
                    color: AppColors.inputBackgroundLight,
                    child: Icon(
                      Iconsax.book,
                      size: 20.sp,
                      color: AppColors.textTertiaryLight,
                    ),
                  ),
                ),
              )
            else
              Container(
                width: 72.w,
                height: 72.h,
                decoration: BoxDecoration(
                  color: AppColors.inputBackgroundLight,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Iconsax.book,
                  size: 20.sp,
                  color: AppColors.textTertiaryLight,
                ),
              ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    content.getTitle(locale),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    content.type.getName(locale),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (content.getExcerpt(locale) != null)
                    Padding(
                      padding: EdgeInsets.only(top: 4.h),
                      child: Text(
                        content.getExcerpt(locale)!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Icon(
              Iconsax.arrow_left_2,
              size: 16.sp,
              color: AppColors.textTertiaryLight,
            ),
          ],
        ),
      ),
    );
  }
}
