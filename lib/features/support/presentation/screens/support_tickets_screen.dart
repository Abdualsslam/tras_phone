/// Support Tickets List Screen - List of support tickets
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/config/theme/app_colors.dart';

enum TicketStatus { open, inProgress, resolved, closed }

class SupportTicketsScreen extends StatelessWidget {
  const SupportTicketsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final tickets = [
      _Ticket(
        id: 1,
        subject: 'مشكلة في الطلب #ORD-2024-001',
        category: 'الطلبات',
        status: TicketStatus.open,
        lastMessage: 'سأقوم بالتحقق من المشكلة وأرد عليك قريباً',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        unreadCount: 2,
      ),
      _Ticket(
        id: 2,
        subject: 'استفسار عن منتج',
        category: 'المنتجات',
        status: TicketStatus.resolved,
        lastMessage: 'شكراً لتواصلك معنا',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        unreadCount: 0,
      ),
    ];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('الدعم الفني')),
      body: tickets.isEmpty
          ? _buildEmptyState(theme)
          : ListView.separated(
              padding: EdgeInsets.all(16.w),
              itemCount: tickets.length,
              separatorBuilder: (_, __) => SizedBox(height: 12.h),
              itemBuilder: (context, index) {
                return _buildTicketCard(theme, isDark, tickets[index]);
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Iconsax.add),
        label: const Text('تذكرة جديدة'),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Iconsax.message_question,
            size: 80.sp,
            color: AppColors.textTertiaryLight,
          ),
          SizedBox(height: 24.h),
          Text(
            'لا توجد تذاكر دعم',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'إذا كان لديك أي استفسار، أنشئ تذكرة جديدة',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textTertiaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketCard(ThemeData theme, bool isDark, _Ticket ticket) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(Iconsax.message_text, color: AppColors.primary),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ticket.subject,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      ticket.category,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textTertiaryLight,
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusBadge(ticket.status),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            ticket.lastMessage,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondaryLight,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDate(ticket.createdAt),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textTertiaryLight,
                ),
              ),
              if (ticket.unreadCount > 0)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Text(
                    '${ticket.unreadCount}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(TicketStatus status) {
    Color color;
    String text;
    switch (status) {
      case TicketStatus.open:
        color = Colors.orange;
        text = 'مفتوحة';
        break;
      case TicketStatus.inProgress:
        color = Colors.blue;
        text = 'قيد المعالجة';
        break;
      case TicketStatus.resolved:
        color = AppColors.success;
        text = 'تم الحل';
        break;
      case TicketStatus.closed:
        color = AppColors.textTertiaryLight;
        text = 'مغلقة';
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعة';
    if (diff.inDays == 1) return 'أمس';
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _Ticket {
  final int id;
  final String subject;
  final String category;
  final TicketStatus status;
  final String lastMessage;
  final DateTime createdAt;
  final int unreadCount;

  _Ticket({
    required this.id,
    required this.subject,
    required this.category,
    required this.status,
    required this.lastMessage,
    required this.createdAt,
    required this.unreadCount,
  });
}
