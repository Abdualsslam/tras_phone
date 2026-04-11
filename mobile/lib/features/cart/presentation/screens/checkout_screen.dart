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
            if (_selectedAddressId == null &&
                state.session.addresses.isNotEmpty) {
              final defaultAddress = state.session.defaultAddress;
              if (defaultAddress != null) {
                setState(() => _selectedAddressId = defaultAddress.id);
              }
            }

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
            return _buildScaffoldShell(
              theme: theme,
              body: const Center(child: CircularProgressIndicator()),
            );
          }

          if (state is CheckoutSessionError) {
            return _buildScaffoldShell(
              theme: theme,
              body: AppError(
                title: 'حدث خطأ أثناء تحميل البيانات',
                message: state.message,
                onRetry: () =>
                    context.read<CheckoutSessionCubit>().loadSession(),
              ),
            );
          }

          return _buildScaffoldShell(
            theme: theme,
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
                        _buildAddressesSection(isDark),
                        SizedBox(height: 24.h),
                        _buildPaymentSection(isDark),
                        SizedBox(height: 24.h),
                        _buildBankTransferDetailsSection(isDark),
                        _buildWalletUsageSection(isDark),
                        SizedBox(height: 24.h),
                        _buildCouponSection(),
                        SizedBox(height: 24.h),
                        _buildSummarySection(theme, isDark),
                        SizedBox(height: 100.h),
                      ],
                    ),
                  ),
                ),
                _buildBottomBarSection(theme, isDark),
              ],
            ),
          );
        },
      ),
    );
  }

  Scaffold _buildScaffoldShell({
    required ThemeData theme,
    required Widget body,
  }) {
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.checkout),
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_right_3),
          onPressed: () => context.pop(),
        ),
      ),
      body: body,
    );
  }

  Widget _buildAddressesSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CheckoutSectionTitle(title: AppLocalizations.of(context)!.addresses),
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
            if (_selectedAddressId == null && addresses.isNotEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                final defaultAddress = addresses.firstWhere(
                  (a) => a.isDefault,
                  orElse: () => addresses.first,
                );
                setState(() => _selectedAddressId = defaultAddress.id);
              });
            }

            return CheckoutAddressSection(
              isDark: isDark,
              addresses: addresses,
              selectedAddressId: _selectedAddressId,
              addAddressLabel: AppLocalizations.of(context)!.addAddress,
              onAddAddress: _handleAddAddress,
              onSelectAddress: (address) {
                setState(() => _selectedAddressId = address.id);
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildPaymentSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CheckoutSectionTitle(
          title: AppLocalizations.of(context)!.paymentMethod,
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
            if (_isWalletCreditMerged(sessionState.session.paymentMethods)) {
              for (final method in sessionState.session.paymentMethods) {
                if (method.type == 'credit') {
                  mergedCreditMethod = method;
                  break;
                }
              }
            }

            final selectedIdExists = paymentMethods.any(
              (m) => m.id == _selectedPaymentMethodId,
            );
            if ((_selectedPaymentMethodId == null || !selectedIdExists) &&
                paymentMethods.isNotEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                final firstMethod = paymentMethods.first;
                setState(() => _selectedPaymentMethodId = firstMethod.id);
                _fetchBankAccountsIfNeeded(firstMethod);
              });
            }

            return CheckoutPaymentMethodsSection(
              isDark: isDark,
              paymentMethods: paymentMethods,
              selectedPaymentMethodId: _selectedPaymentMethodId,
              isWalletCreditMerged: _isWalletCreditMerged(
                sessionState.session.paymentMethods,
              ),
              mergedCreditMethod: mergedCreditMethod,
              onSelectMethod: _onSelectPaymentMethod,
              getPaymentMethodIcon: _getPaymentMethodIcon,
              buildDetails: (method, isSelected) {
                return [
                  if (method.type == 'wallet' && isSelected)
                    _buildWalletInfoPanel(isDark),
                  if (_isWalletCreditMerged(
                        sessionState.session.paymentMethods,
                      ) &&
                      method.type == 'wallet' &&
                      mergedCreditMethod != null &&
                      isSelected)
                    _buildCreditInfoPanel(isDark, mergedCreditMethod),
                  if (method.isCreditMethod && method.creditLimit != null)
                    _buildCreditInfoPanel(isDark, method),
                  if (_isBankTransferMethod(method) && isSelected)
                    _buildSupportedBanksPanel(isDark),
                ];
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildBankTransferDetailsSection(bool isDark) {
    return BlocBuilder<CheckoutSessionCubit, CheckoutSessionState>(
      builder: (context, sessionState) {
        if (sessionState is! CheckoutSessionLoaded) {
          return const SizedBox.shrink();
        }

        final selectedMethod = _getSelectedPaymentMethod(sessionState.session);
        if (!_isBankTransferMethod(selectedMethod)) {
          return const SizedBox.shrink();
        }

        if (!_hasRequestedBankAccounts && selectedMethod != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            _fetchBankAccountsIfNeeded(selectedMethod);
          });
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CheckoutSectionTitle(title: 'بيانات التحويل البنكي'),
            SizedBox(height: 12.h),
            _buildBankTransferSection(isDark),
            SizedBox(height: 24.h),
          ],
        );
      },
    );
  }

  Widget _buildWalletUsageSection(bool isDark) {
    return BlocBuilder<WalletCubit, WalletState>(
      builder: (context, walletState) {
        final checkoutState = context.read<CheckoutSessionCubit>().state;
        if (checkoutState is! CheckoutSessionLoaded) {
          return const SizedBox.shrink();
        }

        final session = checkoutState.session;
        if (!session.paymentMethods.any((m) => m.type == 'wallet')) {
          return const SizedBox.shrink();
        }

        final selectedMethod = _getSelectedPaymentMethod(session);
        final isWalletMethodSelected = selectedMethod?.type == 'wallet';
        final cubitWalletBalance = walletState is WalletLoaded
            ? (walletState.balance ?? 0)
            : 0.0;
        final walletBalance = cubitWalletBalance > 0
            ? cubitWalletBalance
            : session.customer.walletBalance;
        final orderTotal = _resolveOrderTotal(session);
        final availableCredit = _resolveAvailableCredit(session);
        final walletAutoUse = _calculateWalletAmountToUse(
          orderTotal: orderTotal,
          walletBalance: walletBalance,
        );
        final creditAutoUse =
            isWalletMethodSelected && orderTotal > walletAutoUse
            ? ((orderTotal - walletAutoUse) > availableCredit
                  ? availableCredit
                  : (orderTotal - walletAutoUse))
            : 0.0;
        final remainingAfterWalletAndCredit = isWalletMethodSelected
            ? (orderTotal - walletAutoUse - creditAutoUse)
                  .clamp(0, orderTotal)
                  .toDouble()
            : 0.0;

        return CheckoutWalletUsageCard(
          isDark: isDark,
          walletBalance: walletBalance,
          orderTotal: orderTotal,
          isWalletMethodSelected: isWalletMethodSelected,
          walletAutoUse: walletAutoUse,
          creditAutoUse: creditAutoUse,
          remainingAfterWalletAndCredit: remainingAfterWalletAndCredit,
        );
      },
    );
  }

  Widget _buildCouponSection() {
    return BlocBuilder<CheckoutSessionCubit, CheckoutSessionState>(
      builder: (context, _) {
        final session = context.read<CheckoutSessionCubit>().currentSession;
        final appliedCode = session?.coupon?.code ?? session?.cart.couponCode;
        final appliedDiscount = _resolveCouponDiscount(session);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CheckoutSectionTitle(title: 'كود الخصم'),
            SizedBox(height: 12.h),
            CouponInput(
              appliedCode: appliedCode,
              appliedDiscount: appliedDiscount,
              onApplyCoupon: (code) async {
                return context.read<CheckoutSessionCubit>().applyCoupon(code);
              },
              onRemoveCoupon: () async {
                await context.read<CheckoutSessionCubit>().removeCoupon();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildSummarySection(ThemeData theme, bool isDark) {
    return BlocBuilder<CheckoutSessionCubit, CheckoutSessionState>(
      builder: (context, sessionState) {
        if (sessionState is! CheckoutSessionLoaded) {
          return const SizedBox.shrink();
        }
        return _buildOrderSummary(theme, isDark, sessionState.session);
      },
    );
  }

  Widget _buildBottomBarSection(ThemeData theme, bool isDark) {
    return BlocBuilder<CheckoutSessionCubit, CheckoutSessionState>(
      builder: (context, sessionState) {
        if (sessionState is CheckoutSessionLoaded) {
          return _buildBottomBar(theme, isDark, sessionState.session);
        }
        return const SizedBox.shrink();
      },
    );
  }

  Future<void> _handleAddAddress() async {
    final result = await context.push('/address/add');
    if (result != true || !mounted) return;
    context.read<CheckoutSessionCubit>().refresh();
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
        'Ã˜ÂªÃ˜Â¹Ã˜Â°Ã˜Â± Ã˜ÂªÃ˜Â­Ã™â€¦Ã™Å Ã™â€ž Ã˜Â§Ã™â€žÃ˜Â­Ã˜Â³Ã˜Â§Ã˜Â¨Ã˜Â§Ã˜Âª Ã˜Â§Ã™â€žÃ˜Â¨Ã™â€ Ã™Æ’Ã™Å Ã˜Â©',
      );
    }
  }

  bool _isBankTransferMethod(PaymentMethodEntity? method) {
    return method?.orderPaymentMethodValue == 'bank_transfer';
  }

  Widget _buildBankTransferSection(bool isDark) {
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
                title: const Text(
                  'Ã˜Â§Ã™â€žÃ˜ÂªÃ™â€šÃ˜Â§Ã˜Â· Ã˜ÂµÃ™Ë†Ã˜Â±Ã˜Â©',
                ),
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
                title: const Text(
                  'Ã˜Â§Ã˜Â®Ã˜ÂªÃ™Å Ã˜Â§Ã˜Â± Ã™â€¦Ã™â€  Ã˜Â§Ã™â€žÃ™â€¦Ã˜Â¹Ã˜Â±Ã˜Â¶',
                ),
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

  Widget _buildCreditInfoPanel(bool isDark, PaymentMethodEntity method) {
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

  Widget _buildSupportedBanksPanel(bool isDark) {
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
      final message = isArabic
          ? 'Ã˜ÂªÃ™â€¦ Ã™â€ Ã˜Â³Ã˜Â® $label'
          : '$label copied';
      AppSnackbar.showSuccess(context, message);
    } catch (_) {
      if (!mounted) return;
      AppSnackbar.showError(
        context,
        'Ã˜ÂªÃ˜Â¹Ã˜Â°Ã˜Â± Ã™â€ Ã˜Â³Ã˜Â® Ã˜Â§Ã™â€žÃ˜Â¨Ã™Å Ã˜Â§Ã™â€ Ã˜Â§Ã˜Âª',
      );
    }
  }

  Widget _buildWalletInfoPanel(bool isDark) {
    final checkoutState = context.read<CheckoutSessionCubit>().state;
    final orderTotal = checkoutState is CheckoutSessionLoaded
        ? _resolveOrderTotal(checkoutState.session)
        : 0.0;

    return BlocBuilder<WalletCubit, WalletState>(
      builder: (context, walletState) {
        final cubitBalance = walletState is WalletLoaded
            ? (walletState.balance ?? 0)
            : 0.0;
        final sessionBalance = checkoutState is CheckoutSessionLoaded
            ? checkoutState.session.customer.walletBalance
            : 0.0;

        return CheckoutWalletInfoPanel(
          isDark: isDark,
          walletBalance: cubitBalance > 0 ? cubitBalance : sessionBalance,
          orderTotal: orderTotal,
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
    // Ã˜Â§Ã™â€žÃ˜ÂªÃ˜Â­Ã™â€šÃ™â€š Ã™â€¦Ã™â€  Ã˜Â£Ã™â€  Ã˜Â§Ã™â€žÃ˜Â³Ã™â€žÃ˜Â© Ã™â€žÃ™Å Ã˜Â³Ã˜Âª Ã™ÂÃ˜Â§Ã˜Â±Ã˜ÂºÃ˜Â©
    if (session.cart.isEmpty) {
      AppSnackbar.showError(
        context,
        'Ã˜Â§Ã™â€žÃ˜Â³Ã™â€žÃ˜Â© Ã™ÂÃ˜Â§Ã˜Â±Ã˜ÂºÃ˜Â©',
      );
      return;
    }

    HapticFeedback.mediumImpact();

    // Ã˜Â¹Ã˜Â±Ã˜Â¶ Ã™â€¦Ã˜Â¤Ã˜Â´Ã˜Â± Ã˜Â§Ã™â€žÃ˜ÂªÃ˜Â­Ã™â€¦Ã™Å Ã™â€ž
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final cartCubit = context.read<CartCubit>();
      final ordersCubit = context.read<OrdersCubit>();

      // Ã™â€¦Ã˜Â­Ã˜Â§Ã™Ë†Ã™â€žÃ˜Â© Ã˜Â§Ã™â€žÃ™â€¦Ã˜Â²Ã˜Â§Ã™â€¦Ã™â€ Ã˜Â© (Ã˜Â§Ã˜Â®Ã˜ÂªÃ™Å Ã˜Â§Ã˜Â±Ã™Å  - Ã™â€žÃ˜Â§ Ã™Å Ã™â€¦Ã™â€ Ã˜Â¹ Ã˜Â§Ã™â€žÃ˜Â·Ã™â€žÃ˜Â¨ Ã˜Â¥Ã˜Â°Ã˜Â§ Ã™ÂÃ˜Â´Ã™â€ž)
      try {
        await cartCubit.syncCart(silent: true);
      } catch (_) {
        // Ã˜ÂªÃ˜Â¬Ã˜Â§Ã™â€¡Ã™â€ž Ã˜Â£Ã˜Â®Ã˜Â·Ã˜Â§Ã˜Â¡ Ã˜Â§Ã™â€žÃ™â€¦Ã˜Â²Ã˜Â§Ã™â€¦Ã™â€ Ã˜Â© - Ã˜Â³Ã™Å Ã˜ÂªÃ˜Â­Ã™â€šÃ™â€š Ã˜Â§Ã™â€žÃ˜Â³Ã™Å Ã˜Â±Ã™ÂÃ˜Â± Ã˜Â¹Ã™â€ Ã˜Â¯ Ã˜Â¥Ã™â€ Ã˜Â´Ã˜Â§Ã˜Â¡ Ã˜Â§Ã™â€žÃ˜Â·Ã™â€žÃ˜Â¨
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
        Navigator.of(
          context,
        ).pop(); // Ã˜Â¥Ã˜ÂºÃ™â€žÃ˜Â§Ã™â€š Ã™â€¦Ã˜Â¤Ã˜Â´Ã˜Â± Ã˜Â§Ã™â€žÃ˜ÂªÃ˜Â­Ã™â€¦Ã™Å Ã™â€ž
        AppSnackbar.showError(
          context,
          'Ã™Å Ã˜Â±Ã˜Â¬Ã™â€° Ã˜Â§Ã˜Â®Ã˜ÂªÃ™Å Ã˜Â§Ã˜Â± Ã˜Â¹Ã™â€ Ã™Ë†Ã˜Â§Ã™â€  Ã˜Â§Ã™â€žÃ˜ÂªÃ™Ë†Ã˜ÂµÃ™Å Ã™â€ž',
        );
        return;
      }

      if (selectedPaymentMethod == null) {
        Navigator.of(
          context,
        ).pop(); // Ã˜Â¥Ã˜ÂºÃ™â€žÃ˜Â§Ã™â€š Ã™â€¦Ã˜Â¤Ã˜Â´Ã˜Â± Ã˜Â§Ã™â€žÃ˜ÂªÃ˜Â­Ã™â€¦Ã™Å Ã™â€ž
        AppSnackbar.showError(
          context,
          'Ã™Å Ã˜Â±Ã˜Â¬Ã™â€° Ã˜Â§Ã˜Â®Ã˜ÂªÃ™Å Ã˜Â§Ã˜Â± Ã˜Â·Ã˜Â±Ã™Å Ã™â€šÃ˜Â© Ã˜Â§Ã™â€žÃ˜Â¯Ã™ÂÃ˜Â¹',
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
            'Ã™Å Ã˜Â±Ã˜Â¬Ã™â€° Ã˜Â§Ã˜Â®Ã˜ÂªÃ™Å Ã˜Â§Ã˜Â± Ã˜Â§Ã™â€žÃ˜Â¨Ã™â€ Ã™Æ’ Ã˜Â§Ã™â€žÃ˜Â°Ã™Å  Ã˜ÂªÃ™â€¦ Ã˜Â§Ã™â€žÃ˜ÂªÃ˜Â­Ã™Ë†Ã™Å Ã™â€ž Ã˜Â¥Ã™â€žÃ™Å Ã™â€¡',
          );
          return;
        }

        if (_receiptImagePath == null) {
          Navigator.of(context).pop();
          AppSnackbar.showError(
            context,
            'Ã™Å Ã˜Â±Ã˜Â¬Ã™â€° Ã˜Â±Ã™ÂÃ˜Â¹ Ã˜Â¥Ã™Å Ã˜ÂµÃ˜Â§Ã™â€ž Ã˜Â§Ã™â€žÃ˜ÂªÃ˜Â­Ã™Ë†Ã™Å Ã™â€ž Ã˜Â§Ã™â€žÃ˜Â¨Ã™â€ Ã™Æ’Ã™Å ',
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
      Navigator.of(
        context,
      ).pop(); // Ã˜Â¥Ã˜ÂºÃ™â€žÃ˜Â§Ã™â€š Ã™â€¦Ã˜Â¤Ã˜Â´Ã˜Â± Ã˜Â§Ã™â€žÃ˜ÂªÃ˜Â­Ã™â€¦Ã™Å Ã™â€ž

      if (order != null) {
        // Clear local cart after successful order
        await cartCubit.clearCartLocal();
        if (!mounted) return;

        context.go('/order-details/${order.id}');
      } else {
        AppSnackbar.showError(
          context,
          'Ã™ÂÃ˜Â´Ã™â€ž Ã˜Â¥Ã™â€ Ã˜Â´Ã˜Â§Ã˜Â¡ Ã˜Â§Ã™â€žÃ˜Â·Ã™â€žÃ˜Â¨. Ã˜Â­Ã˜Â§Ã™Ë†Ã™â€ž Ã™â€¦Ã˜Â±Ã˜Â© Ã˜Â£Ã˜Â®Ã˜Â±Ã™â€°.',
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.of(
        context,
      ).pop(); // Ã˜Â¥Ã˜ÂºÃ™â€žÃ˜Â§Ã™â€š Ã™â€¦Ã˜Â¤Ã˜Â´Ã˜Â± Ã˜Â§Ã™â€žÃ˜ÂªÃ˜Â­Ã™â€¦Ã™Å Ã™â€ž
      AppSnackbar.showError(context, 'Ã˜Â®Ã˜Â·Ã˜Â£: ${e.toString()}');
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
