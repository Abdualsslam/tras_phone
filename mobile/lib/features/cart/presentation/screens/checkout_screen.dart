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
import '../../../orders/presentation/cubit/orders_cubit.dart';
import '../../../orders/domain/enums/order_enums.dart';
import '../../../orders/domain/entities/payment_method_entity.dart';
import '../../../orders/data/models/shipping_address_model.dart';
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

    return BlocConsumer<CheckoutSessionCubit, CheckoutSessionState>(
      listener: (context, state) {
        if (state is CheckoutSessionLoaded) {
          // Auto-select default address if not selected
          if (_selectedAddressId == null &&
              state.session.addresses.isNotEmpty) {
            final defaultAddress = state.session.defaultAddress;
            if (defaultAddress != null) {
              setState(() => _selectedAddressId = defaultAddress.id);
            }
          }
          // Auto-select first payment method if not selected
          if (_selectedPaymentMethodId == null &&
              state.session.paymentMethods.isNotEmpty) {
            setState(
              () => _selectedPaymentMethodId =
                  state.session.paymentMethods.first.id,
            );
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
        if (state is CheckoutSessionLoading) {
          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            appBar: AppBar(
              title: Text(AppLocalizations.of(context)!.checkout),
              leading: IconButton(
                icon: const Icon(Iconsax.arrow_right_3),
                onPressed: () => context.pop(),
              ),
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        if (state is CheckoutSessionError) {
          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            appBar: AppBar(
              title: Text(AppLocalizations.of(context)!.checkout),
              leading: IconButton(
                icon: const Icon(Iconsax.arrow_right_3),
                onPressed: () => context.pop(),
              ),
            ),
            body: Center(
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
                    onPressed: () =>
                        context.read<CheckoutSessionCubit>().loadSession(),
                    icon: const Icon(Iconsax.refresh),
                    label: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            ),
          );
        }
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
                      // Address Section (from checkout session)
                      _buildSectionTitle(
                        theme,
                        AppLocalizations.of(context)!.addresses,
                      ),
                      SizedBox(height: 12.h),
                      BlocBuilder<CheckoutSessionCubit, CheckoutSessionState>(
                        builder: (context, sessionState) {
                          if (sessionState is CheckoutSessionLoading) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(24.0),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }
                          if (sessionState is! CheckoutSessionLoaded) {
                            return const SizedBox.shrink();
                          }
                          final addresses = sessionState.session.addresses;

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
                              padding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 16.h,
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
                                children: [
                                  Icon(
                                    Iconsax.location,
                                    size: 40.sp,
                                    color: AppColors.textSecondaryLight,
                                  ),
                                  SizedBox(height: 8.h),
                                  Text(
                                    'لا توجد عناوين متاحة',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                  SizedBox(height: 12.h),
                                  ElevatedButton.icon(
                                    onPressed: () async {
                                      final result = await context.push(
                                        '/address/add',
                                      );
                                      if (result != true) return;
                                      if (!context.mounted) return;
                                      context
                                          .read<CheckoutSessionCubit>()
                                          .refresh();
                                    },
                                    icon: const Icon(Iconsax.add, size: 18),
                                    label: Text(
                                      AppLocalizations.of(context)!.addAddress,
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 20.w,
                                        vertical: 10.h,
                                      ),
                                    ),
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
                              children: [
                                ...addresses.map((address) {
                                  return _buildAddressCard(
                                    theme,
                                    isDark,
                                    address,
                                    isSelected:
                                        _selectedAddressId == address.id,
                                  );
                                }),
                                TextButton.icon(
                                  onPressed: () async {
                                    final result = await context.push(
                                      '/address/add',
                                    );
                                    if (result != true) return;
                                    if (!context.mounted) return;
                                    context
                                        .read<CheckoutSessionCubit>()
                                        .refresh();
                                  },
                                  icon: Icon(Iconsax.add, size: 18.sp),
                                  label: Text(
                                    AppLocalizations.of(context)!.addAddress,
                                    style: TextStyle(fontSize: 13.sp),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 24.h),

                      // Payment Section (from checkout session)
                      _buildSectionTitle(
                        theme,
                        AppLocalizations.of(context)!.paymentMethod,
                      ),
                      SizedBox(height: 12.h),
                      BlocBuilder<CheckoutSessionCubit, CheckoutSessionState>(
                        builder: (context, sessionState) {
                          if (sessionState is CheckoutSessionLoading) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(24.0),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }
                          if (sessionState is! CheckoutSessionLoaded) {
                            return const SizedBox.shrink();
                          }
                          final paymentMethods =
                              sessionState.session.paymentMethods;

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
                        },
                      ),
                      SizedBox(height: 24.h),

                      // Coupon Section
                      BlocBuilder<CheckoutSessionCubit, CheckoutSessionState>(
                        builder: (context, sessionState) {
                          final orderTotal =
                              sessionState is CheckoutSessionLoaded
                              ? sessionState.session.cart.subtotal
                              : 0.0;

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
                      BlocBuilder<CheckoutSessionCubit, CheckoutSessionState>(
                        builder: (context, sessionState) {
                          if (sessionState is! CheckoutSessionLoaded) {
                            return const SizedBox.shrink();
                          }
                          final cart = sessionState.session.cart;
                          return _buildOrderSummary(theme, isDark, cart);
                        },
                      ),
                      SizedBox(height: 100.h),
                    ],
                  ),
                ),
              ),
              BlocBuilder<CheckoutSessionCubit, CheckoutSessionState>(
                builder: (context, sessionState) {
                  if (sessionState is CheckoutSessionLoaded) {
                    return _buildBottomBar(
                      context,
                      theme,
                      isDark,
                      sessionState.session,
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        );
      },
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
        margin: EdgeInsets.only(bottom: 4.h),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
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
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                Iconsax.location,
                color: AppColors.primary,
                size: 22.sp,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text(
                        address.label,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 14.sp,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (address.isDefault) ...[
                        SizedBox(width: 6.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
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
                  SizedBox(height: 2.h),
                  Text(
                    address.addressLine,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondaryLight,
                      fontSize: 12.sp,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (address.cityName != null || address.phone != null) ...[
                    SizedBox(height: 2.h),
                    Text(
                      [
                        if (address.cityName != null) address.cityName!,
                        if (address.phone != null) address.phone!,
                      ].join(' • '),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textTertiaryLight,
                        fontSize: 11.sp,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(width: 8.w),
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

  Widget _buildOrderSummary(
    ThemeData theme,
    bool isDark,
    CheckoutCartEntity cart,
  ) {
    final couponDiscount = _appliedCoupon?.discountAmount ?? 0.0;
    final subtotal = cart.subtotal;
    final shippingCost = cart.shippingCost;
    final taxAmount = cart.taxAmount;
    final total = subtotal - couponDiscount + shippingCost + taxAmount;
    final itemsCount = cart.itemsCount;
    final locale = Localizations.localeOf(context).languageCode;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // تفاصيل المنتجات - شكل فاتورة
          Text(
            AppLocalizations.of(context)!.products,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 12.h),
          if (cart.items.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              child: Text(
                'لا توجد منتجات',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondaryLight,
                ),
              ),
            )
          else ...[
            // رأس الفاتورة
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'المنتج',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                ),
                SizedBox(
                  width: 40.w,
                  child: Text(
                    'الكمية',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                ),
                SizedBox(
                  width: 56.w,
                  child: Text(
                    'السعر',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                ),
                SizedBox(
                  width: 56.w,
                  child: Text(
                    'الإجمالي',
                    textAlign: TextAlign.end,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Divider(
              height: 1,
              color: AppColors.dividerLight.withValues(alpha: 0.5),
            ),
            SizedBox(height: 8.h),
            // صفوف المنتجات
            ...cart.items.map((item) {
              return Padding(
                padding: EdgeInsets.only(bottom: 10.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        item.getProductName(locale),
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(
                      width: 40.w,
                      child: Text(
                        '${item.quantity}',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                    SizedBox(
                      width: 56.w,
                      child: Text(
                        item.unitPrice.toStringAsFixed(0),
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                    SizedBox(
                      width: 56.w,
                      child: Text(
                        item.totalPrice.toStringAsFixed(0),
                        textAlign: TextAlign.end,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
            Divider(height: 20.h, color: AppColors.dividerLight),
          ],
          // المجموع الفرعي وما بعده
          Text(
            AppLocalizations.of(context)!.subtotal,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 12.h),
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

    // تفعيل الزر عند توفر: سلة غير فارغة + عنوان + طريقة دفع
    // التحقق من المخزون والمنتجات غير النشطة يبقى داخل _handlePlaceOrder مع رسالة للمستخدم
    final canPlaceOrder =
        !session.cart.isEmpty &&
        _selectedAddressId != null &&
        session.addresses.isNotEmpty &&
        _selectedPaymentMethodId != null &&
        session.paymentMethods.isNotEmpty;

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
        child: Opacity(
          opacity: canPlaceOrder ? 1.0 : 0.5,
          child: ElevatedButton(
            onPressed: canPlaceOrder ? () => _handlePlaceOrder(session) : null,
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
      ),
    );
  }

  Future<void> _handlePlaceOrder(CheckoutSessionEntity session) async {
    // التحقق من أن السلة ليست فارغة
    if (session.cart.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('السلة فارغة')));
      return;
    }

    HapticFeedback.mediumImpact();

    // عرض مؤشر التحميل
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // محاولة المزامنة (اختياري - لا يمنع الطلب إذا فشل)
      try {
        await context.read<CartCubit>().syncCart(silent: true);
      } catch (_) {
        // تجاهل أخطاء المزامنة - سيتحقق السيرفر عند إنشاء الطلب
      }

      if (!mounted) return;

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
      if (_selectedPaymentMethodId != null &&
          session.paymentMethods.isNotEmpty) {
        selectedPaymentMethod = session.paymentMethods.firstWhere(
          (m) => m.id == _selectedPaymentMethodId,
          orElse: () => session.paymentMethods.first,
        );
      }

      if (selectedAddress == null) {
        Navigator.of(context).pop(); // إغلاق مؤشر التحميل
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('يرجى اختيار عنوان التوصيل')),
        );
        return;
      }

      if (selectedPaymentMethod == null) {
        Navigator.of(context).pop(); // إغلاق مؤشر التحميل
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

      if (!mounted) return;
      Navigator.of(context).pop(); // إغلاق مؤشر التحميل

      if (order != null) {
        // Clear local cart after successful order
        await context.read<CartCubit>().clearCartLocal();
        if (!mounted) return;
        // الانتقال لصفحة تفاصيل الطلب
        context.go('/order-details/${order.id}');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('فشل إنشاء الطلب. حاول مرة أخرى.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop(); // إغلاق مؤشر التحميل
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
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
