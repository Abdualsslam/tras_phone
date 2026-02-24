/// Education Details Screen - Article or video content
library;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/shimmer/index.dart';
import '../../../catalog/domain/entities/product_entity.dart';
import '../../../catalog/domain/repositories/catalog_repository.dart';
import '../../data/services/favorites_service.dart';
import '../../domain/entities/educational_content_entity.dart';
import '../cubit/education_details_cubit.dart';
import '../cubit/education_details_state.dart';
import '../widgets/video_player_widget.dart';
import '../widgets/html_content_widget.dart';

class EducationDetailsScreen extends StatelessWidget {
  final String contentId;

  const EducationDetailsScreen({super.key, required this.contentId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          getIt<EducationDetailsCubit>()..loadContent(contentId),
      child: const _EducationDetailsView(),
    );
  }
}

class _EducationDetailsView extends StatefulWidget {
  const _EducationDetailsView();

  @override
  State<_EducationDetailsView> createState() => _EducationDetailsViewState();
}

class _EducationDetailsViewState extends State<_EducationDetailsView> {
  final FavoritesService _favoritesService = getIt<FavoritesService>();
  final CatalogRepository _catalogRepository = getIt<CatalogRepository>();
  bool _isFavorite = false;
  String? _favoriteLoadedForContentId;
  String? _relatedProductsLoadedForContentId;
  bool _relatedProductsLoading = false;
  String? _relatedProductsError;
  List<ProductEntity> _relatedProducts = [];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocBuilder<EducationDetailsCubit, EducationDetailsState>(
      builder: (context, state) {
        if (state is EducationDetailsLoading) {
          return Scaffold(
            appBar: AppBar(),
            body: const EducationDetailsShimmer(),
          );
        }

        if (state is EducationDetailsError) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Iconsax.info_circle, size: 64.sp, color: Colors.red),
                  SizedBox(height: 16.h),
                  Text(
                    'حدث خطأ في تحميل المحتوى',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    state.message,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.textSecondaryLight,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 24.h),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Iconsax.arrow_right),
                    label: const Text('رجوع'),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is EducationDetailsLoaded) {
          final content = state.content;
          _scheduleContentSideEffects(content);

          final locale = 'ar'; // TODO: Get from localization

          return Scaffold(
            appBar: AppBar(
              title: Text(content.getTitle(locale)),
              actions: [
                IconButton(
                  onPressed: () => _toggleFavorite(content.id),
                  icon: Icon(
                    _isFavorite ? Iconsax.heart5 : Iconsax.heart,
                    size: 22.sp,
                    color: _isFavorite ? Colors.red : null,
                  ),
                ),
                IconButton(
                  onPressed: () => _shareContent(content),
                  icon: Icon(Iconsax.share, size: 22.sp),
                ),
              ],
            ),
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Video Player or Featured Image
                  if (content.videoUrl != null)
                    VideoPlayerWidget(videoUrl: content.videoUrl!)
                  else if (content.featuredImage != null)
                    Image.network(
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
                    ),

                  Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Meta Info
                        _buildMetaInfo(content, isDark),
                        SizedBox(height: 16.h),

                        // Title
                        Text(
                          content.getTitle(locale),
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 8.h),

                        // Excerpt
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

                        // Stats
                        _buildStats(content, context),
                        SizedBox(height: 24.h),

                        // Content
                        if (content.type == ContentType.article ||
                            content.type == ContentType.tutorial ||
                            content.type == ContentType.guide)
                          HtmlContentWidget(
                            htmlContent: content.getContentText(locale),
                          )
                        else
                          Text(
                            content.getContentText(locale),
                            style: TextStyle(fontSize: 15.sp, height: 1.8),
                          ),
                        SizedBox(height: 24.h),

                        // Tags
                        if (content.tags.isNotEmpty) ...[
                          Text(
                            'الوسوم',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 12.h),
                          Wrap(
                            spacing: 8.w,
                            runSpacing: 8.h,
                            children: content.tags.map((tag) {
                              return Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12.w,
                                  vertical: 6.h,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(20.r),
                                ),
                                child: Text(
                                  tag,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: AppColors.primary,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
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
                          if (_relatedProductsLoading)
                            const EducationRelatedProductsShimmer()
                          else if (_relatedProductsError != null)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _relatedProductsError!,
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    color: AppColors.error,
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                TextButton.icon(
                                  onPressed: () => _loadRelatedProducts(
                                    content.relatedProducts,
                                  ),
                                  icon: const Icon(Iconsax.refresh),
                                  label: const Text('إعادة المحاولة'),
                                ),
                              ],
                            )
                          else
                            _buildRelatedProductsSection(),
                          SizedBox(height: 24.h),
                        ],

                        // Related Content (placeholder)
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
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildMetaInfo(EducationalContentEntity content, bool isDark) {
    final locale = 'ar'; // TODO: Get from localization

    return Row(
      children: [
        // Type Badge
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6.r),
          ),
          child: Text(
            content.type.getName(locale),
            style: TextStyle(
              fontSize: 12.sp,
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        SizedBox(width: 8.w),

        // Difficulty Badge
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: content.difficulty.color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6.r),
          ),
          child: Text(
            content.difficulty.getName(locale),
            style: TextStyle(
              fontSize: 12.sp,
              color: content.difficulty.color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        SizedBox(width: 12.w),

        // Duration
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

  Widget _buildStats(EducationalContentEntity content, BuildContext context) {
    return Row(
      children: [
        _buildStatItem(
          icon: Iconsax.eye,
          value: content.viewCount,
          label: 'مشاهدة',
        ),
        SizedBox(width: 24.w),
        GestureDetector(
          onTap: () {
            _likeContent(content.id);
          },
          child: _buildStatItem(
            icon: Iconsax.heart,
            value: content.likeCount,
            label: 'إعجاب',
            isInteractive: true,
          ),
        ),
        SizedBox(width: 24.w),
        _buildStatItem(
          icon: Iconsax.share,
          value: content.shareCount,
          label: 'مشاركة',
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required int value,
    required String label,
    bool isInteractive = false,
  }) {
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

  void _scheduleContentSideEffects(EducationalContentEntity content) {
    if (_favoriteLoadedForContentId != content.id) {
      _favoriteLoadedForContentId = content.id;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        unawaited(_checkFavoriteStatus(content.id));
      });
    }

    if (_relatedProductsLoadedForContentId != content.id) {
      _relatedProductsLoadedForContentId = content.id;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        unawaited(_loadRelatedProducts(content.relatedProducts));
      });
    }
  }

  Future<void> _loadRelatedProducts(List<String> productIds) async {
    final normalizedIds = productIds
        .where((id) => id.trim().isNotEmpty)
        .map((id) => id.trim())
        .toSet()
        .take(6)
        .toList();

    if (normalizedIds.isEmpty) {
      if (!mounted) return;
      setState(() {
        _relatedProducts = [];
        _relatedProductsError = null;
        _relatedProductsLoading = false;
      });
      return;
    }

    setState(() {
      _relatedProductsLoading = true;
      _relatedProductsError = null;
    });

    try {
      final results = await Future.wait(
        normalizedIds.map((id) => _catalogRepository.getProduct(id)),
      );

      final products = <ProductEntity>[];
      for (final result in results) {
        result.fold((_) {}, (product) => products.add(product));
      }

      if (!mounted) return;
      setState(() {
        _relatedProducts = products;
        _relatedProductsLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _relatedProductsError = 'تعذر تحميل المنتجات المرتبطة';
        _relatedProductsLoading = false;
      });
    }
  }

  Widget _buildRelatedProductsSection() {
    if (_relatedProducts.isEmpty) {
      return Text(
        'لا توجد منتجات مرتبطة متاحة حاليا',
        style: TextStyle(fontSize: 13.sp, color: AppColors.textSecondaryLight),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _relatedProducts.length,
      separatorBuilder: (context, index) => SizedBox(height: 8.h),
      itemBuilder: (context, index) {
        final product = _relatedProducts[index];
        return InkWell(
          borderRadius: BorderRadius.circular(10.r),
          onTap: () => _openProduct(product),
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
                              _relatedProductFallback(),
                        )
                      : _relatedProductFallback(),
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

  Widget _relatedProductFallback() {
    return Container(
      width: 48.w,
      height: 48.h,
      color: AppColors.inputBackgroundLight,
      child: Icon(Iconsax.box, size: 16.sp, color: AppColors.textTertiaryLight),
    );
  }

  void _openProduct(ProductEntity product) {
    context.push('/product/${product.id}', extra: product);
  }

  Future<void> _likeContent(String contentId) async {
    final success = await context.read<EducationDetailsCubit>().likeContent(
      contentId,
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'تم تسجيل الإعجاب' : 'تعذر تسجيل الإعجاب'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _checkFavoriteStatus(String contentId) async {
    final isFav = await _favoritesService.isFavorite(contentId);
    if (mounted) {
      setState(() => _isFavorite = isFav);
    }
  }

  Future<void> _toggleFavorite(String contentId) async {
    try {
      await _favoritesService.toggleFavorite(contentId);
      await _checkFavoriteStatus(contentId);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isFavorite ? 'تمت الاضافة للمفضلة' : 'تمت الازالة من المفضلة',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تعذر تحديث المفضلة'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _shareContent(EducationalContentEntity content) async {
    final cubit = context.read<EducationDetailsCubit>();

    await Share.share(
      '${content.titleAr ?? content.title}\n\n${content.excerptAr ?? content.excerpt ?? ''}\n\nشاهد المزيد على تطبيق TRAS Phone',
      subject: content.titleAr ?? content.title,
    );

    final tracked = await cubit.shareContent(content.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          tracked ? 'تمت مشاركة المحتوى' : 'تمت المشاركة بدون تتبع',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
