/// Education Details Screen - Article or video content
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../../../../core/di/injection.dart';
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
      create: (context) => getIt<EducationDetailsCubit>()..loadContent(contentId),
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
  bool _isFavorite = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocBuilder<EducationDetailsCubit, EducationDetailsState>(
      builder: (context, state) {
        if (state is EducationDetailsLoading) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: CircularProgressIndicator()),
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
                    style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    state.message,
                    style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondaryLight),
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
          _checkFavoriteStatus(content.id);

          return Scaffold(
            appBar: AppBar(
              title: Text(content.titleAr ?? content.title),
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
                      errorBuilder: (_, __, ___) => Container(
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
                          content.titleAr ?? content.title,
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 8.h),

                        // Excerpt
                        if (content.excerpt != null || content.excerptAr != null)
                          Text(
                            content.excerptAr ?? content.excerpt!,
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
                            htmlContent: content.contentAr ?? content.content,
                          )
                        else
                          Text(
                            content.contentAr ?? content.content,
                            style: TextStyle(
                              fontSize: 15.sp,
                              height: 1.8,
                            ),
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
                                  color: AppColors.primary.withValues(alpha: 0.1),
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
    String getTypeLabel(ContentType type) {
      switch (type) {
        case ContentType.article:
          return 'مقال';
        case ContentType.video:
          return 'فيديو';
        case ContentType.tutorial:
          return 'درس';
        case ContentType.tip:
          return 'نصيحة';
        case ContentType.guide:
          return 'دليل';
      }
    }

    Color getTypeColor(ContentType type) {
      switch (type) {
        case ContentType.video:
          return AppColors.error;
        case ContentType.tutorial:
          return AppColors.warning;
        case ContentType.tip:
          return AppColors.success;
        default:
          return AppColors.info;
      }
    }

    String getDifficultyLabel(ContentDifficulty difficulty) {
      switch (difficulty) {
        case ContentDifficulty.beginner:
          return 'مبتدئ';
        case ContentDifficulty.intermediate:
          return 'متوسط';
        case ContentDifficulty.advanced:
          return 'متقدم';
      }
    }

    return Row(
      children: [
        // Type Badge
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: getTypeColor(content.type).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6.r),
          ),
          child: Text(
            getTypeLabel(content.type),
            style: TextStyle(
              fontSize: 12.sp,
              color: getTypeColor(content.type),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        SizedBox(width: 8.w),

        // Difficulty Badge
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: AppColors.textSecondaryLight.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6.r),
          ),
          child: Text(
            getDifficultyLabel(content.difficulty),
            style: TextStyle(
              fontSize: 12.sp,
              color: AppColors.textSecondaryLight,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        SizedBox(width: 12.w),

        // Duration
        Icon(Iconsax.clock, size: 14.sp, color: AppColors.textSecondaryLight),
        SizedBox(width: 4.w),
        Text(
          content.videoDuration != null
              ? '${(content.videoDuration! / 60).round()} دقيقة'
              : content.readingTime != null
                  ? '${content.readingTime} دقائق قراءة'
                  : '5 دقائق',
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
            context.read<EducationDetailsCubit>().likeContent(content.id);
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
          color: isInteractive ? AppColors.primary : AppColors.textSecondaryLight,
        ),
        SizedBox(width: 4.w),
        Text(
          '$value',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
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

  Future<void> _checkFavoriteStatus(String contentId) async {
    final isFav = await _favoritesService.isFavorite(contentId);
    if (mounted) {
      setState(() => _isFavorite = isFav);
    }
  }

  Future<void> _toggleFavorite(String contentId) async {
    await _favoritesService.toggleFavorite(contentId);
    await _checkFavoriteStatus(contentId);
  }

  Future<void> _shareContent(EducationalContentEntity content) async {
    final cubit = context.read<EducationDetailsCubit>();
    
    await Share.share(
      '${content.titleAr ?? content.title}\n\n${content.excerptAr ?? content.excerpt ?? ''}\n\nشاهد المزيد على تطبيق TRAS Phone',
      subject: content.titleAr ?? content.title,
    );
    
    // Track share
    cubit.shareContent(content.id);
  }
}
