import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/config/theme/app_colors.dart';
import '../../data/models/support_model.dart';
import '../widgets/ticket_message_bubble.dart';
import '../widgets/ticket_priority_badge.dart';
import '../widgets/ticket_status_badge.dart';

class TicketDetailsErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const TicketDetailsErrorState({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(message, style: const TextStyle(color: AppColors.error)),
          SizedBox(height: 16.h),
          ElevatedButton(
            onPressed: onRetry,
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }
}

class TicketConversationHeader extends StatelessWidget {
  final TicketModel ticket;
  final bool isDark;

  const TicketConversationHeader({
    super.key,
    required this.ticket,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ticket.subject,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      ticket.ticketNumber,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
              TicketStatusBadge(status: ticket.status),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              if (ticket.category case final category?)
                Chip(
                  label: Text(category.getName('ar')),
                  avatar: const Icon(Iconsax.category, size: 16),
                ),
              SizedBox(width: 8.w),
              TicketPriorityBadge(priority: ticket.priority),
            ],
          ),
        ],
      ),
    );
  }
}

class TicketConversationList extends StatelessWidget {
  final ScrollController controller;
  final List<TicketMessageModel> messages;
  final bool isDark;
  final Future<void> Function() onRefresh;

  const TicketConversationList({
    super.key,
    required this.controller,
    required this.messages,
    required this.isDark,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: messages.isEmpty
          ? const TicketConversationEmptyState()
          : ListView.builder(
              controller: controller,
              padding: EdgeInsets.all(16.w),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return TicketMessageBubble(
                  message: messages[index],
                  isDark: isDark,
                );
              },
            ),
    );
  }
}

class TicketConversationEmptyState extends StatelessWidget {
  const TicketConversationEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView(
      padding: EdgeInsets.all(16.w),
      children: [
        Center(
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Iconsax.message_text,
                  size: 48.sp,
                  color: isDark
                      ? AppColors.textTertiaryDark
                      : AppColors.textTertiaryLight,
                ),
                SizedBox(height: 16.h),
                Text(
                  'لا توجد رسائل بعد',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'اكتب رسالتك أدناه وسيرد فريق الدعم قريباً',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isDark
                        ? AppColors.textTertiaryDark
                        : AppColors.textTertiaryLight,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class TicketAttachmentsPreview extends StatelessWidget {
  final List<String> attachments;
  final bool isDark;
  final ValueChanged<int> onRemove;

  const TicketAttachmentsPreview({
    super.key,
    required this.attachments,
    required this.isDark,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    if (attachments.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 100.h,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.backgroundLight,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
          ),
        ),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: attachments.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(right: 8.w),
            child: Stack(
              children: [
                Container(
                  width: 80.w,
                  height: 80.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color: isDark
                          ? AppColors.dividerDark
                          : AppColors.dividerLight,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.r),
                    child: Image.asset(
                      attachments[index],
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) {
                        return Container(
                          color: Colors.grey[300],
                          child: Icon(Icons.image, size: 24.sp),
                        );
                      },
                    ),
                  ),
                ),
                Positioned(
                  top: -4,
                  right: -4,
                  child: CircleAvatar(
                    radius: 12.r,
                    backgroundColor: AppColors.error,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      iconSize: 14.sp,
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => onRemove(index),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class TicketMessageInputBar extends StatelessWidget {
  final TextEditingController controller;
  final bool isDark;
  final bool isSending;
  final VoidCallback onPickAttachment;
  final VoidCallback onSend;

  const TicketMessageInputBar({
    super.key,
    required this.controller,
    required this.isDark,
    required this.isSending,
    required this.onPickAttachment,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              onPressed: isSending ? null : onPickAttachment,
              icon: Icon(
                Iconsax.attach_circle,
                color: AppColors.textSecondaryLight,
              ),
            ),
            Expanded(
              child: TextField(
                controller: controller,
                enabled: !isSending,
                decoration: InputDecoration(
                  hintText: 'اكتب رسالتك...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.r),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: isDark
                      ? AppColors.cardDark
                      : AppColors.backgroundLight,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 10.h,
                  ),
                ),
                onSubmitted: (_) => onSend(),
              ),
            ),
            SizedBox(width: 8.w),
            CircleAvatar(
              radius: 22.r,
              backgroundColor: AppColors.primary,
              child: isSending
                  ? SizedBox(
                      width: 20.w,
                      height: 20.h,
                      child: const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : IconButton(
                      onPressed: onSend,
                      icon: Icon(
                        Iconsax.send_1,
                        color: Colors.white,
                        size: 20.sp,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
