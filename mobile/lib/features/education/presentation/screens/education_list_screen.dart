/// Education List Screen - Articles list by category
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../domain/entities/educational_content_entity.dart';
import '../cubit/education_content_cubit.dart';
import '../cubit/education_content_state.dart';

class EducationListScreen extends StatelessWidget {
  final String categoryId;

  const EducationListScreen({super.key, required this.categoryId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<EducationContentCubit>()
        ..loadContent(categoryId: categoryId),
      child: _EducationListView(categoryId: categoryId),
    );
  }
}

class _EducationListView extends StatefulWidget {
  final String categoryId;

  const _EducationListView({required this.categoryId});

  @override
  State<_EducationListView> createState() => _EducationListViewState();
}

class _EducationListViewState extends State<_EducationListView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      context.read<EducationContentCubit>().loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('المحتوى التعليمي'),
        actions: [
          PopupMenuButton<ContentType?>(
            icon: const Icon(Iconsax.filter),
            onSelected: (type) {
              context.read<EducationContentCubit>().filterByType(type);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: null,
                child: Text('الكل'),
              ),
              const PopupMenuItem(
                value: ContentType.article,
                child: Text('مقالات'),
              ),
              const PopupMenuItem(
                value: ContentType.video,
                child: Text('فيديوهات'),
              ),
              const PopupMenuItem(
                value: ContentType.tutorial,
                child: Text('دروس'),
              ),
              const PopupMenuItem(
                value: ContentType.tip,
                child: Text('نصائح'),
              ),
              const PopupMenuItem(
                value: ContentType.guide,
                child: Text('أدلة'),
              ),
            ],
          ),
        ],
      ),
      body: BlocBuilder<EducationContentCubit, EducationContentState>(
        builder: (context, state) {
          if (state is EducationContentLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is EducationContentError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Iconsax.info_circle, size: 64.sp, color: Colors.red),
                  SizedBox(height: 16.h),
                  Text(
                    'حدث خطأ في تحميل البيانات',
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
                    onPressed: () => context.read<EducationContentCubit>().refresh(),
                    icon: const Icon(Iconsax.refresh),
                    label: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          }

          if (state is EducationContentLoaded) {
            final content = state.content;

            if (content.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Iconsax.document_text, size: 64.sp, color: AppColors.textSecondaryLight),
                    SizedBox(height: 16.h),
                    Text(
                      'لا يوجد محتوى متاح',
                      style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () => context.read<EducationContentCubit>().refresh(),
              child: ListView.separated(
                controller: _scrollController,
                padding: EdgeInsets.all(16.w),
                itemCount: content.length + (state.hasMore ? 1 : 0),
                separatorBuilder: (_, __) => SizedBox(height: 12.h),
                itemBuilder: (context, index) {
                  if (index >= content.length) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  return _buildArticleCard(content[index], isDark, context);
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildArticleCard(
    EducationalContentEntity content,
    bool isDark,
    BuildContext context,
  ) {
    final isVideo = content.type == ContentType.video;
    
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

    String getDuration() {
      if (content.videoDuration != null) {
        final minutes = (content.videoDuration! / 60).round();
        return '$minutes دقيقة';
      } else if (content.readingTime != null) {
        return '${content.readingTime} دقائق قراءة';
      }
      return '5 دقائق';
    }

    return GestureDetector(
      onTap: () => context.push('/education/details/${content.slug}'),
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.cardLight,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            // Thumbnail
            Container(
              width: 80.w,
              height: 80.w,
              decoration: BoxDecoration(
                color: getTypeColor(content.type).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10.r),
                image: content.featuredImage != null
                    ? DecorationImage(
                        image: NetworkImage(content.featuredImage!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: content.featuredImage == null
                  ? Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(
                          isVideo ? Iconsax.video : Iconsax.document_text,
                          size: 32.sp,
                          color: getTypeColor(content.type),
                        ),
                        if (isVideo)
                          Container(
                            padding: EdgeInsets.all(6.w),
                            decoration: BoxDecoration(
                              color: getTypeColor(content.type),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.play_arrow,
                              size: 16.sp,
                              color: Colors.white,
                            ),
                          ),
                      ],
                    )
                  : isVideo
                      ? Center(
                          child: Container(
                            padding: EdgeInsets.all(8.w),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.play_arrow,
                              size: 24.sp,
                              color: Colors.white,
                            ),
                          ),
                        )
                      : null,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Type Badge
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 2.h,
                    ),
                    decoration: BoxDecoration(
                      color: getTypeColor(content.type).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      getTypeLabel(content.type),
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: getTypeColor(content.type),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  SizedBox(height: 6.h),
                  // Title
                  Text(
                    content.titleAr ?? content.title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 6.h),
                  // Meta info
                  Row(
                    children: [
                      Icon(
                        Iconsax.clock,
                        size: 14.sp,
                        color: AppColors.textSecondaryLight,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        getDuration(),
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Icon(
                        Iconsax.eye,
                        size: 14.sp,
                        color: AppColors.textSecondaryLight,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        '${content.viewCount}',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(
              Iconsax.arrow_left_2,
              size: 18.sp,
              color: AppColors.textSecondaryLight,
            ),
          ],
        ),
      ),
    );
  }
}
