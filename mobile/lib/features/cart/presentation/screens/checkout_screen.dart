/// Checkout Screen - Order summary and address/payment selection
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../promotions/presentation/widgets/coupon_input.dart';
import '../../../promotions/data/models/coupon_validation_model.dart';
import '../../domain/entities/checkout_session_entity.dart';
import '../cubit/cart_cubit.dart';
import '../cubit/checkout_session_cubit.dart';
import '../cubit/checkout_session_state.dart';
import '../../../orders/presentation/cubit/orders_cubit.dart';
import '../../../orders/presentation/cubit/orders_state.dart';
import '../../../orders/domain/enums/order_enums.dart';
import '../../../orders/domain/entities/bank_account_entity.dart';
import '../../../orders/domain/entities/payment_method_entity.dart';
import '../../../orders/data/models/shipping_address_model.dart';
import '../../../profile/domain/entities/address_entity.dart';
import '../../../wallet/presentation/cubit/wallet_cubit.dart';
import '../../../wallet/presentation/cubit/wallet_state.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen>
    with WidgetsBindingObserver {
  String? _selectedAddressId;
  String? _selectedPaymentMethodId;
  CouponValidation? _appliedCoupon;
  final TextEditingController _transferReferenceController =
      TextEditingController();
  final TextEditingController _transferNotesController =
      TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  DateTime? _transferDate;
  String? _receiptImagePath;
  String? _selectedBankAccountId;
  bool _isLoadingBankAccounts = false;
  bool _hasRequestedBankAccounts = false;
  List<BankAccountEntity> _bankAccounts = const [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Load checkout session (cart + addresses + payment methods)
    context.read<CheckoutSessionCubit>().loadSession();
    context.read<WalletCubit>().loadBalance();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _transferReferenceController.dispose();
    _transferNotesController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Refresh session when app comes back to foreground
    if (state == AppLifecycleState.resumed) {
      context.read<CheckoutSessionCubit>().refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocListener<OrdersCubit, OrdersState>(
      listener: (context, ordersState) {
        if (ordersState is BankAccountsLoaded) {
          String? nextSelectedBankId = _selectedBankAccountId;
          final hasCurrent = ordersState.accounts.any(
            (account) => account.id == _selectedBankAccountId,
          );
          if (!hasCurrent) {
            final defaultAccount = ordersState.accounts.where(
              (a) => a.isDefault,
            );
            if (defaultAccount.isNotEmpty) {
              nextSelectedBankId = defaultAccount.first.id;
            } else if (ordersState.accounts.isNotEmpty) {
              nextSelectedBankId = ordersState.accounts.first.id;
            } else {
              nextSelectedBankId = null;
            }
          }

          setState(() {
            _bankAccounts = ordersState.accounts;
            _selectedBankAccountId = nextSelectedBankId;
            _isLoadingBankAccounts = false;
          });
        }
      },
      child: BlocConsumer<CheckoutSessionCubit, CheckoutSessionState>(
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
            final displayPaymentMethods = _buildDisplayPaymentMethods(
              state.session.paymentMethods,
            );
            if (_selectedPaymentMethodId == null &&
                displayPaymentMethods.isNotEmpty) {
              final defaultMethod = displayPaymentMethods.first;
              setState(() => _selectedPaymentMethodId = defaultMethod.id);
              _fetchBankAccountsIfNeeded(defaultMethod);
            }
            // Set coupon if applied from session
            if (state.session.hasCouponApplied && _appliedCoupon == null) {
              _appliedCoupon = state.session.coupon?.toCouponValidation();
            }
          } else if (state is CheckoutSessionCouponError) {
            AppSnackbar.showError(context, state.message);
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
              body: AppError(
                title: 'حدث خطأ أثناء تحميل البيانات',
                message: state.message,
                onRetry: () =>
                    context.read<CheckoutSessionCubit>().loadSession(),
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
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(fontSize: 14.sp),
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
                                        AppLocalizations.of(
                                          context,
                                        )!.addAddress,
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
                            final paymentMethods = _buildDisplayPaymentMethods(
                              sessionState.session.paymentMethods,
                            );
                            PaymentMethodEntity? mergedCreditMethod;
                            if (_isWalletCreditMerged(
                              sessionState.session.paymentMethods,
                            )) {
                              for (final method
                                  in sessionState.session.paymentMethods) {
                                if (method.type == 'credit') {
                                  mergedCreditMethod = method;
                                  break;
                                }
                              }
                            }

                            // Set default payment method if not selected
                            final selectedIdExists = paymentMethods.any(
                              (m) => m.id == _selectedPaymentMethodId,
                            );
                            if ((_selectedPaymentMethodId == null ||
                                    !selectedIdExists) &&
                                paymentMethods.isNotEmpty) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                final firstMethod = paymentMethods.first;
                                setState(
                                  () =>
                                      _selectedPaymentMethodId = firstMethod.id,
                                );
                                _fetchBankAccountsIfNeeded(firstMethod);
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
                                    isWalletCreditMerged: _isWalletCreditMerged(
                                      sessionState.session.paymentMethods,
                                    ),
                                    mergedCreditMethod: mergedCreditMethod,
                                    isSelected:
                                        _selectedPaymentMethodId == method.id,
                                  );
                                }).toList(),
                              ),
                            );
                          },
                        ),
                        SizedBox(height: 24.h),

                        BlocBuilder<CheckoutSessionCubit, CheckoutSessionState>(
                          builder: (context, sessionState) {
                            if (sessionState is! CheckoutSessionLoaded) {
                              return const SizedBox.shrink();
                            }

                            final selectedMethod = _getSelectedPaymentMethod(
                              sessionState.session,
                            );
                            final isBankTransferSelected =
                                _isBankTransferMethod(selectedMethod);

                            if (!isBankTransferSelected) {
                              return const SizedBox.shrink();
                            }

                            if (!_hasRequestedBankAccounts &&
                                selectedMethod != null) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (!mounted) return;
                                _fetchBankAccountsIfNeeded(selectedMethod);
                              });
                            }

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSectionTitle(
                                  theme,
                                  'بيانات التحويل البنكي',
                                ),
                                SizedBox(height: 12.h),
                                _buildBankTransferSection(theme, isDark),
                                SizedBox(height: 24.h),
                              ],
                            );
                          },
                        ),

                        // Wallet partial payment (hybrid)
                        BlocBuilder<WalletCubit, WalletState>(
                          builder: (context, walletState) {
                            if (state is! CheckoutSessionLoaded) {
                              return const SizedBox.shrink();
                            }

                            final session = (state).session;
                            final hasWalletMethod = session.paymentMethods.any(
                              (m) => m.type == 'wallet',
                            );

                            if (!hasWalletMethod) {
                              return const SizedBox.shrink();
                            }

                            final selectedMethod = _getSelectedPaymentMethod(
                              session,
                            );
                            final isWalletMethodSelected =
                                selectedMethod?.type == 'wallet';
                            final cubitWalletBalance =
                                walletState is WalletLoaded
                                ? (walletState.balance ?? 0)
                                : 0.0;
                            // Fallback to checkout session wallet balance
                            final sessionWalletBalance =
                                session.customer.walletBalance;
                            final walletBalance = cubitWalletBalance > 0
                                ? cubitWalletBalance
                                : sessionWalletBalance;
                            final orderTotal =
                                session.cart.subtotal -
                                (_appliedCoupon?.discountAmount ?? 0) +
                                session.cart.shippingCost +
                                session.cart.taxAmount;
                            PaymentMethodEntity? creditMethod;
                            for (final method in session.paymentMethods) {
                              if (method.type == 'credit') {
                                creditMethod = method;
                                break;
                              }
                            }
                            final availableCredit =
                                (creditMethod?.availableCredit ?? 0).toDouble();
                            final walletAutoUse =
                                (walletBalance < orderTotal
                                        ? walletBalance
                                        : orderTotal)
                                    .toDouble();
                            final creditAutoUse =
                                isWalletMethodSelected &&
                                    orderTotal > walletAutoUse
                                ? ((orderTotal - walletAutoUse) >
                                          availableCredit
                                      ? availableCredit
                                      : (orderTotal - walletAutoUse))
                                : 0.0;
                            final remainingAfterWalletAndCredit =
                                isWalletMethodSelected
                                ? (orderTotal - walletAutoUse - creditAutoUse)
                                      .clamp(0, orderTotal)
                                      .toDouble()
                                : 0.0;

                            return Container(
                              padding: EdgeInsets.all(12.w),
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Iconsax.wallet_money,
                                        size: 20.sp,
                                        color: AppColors.primary,
                                      ),
                                      SizedBox(width: 8.w),
                                      Expanded(
                                        child: Text(
                                          'استخدام رصيد المحفظة',
                                          style: theme.textTheme.titleSmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.w700,
                                              ),
                                        ),
                                      ),
                                      Text(
                                        '${walletBalance.toStringAsFixed(2)} ${AppLocalizations.of(context)!.currency}',
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              color:
                                                  AppColors.textSecondaryLight,
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10.h),
                                  if (isWalletMethodSelected)
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'تم اختيار الدفع بالمحفظة، سيتم الخصم من المحفظة أولاً ثم من حد الائتمان تلقائياً.',
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                                color: AppColors
                                                    .textSecondaryLight,
                                              ),
                                        ),
                                        SizedBox(height: 8.h),
                                        Text(
                                          'من المحفظة: ${walletAutoUse.toStringAsFixed(2)} ${AppLocalizations.of(context)!.currency}',
                                          style: theme.textTheme.bodySmall,
                                        ),
                                        Text(
                                          'من الائتمان: ${creditAutoUse.toStringAsFixed(2)} ${AppLocalizations.of(context)!.currency}',
                                          style: theme.textTheme.bodySmall,
                                        ),
                                        if (remainingAfterWalletAndCredit > 0)
                                          Text(
                                            'المتبقي بعد المحفظة والائتمان: ${remainingAfterWalletAndCredit.toStringAsFixed(2)} ${AppLocalizations.of(context)!.currency}',
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(
                                                  color: AppColors.error,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                      ],
                                    )
                                  else ...[
                                    Text(
                                      'سيتم الخصم تلقائياً من المحفظة أولاً في جميع الطلبات.',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: AppColors.textSecondaryLight,
                                      ),
                                    ),
                                    SizedBox(height: 8.h),
                                    Text(
                                      'المخصوم تلقائياً: ${walletAutoUse.toStringAsFixed(2)} ${AppLocalizations.of(context)!.currency}',
                                      style: theme.textTheme.bodySmall,
                                    ),
                                    Text(
                                      'المتبقي بعد المحفظة: ${(orderTotal - walletAutoUse).clamp(0, orderTotal).toStringAsFixed(2)} ${AppLocalizations.of(context)!.currency}',
                                      style: theme.textTheme.bodySmall,
                                    ),
                                  ],
                                ],
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
                            return _buildOrderSummary(
                              theme,
                              isDark,
                              sessionState.session,
                            );
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
      ),
    );
  }

  void _onSelectPaymentMethod(PaymentMethodEntity method) {
    setState(() {
      _selectedPaymentMethodId = method.id;
      if (!_isBankTransferMethod(method)) {
        _selectedBankAccountId = null;
      }
    });
    _fetchBankAccountsIfNeeded(method);
  }

  Future<void> _fetchBankAccountsIfNeeded(PaymentMethodEntity method) async {
    if (!_isBankTransferMethod(method)) {
      return;
    }
    if (_hasRequestedBankAccounts) {
      if (_selectedBankAccountId == null && _bankAccounts.isNotEmpty) {
        final defaultAccount = _bankAccounts.where((a) => a.isDefault);
        setState(() {
          _selectedBankAccountId = defaultAccount.isNotEmpty
              ? defaultAccount.first.id
              : _bankAccounts.first.id;
        });
      }
      return;
    }

    setState(() {
      _hasRequestedBankAccounts = true;
      _isLoadingBankAccounts = true;
    });
    await context.read<OrdersCubit>().loadBankAccounts();
    if (!mounted) return;

    if (_isLoadingBankAccounts) {
      setState(() => _isLoadingBankAccounts = false);
    }

    final state = context.read<OrdersCubit>().state;
    if (state is OrdersError && _bankAccounts.isEmpty) {
      AppSnackbar.showError(context, 'تعذر تحميل الحسابات البنكية');
    }
  }

  bool _isBankTransferMethod(PaymentMethodEntity? method) {
    return method?.orderPaymentMethodValue == 'bank_transfer';
  }

  Widget _buildBankTransferSection(ThemeData theme, bool isDark) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'إيصال التحويل (مطلوب)',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 8.h),
          GestureDetector(
            onTap: _pickTransferReceiptImage,
            child: Container(
              height: 170.h,
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : AppColors.cardLight,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: _receiptImagePath != null
                      ? AppColors.primary
                      : (isDark
                            ? AppColors.dividerDark
                            : AppColors.dividerLight),
                ),
              ),
              child: _receiptImagePath == null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Iconsax.gallery_add,
                          size: 36.sp,
                          color: AppColors.textTertiaryLight,
                        ),
                        SizedBox(height: 10.h),
                        Text(
                          'اضغط لاختيار صورة الإيصال',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondaryLight,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'PNG, JPG حتى 10 MB',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.textTertiaryLight,
                          ),
                        ),
                      ],
                    )
                  : Stack(
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
                              decoration: const BoxDecoration(
                                color: AppColors.error,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.close,
                                size: 14.sp,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          SizedBox(height: 14.h),
          TextField(
            controller: _transferReferenceController,
            decoration: const InputDecoration(
              labelText: 'رقم التحويل (اختياري)',
              hintText: 'مثال: TRF123456',
            ),
          ),
          SizedBox(height: 10.h),
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
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : AppColors.cardLight,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: isDark
                      ? AppColors.dividerDark
                      : AppColors.dividerLight,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Iconsax.calendar_1,
                    size: 18.sp,
                    color: AppColors.textSecondaryLight,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      _transferDate != null
                          ? DateFormat('yyyy-MM-dd').format(_transferDate!)
                          : 'تاريخ التحويل (اختياري)',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: _transferDate != null
                            ? null
                            : AppColors.textTertiaryLight,
                      ),
                    ),
                  ),
                  if (_transferDate != null)
                    GestureDetector(
                      onTap: () => setState(() => _transferDate = null),
                      child: Icon(
                        Icons.close,
                        size: 18.sp,
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                ],
              ),
            ),
          ),
          SizedBox(height: 10.h),
          TextField(
            controller: _transferNotesController,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'ملاحظات التحويل (اختياري)',
              hintText: 'أي تفاصيل إضافية عن عملية التحويل',
            ),
          ),
          SizedBox(height: 14.h),
          Text(
            'ستجد البنوك المدعومة تحت خيار "تحويل بنكي" بالأعلى.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickTransferReceiptImage() async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Iconsax.camera),
                title: const Text('التقاط صورة'),
                onTap: () async {
                  Navigator.pop(context);
                  final xFile = await _imagePicker.pickImage(
                    source: ImageSource.camera,
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
                  final xFile = await _imagePicker.pickImage(
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
    bool isWalletCreditMerged = false,
    PaymentMethodEntity? mergedCreditMethod,
    required bool isSelected,
  }) {
    final locale = Localizations.localeOf(context).languageCode;
    final iconData = _getPaymentMethodIcon(method.type);
    final displayName = isWalletCreditMerged && method.type == 'wallet'
        ? 'المحفظة + الآجل'
        : method.getName(locale);
    final displayDescription = isWalletCreditMerged && method.type == 'wallet'
        ? 'خصم تلقائي من المحفظة ثم من حد الائتمان'
        : method.getDescription(locale);

    return GestureDetector(
      onTap: () => _onSelectPaymentMethod(method),
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                // Icon/logo (left)
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
                        displayName,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 14.sp,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (displayDescription != null) ...[
                        SizedBox(height: 2.h),
                        Text(
                          displayDescription,
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
                // Selection indicator (right)
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
            // Credit limit details panel
            if (method.isCreditMethod && method.creditLimit != null)
              _buildCreditInfoPanel(theme, isDark, method),
            if (isWalletCreditMerged &&
                method.type == 'wallet' &&
                mergedCreditMethod != null &&
                isSelected)
              _buildCreditInfoPanel(theme, isDark, mergedCreditMethod),
            if (_isBankTransferMethod(method) && isSelected)
              _buildSupportedBanksPanel(theme, isDark),
            // Wallet balance details panel
            if (method.type == 'wallet' && isSelected)
              _buildWalletInfoPanel(theme, isDark),
          ],
        ),
      ),
    );
  }

  /// Builds the credit limit info panel shown under the credit payment method
  Widget _buildCreditInfoPanel(
    ThemeData theme,
    bool isDark,
    PaymentMethodEntity method,
  ) {
    final creditLimit = method.creditLimit ?? 0;
    final creditUsed = method.creditUsed ?? 0;
    final availableCredit =
        method.availableCredit ?? (creditLimit - creditUsed);
    final usageRatio = creditLimit > 0 ? creditUsed / creditLimit : 0.0;

    // Color based on usage percentage
    final Color progressColor;
    if (usageRatio < 0.5) {
      progressColor = AppColors.success;
    } else if (usageRatio < 0.8) {
      progressColor = Colors.orange;
    } else {
      progressColor = AppColors.error;
    }

    return Container(
      margin: EdgeInsets.only(top: 8.h),
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.surfaceDark.withValues(alpha: 0.5)
            : AppColors.primary.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: isDark
              ? AppColors.dividerDark
              : AppColors.primary.withValues(alpha: 0.1),
          width: 0.5,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Available credit - highlighted
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Iconsax.wallet_check, size: 14.sp, color: progressColor),
                  SizedBox(width: 6.w),
                  Text(
                    'المتاح',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 12.sp,
                      color: isDark
                          ? Colors.white70
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
              Text(
                '${availableCredit.toStringAsFixed(0)} ${AppLocalizations.of(context)!.currency}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: progressColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4.r),
            child: LinearProgressIndicator(
              value: usageRatio.clamp(0.0, 1.0),
              minHeight: 5.h,
              backgroundColor: isDark ? Colors.white12 : AppColors.dividerLight,
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            ),
          ),
          SizedBox(height: 8.h),
          // Credit limit and used
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Credit limit
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'الحد: ',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 11.sp,
                      color: isDark
                          ? Colors.white54
                          : AppColors.textTertiaryLight,
                    ),
                  ),
                  Text(
                    '${creditLimit.toStringAsFixed(0)} ${AppLocalizations.of(context)!.currency}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? Colors.white70
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
              // Used amount
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'المستخدم: ',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 11.sp,
                      color: isDark
                          ? Colors.white54
                          : AppColors.textTertiaryLight,
                    ),
                  ),
                  Text(
                    '${creditUsed.toStringAsFixed(0)} ${AppLocalizations.of(context)!.currency}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? Colors.white70
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSupportedBanksPanel(ThemeData theme, bool isDark) {
    final locale = Localizations.localeOf(context).languageCode;

    return Container(
      margin: EdgeInsets.only(top: 8.h),
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.surfaceDark.withValues(alpha: 0.5)
            : AppColors.primary.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: isDark
              ? AppColors.dividerDark
              : AppColors.primary.withValues(alpha: 0.1),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'البنوك المدعومة',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'اختر البنك الذي قمت بالتحويل إليه',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondaryLight,
            ),
          ),
          SizedBox(height: 8.h),
          if (_isLoadingBankAccounts)
            const Center(child: CircularProgressIndicator())
          else if (_bankAccounts.isEmpty)
            Text(
              'لا توجد حسابات بنكية متاحة حالياً',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondaryLight,
              ),
            )
          else
            ..._bankAccounts.map((account) {
              final isSelected = _selectedBankAccountId == account.id;
              return GestureDetector(
                onTap: () =>
                    setState(() => _selectedBankAccountId = account.id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  margin: EdgeInsets.only(bottom: 8.h),
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.cardDark
                        : (isSelected
                              ? AppColors.primary.withValues(alpha: 0.05)
                              : AppColors.cardLight),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : (isDark
                                ? AppColors.dividerDark
                                : AppColors.dividerLight),
                      width: isSelected ? 1.4 : 1,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 34.w,
                        height: 34.w,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: account.logo != null && account.logo!.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8.r),
                                child: Image.network(
                                  account.logo!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, error, stackTrace) => Icon(
                                    Iconsax.bank,
                                    size: 16.sp,
                                    color: AppColors.primary,
                                  ),
                                ),
                              )
                            : Icon(
                                Iconsax.bank,
                                size: 16.sp,
                                color: AppColors.primary,
                              ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    account.getDisplayName(locale),
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                if (account.isDefault)
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 6.w,
                                      vertical: 2.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.success.withValues(
                                        alpha: 0.12,
                                      ),
                                      borderRadius: BorderRadius.circular(4.r),
                                    ),
                                    child: Text(
                                      'افتراضي',
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            fontSize: 10.sp,
                                            color: AppColors.success,
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                  ),
                              ],
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              'اسم الحساب: ${account.getAccountName(locale)}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondaryLight,
                              ),
                            ),
                            Text(
                              'رقم الحساب: ${account.accountNumber}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondaryLight,
                              ),
                            ),
                            if (account.iban != null &&
                                account.iban!.isNotEmpty)
                              Text(
                                'IBAN: ${account.iban}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppColors.textSecondaryLight,
                                ),
                              ),
                          ],
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Icon(
                        isSelected ? Iconsax.tick_circle5 : Iconsax.tick_circle,
                        size: 22.sp,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textTertiaryLight,
                      ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  /// Builds the wallet balance info panel shown under the wallet payment method
  Widget _buildWalletInfoPanel(ThemeData theme, bool isDark) {
    return BlocBuilder<WalletCubit, WalletState>(
      builder: (context, walletState) {
        final cubitBalance = walletState is WalletLoaded
            ? (walletState.balance ?? 0)
            : 0.0;

        // Also read from checkout session customer data as fallback
        final checkoutState = context.read<CheckoutSessionCubit>().state;
        final sessionBalance = checkoutState is CheckoutSessionLoaded
            ? checkoutState.session.customer.walletBalance
            : 0.0;

        // Use the greater of the two sources (in case one hasn't loaded yet)
        final walletBalance = cubitBalance > 0 ? cubitBalance : sessionBalance;

        // Get order total from checkout session
        double orderTotal = 0;
        if (checkoutState is CheckoutSessionLoaded) {
          final session = checkoutState.session;
          orderTotal =
              session.cart.subtotal -
              (_appliedCoupon?.discountAmount ?? 0) +
              session.cart.shippingCost +
              session.cart.taxAmount;
        }

        final isSufficient = walletBalance >= orderTotal;
        final usageRatio = walletBalance > 0 && orderTotal > 0
            ? (orderTotal / walletBalance).clamp(0.0, 1.0)
            : 0.0;

        // Color based on sufficiency
        final Color statusColor = isSufficient
            ? AppColors.success
            : Colors.orange;

        return Container(
          margin: EdgeInsets.only(top: 8.h),
          padding: EdgeInsets.all(10.w),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.surfaceDark.withValues(alpha: 0.5)
                : AppColors.primary.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(
              color: isDark
                  ? AppColors.dividerDark
                  : AppColors.primary.withValues(alpha: 0.1),
              width: 0.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Available balance - highlighted
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Iconsax.wallet_money,
                        size: 14.sp,
                        color: statusColor,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        'الرصيد المتاح',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 12.sp,
                          color: isDark
                              ? Colors.white70
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${walletBalance.toStringAsFixed(2)} ${AppLocalizations.of(context)!.currency}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(4.r),
                child: LinearProgressIndicator(
                  value: usageRatio,
                  minHeight: 5.h,
                  backgroundColor: isDark
                      ? Colors.white12
                      : AppColors.dividerLight,
                  valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                ),
              ),
              SizedBox(height: 8.h),
              // Order total and remaining
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Order total
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'المطلوب: ',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 11.sp,
                          color: isDark
                              ? Colors.white54
                              : AppColors.textTertiaryLight,
                        ),
                      ),
                      Text(
                        '${orderTotal.toStringAsFixed(2)} ${AppLocalizations.of(context)!.currency}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? Colors.white70
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                  // Remaining balance after order
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'المتبقي: ',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 11.sp,
                          color: isDark
                              ? Colors.white54
                              : AppColors.textTertiaryLight,
                        ),
                      ),
                      Text(
                        '${(walletBalance - orderTotal).clamp(0, double.infinity).toStringAsFixed(2)} ${AppLocalizations.of(context)!.currency}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? Colors.white70
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // Warning if insufficient
              if (!isSufficient) ...[
                SizedBox(height: 8.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Iconsax.warning_2,
                        size: 14.sp,
                        color: Colors.orange,
                      ),
                      SizedBox(width: 6.w),
                      Expanded(
                        child: Text(
                          'الرصيد غير كافٍ. ينقصك ${(orderTotal - walletBalance).toStringAsFixed(2)} ${AppLocalizations.of(context)!.currency}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 11.sp,
                            color: Colors.orange.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildOrderSummary(
    ThemeData theme,
    bool isDark,
    CheckoutSessionEntity session,
  ) {
    final cart = session.cart;
    final couponDiscount = _appliedCoupon?.discountAmount ?? 0.0;
    final subtotal = cart.subtotal;
    final shippingCost = cart.shippingCost;
    final taxAmount = cart.taxAmount;
    final total = subtotal - couponDiscount + shippingCost + taxAmount;
    final walletAmountToUse = _calculateWalletAmountToUse(
      orderTotal: total,
      walletBalance: _resolveWalletBalance(),
    );
    final payableNow = (total - walletAmountToUse).clamp(0, total).toDouble();
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
          if (walletAmountToUse > 0) ...[
            _buildSummaryRow(
              theme,
              'المخصوم من المحفظة',
              '-${walletAmountToUse.toStringAsFixed(0)} ${AppLocalizations.of(context)!.currency}',
              valueColor: AppColors.success,
            ),
            SizedBox(height: 8.h),
            _buildSummaryRow(
              theme,
              'المتبقي للدفع الآن',
              '${payableNow.toStringAsFixed(0)} ${AppLocalizations.of(context)!.currency}',
            ),
            Divider(height: 24.h),
          ],
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

  PaymentMethodEntity? _getSelectedPaymentMethod(
    CheckoutSessionEntity session,
  ) {
    if (_selectedPaymentMethodId == null || session.paymentMethods.isEmpty) {
      return null;
    }

    return session.paymentMethods.firstWhere(
      (m) => m.id == _selectedPaymentMethodId,
      orElse: () => session.paymentMethods.first,
    );
  }

  double _resolveWalletBalance() {
    final walletState = context.read<WalletCubit>().state;
    if (walletState is WalletLoaded &&
        walletState.balance != null &&
        walletState.balance! > 0) {
      return walletState.balance!;
    }
    // Fallback: read from checkout session
    final checkoutState = context.read<CheckoutSessionCubit>().state;
    if (checkoutState is CheckoutSessionLoaded) {
      return checkoutState.session.customer.walletBalance;
    }
    return 0;
  }

  double _calculateWalletAmountToUse({
    required double orderTotal,
    required double walletBalance,
  }) {
    return walletBalance < orderTotal ? walletBalance : orderTotal;
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
    final selectedPaymentMethod = _getSelectedPaymentMethod(session);
    final walletAmountToUse = _calculateWalletAmountToUse(
      orderTotal: total,
      walletBalance: _resolveWalletBalance(),
    );
    final availableCredit = _resolveAvailableCredit(session);
    final payableNow = selectedPaymentMethod?.type == 'wallet'
        ? (total - walletAmountToUse - availableCredit)
              .clamp(0, total)
              .toDouble()
        : (total - walletAmountToUse).clamp(0, total).toDouble();
    final requiresTransferData =
        _isBankTransferMethod(selectedPaymentMethod) && payableNow > 0;

    // تفعيل الزر عند توفر: سلة غير فارغة + عنوان + طريقة دفع
    // التحقق من المخزون والمنتجات غير النشطة يبقى داخل _handlePlaceOrder مع رسالة للمستخدم
    final canPlaceOrder =
        session.cart.isNotEmpty &&
        _selectedAddressId != null &&
        session.addresses.isNotEmpty &&
        _selectedPaymentMethodId != null &&
        session.paymentMethods.isNotEmpty &&
        (!requiresTransferData ||
            (_receiptImagePath != null && _selectedBankAccountId != null));

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
              '${AppLocalizations.of(context)!.confirm} • ${payableNow.toStringAsFixed(0)} ${AppLocalizations.of(context)!.currency}',
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
      AppSnackbar.showError(context, 'السلة فارغة');
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
      final cartCubit = context.read<CartCubit>();
      final ordersCubit = context.read<OrdersCubit>();

      // محاولة المزامنة (اختياري - لا يمنع الطلب إذا فشل)
      try {
        await cartCubit.syncCart(silent: true);
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
        AppSnackbar.showError(context, 'يرجى اختيار عنوان التوصيل');
        return;
      }

      if (selectedPaymentMethod == null) {
        Navigator.of(context).pop(); // إغلاق مؤشر التحميل
        AppSnackbar.showError(context, 'يرجى اختيار طريقة الدفع');
        return;
      }

      // Map payment method
      final paymentMethod = OrderPaymentMethod.fromString(
        selectedPaymentMethod.orderPaymentMethodValue,
      );

      final orderTotal =
          session.cart.subtotal -
          (_appliedCoupon?.discountAmount ?? 0) +
          session.cart.shippingCost +
          session.cart.taxAmount;
      final walletBalance = _resolveWalletBalance();
      final walletAmountToUse = _calculateWalletAmountToUse(
        orderTotal: orderTotal,
        walletBalance: walletBalance,
      );
      final payableNow = (orderTotal - walletAmountToUse)
          .clamp(0, orderTotal)
          .toDouble();

      // Create shipping address model
      final shippingAddress = ShippingAddressModel(
        fullName: selectedAddress.recipientName ?? selectedAddress.label,
        phone: selectedAddress.phone ?? '',
        address: selectedAddress.addressLine,
        city: selectedAddress.cityName ?? '',
      );

      String? receiptImage;
      String? bankAccountId;
      String? transferReference;
      String? transferDate;
      String? transferNotes;

      if (paymentMethod == OrderPaymentMethod.bankTransfer && payableNow > 0) {
        if (_selectedBankAccountId == null) {
          Navigator.of(context).pop();
          AppSnackbar.showError(
            context,
            'يرجى اختيار البنك الذي تم التحويل إليه',
          );
          return;
        }

        if (_receiptImagePath == null) {
          Navigator.of(context).pop();
          AppSnackbar.showError(context, 'يرجى رفع إيصال التحويل البنكي');
          return;
        }

        bankAccountId = _selectedBankAccountId;
        final file = File(_receiptImagePath!);
        final bytes = await file.readAsBytes();
        receiptImage = base64Encode(bytes);
        transferReference = _transferReferenceController.text.trim().isNotEmpty
            ? _transferReferenceController.text.trim()
            : null;
        transferDate = _transferDate != null
            ? DateFormat('yyyy-MM-dd').format(_transferDate!)
            : null;
        transferNotes = _transferNotesController.text.trim().isNotEmpty
            ? _transferNotesController.text.trim()
            : null;
      }

      // Create order
      final order = await ordersCubit.createOrder(
        shippingAddressId: selectedAddress.id,
        shippingAddress: shippingAddress,
        paymentMethod: paymentMethod,
        couponCode: couponCode,
        bankAccountId: bankAccountId,
        receiptImage: receiptImage,
        transferReference: transferReference,
        transferDate: transferDate,
        transferNotes: transferNotes,
      );

      if (!mounted) return;
      Navigator.of(context).pop(); // إغلاق مؤشر التحميل

      if (order != null) {
        // Clear local cart after successful order
        await cartCubit.clearCartLocal();
        if (!mounted) return;

        context.go('/order-details/${order.id}');
      } else {
        AppSnackbar.showError(context, 'فشل إنشاء الطلب. حاول مرة أخرى.');
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop(); // إغلاق مؤشر التحميل
      AppSnackbar.showError(context, 'خطأ: ${e.toString()}');
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
      case 'apple_pay':
      case 'stc_pay':
        return Iconsax.card;
      case 'credit':
        return Iconsax.receipt_21;
      default:
        return Iconsax.money;
    }
  }

  List<PaymentMethodEntity> _buildDisplayPaymentMethods(
    List<PaymentMethodEntity> methods,
  ) {
    if (!_isWalletCreditMerged(methods)) {
      return methods;
    }

    return methods.where((method) => method.type != 'credit').toList();
  }

  bool _isWalletCreditMerged(List<PaymentMethodEntity> methods) {
    bool hasWallet = false;
    bool hasCredit = false;

    for (final method in methods) {
      if (method.type == 'wallet') hasWallet = true;
      if (method.type == 'credit') hasCredit = true;
    }

    return hasWallet && hasCredit;
  }

  double _resolveAvailableCredit(CheckoutSessionEntity session) {
    for (final method in session.paymentMethods) {
      if (method.type == 'credit') {
        return (method.availableCredit ?? 0).toDouble();
      }
    }

    return 0;
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
