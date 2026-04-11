import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/config/theme/app_colors.dart';
import '../../domain/entities/bank_account_entity.dart';

class UploadReceiptOrderInfoCard extends StatelessWidget {
  final String orderId;
  final double amount;
  final bool isDark;

  const UploadReceiptOrderInfoCard({
    super.key,
    required this.orderId,
    required this.amount,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          _ReceiptInfoRow(label: 'رقم الطلب', value: '#$orderId'),
          SizedBox(height: 8.h),
          _ReceiptInfoRow(
            label: 'المبلغ المطلوب',
            value: '${amount.toStringAsFixed(0)} ر.س',
            valueColor: AppColors.primary,
            valueFontSize: 18,
            isBold: true,
          ),
        ],
      ),
    );
  }
}

class UploadReceiptImageSection extends StatelessWidget {
  final bool isDark;
  final String? imagePath;
  final VoidCallback onPickImage;
  final VoidCallback onClearImage;

  const UploadReceiptImageSection({
    super.key,
    required this.isDark,
    required this.imagePath,
    required this.onPickImage,
    required this.onClearImage,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPickImage,
      child: Container(
        height: 200.h,
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.backgroundLight,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
            width: 2,
          ),
        ),
        child: imagePath != null
            ? Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10.r),
                    child: Image.file(File(imagePath!), fit: BoxFit.cover),
                  ),
                  Positioned(
                    top: 8.h,
                    left: 8.w,
                    child: GestureDetector(
                      onTap: onClearImage,
                      child: Container(
                        padding: EdgeInsets.all(6.w),
                        decoration: const BoxDecoration(
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
    );
  }
}

class UploadReceiptDateField extends StatelessWidget {
  final bool isDark;
  final DateTime? transferDate;
  final String formattedDate;
  final VoidCallback onTap;
  final VoidCallback onClear;

  const UploadReceiptDateField({
    super.key,
    required this.isDark,
    required this.transferDate,
    required this.formattedDate,
    required this.onTap,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.backgroundLight,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Iconsax.calendar_1,
              size: 20.sp,
              color: AppColors.textSecondaryLight,
            ),
            SizedBox(width: 12.w),
            Text(
              formattedDate,
              style: TextStyle(
                fontSize: 14.sp,
                color: transferDate != null
                    ? null
                    : AppColors.textTertiaryLight,
              ),
            ),
            if (transferDate != null) ...[
              const Spacer(),
              IconButton(
                icon: Icon(Icons.clear, size: 18.sp),
                onPressed: onClear,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class UploadReceiptBankAccountsSection extends StatelessWidget {
  final bool isDark;
  final String locale;
  final List<BankAccountEntity> bankAccounts;

  const UploadReceiptBankAccountsSection({
    super.key,
    required this.isDark,
    required this.locale,
    required this.bankAccounts,
  });

  @override
  Widget build(BuildContext context) {
    if (bankAccounts.isEmpty) {
      return Container(
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
      );
    }

    return Column(
      children: bankAccounts
          .map(
            (account) => Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: UploadReceiptBankAccountCard(
                account: account,
                isDark: isDark,
                locale: locale,
              ),
            ),
          )
          .toList(),
    );
  }
}

class UploadReceiptBankAccountCard extends StatelessWidget {
  final BankAccountEntity account;
  final bool isDark;
  final String locale;

  const UploadReceiptBankAccountCard({
    super.key,
    required this.account,
    required this.isDark,
    required this.locale,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Iconsax.bank, size: 20.sp, color: AppColors.primary),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  account.getDisplayName(locale),
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (account.iban != null) ...[
            SizedBox(height: 8.h),
            Text(
              'IBAN: ${account.iban}',
              style: TextStyle(
                fontSize: 12.sp,
                fontFamily: 'monospace',
                color: AppColors.textSecondaryLight,
              ),
            ),
          ],
          SizedBox(height: 4.h),
          Text(
            'رقم الحساب: ${account.accountNumber}',
            style: TextStyle(
              fontSize: 12.sp,
              color: AppColors.textSecondaryLight,
            ),
          ),
          if (account.getInstructions(locale) case final instructions?) ...[
            SizedBox(height: 8.h),
            Text(
              instructions,
              style: TextStyle(
                fontSize: 11.sp,
                color: AppColors.textTertiaryLight,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class UploadReceiptSubmitButton extends StatelessWidget {
  final bool isUploading;
  final bool enabled;
  final VoidCallback onPressed;

  const UploadReceiptSubmitButton({
    super.key,
    required this.isUploading,
    required this.enabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: enabled ? onPressed : null,
      child: isUploading
          ? SizedBox(
              width: 20.w,
              height: 20.w,
              child: const CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : Text('رفع الإيصال', style: TextStyle(fontSize: 16.sp)),
    );
  }
}

class _ReceiptInfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final double? valueFontSize;
  final bool isBold;

  const _ReceiptInfoRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.valueFontSize,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            color: AppColors.textSecondaryLight,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: (valueFontSize ?? 14).sp,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
