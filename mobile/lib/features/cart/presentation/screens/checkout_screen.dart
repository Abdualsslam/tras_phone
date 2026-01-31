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
import '../../../orders/presentation/cubit/payment_methods_cubit.dart';
import '../../../orders/presentation/cubit/payment_methods_state.dart';
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
    // Load local cart when entering checkout
    context.read<CartCubit>().loadLocalCart();
    // Load addresses and payment methods
    context.read<AddressesCubit>().loadAddresses();
    context.read<PaymentMethodsCubit>().loadPaymentMethods();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocListener<AddressesCubit, AddressesState>(
      listener: (context, state) {
        // Reload addresses after successful add/edit/delete
        if (state is AddressOperationSuccess) {
          // Auto-select the newly added address if it's the only one
          if (state.addresses.isNotEmpty && _selectedAddressId == null) {
            final defaultAddress = state.addresses.firstWhere(
              (a) => a.isDefault,
              orElse: () => state.addresses.first,
            );
            setState(() => _selectedAddressId = defaultAddress.id);
          }
        }
      },
      child: Scaffold(
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
                    _buildSectionTitle(
                      theme,
                      AppLocalizations.of(context)!.addresses,
                    ),
                    SizedBox(height: 12.h),
                    BlocBuilder<AddressesCubit, AddressesState>(
                      builder: (context, addressesState) {
                        if (addressesState is AddressesLoading) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(24.0),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        if (addressesState is AddressesError) {
                          return Container(
                            padding: EdgeInsets.all(16.w),
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Iconsax.info_circle,
                                  color: AppColors.error,
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: Text(
                                    addressesState.message,
                                    style: TextStyle(color: AppColors.error),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        if (addressesState is AddressesLoaded ||
                            addressesState is AddressOperationLoading ||
                            addressesState is AddressOperationSuccess) {
                          final addresses = addressesState is AddressesLoaded
                              ? addressesState.addresses
                              : addressesState is AddressOperationLoading
                              ? addressesState.addresses
                              : (addressesState as AddressOperationSuccess)
                                    .addresses;

                          // Set default address if not selected
                          if (_selectedAddressId == null &&
                              addresses.isNotEmpty) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              final defaultAddress = addresses.firstWhere(
                                (a) => a.isDefault,
                                orElse: () => addresses.first,
                              );
                              setState(
                                () => _selectedAddressId = defaultAddress.id,
                              );
                            });
                          }

                          if (addresses.isEmpty) {
                            return Container(
                              padding: EdgeInsets.all(16.w),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.cardDark
                                    : AppColors.cardLight,
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Iconsax.location,
                                    size: 48.sp,
                                    color: AppColors.textSecondaryLight,
                                  ),
                                  SizedBox(height: 8.h),
                                  Text(
                                    'لا توجد عناوين متاحة',
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                  SizedBox(height: 12.h),
                                  ElevatedButton.icon(
                                    onPressed: () async {
                                      final result = await context.push(
                                        '/address/add',
                                      );
                                      if (result == true && mounted) {
                                        // Reload addresses after adding
                                        context
                                            .read<AddressesCubit>()
                                            .loadAddresses();
                                      }
                                    },
                                    icon: const Icon(Iconsax.add, size: 18),
                                    label: Text(
                                      AppLocalizations.of(context)!.addAddress,
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 24.w,
                                        vertical: 12.h,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          return Column(
                            children: [
                              ...addresses.map((address) {
                                return _buildAddressCard(
                                  theme,
                                  isDark,
                                  address,
                                  isSelected: _selectedAddressId == address.id,
                                );
                              }),
                              TextButton.icon(
                                onPressed: () async {
                                  final result = await context.push(
                                    '/address/add',
                                  );
                                  if (result == true && mounted) {
                                    // Reload addresses after adding
                                    context
                                        .read<AddressesCubit>()
                                        .loadAddresses();
                                  }
                                },
                                icon: const Icon(Iconsax.add),
                                label: Text(
                                  AppLocalizations.of(context)!.addAddress,
                                ),
                              ),
                            ],
                          );
                        }

                        return const SizedBox.shrink();
                      },
                    ),
                    SizedBox(height: 24.h),

                    // Payment Section
                    _buildSectionTitle(
                      theme,
                      AppLocalizations.of(context)!.paymentMethod,
                    ),
                    SizedBox(height: 12.h),
                    BlocBuilder<PaymentMethodsCubit, PaymentMethodsState>(
                      builder: (context, paymentState) {
                        if (paymentState is PaymentMethodsLoading) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(24.0),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        if (paymentState is PaymentMethodsError) {
                          return Container(
                            padding: EdgeInsets.all(16.w),
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Iconsax.info_circle,
                                  color: AppColors.error,
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: Text(
                                    paymentState.message,
                                    style: TextStyle(color: AppColors.error),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        if (paymentState is PaymentMethodsLoaded) {
                          final paymentMethods = paymentState.paymentMethods;

                          // Set default payment method if not selected
                          if (_selectedPaymentMethodId == null &&
                              paymentMethods.isNotEmpty) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              setState(
                                () => _selectedPaymentMethodId =
                                    paymentMethods.first.id,
                              );
                            });
                          }

                          if (paymentMethods.isEmpty) {
                            return Container(
                              padding: EdgeInsets.all(16.w),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.cardDark
                                    : AppColors.cardLight,
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Iconsax.card,
                                    size: 48.sp,
                                    color: AppColors.textSecondaryLight,
                                  ),
                                  SizedBox(height: 8.h),
                                  Text(
                                    'لا توجد طرق دفع متاحة',
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            );
                          }

                          return Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 10.h,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.surfaceDark
                                  : AppColors.backgroundLight,
                              borderRadius: BorderRadius.circular(14.r),
                              border: Border.all(
                                color: isDark
                                    ? AppColors.dividerDark
                                    : AppColors.dividerLight,
                                width: 1,
                              ),
                            ),
                            child: Column(
                              children: paymentMethods.map((method) {
                                return _buildPaymentCard(
                                  theme,
                                  isDark,
                                  method,
                                  isSelected:
                                      _selectedPaymentMethodId == method.id,
                                );
                              }).toList(),
                            ),
                          );
                        }

                        return const SizedBox.shrink();
                      },
                    ),
                    SizedBox(height: 24.h),

                    // Coupon Section
                    BlocBuilder<CartCubit, CartState>(
                      builder: (context, cartState) {
                        final cart = cartState is CartLoaded
                            ? cartState.cart
                            : null;
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
                        final cart = cartState is CartLoaded
                            ? cartState.cart
                            : null;
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
                        address.label,
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
    PaymentMethodEntity method, {
    required bool isSelected,
  }) {
    final locale = Localizations.localeOf(context).languageCode;
    final iconData = _getPaymentMethodIcon(method.type);

    return GestureDetector(
      onTap: () => setState(() => _selectedPaymentMethodId = method.id),
      child: Container(
        margin: EdgeInsets.only(bottom: 4.h),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.cardDark
              : (isSelected
                    ? AppColors.primary.withValues(alpha: 0.04)
                    : AppColors.inputBackgroundLight),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isDark ? AppColors.dividerDark : AppColors.dividerLight),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
        ),
        child: Row(
          children: [
            // Icon/logo (left) - كما كان سابقاً
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(iconData, color: AppColors.primary, size: 22.sp),
            ),
            SizedBox(width: 12.w),
            // Payment method name and description (center)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    method.getName(locale),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 14.sp,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (method.getDescription(locale) != null) ...[
                    SizedBox(height: 2.h),
                    Text(
                      method.getDescription(locale)!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textTertiaryLight,
                        fontSize: 12.sp,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(width: 8.w),
            // Selection indicator (right) - كما كان سابقاً
            Container(
              width: 22.w,
              height: 22.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.primary : Colors.transparent,
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
                        width: 8.w,
                        height: 8.w,
                        decoration: const BoxDecoration(
                          color: Colors.white,
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
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('السلة فارغة')));
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

                // Get selected address and payment method from state
                final addressesState = context.read<AddressesCubit>().state;
                final paymentState = context.read<PaymentMethodsCubit>().state;

                AddressEntity? selectedAddress;
                if (addressesState is AddressesLoaded ||
                    addressesState is AddressOperationLoading ||
                    addressesState is AddressOperationSuccess) {
                  final addresses = addressesState is AddressesLoaded
                      ? addressesState.addresses
                      : addressesState is AddressOperationLoading
                      ? addressesState.addresses
                      : (addressesState as AddressOperationSuccess).addresses;
                  selectedAddress = addresses.firstWhere(
                    (a) => a.id == _selectedAddressId,
                    orElse: () => addresses.first,
                  );
                }

                PaymentMethodEntity? selectedPaymentMethod;
                if (paymentState is PaymentMethodsLoaded) {
                  selectedPaymentMethod = paymentState.paymentMethods
                      .firstWhere(
                        (m) => m.id == _selectedPaymentMethodId,
                        orElse: () => paymentState.paymentMethods.first,
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
                  fullName:
                      selectedAddress.recipientName ?? selectedAddress.label,
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
