/// Checkout Screen - Order summary and address/payment selection
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../promotions/presentation/widgets/coupon_input.dart';
import '../../../promotions/data/models/coupon_validation_model.dart';
import '../../domain/entities/cart_entity.dart';
import '../cubit/cart_cubit.dart';
import '../cubit/cart_state.dart';
import '../../../orders/presentation/cubit/orders_cubit.dart';
import '../../../orders/domain/enums/order_enums.dart';
import '../../../orders/data/models/shipping_address_model.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  int _selectedAddressIndex = 0;
  int _selectedPaymentIndex = 0;
  CouponValidation? _appliedCoupon;

  final _addresses = [
    _Address(
      id: 1,
      title: 'المنزل',
      address: 'الرياض - حي الملز - شارع الأمير سلطان',
      phone: '0555123456',
      isDefault: true,
    ),
    _Address(
      id: 2,
      title: 'العمل',
      address: 'الرياض - حي العليا - برج المملكة',
      phone: '0555123456',
      isDefault: false,
    ),
  ];

  final _paymentMethods = [
    _PaymentMethod(
      id: 1,
      title: 'الدفع عند الاستلام',
      icon: Iconsax.money,
      description: 'ادفع نقداً عند استلام الطلب',
    ),
    _PaymentMethod(
      id: 2,
      title: 'المحفظة',
      icon: Iconsax.wallet,
      description: 'الرصيد المتاح: 500 ر.س',
    ),
    _PaymentMethod(
      id: 3,
      title: 'تحويل بنكي',
      icon: Iconsax.bank,
      description: 'تحويل إلى حساب الشركة',
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Load local cart when entering checkout
    context.read<CartCubit>().loadLocalCart();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.checkout),
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_right_3),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              physics: const ClampingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
            // Address Section
            _buildSectionTitle(theme, AppLocalizations.of(context)!.addresses),
            SizedBox(height: 12.h),
            ..._addresses.asMap().entries.map((entry) {
              return _buildAddressCard(theme, isDark, entry.key, entry.value);
            }),
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Iconsax.add),
              label: Text(AppLocalizations.of(context)!.addAddress),
            ),
            SizedBox(height: 24.h),

            // Payment Section
            _buildSectionTitle(
              theme,
              AppLocalizations.of(context)!.paymentMethod,
            ),
            SizedBox(height: 12.h),
            ..._paymentMethods.asMap().entries.map((entry) {
              return _buildPaymentCard(theme, isDark, entry.key, entry.value);
            }),
            SizedBox(height: 24.h),

            // Coupon Section
            BlocBuilder<CartCubit, CartState>(
              builder: (context, cartState) {
                final cart = cartState is CartLoaded ? cartState.cart : null;
                final orderTotal = cart?.subtotal ?? 0.0;
                
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle(theme, 'كود الخصم'),
                    SizedBox(height: 12.h),
                    CouponInput(
                      orderTotal: orderTotal,
                      onCouponApplied: (validation) {
                        setState(() => _appliedCoupon = validation);
                      },
                      onCouponRemoved: () {
                        setState(() => _appliedCoupon = null);
                      },
                    ),
                  ],
                );
              },
            ),
            SizedBox(height: 24.h),

            // Order Summary
            BlocBuilder<CartCubit, CartState>(
              builder: (context, cartState) {
                final cart = cartState is CartLoaded ? cartState.cart : null;
                if (cart == null) {
                  return SizedBox.shrink();
                }
                return _buildOrderSummary(theme, isDark, cart);
              },
            ),
            SizedBox(height: 100.h),
                ],
              ),
            ),
          ),
          _buildBottomBar(context, theme, isDark),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(ThemeData theme, String title) {
    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
    );
  }

  Widget _buildAddressCard(
    ThemeData theme,
    bool isDark,
    int index,
    _Address address,
  ) {
    final isSelected = _selectedAddressIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedAddressIndex = index),
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.cardLight,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 24.w,
              height: 24.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.textTertiaryLight,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12.w,
                        height: 12.w,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        address.title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (address.isDefault) ...[
                        SizedBox(width: 8.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text(
                            'افتراضي',
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    address.address,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    address.phone,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textTertiaryLight,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Iconsax.edit_2, size: 20),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentCard(
    ThemeData theme,
    bool isDark,
    int index,
    _PaymentMethod method,
  ) {
    final isSelected = _selectedPaymentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedPaymentIndex = index),
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.cardLight,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(method.icon, color: AppColors.primary),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    method.title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    method.description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textTertiaryLight,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 24.w,
              height: 24.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.textTertiaryLight,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12.w,
                        height: 12.w,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary(ThemeData theme, bool isDark, CartEntity cart) {
    final couponDiscount = _appliedCoupon?.discountAmount ?? 0.0;
    final subtotal = cart.subtotal;
    final shippingCost = cart.shippingCost;
    final taxAmount = cart.taxAmount;
    final total = subtotal - couponDiscount + shippingCost + taxAmount;
    final itemsCount = cart.itemsCount;
    
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.subtotal,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 16.h),
          _buildSummaryRow(
            theme,
            'المجموع الفرعي ($itemsCount ${itemsCount == 1 ? 'منتج' : 'منتجات'})',
            '${subtotal.toStringAsFixed(0)} ${AppLocalizations.of(context)!.currency}',
          ),
          SizedBox(height: 8.h),
          _buildSummaryRow(
            theme,
            'الشحن',
            '${shippingCost.toStringAsFixed(0)} ${AppLocalizations.of(context)!.currency}',
          ),
          if (couponDiscount > 0) ...[
            SizedBox(height: 8.h),
            _buildSummaryRow(
              theme,
              'الخصم',
              '-${couponDiscount.toStringAsFixed(0)} ${AppLocalizations.of(context)!.currency}',
              valueColor: AppColors.success,
            ),
          ],
          if (taxAmount > 0) ...[
            SizedBox(height: 8.h),
            _buildSummaryRow(
              theme,
              'الضريبة',
              '${taxAmount.toStringAsFixed(0)} ${AppLocalizations.of(context)!.currency}',
            ),
          ],
          Divider(height: 24.h),
          _buildSummaryRow(
            theme,
            'الإجمالي',
            '${total.toStringAsFixed(0)} ${AppLocalizations.of(context)!.currency}',
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    ThemeData theme,
    String label,
    String value, {
    Color? valueColor,
    bool isTotal = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isTotal
              ? theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                )
              : theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondaryLight,
                ),
        ),
        Text(
          value,
          style: isTotal
              ? TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                )
              : theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: valueColor,
                ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context, ThemeData theme, bool isDark) {
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, cartState) {
        final cart = cartState is CartLoaded ? cartState.cart : null;
        final couponDiscount = _appliedCoupon?.discountAmount ?? 0.0;
        final subtotal = cart?.subtotal ?? 0.0;
        final shippingCost = cart?.shippingCost ?? 0.0;
        final taxAmount = cart?.taxAmount ?? 0.0;
        final total = subtotal - couponDiscount + shippingCost + taxAmount;
        
        return Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
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
              onPressed: () async {
                if (cart == null || cart.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('السلة فارغة')),
                  );
                  return;
                }

                HapticFeedback.mediumImpact();

                // Sync cart before creating order
                final syncResult = await context.read<CartCubit>().syncCart();
                if (syncResult == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('فشلت المزامنة. حاول مرة أخرى.')),
                  );
                  return;
                }

                // Get coupon code if applied
                final couponCode = _appliedCoupon?.coupon?.code;

                // Get selected address and payment method
                final selectedAddress = _addresses[_selectedAddressIndex];
                final selectedPayment = _paymentMethods[_selectedPaymentIndex];

                // Map payment method
                OrderPaymentMethod? paymentMethod;
                switch (selectedPayment.id) {
                  case 1:
                    paymentMethod = OrderPaymentMethod.cash;
                    break;
                  case 2:
                    paymentMethod = OrderPaymentMethod.wallet;
                    break;
                  case 3:
                    paymentMethod = OrderPaymentMethod.bankTransfer;
                    break;
                }

                // Create shipping address model
                final shippingAddress = ShippingAddressModel(
                  fullName: selectedAddress.title,
                  phone: selectedAddress.phone,
                  address: selectedAddress.address,
                  city: selectedAddress.address.split(' - ')[0], // Extract city
                );

                // Create order
                final order = await context.read<OrdersCubit>().createOrder(
                      shippingAddress: shippingAddress,
                      paymentMethod: paymentMethod,
                      couponCode: couponCode,
                    );

                if (order != null) {
                  // Clear local cart after successful order
                  await context.read<CartCubit>().clearCartLocal();
                  context.push('/order-confirmation');
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('فشل إنشاء الطلب. حاول مرة أخرى.')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
              ),
              child: Text(
                '${AppLocalizations.of(context)!.confirm} • ${total.toStringAsFixed(0)} ${AppLocalizations.of(context)!.currency}',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Address {
  final int id;
  final String title;
  final String address;
  final String phone;
  final bool isDefault;

  _Address({
    required this.id,
    required this.title,
    required this.address,
    required this.phone,
    required this.isDefault,
  });
}

class _PaymentMethod {
  final int id;
  final String title;
  final IconData icon;
  final String description;

  _PaymentMethod({
    required this.id,
    required this.title,
    required this.icon,
    required this.description,
  });
}
