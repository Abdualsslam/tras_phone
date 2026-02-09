/// Upload Receipt Screen - Upload bank transfer receipt
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../../domain/entities/bank_account_entity.dart';
import '../cubit/orders_cubit.dart';
import '../cubit/orders_state.dart';

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
  final _transferRefController = TextEditingController();
  bool _isUploading = false;
  DateTime? _transferDate;
  List<BankAccountEntity> _bankAccounts = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    context.read<OrdersCubit>().loadBankAccounts();
  }

  @override
  void dispose() {
    _notesController.dispose();
    _transferRefController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final locale = Localizations.localeOf(context).languageCode;

    return BlocListener<OrdersCubit, OrdersState>(
      listener: (context, state) {
        if (state is BankAccountsLoaded) {
          setState(() => _bankAccounts = state.accounts);
        }
      },
      child: Scaffold(
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
                          child: Image.file(
                            File(_receiptImagePath!),
                            fit: BoxFit.cover,
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

          // Transfer Reference
          Text(
            'رقم التحويل (اختياري)',
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 12.h),
          TextField(
            controller: _transferRefController,
            decoration: const InputDecoration(
              hintText: 'أدخل رقم التحويل البنكي...',
            ),
          ),
          SizedBox(height: 16.h),

          // Transfer Date
          Text(
            'تاريخ التحويل (اختياري)',
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 12.h),
          InkWell(
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _transferDate ?? DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
              );
              if (date != null && mounted) {
                setState(() => _transferDate = date);
              }
            },
            borderRadius: BorderRadius.circular(12.r),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : AppColors.backgroundLight,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: isDark
                      ? AppColors.dividerDark
                      : AppColors.dividerLight,
                ),
              ),
              child: Row(
                children: [
                  Icon(Iconsax.calendar_1,
                      size: 20.sp, color: AppColors.textSecondaryLight),
                  SizedBox(width: 12.w),
                  Text(
                    _transferDate != null
                        ? DateFormat('yyyy-MM-dd').format(_transferDate!)
                        : 'اختر تاريخ التحويل',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: _transferDate != null
                          ? null
                          : AppColors.textTertiaryLight,
                    ),
                  ),
                  if (_transferDate != null) ...[
                    const Spacer(),
                    IconButton(
                      icon: Icon(Icons.clear, size: 18.sp),
                      onPressed: () => setState(() => _transferDate = null),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ],
              ),
            ),
          ),
          SizedBox(height: 16.h),

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

          // Bank Accounts Section
          Text(
            'الحسابات البنكية',
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 12.h),
          if (_bankAccounts.isEmpty)
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
            )
          else
            ...List.generate(_bankAccounts.length, (i) {
              final acc = _bankAccounts[i];
              return Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.cardDark : AppColors.cardLight,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: isDark
                          ? AppColors.dividerDark
                          : AppColors.dividerLight,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Iconsax.bank,
                              size: 20.sp, color: AppColors.primary),
                          SizedBox(width: 8.w),
                          Text(
                            acc.getDisplayName(locale),
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      if (acc.iban != null) ...[
                        SizedBox(height: 8.h),
                        Text(
                          'IBAN: ${acc.iban}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontFamily: 'monospace',
                            color: AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                      SizedBox(height: 4.h),
                      Text(
                        'رقم الحساب: ${acc.accountNumber}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                      if (acc.getInstructions(locale) != null) ...[
                        SizedBox(height: 8.h),
                        Text(
                          acc.getInstructions(locale)!,
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: AppColors.textTertiaryLight,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }),
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
      ),
    );
  }

  Future<void> _pickImage() async {
    await showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Iconsax.camera),
              title: const Text('التقاط صورة'),
              onTap: () async {
                Navigator.pop(context);
                final source = ImageSource.camera;
                final xFile = await _picker.pickImage(
                  source: source,
                  imageQuality: 85,
                  maxWidth: 1920,
                );
                if (xFile != null && mounted) {
                  setState(() => _receiptImagePath = xFile.path);
                }
              },
            ),
            ListTile(
              leading: const Icon(Iconsax.gallery),
              title: const Text('اختيار من المعرض'),
              onTap: () async {
                Navigator.pop(context);
                final xFile = await _picker.pickImage(
                  source: ImageSource.gallery,
                  imageQuality: 85,
                  maxWidth: 1920,
                );
                if (xFile != null && mounted) {
                  setState(() => _receiptImagePath = xFile.path);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _uploadReceipt() async {
    if (_receiptImagePath == null) return;

    final cubit = context.read<OrdersCubit>();
    setState(() => _isUploading = true);

    try {
      final file = File(_receiptImagePath!);
      final bytes = await file.readAsBytes();
      final base64Image = base64Encode(bytes);

      final order = await cubit.uploadReceipt(
            orderId: widget.orderId,
            receiptImage: base64Image,
            transferReference: _transferRefController.text.trim().isNotEmpty
                ? _transferRefController.text.trim()
                : null,
            transferDate: _transferDate != null
                ? DateFormat('yyyy-MM-dd').format(_transferDate!)
                : null,
            notes: _notesController.text.trim().isNotEmpty
                ? _notesController.text.trim()
                : null,
          );

      if (!mounted) return;
      setState(() => _isUploading = false);

      if (order != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم رفع الإيصال بنجاح'),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('فشل رفع الإيصال. حاول مرة أخرى.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل رفع الإيصال: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
