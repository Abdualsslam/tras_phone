import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/config/theme/app_colors.dart';
import '../../../../core/shimmer/index.dart';
import '../../../catalog/domain/entities/product_entity.dart';
import '../../domain/entities/educational_content_entity.dart';
import 'html_content_widget.dart';
import 'video_player_widget.dart';

class EducationDetailsErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onBack;

  const EducationDetailsErrorState({
    super.key,
    required this.message,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.info_circle, size: 64.sp, color: Colors.red),
          SizedBox(height: 16.h),
          Text(
            'حدث خطأ في تحميل المحتوى',
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 8.h),
          Text(
            message,
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.textSecondaryLight,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          ElevatedButton.icon(
            onPressed: onBack,
            icon: const Icon(Iconsax.arrow_right),
            label: const Text('رجوع'),
          ),
        ],
      ),
    );
  }
}

class EducationDetailsContent extends StatelessWidget {
  final EducationalContentEntity content;
  final bool relatedProductsLoading;
  final String? relatedProductsError;
  final List<ProductEntity> relatedProducts;
  final VoidCallback onLikeTap;
  final VoidCallback onRetryRelatedProducts;
  final ValueChanged<ProductEntity> onRelatedProductTap;

  const EducationDetailsContent({
    super.key,
    required this.content,
    required this.relatedProductsLoading,
    required this.relatedProductsError,
    required this.relatedProducts,
    required this.onLikeTap,
    required this.onRetryRelatedProducts,
    required this.onRelatedProductTap,
  });

  @override
  Widget build(BuildContext context) {
    const locale = 'ar';

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EducationDetailsMediaHeader(content: content),
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                EducationDetailsMetaInfo(content: content),
                SizedBox(height: 16.h),
                Text(
                  content.getTitle(locale),
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 8.h),
                if (content.getExcerpt(locale) != null)
                  Text(
                    content.getExcerpt(locale)!,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.textSecondaryLight,
                      height: 1.5,
                    ),
                  ),
                SizedBox(height: 16.h),
                EducationDetailsStats(content: content, onLikeTap: onLikeTap),
                SizedBox(height: 24.h),
                EducationDetailsBody(content: content),
                SizedBox(height: 24.h),
                if (content.tags.isNotEmpty) ...[
                  EducationDetailsTags(tags: content.tags),
                  SizedBox(height: 24.h),
                ],
                if (content.relatedProducts.isNotEmpty) ...[
                  Text(
                    'منتجات مرتبطة',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  if (relatedProductsLoading)
                    const EducationRelatedProductsShimmer()
                  else if (relatedProductsError != null)
                    EducationRelatedProductsError(
                      message: relatedProductsError!,
                      onRetry: onRetryRelatedProducts,
                    )
                  else
                    EducationRelatedProductsList(
                      products: relatedProducts,
                      onProductTap: onRelatedProductTap,
                    ),
                  SizedBox(height: 24.h),
                ],
                if (content.relatedContent.isNotEmpty) ...[
                  Text(
                    'محتوى ذو صلة',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'سيتم عرض المحتوى المرتبط هنا',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class EducationDetailsMediaHeader extends StatelessWidget {
  final EducationalContentEntity content;

  const EducationDetailsMediaHeader({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    if (content.videoUrl != null) {
      return VideoPlayerWidget(videoUrl: content.videoUrl!);
    }

    if (content.featuredImage != null) {
      return Image.network(
        content.featuredImage!,
        width: double.infinity,
        height: 220.h,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          height: 220.h,
          color: AppColors.primary.withValues(alpha: 0.1),
          child: Icon(
            Iconsax.image,
            size: 60.sp,
            color: AppColors.primary.withValues(alpha: 0.3),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}

class EducationDetailsMetaInfo extends StatelessWidget {
  final EducationalContentEntity content;

  const EducationDetailsMetaInfo({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    const locale = 'ar';

    return Row(
      children: [
        _EducationBadge(
          label: content.type.getName(locale),
          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
          foregroundColor: AppColors.primary,
        ),
        SizedBox(width: 8.w),
        _EducationBadge(
          label: content.difficulty.getName(locale),
          backgroundColor: content.difficulty.color.withValues(alpha: 0.1),
          foregroundColor: content.difficulty.color,
        ),
        SizedBox(width: 12.w),
        Icon(Iconsax.clock, size: 14.sp, color: AppColors.textSecondaryLight),
        SizedBox(width: 4.w),
        Text(
          content.videoDurationFormatted ??
              (content.readingTimeFormatted.isNotEmpty
                  ? content.readingTimeFormatted
                  : '5 دقائق'),
          style: TextStyle(
            fontSize: 12.sp,
            color: AppColors.textSecondaryLight,
          ),
        ),
      ],
    );
  }
}

class EducationDetailsStats extends StatelessWidget {
  final EducationalContentEntity content;
  final VoidCallback onLikeTap;

  const EducationDetailsStats({
    super.key,
    required this.content,
    required this.onLikeTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        EducationStatItem(
          icon: Iconsax.eye,
          value: content.viewCount,
          label: 'مشاهدة',
          isInteractive: false,
        ),
        SizedBox(width: 24.w),
        GestureDetector(
          onTap: onLikeTap,
          child: EducationStatItem(
            icon: Iconsax.heart,
            value: content.likeCount,
            label: 'إعجاب',
            isInteractive: true,
          ),
        ),
        SizedBox(width: 24.w),
        EducationStatItem(
          icon: Iconsax.share,
          value: content.shareCount,
          label: 'مشاركة',
          isInteractive: false,
        ),
      ],
    );
  }
}

class EducationStatItem extends StatelessWidget {
  final IconData icon;
  final int value;
  final String label;
  final bool isInteractive;

  const EducationStatItem({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    required this.isInteractive,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18.sp,
          color: isInteractive
              ? AppColors.primary
              : AppColors.textSecondaryLight,
        ),
        SizedBox(width: 4.w),
        Text(
          '$value',
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
        ),
        SizedBox(width: 4.w),
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: AppColors.textSecondaryLight,
          ),
        ),
      ],
    );
  }
}

class EducationDetailsBody extends StatelessWidget {
  final EducationalContentEntity content;

  const EducationDetailsBody({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    const locale = 'ar';

    if (content.type == ContentType.article ||
        content.type == ContentType.tutorial ||
        content.type == ContentType.guide) {
      return HtmlContentWidget(htmlContent: content.getContentText(locale));
    }

    return Text(
      content.getContentText(locale),
      style: TextStyle(fontSize: 15.sp, height: 1.8),
    );
  }
}

class EducationDetailsTags extends StatelessWidget {
  final List<String> tags;

  const EducationDetailsTags({super.key, required this.tags});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الوسوم',
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 12.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: tags.map((tag) => EducationTagChip(tag: tag)).toList(),
        ),
      ],
    );
  }
}

class EducationTagChip extends StatelessWidget {
  final String tag;

  const EducationTagChip({super.key, required this.tag});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        tag,
        style: TextStyle(fontSize: 12.sp, color: AppColors.primary),
      ),
    );
  }
}

class EducationRelatedProductsError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const EducationRelatedProductsError({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          message,
          style: TextStyle(fontSize: 13.sp, color: AppColors.error),
        ),
        SizedBox(height: 8.h),
        TextButton.icon(
          onPressed: onRetry,
          icon: const Icon(Iconsax.refresh),
          label: const Text('إعادة المحاولة'),
        ),
      ],
    );
  }
}

class EducationRelatedProductsList extends StatelessWidget {
  final List<ProductEntity> products;
  final ValueChanged<ProductEntity> onProductTap;

  const EducationRelatedProductsList({
    super.key,
    required this.products,
    required this.onProductTap,
  });

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return Text(
        'لا توجد منتجات مرتبطة متاحة حالياً',
        style: TextStyle(fontSize: 13.sp, color: AppColors.textSecondaryLight),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: products.length,
      separatorBuilder: (context, index) => SizedBox(height: 8.h),
      itemBuilder: (context, index) {
        final product = products[index];
        return InkWell(
          borderRadius: BorderRadius.circular(10.r),
          onTap: () => onProductTap(product),
          child: Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: product.imageUrl != null
                      ? Image.network(
                          product.imageUrl!,
                          width: 48.w,
                          height: 48.h,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const EducationRelatedProductFallback(),
                        )
                      : const EducationRelatedProductFallback(),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    product.getName('ar'),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Icon(
                  Iconsax.arrow_left_2,
                  size: 16.sp,
                  color: AppColors.textSecondaryLight,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class EducationRelatedProductFallback extends StatelessWidget {
  const EducationRelatedProductFallback({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48.w,
      height: 48.h,
      color: AppColors.inputBackgroundLight,
      child: Icon(Iconsax.box, size: 16.sp, color: AppColors.textTertiaryLight),
    );
  }
}

class _EducationBadge extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color foregroundColor;

  const _EducationBadge({
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12.sp,
          color: foregroundColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
