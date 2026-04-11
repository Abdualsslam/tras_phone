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
import '../../../../core/config/theme/app_colors.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../promotions/presentation/widgets/coupon_input.dart';
import '../../domain/entities/checkout_session_entity.dart';
import '../widgets/checkout_sections.dart';
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

  final TextEditingController _transferNotesController =
      TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

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
                title: 'Ø­Ø¯Ø« Ø®Ø·Ø£ Ø£Ø«Ù†Ø§Ø¡ ØªØ­Ù…ÙŠÙ„ Ø§Ù„Ø¨ÙŠØ§Ù†Ø§Øª',
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
                                      'Ù„Ø§ ØªÙˆØ¬Ø¯ Ø¹Ù†Ø§ÙˆÙŠÙ† Ù…ØªØ§Ø­Ø©',
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
                                      'Ù„Ø§ ØªÙˆØ¬Ø¯ Ø·Ø±Ù‚ Ø¯ÙØ¹ Ù…ØªØ§Ø­Ø©',
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
                                  'Ø¨ÙŠØ§Ù†Ø§Øª Ø§Ù„ØªØ­ÙˆÙŠÙ„ Ø§Ù„Ø¨Ù†ÙƒÙŠ',
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
                            final orderTotal = _resolveOrderTotal(session);
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
                                          'Ø§Ø³ØªØ®Ø¯Ø§Ù… Ø±ØµÙŠØ¯ Ø§Ù„Ù…Ø­ÙØ¸Ø©',
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
                                          'ØªÙ… Ø§Ø®ØªÙŠØ§Ø± Ø§Ù„Ø¯ÙØ¹ Ø¨Ø§Ù„Ù…Ø­ÙØ¸Ø©ØŒ Ø³ÙŠØªÙ… Ø§Ù„Ø®ØµÙ… Ù…Ù† Ø§Ù„Ù…Ø­ÙØ¸Ø© Ø£ÙˆÙ„Ø§Ù‹ Ø«Ù… Ù…Ù† Ø­Ø¯ Ø§Ù„Ø§Ø¦ØªÙ…Ø§Ù† ØªÙ„Ù‚Ø§Ø¦ÙŠØ§Ù‹.',
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                                color: AppColors
                                                    .textSecondaryLight,
                                              ),
                                        ),
                                        SizedBox(height: 8.h),
                                        Text(
                                          'Ù…Ù† Ø§Ù„Ù…Ø­ÙØ¸Ø©: ${walletAutoUse.toStringAsFixed(2)} ${AppLocalizations.of(context)!.currency}',
                                          style: theme.textTheme.bodySmall,
                                        ),
                                        Text(
                                          'Ù…Ù† Ø§Ù„Ø§Ø¦ØªÙ…Ø§Ù†: ${creditAutoUse.toStringAsFixed(2)} ${AppLocalizations.of(context)!.currency}',
                                          style: theme.textTheme.bodySmall,
                                        ),
                                        if (remainingAfterWalletAndCredit > 0)
                                          Text(
                                            'Ø§Ù„Ù…ØªØ¨Ù‚ÙŠ Ø¨Ø¹Ø¯ Ø§Ù„Ù…Ø­ÙØ¸Ø© ÙˆØ§Ù„Ø§Ø¦ØªÙ…Ø§Ù†: ${remainingAfterWalletAndCredit.toStringAsFixed(2)} ${AppLocalizations.of(context)!.currency}',
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
                                      'Ø³ÙŠØªÙ… Ø§Ù„Ø®ØµÙ… ØªÙ„Ù‚Ø§Ø¦ÙŠØ§Ù‹ Ù…Ù† Ø§Ù„Ù…Ø­ÙØ¸Ø© Ø£ÙˆÙ„Ø§Ù‹ ÙÙŠ Ø¬Ù…ÙŠØ¹ Ø§Ù„Ø·Ù„Ø¨Ø§Øª.',
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: AppColors.textSecondaryLight,
                                          ),
                                    ),
                                    SizedBox(height: 8.h),
                                    Text(
                                      'Ø§Ù„Ù…Ø®ØµÙˆÙ… ØªÙ„Ù‚Ø§Ø¦ÙŠØ§Ù‹: ${walletAutoUse.toStringAsFixed(2)} ${AppLocalizations.of(context)!.currency}',
                                      style: theme.textTheme.bodySmall,
                                    ),
                                    Text(
                                      'Ø§Ù„Ù…ØªØ¨Ù‚ÙŠ Ø¨Ø¹Ø¯ Ø§Ù„Ù…Ø­ÙØ¸Ø©: ${(orderTotal - walletAutoUse).clamp(0, orderTotal).toStringAsFixed(2)} ${AppLocalizations.of(context)!.currency}',
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
                          builder: (context, _) {
                            final session = context
                                .read<CheckoutSessionCubit>()
                                .currentSession;
                            final appliedCode =
                                session?.coupon?.code ??
                                session?.cart.couponCode;
                            final appliedDiscount = _resolveCouponDiscount(
                              session,
                            );

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSectionTitle(theme, 'ÙƒÙˆØ¯ Ø§Ù„Ø®ØµÙ…'),
                                SizedBox(height: 12.h),
                                CouponInput(
                                  appliedCode: appliedCode,
                                  appliedDiscount: appliedDiscount,
                                  onApplyCoupon: (code) async {
                                    return context
                                        .read<CheckoutSessionCubit>()
                                        .applyCoupon(code);
                                  },
                                  onRemoveCoupon: () async {
                                    await context
                                        .read<CheckoutSessionCubit>()
                                        .removeCoupon();
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
      AppSnackbar.showError(
        context,
        'ØªØ¹Ø°Ø± ØªØ­Ù…ÙŠÙ„ Ø§Ù„Ø­Ø³Ø§Ø¨Ø§Øª Ø§Ù„Ø¨Ù†ÙƒÙŠØ©',
      );
    }
  }

  bool _isBankTransferMethod(PaymentMethodEntity? method) {
    return method?.orderPaymentMethodValue == 'bank_transfer';
  }

  Widget _buildBankTransferSection(ThemeData theme, bool isDark) {
    return CheckoutTransferReceiptSection(
      isDark: isDark,
      receiptImagePath: _receiptImagePath,
      transferNotesController: _transferNotesController,
      onPickImage: _pickTransferReceiptImage,
      onClearImage: () => setState(() => _receiptImagePath = null),
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
                title: const Text('Ø§Ù„ØªÙ‚Ø§Ø· ØµÙˆØ±Ø©'),
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
                title: const Text('Ø§Ø®ØªÙŠØ§Ø± Ù…Ù† Ø§Ù„Ù…Ø¹Ø±Ø¶'),
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
    return CheckoutAddressCard(
      address: address,
      isSelected: isSelected,
      isDark: isDark,
      onTap: () => setState(() => _selectedAddressId = address.id),
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
        ? 'Wallet + Credit'
        : method.getName(locale);
    final displayDescription = isWalletCreditMerged && method.type == 'wallet'
        ? 'Wallet balance is used first, then available credit.'
        : method.getDescription(locale);
    return CheckoutPaymentCard(
      isDark: isDark,
      isSelected: isSelected,
      iconData: iconData,
      displayName: displayName,
      displayDescription: displayDescription,
      onTap: () => _onSelectPaymentMethod(method),
      details: [
        if (method.type == 'wallet' && isSelected)
          _buildWalletInfoPanel(theme, isDark),
        if (isWalletCreditMerged &&
            method.type == 'wallet' &&
            mergedCreditMethod != null &&
            isSelected)
          _buildCreditInfoPanel(theme, isDark, mergedCreditMethod),
        if (method.isCreditMethod && method.creditLimit != null)
          _buildCreditInfoPanel(theme, isDark, method),
        if (_isBankTransferMethod(method) && isSelected)
          _buildSupportedBanksPanel(theme, isDark),
      ],
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
    return CheckoutCreditInfoPanel(
      isDark: isDark,
      creditLimit: creditLimit,
      creditUsed: creditUsed,
      availableCredit: availableCredit,
    );
  }

  Widget _buildSupportedBanksPanel(ThemeData theme, bool isDark) {
    return CheckoutSupportedBanksPanel(
      isDark: isDark,
      isLoading: _isLoadingBankAccounts,
      bankAccounts: _bankAccounts,
      selectedBankAccountId: _selectedBankAccountId,
      onSelectBankAccount: (bankId) =>
          setState(() => _selectedBankAccountId = bankId),
      onCopyValue: _copyBankValue,
    );
  }

  Future<void> _copyBankValue(String value, String label) async {
    try {
      await Clipboard.setData(ClipboardData(text: value));
      if (!mounted) return;

      final isArabic = Localizations.localeOf(context).languageCode == 'ar';
      final message = isArabic ? 'ØªÙ… Ù†Ø³Ø® $label' : '$label copied';
      AppSnackbar.showSuccess(context, message);
    } catch (_) {
      if (!mounted) return;
      AppSnackbar.showError(context, 'ØªØ¹Ø°Ø± Ù†Ø³Ø® Ø§Ù„Ø¨ÙŠØ§Ù†Ø§Øª');
    }
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
          orderTotal = _resolveOrderTotal(checkoutState.session);
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
                        'Ø§Ù„Ø±ØµÙŠØ¯ Ø§Ù„Ù…ØªØ§Ø­',
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
                        'Ø§Ù„Ù…Ø·Ù„ÙˆØ¨: ',
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
                        'Ø§Ù„Ù…ØªØ¨Ù‚ÙŠ: ',
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
                          'Ø§Ù„Ø±ØµÙŠØ¯ ØºÙŠØ± ÙƒØ§ÙÙ. ÙŠÙ†Ù‚ØµÙƒ ${(orderTotal - walletBalance).toStringAsFixed(2)} ${AppLocalizations.of(context)!.currency}',
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
    final total = _resolveOrderTotal(session);
    final walletAmountToUse = _calculateWalletAmountToUse(
      orderTotal: total,
      walletBalance: _resolveWalletBalance(),
    );
    final payableNow = (total - walletAmountToUse).clamp(0, total).toDouble();
    return CheckoutOrderSummaryCard(
      session: session,
      couponDiscount: _resolveCouponDiscount(session),
      total: total,
      walletAmountToUse: walletAmountToUse,
      payableNow: payableNow,
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

  double _resolveCouponDiscount(CheckoutSessionEntity? session) {
    if (session == null) return 0;
    final sessionCouponDiscount = (session.coupon?.discountAmount ?? 0)
        .toDouble();
    if (sessionCouponDiscount > 0) return sessionCouponDiscount;
    return session.cart.couponDiscount;
  }

  double _resolveOrderTotal(CheckoutSessionEntity session) {
    final cartTotal = session.cart.total;
    if (cartTotal.isFinite) {
      return cartTotal;
    }
    return session.cart.subtotal -
        session.cart.discount -
        _resolveCouponDiscount(session) +
        session.cart.shippingCost +
        session.cart.taxAmount;
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
    final total = _resolveOrderTotal(session);
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
    final canPlaceOrder =
        session.cart.isNotEmpty &&
        _selectedAddressId != null &&
        session.addresses.isNotEmpty &&
        _selectedPaymentMethodId != null &&
        session.paymentMethods.isNotEmpty &&
        (!requiresTransferData ||
            (_receiptImagePath != null && _selectedBankAccountId != null));
    return CheckoutPlaceOrderBar(
      isDark: isDark,
      canPlaceOrder: canPlaceOrder,
      payableNow: payableNow,
      onPlaceOrder: canPlaceOrder ? () => _handlePlaceOrder(session) : null,
    );
  }

  Future<void> _handlePlaceOrder(CheckoutSessionEntity session) async {
    // Ø§Ù„ØªØ­Ù‚Ù‚ Ù…Ù† Ø£Ù† Ø§Ù„Ø³Ù„Ø© Ù„ÙŠØ³Øª ÙØ§Ø±ØºØ©
    if (session.cart.isEmpty) {
      AppSnackbar.showError(context, 'Ø§Ù„Ø³Ù„Ø© ÙØ§Ø±ØºØ©');
      return;
    }

    HapticFeedback.mediumImpact();

    // Ø¹Ø±Ø¶ Ù…Ø¤Ø´Ø± Ø§Ù„ØªØ­Ù…ÙŠÙ„
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final cartCubit = context.read<CartCubit>();
      final ordersCubit = context.read<OrdersCubit>();

      // Ù…Ø­Ø§ÙˆÙ„Ø© Ø§Ù„Ù…Ø²Ø§Ù…Ù†Ø© (Ø§Ø®ØªÙŠØ§Ø±ÙŠ - Ù„Ø§ ÙŠÙ…Ù†Ø¹ Ø§Ù„Ø·Ù„Ø¨ Ø¥Ø°Ø§ ÙØ´Ù„)
      try {
        await cartCubit.syncCart(silent: true);
      } catch (_) {
        // ØªØ¬Ø§Ù‡Ù„ Ø£Ø®Ø·Ø§Ø¡ Ø§Ù„Ù…Ø²Ø§Ù…Ù†Ø© - Ø³ÙŠØªØ­Ù‚Ù‚ Ø§Ù„Ø³ÙŠØ±ÙØ± Ø¹Ù†Ø¯ Ø¥Ù†Ø´Ø§Ø¡ Ø§Ù„Ø·Ù„Ø¨
      }

      if (!mounted) return;

      // Get coupon code if applied (session coupon first, then cart coupon)
      final couponCode = (session.coupon?.code?.trim().isNotEmpty ?? false)
          ? session.coupon!.code!.trim()
          : ((session.cart.couponCode?.trim().isNotEmpty ?? false)
                ? session.cart.couponCode!.trim()
                : null);

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
        Navigator.of(context).pop(); // Ø¥ØºÙ„Ø§Ù‚ Ù…Ø¤Ø´Ø± Ø§Ù„ØªØ­Ù…ÙŠÙ„
        AppSnackbar.showError(
          context,
          'ÙŠØ±Ø¬Ù‰ Ø§Ø®ØªÙŠØ§Ø± Ø¹Ù†ÙˆØ§Ù† Ø§Ù„ØªÙˆØµÙŠÙ„',
        );
        return;
      }

      if (selectedPaymentMethod == null) {
        Navigator.of(context).pop(); // Ø¥ØºÙ„Ø§Ù‚ Ù…Ø¤Ø´Ø± Ø§Ù„ØªØ­Ù…ÙŠÙ„
        AppSnackbar.showError(
          context,
          'ÙŠØ±Ø¬Ù‰ Ø§Ø®ØªÙŠØ§Ø± Ø·Ø±ÙŠÙ‚Ø© Ø§Ù„Ø¯ÙØ¹',
        );
        return;
      }

      // Map payment method
      final paymentMethod = OrderPaymentMethod.fromString(
        selectedPaymentMethod.orderPaymentMethodValue,
      );

      final orderTotal = _resolveOrderTotal(session);
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
            'ÙŠØ±Ø¬Ù‰ Ø§Ø®ØªÙŠØ§Ø± Ø§Ù„Ø¨Ù†Ùƒ Ø§Ù„Ø°ÙŠ ØªÙ… Ø§Ù„ØªØ­ÙˆÙŠÙ„ Ø¥Ù„ÙŠÙ‡',
          );
          return;
        }

        if (_receiptImagePath == null) {
          Navigator.of(context).pop();
          AppSnackbar.showError(
            context,
            'ÙŠØ±Ø¬Ù‰ Ø±ÙØ¹ Ø¥ÙŠØµØ§Ù„ Ø§Ù„ØªØ­ÙˆÙŠÙ„ Ø§Ù„Ø¨Ù†ÙƒÙŠ',
          );
          return;
        }

        bankAccountId = _selectedBankAccountId;
        final file = File(_receiptImagePath!);
        final bytes = await file.readAsBytes();
        receiptImage = base64Encode(bytes);
        transferReference = null;
        transferDate = null;
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
      Navigator.of(context).pop(); // Ø¥ØºÙ„Ø§Ù‚ Ù…Ø¤Ø´Ø± Ø§Ù„ØªØ­Ù…ÙŠÙ„

      if (order != null) {
        // Clear local cart after successful order
        await cartCubit.clearCartLocal();
        if (!mounted) return;

        context.go('/order-details/${order.id}');
      } else {
        AppSnackbar.showError(
          context,
          'ÙØ´Ù„ Ø¥Ù†Ø´Ø§Ø¡ Ø§Ù„Ø·Ù„Ø¨. Ø­Ø§ÙˆÙ„ Ù…Ø±Ø© Ø£Ø®Ø±Ù‰.',
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop(); // Ø¥ØºÙ„Ø§Ù‚ Ù…Ø¤Ø´Ø± Ø§Ù„ØªØ­Ù…ÙŠÙ„
      AppSnackbar.showError(context, 'Ø®Ø·Ø£: ${e.toString()}');
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
