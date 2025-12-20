/// Wallet Screen - User wallet and transaction history
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/config/theme/app_colors.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('محفظتي')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            // Balance Card
            _buildBalanceCard(theme, isDark),
            SizedBox(height: 24.h),

            // Quick Actions
            _buildQuickActions(context, theme, isDark),
            SizedBox(height: 24.h),

            // Transaction History
            _buildTransactionHistory(theme, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard(ThemeData theme, bool isDark) {
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
            '٥٠٠.٠٠ ر.س',
            style: TextStyle(
              fontSize: 36.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'آخر تحديث: اليوم',
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
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

  Widget _buildTransactionHistory(ThemeData theme, bool isDark) {
    final transactions = [
      _Transaction(
        title: 'دفع طلب #ORD-2024-001',
        amount: -1242.5,
        date: DateTime.now().subtract(const Duration(days: 2)),
        type: _TransactionType.payment,
      ),
      _Transaction(
        title: 'إضافة رصيد',
        amount: 1000,
        date: DateTime.now().subtract(const Duration(days: 5)),
        type: _TransactionType.deposit,
      ),
      _Transaction(
        title: 'استرداد طلب ملغي',
        amount: 350,
        date: DateTime.now().subtract(const Duration(days: 10)),
        type: _TransactionType.refund,
      ),
      _Transaction(
        title: 'دفع طلب #ORD-2024-002',
        amount: -520,
        date: DateTime.now().subtract(const Duration(days: 15)),
        type: _TransactionType.payment,
      ),
    ];

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
            TextButton(onPressed: () {}, child: const Text('عرض الكل')),
          ],
        ),
        SizedBox(height: 12.h),
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : AppColors.cardLight,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: transactions.length,
            separatorBuilder: (_, __) =>
                Divider(height: 1, indent: 72.w, color: AppColors.dividerLight),
            itemBuilder: (context, index) {
              final tx = transactions[index];
              return _buildTransactionItem(theme, tx);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionItem(ThemeData theme, _Transaction tx) {
    final isPositive = tx.amount > 0;
    IconData icon;
    Color iconBg;

    switch (tx.type) {
      case _TransactionType.deposit:
        icon = Iconsax.add;
        iconBg = AppColors.success;
        break;
      case _TransactionType.payment:
        icon = Iconsax.shopping_cart;
        iconBg = AppColors.primary;
        break;
      case _TransactionType.refund:
        icon = Iconsax.rotate_left;
        iconBg = Colors.orange;
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
        tx.title,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        _formatDate(tx.date),
        style: theme.textTheme.bodySmall?.copyWith(
          color: AppColors.textTertiaryLight,
        ),
      ),
      trailing: Text(
        '${isPositive ? '+' : ''}${tx.amount.toStringAsFixed(0)} ر.س',
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w700,
          color: isPositive ? AppColors.success : AppColors.error,
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

class _Transaction {
  final String title;
  final double amount;
  final DateTime date;
  final _TransactionType type;

  _Transaction({
    required this.title,
    required this.amount,
    required this.date,
    required this.type,
  });
}

enum _TransactionType { deposit, payment, refund }
