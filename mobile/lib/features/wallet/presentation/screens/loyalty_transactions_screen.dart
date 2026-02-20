/// Loyalty Transactions Screen - Display loyalty points transactions
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../../../../core/config/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../cubit/wallet_cubit.dart';
import '../cubit/wallet_state.dart';
import '../../data/models/loyalty_transaction_model.dart';
import '../../domain/enums/wallet_enums.dart';

class LoyaltyTransactionsScreen extends StatefulWidget {
  const LoyaltyTransactionsScreen({super.key});

  @override
  State<LoyaltyTransactionsScreen> createState() =>
      _LoyaltyTransactionsScreenState();
}

class _LoyaltyTransactionsScreenState
    extends State<LoyaltyTransactionsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<WalletCubit>().loadPointsTransactions();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final locale = Localizations.localeOf(context).languageCode;

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.pointsTransactions)),
      body: BlocBuilder<WalletCubit, WalletState>(
        builder: (context, state) {
          if (state is WalletLoading && state is! WalletLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is WalletError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: () {
                      context.read<WalletCubit>().loadPointsTransactions();
                    },
                    child: Text(AppLocalizations.of(context)!.retryAction),
                  ),
                ],
              ),
            );
          }

          final transactions = state is WalletLoaded
              ? (state.loyaltyTransactions ?? [])
              : <LoyaltyTransaction>[];

          return RefreshIndicator(
            onRefresh: () async {
              await context.read<WalletCubit>().loadPointsTransactions();
            },
            child: transactions.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Iconsax.medal_star,
                          size: 64.sp,
                          color: AppColors.textTertiaryLight,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'لا توجد معاملات',
                          style: TextStyle(
                            color: AppColors.textTertiaryLight,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    itemCount: transactions.length,
                    separatorBuilder: (_, __) => SizedBox(height: 8.h),
                    itemBuilder: (context, index) => _buildTransactionCard(
                      context,
                      transactions[index],
                      isDark,
                      locale,
                    ),
                  ),
          );
        },
      ),
    );
  }

  Widget _buildTransactionCard(
    BuildContext context,
    LoyaltyTransaction transaction,
    bool isDark,
    String locale,
  ) {
    final isEarned = transaction.isEarned;

    IconData icon;
    Color iconBg;

    switch (transaction.transactionType) {
      case LoyaltyTransactionType.orderEarn:
      case LoyaltyTransactionType.signupBonus:
      case LoyaltyTransactionType.referralEarn:
      case LoyaltyTransactionType.birthdayBonus:
      case LoyaltyTransactionType.tierUpgrade:
      case LoyaltyTransactionType.adminGrant:
      case LoyaltyTransactionType.transferIn:
        icon = Iconsax.add_circle;
        iconBg = AppColors.success;
        break;
      case LoyaltyTransactionType.orderRedeem:
      case LoyaltyTransactionType.adminDeduct:
      case LoyaltyTransactionType.transferOut:
        icon = Iconsax.minus;
        iconBg = AppColors.error;
        break;
      case LoyaltyTransactionType.orderCancel:
      case LoyaltyTransactionType.pointsExpiry:
        icon = Iconsax.close_circle;
        iconBg = Colors.orange;
        break;
    }

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: AppTheme.radiusMd,
      ),
      child: Row(
        children: [
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              color: iconBg.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              icon,
              size: 22.sp,
              color: iconBg,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.getDescription(locale),
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Text(
                      _formatDate(transaction.createdAt),
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                    if (transaction.referenceNumber != null) ...[
                      Text(
                        ' • ',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                      Text(
                        transaction.referenceNumber!,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ],
                ),
                if (transaction.multiplier != null && transaction.multiplier! > 1) ...[
                  SizedBox(height: 4.h),
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
                      'x${transaction.multiplier!.toStringAsFixed(1)}',
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
                if (transaction.isExpired) ...[
                  SizedBox(height: 4.h),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 2.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      'منتهي الصلاحية',
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: Colors.orange,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isEarned ? '+' : '-'}${transaction.points}',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: isEarned ? AppColors.success : AppColors.error,
                ),
              ),
              Text(
                'نقطة',
                style: TextStyle(
                  fontSize: 11.sp,
                  color: AppColors.textTertiaryLight,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                'الرصيد: ${transaction.pointsAfter}',
                style: TextStyle(
                  fontSize: 11.sp,
                  color: AppColors.textTertiaryLight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      if (diff.inHours == 0) {
        return 'منذ ${diff.inMinutes} دقيقة';
      }
      return 'منذ ${diff.inHours} ساعة';
    }
    if (diff.inDays == 1) return 'أمس';
    if (diff.inDays < 7) return 'منذ ${diff.inDays} أيام';
    return '${date.day}/${date.month}/${date.year}';
  }
}
