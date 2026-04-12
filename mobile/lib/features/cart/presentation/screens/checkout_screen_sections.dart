import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../orders/domain/entities/payment_method_entity.dart';
import '../../../promotions/presentation/widgets/coupon_input.dart';
import '../../../wallet/presentation/cubit/wallet_cubit.dart';
import '../../../wallet/presentation/cubit/wallet_state.dart';
import '../../domain/entities/checkout_session_entity.dart';
import '../controllers/checkout_flow_controller.dart';
import '../cubit/checkout_session_cubit.dart';
import '../widgets/checkout_sections.dart';

class CheckoutLoadedContent extends StatelessWidget {
  final ThemeData theme;
  final bool isDark;
  final CheckoutSessionEntity session;
  final CheckoutFlowState flowState;
  final CheckoutFlowController controller;

  const CheckoutLoadedContent({
    super.key,
    required this.theme,
    required this.isDark,
    required this.session,
    required this.flowState,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            physics: const ClampingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildAddressesSection(context),
                SizedBox(height: 24.h),
                _buildPaymentSection(context),
                SizedBox(height: 24.h),
                _buildBankTransferDetailsSection(context),
                _buildWalletUsageSection(context),
                SizedBox(height: 24.h),
                _buildCouponSection(context),
                SizedBox(height: 24.h),
                _buildSummarySection(context),
                SizedBox(height: 100.h),
              ],
            ),
          ),
        ),
        _buildBottomBar(),
      ],
    );
  }

  Widget _buildAddressesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CheckoutSectionTitle(title: AppLocalizations.of(context)!.addresses),
        SizedBox(height: 12.h),
        CheckoutAddressSection(
          isDark: isDark,
          addresses: session.addresses,
          selectedAddressId: flowState.selectedAddressId,
          addAddressLabel: AppLocalizations.of(context)!.addAddress,
          onAddAddress: controller.handleAddAddress,
          onSelectAddress: controller.onSelectAddress,
        ),
      ],
    );
  }

  Widget _buildPaymentSection(BuildContext context) {
    final paymentMethods = CheckoutFlowController.buildDisplayPaymentMethods(
      session.paymentMethods,
    );
    PaymentMethodEntity? mergedCreditMethod;

    if (CheckoutFlowController.isWalletCreditMerged(session.paymentMethods)) {
      for (final method in session.paymentMethods) {
        if (method.type == 'credit') {
          mergedCreditMethod = method;
          break;
        }
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CheckoutSectionTitle(
          title: AppLocalizations.of(context)!.paymentMethod,
        ),
        SizedBox(height: 12.h),
        CheckoutPaymentMethodsSection(
          isDark: isDark,
          paymentMethods: paymentMethods,
          selectedPaymentMethodId: flowState.selectedPaymentMethodId,
          isWalletCreditMerged: CheckoutFlowController.isWalletCreditMerged(
            session.paymentMethods,
          ),
          mergedCreditMethod: mergedCreditMethod,
          onSelectMethod: controller.onSelectPaymentMethod,
          getPaymentMethodIcon: CheckoutFlowController.getPaymentMethodIcon,
          buildDetails: (method, isSelected) {
            return [
              if (method.type == 'wallet' && isSelected)
                _buildWalletInfoPanel(context),
              if (CheckoutFlowController.isWalletCreditMerged(
                    session.paymentMethods,
                  ) &&
                  method.type == 'wallet' &&
                  mergedCreditMethod != null &&
                  isSelected)
                _buildCreditInfoPanel(mergedCreditMethod),
              if (method.isCreditMethod && method.creditLimit != null)
                _buildCreditInfoPanel(method),
              if (CheckoutFlowController.isBankTransferMethod(method) &&
                  isSelected)
                _buildSupportedBanksPanel(),
            ];
          },
        ),
      ],
    );
  }

  Widget _buildBankTransferDetailsSection(BuildContext context) {
    final selectedMethod = CheckoutFlowController.getSelectedPaymentMethod(
      session,
      flowState.selectedPaymentMethodId,
    );

    if (!CheckoutFlowController.isBankTransferMethod(selectedMethod)) {
      return const SizedBox.shrink();
    }

    if (!flowState.hasRequestedBankAccounts && selectedMethod != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.fetchBankAccountsIfNeeded(selectedMethod);
      });
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CheckoutSectionTitle(title: 'بيانات التحويل البنكي'),
        SizedBox(height: 12.h),
        CheckoutTransferReceiptSection(
          isDark: isDark,
          receiptImagePath: flowState.receiptImagePath,
          transferNotesController: controller.transferNotesController,
          onPickImage: controller.pickTransferReceiptImage,
          onClearImage: controller.clearReceiptImage,
        ),
        SizedBox(height: 24.h),
      ],
    );
  }

  Widget _buildWalletUsageSection(BuildContext context) {
    if (!session.paymentMethods.any((method) => method.type == 'wallet')) {
      return const SizedBox.shrink();
    }

    return BlocBuilder<WalletCubit, WalletState>(
      builder: (context, walletState) {
        final selectedMethod = CheckoutFlowController.getSelectedPaymentMethod(
          session,
          flowState.selectedPaymentMethodId,
        );
        final isWalletMethodSelected = selectedMethod?.type == 'wallet';
        final cubitWalletBalance = walletState is WalletLoaded
            ? (walletState.balance ?? 0)
            : 0.0;
        final walletBalance = cubitWalletBalance > 0
            ? cubitWalletBalance
            : session.customer.walletBalance;
        final orderTotal = CheckoutFlowController.resolveOrderTotal(session);
        final availableCredit = CheckoutFlowController.resolveAvailableCredit(
          session,
        );
        final walletAutoUse = CheckoutFlowController.calculateWalletAmountToUse(
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

  Widget _buildCouponSection(BuildContext context) {
    final appliedCode = session.coupon?.code ?? session.cart.couponCode;
    final appliedDiscount = CheckoutFlowController.resolveCouponDiscount(
      session,
    );

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
  }

  Widget _buildSummarySection(BuildContext context) {
    final total = CheckoutFlowController.resolveOrderTotal(session);
    final walletAmountToUse = CheckoutFlowController.calculateWalletAmountToUse(
      orderTotal: total,
      walletBalance: CheckoutFlowController.resolveWalletBalance(context),
    );
    final payableNow = (total - walletAmountToUse).clamp(0, total).toDouble();

    return CheckoutOrderSummaryCard(
      session: session,
      couponDiscount: CheckoutFlowController.resolveCouponDiscount(session),
      total: total,
      walletAmountToUse: walletAmountToUse,
      payableNow: payableNow,
    );
  }

  Widget _buildBottomBar() {
    final total = CheckoutFlowController.resolveOrderTotal(session);
    final selectedMethod = CheckoutFlowController.getSelectedPaymentMethod(
      session,
      flowState.selectedPaymentMethodId,
    );
    final walletAmountToUse = CheckoutFlowController.calculateWalletAmountToUse(
      orderTotal: total,
      walletBalance: CheckoutFlowController.resolveWalletBalance(
        controller.context,
      ),
    );
    final availableCredit = CheckoutFlowController.resolveAvailableCredit(
      session,
    );
    final payableNow = selectedMethod?.type == 'wallet'
        ? (total - walletAmountToUse - availableCredit)
              .clamp(0, total)
              .toDouble()
        : (total - walletAmountToUse).clamp(0, total).toDouble();
    final requiresTransferData =
        CheckoutFlowController.isBankTransferMethod(selectedMethod) &&
        payableNow > 0;
    final canPlaceOrder =
        session.cart.isNotEmpty &&
        flowState.selectedAddressId != null &&
        session.addresses.isNotEmpty &&
        flowState.selectedPaymentMethodId != null &&
        session.paymentMethods.isNotEmpty &&
        (!requiresTransferData ||
            (flowState.receiptImagePath != null &&
                flowState.selectedBankAccountId != null));

    return CheckoutPlaceOrderBar(
      isDark: isDark,
      canPlaceOrder: canPlaceOrder,
      payableNow: payableNow,
      onPlaceOrder: canPlaceOrder
          ? () => controller.handlePlaceOrder(session)
          : null,
    );
  }

  Widget _buildCreditInfoPanel(PaymentMethodEntity method) {
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

  Widget _buildSupportedBanksPanel() {
    return CheckoutSupportedBanksPanel(
      isDark: isDark,
      isLoading: flowState.isLoadingBankAccounts,
      bankAccounts: flowState.bankAccounts,
      selectedBankAccountId: flowState.selectedBankAccountId,
      onSelectBankAccount: controller.selectBankAccount,
      onCopyValue: controller.copyBankValue,
    );
  }

  Widget _buildWalletInfoPanel(BuildContext context) {
    final orderTotal = CheckoutFlowController.resolveOrderTotal(session);

    return BlocBuilder<WalletCubit, WalletState>(
      builder: (context, walletState) {
        final cubitBalance = walletState is WalletLoaded
            ? (walletState.balance ?? 0)
            : 0.0;

        return CheckoutWalletInfoPanel(
          isDark: isDark,
          walletBalance: cubitBalance > 0
              ? cubitBalance
              : session.customer.walletBalance,
          orderTotal: orderTotal,
        );
      },
    );
  }
}
