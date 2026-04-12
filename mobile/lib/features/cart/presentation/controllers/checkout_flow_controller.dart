import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/widgets/widgets.dart';
import '../../../orders/data/models/shipping_address_model.dart';
import '../../../orders/domain/entities/bank_account_entity.dart';
import '../../../orders/domain/entities/payment_method_entity.dart';
import '../../../orders/domain/enums/order_enums.dart';
import '../../../orders/presentation/cubit/orders_cubit.dart';
import '../../../orders/presentation/cubit/orders_state.dart';
import '../../../profile/domain/entities/address_entity.dart';
import '../../../wallet/presentation/cubit/wallet_cubit.dart';
import '../../../wallet/presentation/cubit/wallet_state.dart';
import '../../domain/entities/checkout_session_entity.dart';
import '../cubit/cart_cubit.dart';
import '../cubit/checkout_session_cubit.dart';
import '../cubit/checkout_session_state.dart';

class CheckoutFlowState {
  String? selectedAddressId;
  String? selectedPaymentMethodId;
  String? receiptImagePath;
  String? selectedBankAccountId;
  bool isLoadingBankAccounts = false;
  bool hasRequestedBankAccounts = false;
  List<BankAccountEntity> bankAccounts = const [];
}

class CheckoutFlowController {
  final BuildContext context;
  final CheckoutFlowState state;
  final TextEditingController transferNotesController;
  final ImagePicker imagePicker;
  final void Function(VoidCallback fn) updateState;
  final bool Function() isMounted;

  CheckoutFlowController({
    required this.context,
    required this.state,
    required this.transferNotesController,
    required this.imagePicker,
    required this.updateState,
    required this.isMounted,
  });

  void syncLoadedSession(CheckoutSessionEntity session) {
    if (state.selectedAddressId == null && session.addresses.isNotEmpty) {
      final defaultAddress = session.defaultAddress ?? session.addresses.first;
      updateState(() => state.selectedAddressId = defaultAddress.id);
    }

    final paymentMethods = buildDisplayPaymentMethods(session.paymentMethods);
    final selectedIdExists = paymentMethods.any(
      (method) => method.id == state.selectedPaymentMethodId,
    );

    if ((state.selectedPaymentMethodId == null || !selectedIdExists) &&
        paymentMethods.isNotEmpty) {
      final firstMethod = paymentMethods.first;
      updateState(() => state.selectedPaymentMethodId = firstMethod.id);
      fetchBankAccountsIfNeeded(firstMethod);
    }
  }

  void updateBankAccounts(List<BankAccountEntity> accounts) {
    String? nextSelectedBankId = state.selectedBankAccountId;
    final hasCurrent = accounts.any(
      (account) => account.id == state.selectedBankAccountId,
    );

    if (!hasCurrent) {
      final defaultAccount = accounts.where((account) => account.isDefault);
      if (defaultAccount.isNotEmpty) {
        nextSelectedBankId = defaultAccount.first.id;
      } else if (accounts.isNotEmpty) {
        nextSelectedBankId = accounts.first.id;
      } else {
        nextSelectedBankId = null;
      }
    }

    updateState(() {
      state.bankAccounts = accounts;
      state.selectedBankAccountId = nextSelectedBankId;
      state.isLoadingBankAccounts = false;
    });
  }

  Future<void> handleAddAddress() async {
    final result = await context.push('/address/add');
    if (result != true || !context.mounted) return;
    context.read<CheckoutSessionCubit>().refresh();
  }

  void onSelectAddress(AddressEntity address) {
    updateState(() => state.selectedAddressId = address.id);
  }

  void onSelectPaymentMethod(PaymentMethodEntity method) {
    updateState(() {
      state.selectedPaymentMethodId = method.id;
      if (!isBankTransferMethod(method)) {
        state.selectedBankAccountId = null;
      }
    });
    fetchBankAccountsIfNeeded(method);
  }

  Future<void> fetchBankAccountsIfNeeded(PaymentMethodEntity method) async {
    if (!isBankTransferMethod(method)) return;

    if (state.hasRequestedBankAccounts) {
      if (state.selectedBankAccountId == null &&
          state.bankAccounts.isNotEmpty) {
        final defaultAccount = state.bankAccounts.where((a) => a.isDefault);
        updateState(() {
          state.selectedBankAccountId = defaultAccount.isNotEmpty
              ? defaultAccount.first.id
              : state.bankAccounts.first.id;
        });
      }
      return;
    }

    updateState(() {
      state.hasRequestedBankAccounts = true;
      state.isLoadingBankAccounts = true;
    });

    await context.read<OrdersCubit>().loadBankAccounts();
    if (!context.mounted) return;

    if (state.isLoadingBankAccounts) {
      updateState(() => state.isLoadingBankAccounts = false);
    }

    final ordersState = context.read<OrdersCubit>().state;
    if (ordersState is OrdersError && state.bankAccounts.isEmpty) {
      AppSnackbar.showError(context, 'تعذر تحميل الحسابات البنكية');
    }
  }

  void clearReceiptImage() {
    updateState(() => state.receiptImagePath = null);
  }

  Future<void> pickTransferReceiptImage() async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Iconsax.camera),
                title: const Text('التقاط صورة'),
                onTap: () =>
                    _pickImageFromSource(sheetContext, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Iconsax.gallery),
                title: const Text('اختيار من المعرض'),
                onTap: () =>
                    _pickImageFromSource(sheetContext, ImageSource.gallery),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImageFromSource(
    BuildContext sheetContext,
    ImageSource source,
  ) async {
    Navigator.pop(sheetContext);
    final xFile = await imagePicker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1920,
    );
    if (xFile == null || !isMounted()) return;
    updateState(() => state.receiptImagePath = xFile.path);
  }

  void selectBankAccount(String bankId) {
    updateState(() => state.selectedBankAccountId = bankId);
  }

  Future<void> copyBankValue(String value, String label) async {
    try {
      await Clipboard.setData(ClipboardData(text: value));
      if (!context.mounted) return;

      final isArabic = Localizations.localeOf(context).languageCode == 'ar';
      AppSnackbar.showSuccess(
        context,
        isArabic ? 'تم نسخ $label' : '$label copied',
      );
    } catch (_) {
      if (!context.mounted) return;
      AppSnackbar.showError(context, 'تعذر نسخ البيانات');
    }
  }

  Future<void> handlePlaceOrder(CheckoutSessionEntity session) async {
    if (session.cart.isEmpty) {
      AppSnackbar.showError(context, 'السلة فارغة');
      return;
    }

    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final cartCubit = context.read<CartCubit>();
      final ordersCubit = context.read<OrdersCubit>();

      try {
        await cartCubit.syncCart(silent: true);
      } catch (_) {}

      if (!context.mounted) return;

      final couponCode = (session.coupon?.code?.trim().isNotEmpty ?? false)
          ? session.coupon!.code!.trim()
          : ((session.cart.couponCode?.trim().isNotEmpty ?? false)
                ? session.cart.couponCode!.trim()
                : null);

      final selectedAddress = _resolveSelectedAddress(session);
      final selectedPaymentMethod = getSelectedPaymentMethod(
        session,
        state.selectedPaymentMethodId,
      );

      if (selectedAddress == null) {
        Navigator.of(context).pop();
        AppSnackbar.showError(context, 'يرجى اختيار عنوان التوصيل');
        return;
      }

      if (selectedPaymentMethod == null) {
        Navigator.of(context).pop();
        AppSnackbar.showError(context, 'يرجى اختيار طريقة الدفع');
        return;
      }

      final paymentMethod = OrderPaymentMethod.fromString(
        selectedPaymentMethod.orderPaymentMethodValue,
      );
      final orderTotal = resolveOrderTotal(session);
      final walletAmountToUse = calculateWalletAmountToUse(
        orderTotal: orderTotal,
        walletBalance: resolveWalletBalance(context),
      );
      final payableNow = (orderTotal - walletAmountToUse)
          .clamp(0, orderTotal)
          .toDouble();

      final shippingAddress = ShippingAddressModel(
        fullName: selectedAddress.recipientName ?? selectedAddress.label,
        phone: selectedAddress.phone ?? '',
        address: selectedAddress.addressLine,
        city: selectedAddress.cityName ?? '',
      );

      String? receiptImage;
      String? bankAccountId;
      String? transferNotes;

      if (paymentMethod == OrderPaymentMethod.bankTransfer && payableNow > 0) {
        if (state.selectedBankAccountId == null) {
          Navigator.of(context).pop();
          AppSnackbar.showError(
            context,
            'يرجى اختيار البنك الذي تم التحويل إليه',
          );
          return;
        }

        if (state.receiptImagePath == null) {
          Navigator.of(context).pop();
          AppSnackbar.showError(context, 'يرجى رفع إيصال التحويل البنكي');
          return;
        }

        bankAccountId = state.selectedBankAccountId;
        final file = File(state.receiptImagePath!);
        receiptImage = base64Encode(await file.readAsBytes());
        transferNotes = transferNotesController.text.trim().isNotEmpty
            ? transferNotesController.text.trim()
            : null;
      }

      final order = await ordersCubit.createOrder(
        shippingAddressId: selectedAddress.id,
        shippingAddress: shippingAddress,
        paymentMethod: paymentMethod,
        couponCode: couponCode,
        bankAccountId: bankAccountId,
        receiptImage: receiptImage,
        transferReference: null,
        transferDate: null,
        transferNotes: transferNotes,
      );

      if (!context.mounted) return;
      Navigator.of(context).pop();

      if (order == null) {
        AppSnackbar.showError(context, 'فشل إنشاء الطلب. حاول مرة أخرى.');
        return;
      }

      await cartCubit.clearCartLocal();
      if (!context.mounted) return;
      context.go('/order-details/${order.id}');
    } catch (error) {
      if (!context.mounted) return;
      Navigator.of(context).pop();
      AppSnackbar.showError(context, 'خطأ: ${error.toString()}');
    }
  }

  AddressEntity? _resolveSelectedAddress(CheckoutSessionEntity session) {
    if (state.selectedAddressId == null || session.addresses.isEmpty) {
      return null;
    }

    return session.addresses.firstWhere(
      (address) => address.id == state.selectedAddressId,
      orElse: () => session.addresses.first,
    );
  }

  static bool isBankTransferMethod(PaymentMethodEntity? method) {
    return method?.orderPaymentMethodValue == 'bank_transfer';
  }

  static IconData getPaymentMethodIcon(String type) {
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

  static List<PaymentMethodEntity> buildDisplayPaymentMethods(
    List<PaymentMethodEntity> methods,
  ) {
    if (!isWalletCreditMerged(methods)) return methods;
    return methods.where((method) => method.type != 'credit').toList();
  }

  static bool isWalletCreditMerged(List<PaymentMethodEntity> methods) {
    var hasWallet = false;
    var hasCredit = false;

    for (final method in methods) {
      if (method.type == 'wallet') hasWallet = true;
      if (method.type == 'credit') hasCredit = true;
    }

    return hasWallet && hasCredit;
  }

  static PaymentMethodEntity? getSelectedPaymentMethod(
    CheckoutSessionEntity session,
    String? selectedPaymentMethodId,
  ) {
    if (selectedPaymentMethodId == null || session.paymentMethods.isEmpty) {
      return null;
    }

    return session.paymentMethods.firstWhere(
      (method) => method.id == selectedPaymentMethodId,
      orElse: () => session.paymentMethods.first,
    );
  }

  static double resolveWalletBalance(BuildContext context) {
    final walletState = context.read<WalletCubit>().state;
    if (walletState is WalletLoaded &&
        walletState.balance != null &&
        walletState.balance! > 0) {
      return walletState.balance!;
    }

    final checkoutState = context.read<CheckoutSessionCubit>().state;
    if (checkoutState is CheckoutSessionLoaded) {
      return checkoutState.session.customer.walletBalance;
    }

    return 0;
  }

  static double resolveCouponDiscount(CheckoutSessionEntity? session) {
    if (session == null) return 0;

    final sessionCouponDiscount = (session.coupon?.discountAmount ?? 0)
        .toDouble();
    if (sessionCouponDiscount > 0) return sessionCouponDiscount;
    return session.cart.couponDiscount;
  }

  static double resolveOrderTotal(CheckoutSessionEntity session) {
    final cartTotal = session.cart.total;
    if (cartTotal.isFinite) return cartTotal;

    return session.cart.subtotal -
        session.cart.discount -
        resolveCouponDiscount(session) +
        session.cart.shippingCost +
        session.cart.taxAmount;
  }

  static double calculateWalletAmountToUse({
    required double orderTotal,
    required double walletBalance,
  }) {
    return walletBalance < orderTotal ? walletBalance : orderTotal;
  }

  static double resolveAvailableCredit(CheckoutSessionEntity session) {
    for (final method in session.paymentMethods) {
      if (method.type == 'credit') {
        return (method.availableCredit ?? 0).toDouble();
      }
    }

    return 0;
  }
}
