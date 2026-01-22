/// Rating Dialog Widget
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/config/theme/app_colors.dart';

class RatingDialog extends StatefulWidget {
  final String? title;
  final String? message;
  final bool allowFeedback;

  const RatingDialog({
    super.key,
    this.title,
    this.message,
    this.allowFeedback = true,
  });

  static Future<Map<String, dynamic>?> show(
    BuildContext context, {
    String? title,
    String? message,
    bool allowFeedback = true,
  }) {
    return showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (context) => RatingDialog(
        title: title,
        message: message,
        allowFeedback: allowFeedback,
      ),
    );
  }

  @override
  State<RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  int _selectedRating = 5;
  final _feedbackController = TextEditingController();

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      title: Text(widget.title ?? 'قيم الخدمة'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.message != null) ...[
              Text(widget.message!),
              SizedBox(height: 16.h),
            ],
            // Rating Stars
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < _selectedRating
                        ? Icons.star
                        : Icons.star_border,
                    color: Colors.amber,
                    size: 40.sp,
                  ),
                  onPressed: () {
                    setState(() => _selectedRating = index + 1);
                  },
                );
              }),
            ),
            SizedBox(height: 16.h),
            // Feedback Text Field
            if (widget.allowFeedback)
              TextField(
                controller: _feedbackController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'اكتب تعليقك (اختياري)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  filled: true,
                  fillColor: isDark
                      ? AppColors.cardDark
                      : AppColors.backgroundLight,
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('تخطي'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context, {
              'rating': _selectedRating,
              'feedback': widget.allowFeedback
                  ? _feedbackController.text.trim()
                  : null,
            });
          },
          child: const Text('إرسال'),
        ),
      ],
    );
  }
}
