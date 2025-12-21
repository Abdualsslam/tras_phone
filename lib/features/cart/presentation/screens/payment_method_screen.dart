/// Payment Method Screen - Select payment method during checkout
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/config/theme/app_colors.dart';

class PaymentMethodScreen extends StatefulWidget {
  final String? selectedMethod;
  final double? walletBalance;
  final double? orderTotal;

  const PaymentMethodScreen({
    super.key,
    this.selectedMethod,
    this.walletBalance,
    this.orderTotal,
  });

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  late String _selectedMethod;
  bool _useWalletBalance = false;

  @override
  void initState() {
    super.initState();
    _selectedMethod = widget.selectedMethod ?? 'cod';
  }

  double get _walletBalance => widget.walletBalance ?? 500.0;
  double get _orderTotal => widget.orderTotal ?? 1000.0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('طريقة الدفع')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(16.w),
              children: [
                // Wallet Balance Card
                if (_walletBalance > 0) ...[
                  _buildWalletCard(isDark),
                  SizedBox(height: 24.h),
                ],

                // Payment Methods
                Text(
                  'اختر طريقة الدفع',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                ),
                SizedBox(height: 12.h),

                // COD
                _buildPaymentOption(
                  id: 'cod',
                  title: 'الدفع عند الاستلام',
                  subtitle: 'ادفع نقداً عند استلام طلبك',
                  icon: Iconsax.money,
                  isDark: isDark,
                ),

                // Bank Transfer
                _buildPaymentOption(
                  id: 'bank_transfer',
                  title: 'تحويل بنكي',
                  subtitle: 'حوّل المبلغ إلى حسابنا البنكي',
                  icon: Iconsax.bank,
                  isDark: isDark,
                ),

                // Wallet
                if (_walletBalance >= _orderTotal)
                  _buildPaymentOption(
                    id: 'wallet',
                    title: 'المحفظة',
                    subtitle: 'الدفع من رصيد محفظتك',
                    icon: Iconsax.wallet_3,
                    isDark: isDark,
                  ),

                // Online Payment (Coming Soon)
                _buildPaymentOption(
                  id: 'online',
                  title: 'الدفع الإلكتروني',
                  subtitle: 'Visa, Mastercard, Apple Pay',
                  icon: Iconsax.card,
                  isDark: isDark,
                  isDisabled: true,
                  badge: 'قريباً',
                ),

                SizedBox(height: 24.h),

                // Bank Accounts (if bank transfer selected)
                if (_selectedMethod == 'bank_transfer') ...[
                  Text(
                    'الحسابات البنكية',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  _buildBankAccount(
                    bankName: 'البنك الأهلي السعودي',
                    accountName: 'مؤسسة تراس فون للتجارة',
                    iban: 'SA0380000000608010167519',
                    isDark: isDark,
                  ),
                  SizedBox(height: 8.h),
                  _buildBankAccount(
                    bankName: 'بنك الراجحي',
                    accountName: 'مؤسسة تراس فون للتجارة',
                    iban: 'SA2980000372608019317608',
                    isDark: isDark,
                  ),
                ],
              ],
            ),
          ),

          // Confirm Button
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: ElevatedButton(
                onPressed: _confirmPaymentMethod,
                child: Text('تأكيد', style: TextStyle(fontSize: 16.sp)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWalletCard(bool isDark) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Iconsax.wallet_3, size: 24.sp, color: Colors.white),
                  SizedBox(width: 8.w),
                  Text(
                    'رصيد المحفظة',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
              Text(
                '${_walletBalance.toStringAsFixed(0)} ر.س',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Checkbox(
                value: _useWalletBalance,
                onChanged: (value) =>
                    setState(() => _useWalletBalance = value!),
                fillColor: WidgetStateProperty.all(Colors.white),
                checkColor: AppColors.primary,
              ),
              Text(
                'استخدام رصيد المحفظة',
                style: TextStyle(fontSize: 14.sp, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption({
    required String id,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isDark,
    bool isDisabled = false,
    String? badge,
  }) {
    final isSelected = _selectedMethod == id;

    return GestureDetector(
      onTap: isDisabled ? null : () => setState(() => _selectedMethod = id),
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isDisabled
              ? (isDark ? AppColors.cardDark : AppColors.backgroundLight)
                    .withValues(alpha: 0.5)
              : (isDark ? AppColors.cardDark : AppColors.cardLight),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isDark ? AppColors.dividerDark : AppColors.dividerLight),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : (isDark
                          ? AppColors.surfaceDark
                          : AppColors.backgroundLight),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                icon,
                size: 24.sp,
                color: isSelected
                    ? AppColors.primary
                    : AppColors.textTertiaryLight,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: isDisabled
                              ? AppColors.textTertiaryLight
                              : (isDark
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimaryLight),
                        ),
                      ),
                      if (badge != null) ...[
                        SizedBox(width: 8.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text(
                            badge,
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.warning,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected ? Iconsax.tick_circle5 : Iconsax.tick_circle,
              size: 24.sp,
              color: isSelected
                  ? AppColors.primary
                  : AppColors.textTertiaryLight,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBankAccount({
    required String bankName,
    required String accountName,
    required String iban,
    required bool isDark,
  }) {
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
          Text(
            bankName,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
          SizedBox(height: 8.h),
          _buildBankInfo('اسم الحساب', accountName, isDark),
          SizedBox(height: 4.h),
          Row(
            children: [
              Expanded(child: _buildBankInfo('IBAN', iban, isDark)),
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تم نسخ رقم IBAN'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                child: Icon(
                  Iconsax.copy,
                  size: 20.sp,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBankInfo(String label, String value, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 12.sp,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
        ),
      ],
    );
  }

  void _confirmPaymentMethod() {
    final result = {'method': _selectedMethod, 'useWallet': _useWalletBalance};
    context.pop(result);
  }
}
