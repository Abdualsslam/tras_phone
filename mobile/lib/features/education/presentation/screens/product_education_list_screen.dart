/// Product Education List Screen - Educational content linked to product
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/shimmer/index.dart';
import '../../domain/entities/educational_content_entity.dart';
import '../../domain/repositories/education_repository.dart';

class ProductEducationListScreen extends StatefulWidget {
  final String productId;
  final String? productName;

  const ProductEducationListScreen({
    super.key,
    required this.productId,
    this.productName,
  });

  @override
  State<ProductEducationListScreen> createState() =>
      _ProductEducationListScreenState();
}

class _ProductEducationListScreenState
    extends State<ProductEducationListScreen> {
  final EducationRepository _repository = getIt<EducationRepository>();
  final ScrollController _scrollController = ScrollController();

  static const int _limit = 20;
  int _currentPage = 1;
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasLoadedOnce = false;
  bool _hasMore = false;
  String? _error;
  List<EducationalContentEntity> _content = [];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadInitial();
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_hasMore || _isLoadingMore || _isLoading) return;

    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      _loadMore();
    }
  }

  Future<void> _loadInitial() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _currentPage = 1;
      if (!_hasLoadedOnce) {
        _content = [];
      }
      _hasMore = false;
    });

    try {
      final result = await _repository.getProductEducationalContent(
        productId: widget.productId,
        page: 1,
        limit: _limit,
      );

      final content =
          (result['content'] as List<EducationalContentEntity>?) ??
          <EducationalContentEntity>[];
      final pagination =
          (result['pagination'] as Map<String, dynamic>?) ??
          <String, dynamic>{};

      final pages = (pagination['pages'] as num?)?.toInt() ?? 1;
      final currentPage = (pagination['page'] as num?)?.toInt() ?? 1;

      if (!mounted) return;
      setState(() {
        _content = content;
        _currentPage = currentPage;
        _hasMore = currentPage < pages;
        _hasLoadedOnce = true;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'تعذر تحميل المحتوى التعليمي';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMore() async {
    setState(() => _isLoadingMore = true);

    try {
      final nextPage = _currentPage + 1;
      final result = await _repository.getProductEducationalContent(
        productId: widget.productId,
        page: nextPage,
        limit: _limit,
      );

      final newContent =
          (result['content'] as List<EducationalContentEntity>?) ??
          <EducationalContentEntity>[];
      final pagination =
          (result['pagination'] as Map<String, dynamic>?) ??
          <String, dynamic>{};

      final pages = (pagination['pages'] as num?)?.toInt() ?? nextPage;
      final currentPage = (pagination['page'] as num?)?.toInt() ?? nextPage;

      if (!mounted) return;
      setState(() {
        _content = [..._content, ...newContent];
        _currentPage = currentPage;
        _hasMore = currentPage < pages;
        _isLoadingMore = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoadingMore = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تعذر تحميل المزيد، حاول مرة اخرى'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.productName?.isNotEmpty == true
              ? 'المحتوى التعليمي - ${widget.productName}'
              : 'المحتوى التعليمي الخاص بالمنتج',
        ),
      ),
      body: _buildBody(isDark),
    );
  }

  Widget _buildBody(bool isDark) {
    if (_isLoading && !_hasLoadedOnce) {
      return const EducationListShimmer();
    }

    if (_error != null && _content.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Iconsax.info_circle, size: 62.sp, color: AppColors.error),
            SizedBox(height: 12.h),
            Text(
              _error!,
              style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 12.h),
            OutlinedButton.icon(
              onPressed: _loadInitial,
              icon: const Icon(Iconsax.refresh),
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }

    if (_content.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Iconsax.book,
                size: 72.sp,
                color: AppColors.textSecondaryLight,
              ),
              SizedBox(height: 12.h),
              Text(
                'لا يوجد محتوى تعليمي مرتبط بهذا المنتج حاليا',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 14.h),
              FilledButton.icon(
                onPressed: () => context.push('/education'),
                icon: const Icon(Iconsax.book_1),
                label: const Text('استكشف المركز التعليمي'),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadInitial,
      child: ListView.separated(
        controller: _scrollController,
        padding: EdgeInsets.all(16.w),
        itemCount: _content.length + (_isLoadingMore ? 1 : 0),
        separatorBuilder: (context, index) => SizedBox(height: 10.h),
        itemBuilder: (context, index) {
          if (index >= _content.length) {
            return const EducationListItemShimmer();
          }

          final content = _content[index];
          return InkWell(
            borderRadius: BorderRadius.circular(12.r),
            onTap: () => context.push('/education/details/${content.slug}'),
            child: Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : AppColors.cardLight,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildThumbnail(content),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          content.getTitle('ar'),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          content.type.getName('ar'),
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (content.getExcerpt('ar') != null) ...[
                          SizedBox(height: 4.h),
                          Text(
                            content.getExcerpt('ar')!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ],
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
      ),
    );
  }

  Widget _buildThumbnail(EducationalContentEntity content) {
    if (content.featuredImage == null || content.featuredImage!.isEmpty) {
      return Container(
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
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8.r),
      child: Image.network(
        content.featuredImage!,
        width: 72.w,
        height: 72.h,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
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
    );
  }
}
