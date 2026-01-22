/// Ticket Card Widget - Display ticket in list
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../../data/models/support_model.dart';
import 'ticket_status_badge.dart';
import 'ticket_priority_badge.dart';

class TicketCard extends StatelessWidget {
  final TicketModel ticket;
  final VoidCallback? onTap;

  const TicketCard({
    super.key,
    required this.ticket,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      color: isDark ? AppColors.cardDark : AppColors.cardLight,
      child: InkWell(
        onTap: onTap ??
            () {
              context.push('/ticket/${ticket.id}');
            },
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Subject and Status
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ticket.subject,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimaryLight,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          ticket.ticketNumber,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8.w),
                  TicketStatusBadge(status: ticket.status),
                ],
              ),
              SizedBox(height: 12.h),

              // Category and Priority
              Row(
                children: [
                  if (ticket.category != null) ...[
                    Icon(Iconsax.category, size: 14.sp, color: AppColors.textSecondaryLight),
                    SizedBox(width: 4.w),
                    Text(
                      ticket.category!.getName('ar'),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                    SizedBox(width: 12.w),
                  ],
                  TicketPriorityBadge(priority: ticket.priority),
                ],
              ),
              SizedBox(height: 12.h),

              // Footer: Date and Message Count
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Iconsax.calendar,
                        size: 14.sp,
                        color: AppColors.textTertiaryLight,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        _formatDate(ticket.createdAt),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark
                              ? AppColors.textTertiaryDark
                              : AppColors.textTertiaryLight,
                        ),
                      ),
                    ],
                  ),
                  if (ticket.messageCount > 0)
                    Row(
                      children: [
                        Icon(
                          Iconsax.message,
                          size: 14.sp,
                          color: AppColors.textTertiaryLight,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          '${ticket.messageCount} رسالة',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark
                                ? AppColors.textTertiaryDark
                                : AppColors.textTertiaryLight,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      return 'اليوم';
    } else if (difference.inDays == 1) {
      return 'أمس';
    } else if (difference.inDays < 7) {
      return DateFormat('EEEE', 'ar').format(dateTime);
    } else {
      return DateFormat('dd/MM/yyyy', 'ar').format(dateTime);
    }
  }
}
