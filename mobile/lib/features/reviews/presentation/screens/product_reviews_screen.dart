/// Product Reviews Screen - Show reviews for a product
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../../catalog/domain/repositories/catalog_repository.dart';
import '../../../catalog/data/models/product_review_model.dart';
import '../../../../l10n/app_localizations.dart';

class ProductReviewsScreen extends StatefulWidget {
  final String productId;
  final String? productName;
  final double? averageRating;
  final int? reviewsCount;

  const ProductReviewsScreen({
    super.key,
    required this.productId,
    this.productName,
    this.averageRating,
    this.reviewsCount,
  });

  @override
  State<ProductReviewsScreen> createState() => _ProductReviewsScreenState();
}

class _ProductReviewsScreenState extends State<ProductReviewsScreen> {
  final _catalogRepository = getIt<CatalogRepository>();

  List<ProductReviewModel> _reviews = [];
  bool _isLoading = true;
  String? _error;
  double? _averageRating;
  int _reviewsCount = 0;

  @override
  void initState() {
    super.initState();
    _averageRating = widget.averageRating;
    _reviewsCount = widget.reviewsCount ?? 0;
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final result = await _catalogRepository.getProductReviews(widget.productId);

    result.fold(
      (failure) => setState(() {
        _isLoading = false;
        _error = failure.message;
        _reviews = [];
      }),
      (reviews) => setState(() {
        _isLoading = false;
        _reviews = reviews;
        if (_averageRating == null && reviews.isNotEmpty) {
          _averageRating = reviews
                  .map((r) => r.rating)
                  .reduce((a, b) => a + b) /
              reviews.length;
        }
        if (_reviewsCount == 0) _reviewsCount = reviews.length;
      }),
    );
  }

  Future<void> _onAddReviewPressed() async {
    final added = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddReviewBottomSheet(
        productId: widget.productId,
        productName: widget.productName ?? 'المنتج',
      ),
    );
    if (added == true && mounted) {
      _loadReviews();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.reviews),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildError(theme, isDark)
              : Column(
                  children: [
                    _buildRatingSummary(theme, isDark),
                    Divider(height: 1, color: AppColors.dividerLight),
                    Expanded(
                      child: _reviews.isEmpty
                          ? _buildEmptyState(theme, isDark)
                          : RefreshIndicator(
                              onRefresh: _loadReviews,
                              child: ListView.separated(
                                padding: EdgeInsets.all(16.w),
                                itemCount: _reviews.length,
                                separatorBuilder: (_, __) =>
                                    SizedBox(height: 16.h),
                                itemBuilder: (context, index) {
                                  return _buildReviewCard(
                                    theme,
                                    isDark,
                                    _reviews[index],
                                  );
                                },
                              ),
                            ),
                    ),
                  ],
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _onAddReviewPressed,
        icon: const Icon(Iconsax.edit),
        label: const Text('أضف تقييم'),
      ),
    );
  }

  Widget _buildError(ThemeData theme, bool isDark) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Iconsax.warning_2,
              size: 64.sp,
              color: AppColors.error,
            ),
            SizedBox(height: 16.h),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge,
            ),
            SizedBox(height: 24.h),
            FilledButton(
              onPressed: _loadReviews,
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, bool isDark) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Iconsax.message_question,
              size: 64.sp,
              color: AppColors.textTertiaryLight,
            ),
            SizedBox(height: 16.h),
            Text(
              'لا توجد تقييمات بعد',
              style: theme.textTheme.titleMedium,
            ),
            SizedBox(height: 8.h),
            Text(
              'كن أول من يقيم هذا المنتج',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textTertiaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingSummary(ThemeData theme, bool isDark) {
    final avg = _averageRating ?? 0.0;

    return Container(
      padding: EdgeInsets.all(20.w),
      color: isDark ? AppColors.cardDark : AppColors.cardLight,
      child: Row(
        children: [
          Column(
            children: [
              Text(
                avg.toStringAsFixed(1),
                style: TextStyle(
                  fontSize: 48.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < avg.floor() ? Iconsax.star5 : Iconsax.star,
                    size: 16.sp,
                    color: Colors.amber,
                  );
                }),
              ),
              SizedBox(height: 4.h),
              Text(
                '$_reviewsCount تقييم',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textTertiaryLight,
                ),
              ),
            ],
          ),
          SizedBox(width: 32.w),
          Expanded(
            child: _reviews.isEmpty
                ? const SizedBox.shrink()
                : Column(
                    children: List.generate(5, (i) {
                      final star = 5 - i;
                      final count =
                          _reviews.where((r) => r.rating == star).length;
                      final pct = _reviews.isEmpty
                          ? 0.0
                          : count / _reviews.length;
                      return Padding(
                        padding: EdgeInsets.only(bottom: 6.h),
                        child: _buildRatingBar(theme, star, pct),
                      );
                    }),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingBar(ThemeData theme, int stars, double percentage) {
    return Row(
      children: [
        Text('$stars', style: theme.textTheme.bodySmall),
        SizedBox(width: 4.w),
        Icon(Iconsax.star5, size: 12.sp, color: Colors.amber),
        SizedBox(width: 8.w),
        Expanded(
          child: Container(
            height: 6.h,
            decoration: BoxDecoration(
              color: AppColors.dividerLight,
              borderRadius: BorderRadius.circular(3.r),
            ),
            child: FractionallySizedBox(
              widthFactor: percentage.clamp(0.0, 1.0),
              alignment: Alignment.centerRight,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(3.r),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewCard(
    ThemeData theme,
    bool isDark,
    ProductReviewModel review,
  ) {
    final displayName = review.customerName ?? review.customerShopName ?? 'مستخدم';
    final subTitle = review.customerShopName != null && review.customerName != null
        ? review.customerShopName
        : null;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20.r,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: Text(
                  displayName.isNotEmpty ? displayName[0] : '?',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            displayName,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (review.isVerifiedPurchase) ...[
                          SizedBox(width: 8.w),
                          Icon(
                            Iconsax.verify5,
                            size: 16.sp,
                            color: AppColors.success,
                          ),
                        ],
                      ],
                    ),
                    if (subTitle != null)
                      Text(
                        subTitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textTertiaryLight,
                        ),
                      ),
                    Text(
                      _formatDate(review.createdAt),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textTertiaryLight,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < review.rating ? Iconsax.star5 : Iconsax.star,
                    size: 14.sp,
                    color: Colors.amber,
                  );
                }),
              ),
            ],
          ),
          if (review.title != null && review.title!.isNotEmpty) ...[
            SizedBox(height: 8.h),
            Text(
              review.title!,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          if (review.comment != null && review.comment!.isNotEmpty) ...[
            SizedBox(height: 8.h),
            Text(review.comment!, style: theme.textTheme.bodyMedium),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays == 0) return 'اليوم';
    if (diff.inDays == 1) return 'أمس';
    if (diff.inDays < 7) return 'منذ ${diff.inDays} أيام';
    return '${date.day}/${date.month}/${date.year}';
  }
}

/// Bottom sheet for adding a review
class _AddReviewBottomSheet extends StatefulWidget {
  final String productId;
  final String productName;

  const _AddReviewBottomSheet({
    required this.productId,
    required this.productName,
  });

  @override
  State<_AddReviewBottomSheet> createState() => _AddReviewBottomSheetState();
}

class _AddReviewBottomSheetState extends State<_AddReviewBottomSheet> {
  final _catalogRepository = getIt<CatalogRepository>();
  int _rating = 0;
  final _titleController = TextEditingController();
  final _commentController = TextEditingController();
  bool _isSubmitting = false;
  String? _error;

  @override
  void dispose() {
    _titleController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_rating < 1 || _rating > 5) {
      setState(() => _error = 'الرجاء اختيار التقييم (1-5 نجوم)');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    final result = await _catalogRepository.addReview(
      productId: widget.productId,
      rating: _rating,
      title: _titleController.text.trim().isEmpty
          ? null
          : _titleController.text.trim(),
      comment: _commentController.text.trim().isEmpty
          ? null
          : _commentController.text.trim(),
    );

    if (!mounted) return;

    result.fold(
      (failure) => setState(() {
        _isSubmitting = false;
        _error = failure.message;
      }),
      (_) {
        Navigator.of(context).pop(true);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.only(
        left: 24.w,
        right: 24.w,
        top: 24.h,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24.h,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'أضف تقييم',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              widget.productName,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textTertiaryLight,
              ),
            ),
            SizedBox(height: 24.h),
            Text('التقييم (مطلوب)', style: theme.textTheme.titleSmall),
            SizedBox(height: 8.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final star = index + 1;
                return IconButton(
                  onPressed: () => setState(() => _rating = star),
                  icon: Icon(
                    star <= _rating ? Iconsax.star5 : Iconsax.star,
                    size: 36.sp,
                    color: Colors.amber,
                  ),
                );
              }),
            ),
            SizedBox(height: 24.h),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'عنوان التقييم (اختياري)',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.h),
            TextField(
              controller: _commentController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'التعليق (اختياري)',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
            if (_error != null) ...[
              SizedBox(height: 16.h),
              Text(
                _error!,
                style: TextStyle(color: AppColors.error, fontSize: 12.sp),
              ),
            ],
            SizedBox(height: 24.h),
            FilledButton(
              onPressed: _isSubmitting ? null : _submit,
              child: _isSubmitting
                  ? SizedBox(
                      height: 20.h,
                      width: 20.w,
                      child: const CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('إرسال التقييم'),
            ),
          ],
        ),
      ),
    );
  }
}
