/// Upload Receipt Screen - Upload bank transfer receipt
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/config/theme/app_colors.dart';

class UploadReceiptScreen extends StatefulWidget {
  final String orderId;
  final double amount;

  const UploadReceiptScreen({
    super.key,
    required this.orderId,
    this.amount = 0,
  });

  @override
  State<UploadReceiptScreen> createState() => _UploadReceiptScreenState();
}

class _UploadReceiptScreenState extends State<UploadReceiptScreen> {
  String? _receiptImagePath;
  final _notesController = TextEditingController();
  bool _isUploading = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('رفع إيصال التحويل')),
      body: ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          // Order Info Card
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : AppColors.cardLight,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'رقم الطلب',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                    Text(
                      '#${widget.orderId}',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'المبلغ المطلوب',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                    Text(
                      '${widget.amount.toStringAsFixed(0)} ر.س',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),

          // Upload Section
          Text(
            'صورة الإيصال',
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 12.h),
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              height: 200.h,
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : AppColors.backgroundLight,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: isDark
                      ? AppColors.dividerDark
                      : AppColors.dividerLight,
                  width: 2,
                  style: BorderStyle.solid,
                ),
              ),
              child: _receiptImagePath != null
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10.r),
                          child: Container(
                            color: AppColors.success.withValues(alpha: 0.1),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Iconsax.document_upload,
                                    size: 48.sp,
                                    color: AppColors.success,
                                  ),
                                  SizedBox(height: 8.h),
                                  Text(
                                    'تم اختيار الصورة',
                                    style: TextStyle(
                                      color: AppColors.success,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 8.h,
                          left: 8.w,
                          child: GestureDetector(
                            onTap: () =>
                                setState(() => _receiptImagePath = null),
                            child: Container(
                              padding: EdgeInsets.all(6.w),
                              decoration: BoxDecoration(
                                color: AppColors.error,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.close,
                                size: 16.sp,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Iconsax.gallery_add,
                          size: 48.sp,
                          color: AppColors.textTertiaryLight,
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          'اضغط لاختيار صورة الإيصال',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppColors.textSecondaryLight,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'PNG, JPG حتى 10 MB',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.textTertiaryLight,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          SizedBox(height: 24.h),

          // Notes
          Text(
            'ملاحظات (اختياري)',
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 12.h),
          TextField(
            controller: _notesController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'أضف أي ملاحظات إضافية...',
            ),
          ),
          SizedBox(height: 24.h),

          // Bank Accounts Info
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(Iconsax.info_circle, size: 24.sp, color: AppColors.info),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    'تأكد من تحويل المبلغ الكامل إلى أحد حساباتنا البنكية. سيتم مراجعة التحويل خلال 24 ساعة.',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.info,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 32.h),

          // Upload Button
          ElevatedButton(
            onPressed: _receiptImagePath != null && !_isUploading
                ? _uploadReceipt
                : null,
            child: _isUploading
                ? SizedBox(
                    width: 20.w,
                    height: 20.w,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text('رفع الإيصال', style: TextStyle(fontSize: 16.sp)),
          ),
        ],
      ),
    );
  }

  void _pickImage() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Iconsax.camera),
              title: const Text('التقاط صورة'),
              onTap: () {
                Navigator.pop(context);
                setState(() => _receiptImagePath = 'camera_image.jpg');
              },
            ),
            ListTile(
              leading: const Icon(Iconsax.gallery),
              title: const Text('اختيار من المعرض'),
              onTap: () {
                Navigator.pop(context);
                setState(() => _receiptImagePath = 'gallery_image.jpg');
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _uploadReceipt() async {
    setState(() => _isUploading = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _isUploading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم رفع الإيصال بنجاح'),
          backgroundColor: AppColors.success,
        ),
      );
      context.pop(true);
    }
  }
}
