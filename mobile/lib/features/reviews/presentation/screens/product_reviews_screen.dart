/// Product Reviews Screen - Show reviews for a product
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../../catalog/domain/repositories/catalog_repository.dart';
import '../../../catalog/data/models/product_review_model.dart';
import '../../../catalog/presentation/widgets/add_review_bottom_sheet.dart';
import '../../../catalog/presentation/widgets/product_review_card.dart';
import '../../../catalog/presentation/widgets/rating_bar_row.dart';
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
  ProductReviewModel? _myReview;
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

    final reviewsResult =
        await _catalogRepository.getProductReviews(widget.productId);
    final myReviewResult =
        await _catalogRepository.getMyReview(widget.productId);

    if (!mounted) return;

    String? error;
    List<ProductReviewModel> reviews = [];
    ProductReviewModel? myReview;

    reviewsResult.fold(
      (failure) => error = failure.message,
      (list) => reviews = list,
    );
    myReviewResult.fold(
      (_) => myReview = null,
      (r) => myReview = r,
    );

    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _error = error;
      _reviews = reviews;
      _myReview = myReview;
      if (error == null && reviews.isNotEmpty) {
        if (_averageRating == null) {
          _averageRating = reviews
                  .map((r) => r.rating)
                  .reduce((a, b) => a + b) /
              reviews.length;
        }
        if (_reviewsCount == 0) _reviewsCount = reviews.length;
      }
    });
  }

  Future<void> _onAddReviewPressed() async {
    final added = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddReviewBottomSheet(
        productId: widget.productId,
        productName: widget.productName ?? 'المنتج',
        existingReview: _myReview,
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
                                  return ProductReviewCard(
                                    theme: theme,
                                    isDark: isDark,
                                    review: _reviews[index],
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
        label: Text(_myReview != null ? 'تعديل التقييم' : 'أضف تقييم'),
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
                        child: RatingBarRow(
                          theme: theme,
                          stars: star,
                          percentage: pct,
                        ),
                      );
                    }),
                  ),
          ),
        ],
      ),
    );
  }
}
