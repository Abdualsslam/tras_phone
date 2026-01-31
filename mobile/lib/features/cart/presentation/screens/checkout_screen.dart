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
import '../../domain/entities/checkout_session_entity.dart';
import '../cubit/cart_cubit.dart';
import '../cubit/checkout_session_cubit.dart';
import '../cubit/checkout_session_state.dart';
import '../widgets/checkout_cart_items.dart';
import '../../../orders/presentation/cubit/orders_cubit.dart';
import '../../../orders/domain/enums/order_enums.dart';
import '../../../orders/domain/entities/payment_method_entity.dart';
import '../../../orders/data/models/shipping_address_model.dart';
import '../../../profile/presentation/cubit/profile_cubit.dart';
import '../../../profile/presentation/cubit/profile_state.dart';
import '../../../profile/domain/entities/address_entity.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String? _selectedAddressId;
  String? _selectedPaymentMethodId;
  CouponValidation? _appliedCoupon;

  @override
  void initState() {
    super.initState();
    // Load checkout session (cart + addresses + payment methods)
    context.read<CheckoutSessionCubit>().loadSession();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final locale = Localizations.localeOf(context).languageCode;

    return BlocConsumer<CheckoutSessionCubit, CheckoutSessionState>(
      listener: (context, state) {
        if (state is CheckoutSessionLoaded) {
          // Auto-select default address if not selected
          if (_selectedAddressId == null && state.session.addresses.isNotEmpty) {
            final defaultAddress = state.session.defaultAddress;
            if (defaultAddress != null) {
              setState(() => _selectedAddressId = defaultAddress.id);
            }
          }
          // Auto-select first payment method if not selected
          if (_selectedPaymentMethodId == null && 
              state.session.paymentMethods.isNotEmpty) {
            setState(() => _selectedPaymentMethodId = 
                state.session.paymentMethods.first.id);
          }
          // Set coupon if applied from session
          if (state.session.hasCouponApplied && _appliedCoupon == null) {
            _appliedCoupon = state.session.coupon?.toCouponValidation();
          }
        } else if (state is CheckoutSessionCouponError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            title: Text(AppLocalizations.of(context)!.checkout),
            leading: IconButton(
              icon: const Icon(Iconsax.arrow_right_3),
              onPressed: () => context.pop(),
            ),
          ),
          body: _buildBody(context, theme, isDark, locale, state),
        );
      },
    );
  }

  Widget _buildBody(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    String locale,
    CheckoutSessionState state,
  ) {
    if (state is CheckoutSessionLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is CheckoutSessionError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Iconsax.warning_2, size: 64.sp, color: AppColors.error),
            SizedBox(height: 16.h),
            Text(
              'حدث خطأ أثناء تحميل البيانات',
              style: theme.textTheme.titleMedium,
            ),
            SizedBox(height: 8.h),
            Text(
              state.message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            ElevatedButton.icon(
              onPressed: () => context.read<CheckoutSessionCubit>().loadSession(),
              icon: const Icon(Iconsax.refresh),
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }

    // Get session from state
    CheckoutSessionEntity? session;
    if (state is CheckoutSessionLoaded) {
      session = state.session;
    } else if (state is CheckoutSessionApplyingCoupon) {
      session = state.currentSession;
    } else if (state is CheckoutSessionCouponError) {
      session = state.currentSession;
    }

    if (session == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => context.read<CheckoutSessionCubit>().refresh(),
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Cart Items Section (NEW)
                  _buildSectionTitle(theme, AppLocalizations.of(context)!.products),
                  SizedBox(height: 12.h),
                  CheckoutCartItems(
                    items: session.cart.items,
                    initiallyExpanded: false,
                    locale: locale,
                  ),
                  SizedBox(height: 24.h),

                  // Address Section
                  _buildSectionTitle(theme, AppLocalizations.of(context)!.addresses),
                  SizedBox(height: 12.h),
                  _buildAddressSection(theme, isDark, session.addresses),
                  SizedBox(height: 24.h),

                  // Payment Section
                  _buildSectionTitle(theme, AppLocalizations.of(context)!.paymentMethod),
                  SizedBox(height: 12.h),
                  _buildPaymentSection(theme, isDark, session.paymentMethods),
                  SizedBox(height: 24.h),

                  // Coupon Section
                  _buildSectionTitle(theme, 'كود الخصم'),
                  SizedBox(height: 12.h),
                  CouponInput(
                    orderTotal: session.cart.subtotal,
                    onCouponApplied: (validation) {
                      setState(() => _appliedCoupon = validation);
                    },
                    onCouponRemoved: () {
                      setState(() => _appliedCoupon = null);
                    },
                  ),
                  SizedBox(height: 24.h),

                  // Order Summary
                  _buildOrderSummary(theme, isDark, session.cart),
                  SizedBox(height: 100.h),
                ],
              ),
            ),
          ),
        ),
        _buildBottomBar(context, theme, isDark, session),
      ],
    );
  }

  Widget _buildSectionTitle(ThemeData theme, String title) {
    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
    );
  }

  Widget _buildAddressSection(
    ThemeData theme,
    bool isDark,
    List<AddressEntity> addresses,
  ) {
    if (addresses.isEmpty) {
      return Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.cardLight,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          children: [
            Icon(Iconsax.location, size: 48.sp, color: AppColors.textSecondaryLight),
            SizedBox(height: 8.h),
            Text('لا توجد عناوين متاحة', style: theme.textTheme.bodyMedium),
            SizedBox(height: 12.h),
            ElevatedButton.icon(
              onPressed: () async {
                final result = await context.push('/address/add');
                if (result == true && mounted) {
                  context.read<CheckoutSessionCubit>().refresh();
                }
              },
              icon: const Icon(Iconsax.add, size: 18),
              label: Text(AppLocalizations.of(context)!.addAddress),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        ...addresses.map((address) => _buildAddressCard(
          theme, isDark, address,
          isSelected: _selectedAddressId == address.id,
        )),
        TextButton.icon(
          onPressed: () async {
            final result = await context.push('/address/add');
            if (result == true && mounted) {
              context.read<CheckoutSessionCubit>().refresh();
            }
          },
          icon: const Icon(Iconsax.add),
          label: Text(AppLocalizations.of(context)!.addAddress),
        ),
      ],
    );
  }

  Widget _buildAddressCard(
    ThemeData theme,
    bool isDark,
    AddressEntity address, {
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () => setState(() => _selectedAddressId = address.id),
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
                  color: isSelected ? AppColors.primary : AppColors.textTertiaryLight,
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
                        address.label,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (address.isDefault) ...[
                        SizedBox(width: 8.w),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
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
                    address.addressLine,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                  if (address.cityName != null) ...[
                    SizedBox(height: 2.h),
                    Text(
                      address.cityName!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                  if (address.phone != null) ...[
                    SizedBox(height: 2.h),
                    Text(
                      address.phone!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textTertiaryLight,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentSection(
    ThemeData theme,
    bool isDark,
    List<PaymentMethodEntity> paymentMethods,
  ) {
    if (paymentMethods.isEmpty) {
      return Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.cardLight,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          children: [
            Icon(Iconsax.card, size: 48.sp, color: AppColors.textSecondaryLight),
            SizedBox(height: 8.h),
            Text('لا توجد طرق دفع متاحة', style: theme.textTheme.bodyMedium),
          ],
        ),
      );
    }

    return Column(
      children: paymentMethods.map((method) => _buildPaymentCard(
        theme, isDark, method,
        isSelected: _selectedPaymentMethodId == method.id,
      )).toList(),
    );
  }

  Widget _buildPaymentCard(
    ThemeData theme,
    bool isDark,
    PaymentMethodEntity method, {
    required bool isSelected,
  }) {
    final locale = Localizations.localeOf(context).languageCode;
    final iconData = _getPaymentMethodIcon(method.type);

    return GestureDetector(
      onTap: () => setState(() => _selectedPaymentMethodId = method.id),
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
              child: Icon(iconData, color: AppColors.primary),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    method.getName(locale),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (method.getDescription(locale) != null) ...[
                    SizedBox(height: 2.h),
                    Text(
                      method.getDescription(locale)!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textTertiaryLight,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Container(
              width: 24.w,
              height: 24.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.textTertiaryLight,
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

  Widget _buildOrderSummary(ThemeData theme, bool isDark, CheckoutCartEntity cart) {
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
            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
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
              ? theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)
              : theme.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondaryLight),
        ),
        Text(
          value,
          style: isTotal
              ? TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700, color: AppColors.primary)
              : theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: valueColor),
        ),
      ],
    );
  }

  Widget _buildBottomBar(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    CheckoutSessionEntity session,
  ) {
    final couponDiscount = _appliedCoupon?.discountAmount ?? 0.0;
    final subtotal = session.cart.subtotal;
    final shippingCost = session.cart.shippingCost;
    final taxAmount = session.cart.taxAmount;
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
          onPressed: session.cart.isEmpty ? null : () => _handlePlaceOrder(session),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
          ),
          child: Text(
            '${AppLocalizations.of(context)!.confirm} • ${total.toStringAsFixed(0)} ${AppLocalizations.of(context)!.currency}',
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  Future<void> _handlePlaceOrder(CheckoutSessionEntity session) async {
    if (session.cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('السلة فارغة')),
      );
      return;
    }

    // Check for stock issues
    if (session.cart.hasStockIssues) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('بعض المنتجات غير متوفرة بالكمية المطلوبة'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    // Check for inactive products
    if (session.cart.hasInactiveProducts) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('بعض المنتجات غير متوفرة'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    HapticFeedback.mediumImpact();

    // Sync cart before creating order
    final syncResult = await context.read<CartCubit>().syncCart();
    if (syncResult == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('فشلت المزامنة. حاول مرة أخرى.')),
      );
      return;
    }

    // Get coupon code if applied
    final couponCode = _appliedCoupon?.coupon?.code;

    // Get selected address
    AddressEntity? selectedAddress;
    if (_selectedAddressId != null && session.addresses.isNotEmpty) {
      selectedAddress = session.addresses.firstWhere(
        (a) => a.id == _selectedAddressId,
        orElse: () => session.addresses.first,
      );
    }

    // Get selected payment method
    PaymentMethodEntity? selectedPaymentMethod;
    if (_selectedPaymentMethodId != null && session.paymentMethods.isNotEmpty) {
      selectedPaymentMethod = session.paymentMethods.firstWhere(
        (m) => m.id == _selectedPaymentMethodId,
        orElse: () => session.paymentMethods.first,
      );
    }

    if (selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى اختيار عنوان التوصيل')),
      );
      return;
    }

    if (selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى اختيار طريقة الدفع')),
      );
      return;
    }

    // Map payment method
    final paymentMethod = OrderPaymentMethod.fromString(
      selectedPaymentMethod.orderPaymentMethodValue,
    );

    // Create shipping address model
    final shippingAddress = ShippingAddressModel(
      fullName: selectedAddress.recipientName ?? selectedAddress.label,
      phone: selectedAddress.phone ?? '',
      address: selectedAddress.addressLine,
      city: selectedAddress.cityName ?? '',
    );

    // Create order
    final order = await context.read<OrdersCubit>().createOrder(
      shippingAddressId: selectedAddress.id,
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
        const SnackBar(content: Text('فشل إنشاء الطلب. حاول مرة أخرى.')),
      );
    }
  }

  /// Get icon for payment method type
  IconData _getPaymentMethodIcon(String type) {
    switch (type) {
      case 'cash_on_delivery':
        return Iconsax.money;
      case 'wallet':
        return Iconsax.wallet;
      case 'bank_transfer':
        return Iconsax.bank;
      case 'credit_card':
      case 'mada':
        return Iconsax.card;
      default:
        return Iconsax.money;
    }
  }
}

extension on CheckoutCouponEntity {
  CouponValidation toCouponValidation() {
    return CouponValidation(
      isValid: isValid,
      discountAmount: discountAmount,
      message: message,
    );
  }
}
