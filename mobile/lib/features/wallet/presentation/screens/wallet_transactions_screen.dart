/// Wallet Transactions Screen - Transaction history
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
import '../../data/models/wallet_transaction_model.dart';
import '../../domain/enums/wallet_enums.dart';

class WalletTransactionsScreen extends StatefulWidget {
  const WalletTransactionsScreen({super.key});

  @override
  State<WalletTransactionsScreen> createState() =>
      _WalletTransactionsScreenState();
}

class _WalletTransactionsScreenState extends State<WalletTransactionsScreen> {
  WalletTransactionType? _selectedType;
  int _page = 1;
  final int _limit = 20;
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    context.read<WalletCubit>().loadTransactions(
          page: _page,
          limit: _limit,
          transactionType: _selectedType,
        );
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      _loadMore();
    }
  }

  void _loadMore() {
    if (_isLoadingMore) return;
    setState(() {
      _isLoadingMore = true;
      _page++;
    });
    context.read<WalletCubit>().loadTransactions(
          page: _page,
          limit: _limit,
          transactionType: _selectedType,
        );
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() => _isLoadingMore = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final locale = Localizations.localeOf(context).languageCode;

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.transactionHistoryTitle)),
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
                      _page = 1;
                      context.read<WalletCubit>().loadTransactions(
                            page: _page,
                            limit: _limit,
                            transactionType: _selectedType,
                          );
                    },
                    child: Text(AppLocalizations.of(context)!.retryAction),
                  ),
                ],
              ),
            );
          }

          final transactions = state is WalletLoaded
              ? (state.transactions ?? [])
              : <WalletTransaction>[];

          return Column(
            children: [
              // Filter Chips
              Padding(
                padding: EdgeInsets.all(16.w),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip(
                        context,
                        null,
                        AppLocalizations.of(context)!.allTransactions,
                        isDark,
                      ),
                      SizedBox(width: 8.w),
                      _buildFilterChip(
                        context,
                        WalletTransactionType.orderRefund,
                        AppLocalizations.of(context)!.deposits,
                        isDark,
                      ),
                      SizedBox(width: 8.w),
                      _buildFilterChip(
                        context,
                        WalletTransactionType.orderPayment,
                        AppLocalizations.of(context)!.payments,
                        isDark,
                      ),
                      SizedBox(width: 8.w),
                      _buildFilterChip(
                        context,
                        WalletTransactionType.walletTopup,
                        AppLocalizations.of(context)!.topup,
                        isDark,
                      ),
                    ],
                  ),
                ),
              ),

              // Transactions List
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    _page = 1;
                    await context.read<WalletCubit>().loadTransactions(
                          page: _page,
                          limit: _limit,
                          transactionType: _selectedType,
                        );
                  },
                  child: transactions.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Iconsax.document_text,
                                size: 64.sp,
                                color: AppColors.textTertiaryLight,
                              ),
                              SizedBox(height: 16.h),
                              Text(
                                AppLocalizations.of(context)!.noTransactions,
                                style: TextStyle(
                                  color: AppColors.textTertiaryLight,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          controller: _scrollController,
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          itemCount: transactions.length + (_isLoadingMore ? 1 : 0),
                          separatorBuilder: (_, __) => SizedBox(height: 8.h),
                          itemBuilder: (context, index) {
                            if (index == transactions.length) {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }
                            return _buildTransactionCard(
                              context,
                              transactions[index],
                              isDark,
                              locale,
                            );
                          },
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    WalletTransactionType? type,
    String label,
    bool isDark,
  ) {
    final isSelected = _selectedType == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedType = type;
          _page = 1;
        });
        context.read<WalletCubit>().loadTransactions(
              page: _page,
              limit: _limit,
              transactionType: type,
            );
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : (isDark ? AppColors.cardDark : AppColors.backgroundLight),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.dividerLight,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
            color: isSelected
                ? Colors.white
                : (isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight),
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionCard(
    BuildContext context,
    WalletTransaction transaction,
    bool isDark,
    String locale,
  ) {
    final isCredit = transaction.isCredit;

    IconData icon;
    Color iconBg;

    switch (transaction.transactionType) {
      case WalletTransactionType.walletTopup:
      case WalletTransactionType.orderRefund:
      case WalletTransactionType.referralReward:
      case WalletTransactionType.loyaltyReward:
      case WalletTransactionType.adminCredit:
        icon = Iconsax.money_recive;
        iconBg = AppColors.success;
        break;
      case WalletTransactionType.orderPayment:
      case WalletTransactionType.walletWithdrawal:
      case WalletTransactionType.adminDebit:
      case WalletTransactionType.expiredBalance:
        icon = Iconsax.money_send;
        iconBg = AppColors.error;
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
                if (transaction.status != WalletTransactionStatus.completed) ...[
                  SizedBox(height: 4.h),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 2.h,
                    ),
                    decoration: BoxDecoration(
                      color: transaction.status.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      transaction.status.displayNameAr,
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: transaction.status.color,
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
                '${isCredit ? '+' : '-'}${transaction.amount.toStringAsFixed(2)} ر.س',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: isCredit ? AppColors.success : AppColors.error,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                AppLocalizations.of(context)!.balanceAfter(transaction.balanceAfter.toStringAsFixed(2)),
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
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      if (diff.inHours == 0) {
        return l10n.minutesAgo(diff.inMinutes);
      }
      return l10n.hoursAgo(diff.inHours);
    }
    if (diff.inDays == 1) return l10n.yesterday;
    if (diff.inDays < 7) return l10n.daysAgo(diff.inDays);
    return '${date.day}/${date.month}/${date.year}';
  }
}
