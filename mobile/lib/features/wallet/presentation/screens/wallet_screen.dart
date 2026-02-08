/// Wallet Screen - User wallet and transaction history
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
                    child: const Text('إعادة المحاولة'),
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
                  SizedBox(height: 24.h),

                  // Quick Actions
                  _buildQuickActions(context, theme, isDark),
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
                'الرصيد المتاح',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            balance != null
                ? '${balance.toStringAsFixed(2)} ر.س'
                : '0.00 ر.س',
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
    final now = DateTime.now();
    return 'اليوم ${now.hour}:${now.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildQuickActions(
    BuildContext context,
    ThemeData theme,
    bool isDark,
  ) {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            theme,
            isDark,
            icon: Iconsax.add,
            label: 'إضافة رصيد',
            color: AppColors.success,
            onTap: () {
              HapticFeedback.mediumImpact();
              _showAddBalanceDialog(context);
            },
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _buildActionButton(
            theme,
            isDark,
            icon: Iconsax.arrow_swap_horizontal,
            label: 'تحويل',
            color: Colors.blue,
            onTap: () {
              HapticFeedback.mediumImpact();
            },
          ),
        ),
        SizedBox(width: 12.w),
            Expanded(
          child: _buildActionButton(
            theme,
            isDark,
            icon: Iconsax.document_text,
            label: 'كشف حساب',
            color: Colors.orange,
            onTap: () {
              HapticFeedback.mediumImpact();
              context.push('/wallet/transactions');
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    ThemeData theme,
    bool isDark, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.cardLight,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          children: [
            Container(
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24.sp),
            ),
            SizedBox(height: 8.h),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
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
              'سجل المعاملات',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            TextButton(
              onPressed: () => context.push('/wallet/transactions'),
              child: const Text('عرض الكل'),
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
                    'لا توجد معاملات',
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
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) return 'اليوم';
    if (diff.inDays == 1) return 'أمس';
    if (diff.inDays < 7) return 'منذ ${diff.inDays} أيام';
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showAddBalanceDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: AppColors.dividerLight,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              'إضافة رصيد',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 24.h),
            // Quick amounts
            Wrap(
              spacing: 12.w,
              runSpacing: 12.h,
              children: [100, 250, 500, 1000].map((amount) {
                return GestureDetector(
                  onTap: () => Navigator.pop(ctx),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.w,
                      vertical: 12.h,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.primary),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      '$amount ر.س',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 24.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('إضافة'),
              ),
            ),
            SizedBox(height: MediaQuery.of(ctx).viewInsets.bottom + 16.h),
          ],
        ),
      ),
    );
  }
}

