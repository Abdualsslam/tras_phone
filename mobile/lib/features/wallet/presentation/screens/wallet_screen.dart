/// Wallet Screen - User wallet and transaction history
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../../../../core/shimmer/index.dart';
import '../../../../l10n/app_localizations.dart';
import '../cubit/wallet_cubit.dart';
import '../cubit/wallet_state.dart';
import '../../data/models/wallet_transaction_model.dart';
import '../../domain/enums/wallet_enums.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  @override
  void initState() {
    super.initState();
    // Load wallet data when screen opens
    context.read<WalletCubit>().loadAll();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.wallet)),
      body: BlocBuilder<WalletCubit, WalletState>(
        builder: (context, state) {
          if (state is WalletLoading && state is! WalletLoaded) {
            return const WalletShimmer();
          }

          if (state is WalletError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: () => context.read<WalletCubit>().loadAll(),
                    child: Text(AppLocalizations.of(context)!.retryAction),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await context.read<WalletCubit>().loadAll();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(16.w),
              child: Column(
                children: [
                  // Balance Card
                  _buildBalanceCard(context, theme, isDark, state),
                  SizedBox(height: 16.h),

                  // Credit Summary
                  _buildCreditSummaryCard(context, theme, isDark, state),
                  SizedBox(height: 24.h),

                  // Transaction History
                  _buildTransactionHistory(context, theme, isDark, state),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBalanceCard(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    WalletState state,
  ) {
    final balance = state is WalletLoaded ? state.balance : null;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Iconsax.wallet_3, color: Colors.white, size: 24.sp),
              SizedBox(width: 8.w),
              Text(
                AppLocalizations.of(context)!.availableBalance,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            balance != null ? '${balance.toStringAsFixed(2)} ر.س' : '0.00 ر.س',
            style: TextStyle(
              fontSize: 36.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'آخر تحديث: ${_formatLastUpdate()}',
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  String _formatLastUpdate() {
    // Use actual time from last data fetch, or fallback to now
    final now = DateTime.now();
    return 'اليوم ${now.hour}:${now.minute.toString().padLeft(2, '0')} - آخر تحديث';
  }

  Widget _buildCreditSummaryCard(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    WalletState state,
  ) {
    final loadedState = state is WalletLoaded ? state : null;
    final creditLimit = loadedState?.creditLimit ?? 0;
    final creditUsed = loadedState?.creditUsed ?? 0;
    final availableCredit = loadedState?.availableCredit ?? 0;
    final usageRatio = creditLimit > 0 ? (creditUsed / creditLimit).clamp(0.0, 1.0) : 0.0;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.creditLimit,
            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: _buildCreditMetric(
                  theme,
                  label: AppLocalizations.of(context)!.creditLimit,
                  value: creditLimit,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildCreditMetric(
                  theme,
                  label: AppLocalizations.of(context)!.creditUsed,
                  value: creditUsed,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          LinearProgressIndicator(
            value: usageRatio,
            backgroundColor: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          SizedBox(height: 8.h),
          Text(
            AppLocalizations.of(context)!.creditAvailable(availableCredit.toStringAsFixed(2)),
            style: theme.textTheme.bodySmall?.copyWith(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreditMetric(
    ThemeData theme, {
    required String label,
    required double value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.textTertiaryLight,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          '${value.toStringAsFixed(2)} ر.س',
          style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }

  Widget _buildTransactionHistory(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    WalletState state,
  ) {
    final transactions = state is WalletLoaded
        ? (state.transactions ?? []).take(5).toList()
        : <WalletTransaction>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppLocalizations.of(context)!.transactionHistory,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            TextButton(
              onPressed: () => context.push('/wallet/transactions'),
              child: Text(AppLocalizations.of(context)!.viewAll),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        if (transactions.isEmpty)
          Container(
            padding: EdgeInsets.all(32.w),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : AppColors.cardLight,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Iconsax.document_text,
                    size: 48.sp,
                    color: AppColors.textTertiaryLight,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    AppLocalizations.of(context)!.noTransactions,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textTertiaryLight,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : AppColors.cardLight,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: transactions.length,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                indent: 72.w,
                color: AppColors.dividerLight,
              ),
              itemBuilder: (context, index) {
                final tx = transactions[index];
                return _buildTransactionItem(context, theme, tx);
              },
            ),
          ),
      ],
    );
  }

  Widget _buildTransactionItem(
    BuildContext context,
    ThemeData theme,
    WalletTransaction tx,
  ) {
    final isCredit = tx.isCredit;
    final locale = Localizations.localeOf(context).languageCode;
    IconData icon;
    Color iconBg;

    switch (tx.transactionType) {
      case WalletTransactionType.walletTopup:
      case WalletTransactionType.orderRefund:
      case WalletTransactionType.referralReward:
      case WalletTransactionType.loyaltyReward:
      case WalletTransactionType.adminCredit:
        icon = Iconsax.add;
        iconBg = AppColors.success;
        break;
      case WalletTransactionType.orderPayment:
      case WalletTransactionType.walletWithdrawal:
      case WalletTransactionType.adminDebit:
      case WalletTransactionType.expiredBalance:
        icon = Iconsax.shopping_cart;
        iconBg = AppColors.primary;
        break;
    }

    return ListTile(
      leading: Container(
        width: 44.w,
        height: 44.w,
        decoration: BoxDecoration(
          color: iconBg.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconBg, size: 20.sp),
      ),
      title: Text(
        tx.getDescription(locale),
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _formatDate(tx.createdAt),
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textTertiaryLight,
            ),
          ),
          if (tx.referenceNumber != null)
            Text(
              tx.referenceNumber!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textTertiaryLight,
                fontSize: 10.sp,
              ),
            ),
        ],
      ),
      trailing: Text(
        '${isCredit ? '+' : '-'}${tx.amount.toStringAsFixed(2)} ر.س',
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w700,
          color: isCredit ? AppColors.success : AppColors.error,
        ),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
    );
  }

  String _formatDate(DateTime date) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) return l10n.today;
    if (diff.inDays == 1) return l10n.yesterday;
    if (diff.inDays < 7) return l10n.daysAgo(diff.inDays);
    return '${date.day}/${date.month}/${date.year}';
  }
}
