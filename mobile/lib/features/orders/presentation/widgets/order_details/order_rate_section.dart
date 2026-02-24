import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../../core/config/theme/app_colors.dart';
import '../../cubit/orders_cubit.dart';
import 'section_card.dart';
import 'section_title.dart';

class OrderRateSection extends StatefulWidget {
  final String orderId;
  final Future<void> Function() onRated;

  const OrderRateSection({
    super.key,
    required this.orderId,
    required this.onRated,
  });

  @override
  State<OrderRateSection> createState() => _OrderRateSectionState();
}

class _OrderRateSectionState extends State<OrderRateSection> {
  int _rating = 0;
  final _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SectionCard(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle(title: 'قيّم طلبك', icon: Iconsax.star_1),
          SizedBox(height: 16.h),
          // Star rating row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final starValue = index + 1;
              return GestureDetector(
                onTap: _isSubmitting
                    ? null
                    : () => setState(() => _rating = starValue),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.symmetric(horizontal: 6.w),
                  child: Icon(
                    starValue <= _rating
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    size: 36.sp,
                    color: starValue <= _rating
                        ? AppColors.accent
                        : AppColors.textTertiaryLight,
                  ),
                ),
              );
            }),
          ),
          if (_rating > 0) ...[
            SizedBox(height: 4.h),
            Center(
              child: Text(
                _getRatingLabel(_rating),
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.accent,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
          SizedBox(height: 14.h),
          TextField(
            controller: _commentController,
            enabled: !_isSubmitting,
            maxLines: 2,
            decoration: InputDecoration(
              hintText: 'أضف تعليقاً (اختياري)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 14.w,
                vertical: 12.h,
              ),
            ),
          ),
          SizedBox(height: 14.h),
          SizedBox(
            width: double.infinity,
            height: 46.h,
            child: ElevatedButton.icon(
              onPressed: _rating > 0 && !_isSubmitting ? _submitRating : null,
              icon: _isSubmitting
                  ? SizedBox(
                      width: 18.w,
                      height: 18.w,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Icon(Iconsax.send_1, size: 18.sp),
              label: Text(
                _isSubmitting ? 'جاري الإرسال...' : 'إرسال التقييم',
                style: TextStyle(fontSize: 14.sp),
              ),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getRatingLabel(int rating) {
    return switch (rating) {
      1 => 'سيء',
      2 => 'مقبول',
      3 => 'جيد',
      4 => 'جيد جداً',
      5 => 'ممتاز',
      _ => '',
    };
  }

  Future<void> _submitRating() async {
    setState(() => _isSubmitting = true);
    try {
      await context.read<OrdersCubit>().rateOrder(
        orderId: widget.orderId,
        rating: _rating,
        comment: _commentController.text.trim().isNotEmpty
            ? _commentController.text.trim()
            : null,
      );
      if (mounted) {
        await widget.onRated();
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('فشل إرسال التقييم')));
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}
