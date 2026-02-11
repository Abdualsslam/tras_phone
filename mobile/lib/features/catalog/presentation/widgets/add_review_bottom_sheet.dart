/// Add Review Bottom Sheet - Shared widget for adding a product review
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../domain/repositories/catalog_repository.dart';
import '../../data/models/product_review_model.dart';

/// Bottom sheet for adding or editing a review. Pops with [true] on success.
class AddReviewBottomSheet extends StatefulWidget {
  final String productId;
  final String productName;
  final VoidCallback? onReviewAdded;
  final ProductReviewModel? existingReview;

  const AddReviewBottomSheet({
    super.key,
    required this.productId,
    required this.productName,
    this.onReviewAdded,
    this.existingReview,
  });

  @override
  State<AddReviewBottomSheet> createState() => _AddReviewBottomSheetState();
}

class _AddReviewBottomSheetState extends State<AddReviewBottomSheet> {
  final _catalogRepository = getIt<CatalogRepository>();
  int _rating = 0;
  final _titleController = TextEditingController();
  final _commentController = TextEditingController();
  bool _isSubmitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.existingReview != null) {
      final r = widget.existingReview!;
      _rating = r.rating;
      _titleController.text = r.title ?? '';
      _commentController.text = r.comment ?? '';
    }
  }

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

    final title = _titleController.text.trim().isEmpty
        ? null
        : _titleController.text.trim();
    final comment = _commentController.text.trim().isEmpty
        ? null
        : _commentController.text.trim();

    if (widget.existingReview != null) {
      final result = await _catalogRepository.updateReview(
        productId: widget.productId,
        reviewId: widget.existingReview!.id,
        rating: _rating,
        title: title,
        comment: comment,
      );
      if (!mounted) return;
      result.fold(
        (failure) => setState(() {
          _isSubmitting = false;
          _error = failure.message;
        }),
        (_) {
          widget.onReviewAdded?.call();
          Navigator.of(context).pop(true);
        },
      );
    } else {
      final result = await _catalogRepository.addReview(
        productId: widget.productId,
        rating: _rating,
        title: title,
        comment: comment,
      );
      if (!mounted) return;
      result.fold(
        (failure) => setState(() {
          _isSubmitting = false;
          _error = failure.message;
        }),
        (_) {
          widget.onReviewAdded?.call();
          Navigator.of(context).pop(true);
        },
      );
    }
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
              widget.existingReview != null ? 'تعديل التقييم' : 'أضف تقييم',
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
