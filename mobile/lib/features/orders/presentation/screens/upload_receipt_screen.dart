library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../../core/config/theme/app_colors.dart';
import '../controllers/upload_receipt_form_controller.dart';
import '../cubit/orders_cubit.dart';
import '../cubit/orders_state.dart';
import '../widgets/upload_receipt_sections.dart';

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
  late final UploadReceiptFormController _controller;

  @override
  void initState() {
    super.initState();
    _controller = UploadReceiptFormController()
      ..initialize(context.read<OrdersCubit>());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _showImagePickerSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Iconsax.camera),
              title: const Text('التقاط صورة'),
              onTap: () async {
                Navigator.pop(context);
                await _controller.pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Iconsax.gallery),
              title: const Text('اختيار من المعرض'),
              onTap: () async {
                Navigator.pop(context);
                await _controller.pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickTransferDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _controller.transferDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      _controller.setTransferDate(date);
    }
  }

  Future<void> _uploadReceipt() async {
    final success = await _controller.uploadReceipt(
      cubit: context.read<OrdersCubit>(),
      orderId: widget.orderId,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم رفع الإيصال بنجاح'),
          backgroundColor: AppColors.success,
        ),
      );
      context.pop(true);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('فشل رفع الإيصال. حاول مرة أخرى.'),
        backgroundColor: AppColors.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final locale = Localizations.localeOf(context).languageCode;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return BlocListener<OrdersCubit, OrdersState>(
          listener: (context, state) {
            if (state is BankAccountsLoaded) {
              _controller.setBankAccounts(state.accounts);
            }
          },
          child: Scaffold(
            appBar: AppBar(title: const Text('رفع إيصال التحويل')),
            body: ListView(
              padding: EdgeInsets.all(16.w),
              children: [
                UploadReceiptOrderInfoCard(
                  orderId: widget.orderId,
                  amount: widget.amount,
                  isDark: isDark,
                ),
                SizedBox(height: 24.h),
                _SectionTitle(title: 'صورة الإيصال'),
                SizedBox(height: 12.h),
                UploadReceiptImageSection(
                  isDark: isDark,
                  imagePath: _controller.receiptImagePath,
                  onPickImage: _showImagePickerSheet,
                  onClearImage: _controller.clearImage,
                ),
                SizedBox(height: 24.h),
                _SectionTitle(title: 'رقم التحويل (اختياري)'),
                SizedBox(height: 12.h),
                TextField(
                  controller: _controller.transferRefController,
                  decoration: const InputDecoration(
                    hintText: 'أدخل رقم التحويل البنكي...',
                  ),
                ),
                SizedBox(height: 16.h),
                _SectionTitle(title: 'تاريخ التحويل (اختياري)'),
                SizedBox(height: 12.h),
                UploadReceiptDateField(
                  isDark: isDark,
                  transferDate: _controller.transferDate,
                  formattedDate: _controller.transferDate != null
                      ? DateFormat(
                          'yyyy-MM-dd',
                        ).format(_controller.transferDate!)
                      : 'اختر تاريخ التحويل',
                  onTap: _pickTransferDate,
                  onClear: () => _controller.setTransferDate(null),
                ),
                SizedBox(height: 16.h),
                _SectionTitle(title: 'ملاحظات (اختياري)'),
                SizedBox(height: 12.h),
                TextField(
                  controller: _controller.notesController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'أضف أي ملاحظات إضافية...',
                  ),
                ),
                SizedBox(height: 24.h),
                _SectionTitle(title: 'الحسابات البنكية'),
                SizedBox(height: 12.h),
                UploadReceiptBankAccountsSection(
                  isDark: isDark,
                  locale: locale,
                  bankAccounts: _controller.bankAccounts,
                ),
                SizedBox(height: 32.h),
                UploadReceiptSubmitButton(
                  isUploading: _controller.isUploading,
                  enabled: _controller.canUpload,
                  onPressed: _uploadReceipt,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
    );
  }
}
