/// Wallet Transactions Screen - Transaction history
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../../../../core/config/theme/app_theme.dart';

class WalletTransactionsScreen extends StatefulWidget {
  const WalletTransactionsScreen({super.key});

  @override
  State<WalletTransactionsScreen> createState() =>
      _WalletTransactionsScreenState();
}

class _WalletTransactionsScreenState extends State<WalletTransactionsScreen> {
  String _filter = 'all';

  final List<_TransactionModel> _transactions = [
    _TransactionModel(
      id: '1',
      type: 'credit',
      amount: 500,
      description: 'استرداد طلب #ORD-2024-0015',
      date: '2024-12-20',
      status: 'completed',
    ),
    _TransactionModel(
      id: '2',
      type: 'debit',
      amount: 350,
      description: 'دفع طلب #ORD-2024-0018',
      date: '2024-12-19',
      status: 'completed',
    ),
    _TransactionModel(
      id: '3',
      type: 'credit',
      amount: 100,
      description: 'مكافأة إحالة صديق',
      date: '2024-12-18',
      status: 'completed',
    ),
    _TransactionModel(
      id: '4',
      type: 'credit',
      amount: 1000,
      description: 'شحن محفظة - تحويل بنكي',
      date: '2024-12-15',
      status: 'completed',
    ),
    _TransactionModel(
      id: '5',
      type: 'debit',
      amount: 750,
      description: 'دفع طلب #ORD-2024-0012',
      date: '2024-12-14',
      status: 'completed',
    ),
    _TransactionModel(
      id: '6',
      type: 'credit',
      amount: 50,
      description: 'نقاط ولاء محولة',
      date: '2024-12-10',
      status: 'completed',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('سجل المعاملات')),
      body: Column(
        children: [
          // Filter Chips
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                _buildFilterChip('all', 'الكل', isDark),
                SizedBox(width: 8.w),
                _buildFilterChip('credit', 'الإيداعات', isDark),
                SizedBox(width: 8.w),
                _buildFilterChip('debit', 'المدفوعات', isDark),
              ],
            ),
          ),

          // Transactions List
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              itemCount: _filteredTransactions.length,
              separatorBuilder: (_, __) => SizedBox(height: 8.h),
              itemBuilder: (context, index) =>
                  _buildTransactionCard(_filteredTransactions[index], isDark),
            ),
          ),
        ],
      ),
    );
  }

  List<_TransactionModel> get _filteredTransactions {
    if (_filter == 'all') return _transactions;
    return _transactions.where((t) => t.type == _filter).toList();
  }

  Widget _buildFilterChip(String value, String label, bool isDark) {
    final isSelected = _filter == value;
    return GestureDetector(
      onTap: () => setState(() => _filter = value),
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

  Widget _buildTransactionCard(_TransactionModel transaction, bool isDark) {
    final isCredit = transaction.type == 'credit';
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
              color: (isCredit ? AppColors.success : AppColors.error)
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              isCredit ? Iconsax.money_recive : Iconsax.money_send,
              size: 22.sp,
              color: isCredit ? AppColors.success : AppColors.error,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Text(
                  transaction.date,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${isCredit ? '+' : '-'}${transaction.amount.toStringAsFixed(0)} ر.س',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: isCredit ? AppColors.success : AppColors.error,
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionModel {
  final String id, type, description, date, status;
  final double amount;
  _TransactionModel({
    required this.id,
    required this.type,
    required this.amount,
    required this.description,
    required this.date,
    required this.status,
  });
}
