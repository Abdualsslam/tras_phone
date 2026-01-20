/// Education Favorites Screen - Saved educational content
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../data/services/favorites_service.dart';
import '../../domain/entities/educational_content_entity.dart';
import '../../domain/repositories/education_repository.dart';

class EducationFavoritesScreen extends StatefulWidget {
  const EducationFavoritesScreen({super.key});

  @override
  State<EducationFavoritesScreen> createState() =>
      _EducationFavoritesScreenState();
}

class _EducationFavoritesScreenState extends State<EducationFavoritesScreen> {
  final FavoritesService _favoritesService = getIt<FavoritesService>();
  final EducationRepository _repository = getIt<EducationRepository>();

  List<EducationalContentEntity> _favoriteContent = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final favoriteIds = await _favoritesService.getFavorites();

      // Load content for each favorite ID
      final List<EducationalContentEntity> content = [];
      for (final id in favoriteIds) {
        try {
          final item = await _repository.getContentById(id);
          if (item != null) {
            content.add(item);
          }
        } catch (e) {
          // Skip items that fail to load
          continue;
        }
      }

      setState(() {
        _favoriteContent = content;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _removeFavorite(String contentId) async {
    await _favoritesService.removeFavorite(contentId);
    await _loadFavorites();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم الإزالة من المفضلة'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _clearAllFavorites() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('مسح جميع المفضلة'),
        content: const Text('هل أنت متأكد من حذف جميع العناصر المفضلة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('حذف الكل'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _favoritesService.clearFavorites();
      await _loadFavorites();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم مسح جميع المفضلة'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('المفضلة'),
        actions: [
          if (_favoriteContent.isNotEmpty)
            IconButton(
              onPressed: _clearAllFavorites,
              icon: const Icon(Iconsax.trash),
              tooltip: 'مسح الكل',
            ),
        ],
      ),
      body: _buildBody(isDark),
    );
  }

  Widget _buildBody(bool isDark) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Iconsax.info_circle, size: 64.sp, color: Colors.red),
            SizedBox(height: 16.h),
            Text(
              'حدث خطأ في تحميل المفضلة',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8.h),
            Text(
              _error!,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            ElevatedButton.icon(
              onPressed: _loadFavorites,
              icon: const Icon(Iconsax.refresh),
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }

    if (_favoriteContent.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(32.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Iconsax.heart,
                size: 80.sp,
                color: AppColors.textSecondaryLight,
              ),
              SizedBox(height: 16.h),
              Text(
                'لا توجد مفضلة',
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8.h),
              Text(
                'ابدأ بإضافة محتوى إلى المفضلة لتجده هنا',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textSecondaryLight,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24.h),
              ElevatedButton.icon(
                onPressed: () => context.go('/education'),
                icon: const Icon(Iconsax.book),
                label: const Text('تصفح المحتوى'),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadFavorites,
      child: ListView.separated(
        padding: EdgeInsets.all(16.w),
        itemCount: _favoriteContent.length,
        separatorBuilder: (_, __) => SizedBox(height: 12.h),
        itemBuilder: (context, index) {
          final content = _favoriteContent[index];
          return _buildFavoriteCard(content, isDark);
        },
      ),
    );
  }

  Widget _buildFavoriteCard(EducationalContentEntity content, bool isDark) {
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

    return Dismissible(
      key: Key(content.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.only(left: 20.w),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Icon(Iconsax.trash, color: Colors.white, size: 24.sp),
      ),
      onDismissed: (_) => _removeFavorite(content.id),
      child: GestureDetector(
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
                    ? Icon(
                        content.type == ContentType.video
                            ? Iconsax.video
                            : Iconsax.document_text,
                        size: 32.sp,
                        color: getTypeColor(content.type),
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
                        color: getTypeColor(
                          content.type,
                        ).withValues(alpha: 0.1),
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
                    // Meta
                    Row(
                      children: [
                        Icon(
                          Iconsax.eye,
                          size: 12.sp,
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
                        SizedBox(width: 12.w),
                        Icon(
                          Iconsax.heart,
                          size: 12.sp,
                          color: AppColors.textSecondaryLight,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          '${content.likeCount}',
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
              Column(
                children: [
                  IconButton(
                    onPressed: () => _removeFavorite(content.id),
                    icon: const Icon(Iconsax.heart5),
                    color: Colors.red,
                    iconSize: 20.sp,
                  ),
                  Icon(
                    Iconsax.arrow_left_2,
                    size: 18.sp,
                    color: AppColors.textSecondaryLight,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
