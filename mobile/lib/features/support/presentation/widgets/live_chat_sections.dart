import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/config/theme/app_colors.dart';
import '../../data/models/support_model.dart';
import '../cubit/live_chat_cubit.dart';

class LiveChatTitle extends StatelessWidget {
  final LiveChatState state;

  const LiveChatTitle({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final statusColor = state.isActive
        ? AppColors.success
        : state.isWaiting
        ? AppColors.warning
        : AppColors.textTertiaryLight;
    final statusText = state.isActive
        ? 'متصل الآن'
        : state.isWaiting
        ? 'في الانتظار (${state.queuePosition})'
        : 'غير متصل';

    return Row(
      children: [
        CircleAvatar(
          radius: 18.r,
          backgroundColor: statusColor,
          child: Icon(Iconsax.headphone, size: 18.sp, color: Colors.white),
        ),
        SizedBox(width: 12.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('الدعم المباشر', style: TextStyle(fontSize: 16.sp)),
            Row(
              children: [
                Container(
                  width: 8.w,
                  height: 8.w,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 4.w),
                Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class LiveChatLoadingView extends StatelessWidget {
  const LiveChatLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class LiveChatStartView extends StatelessWidget {
  final VoidCallback onStartChat;

  const LiveChatStartView({super.key, required this.onStartChat});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Iconsax.message_favorite,
              size: 80.sp,
              color: AppColors.primary,
            ),
            SizedBox(height: 24.h),
            Text(
              'مرحباً بك في الدعم المباشر',
              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8.h),
            Text(
              'ابدأ محادثة مع فريق الدعم للحصول على المساعدة الفورية',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textSecondaryLight,
              ),
            ),
            SizedBox(height: 32.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onStartChat,
                icon: const Icon(Iconsax.message_add),
                label: const Text('ابدأ المحادثة'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LiveChatWaitingBanner extends StatelessWidget {
  final int queuePosition;

  const LiveChatWaitingBanner({super.key, required this.queuePosition});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      color: AppColors.warning.withValues(alpha: 0.1),
      child: Row(
        children: [
          SizedBox(
            width: 20.w,
            height: 20.w,
            child: const CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Text(
              'جاري توصيلك بأحد ممثلي الدعم...\nموقعك في الانتظار: $queuePosition',
              style: TextStyle(color: AppColors.warning, fontSize: 13.sp),
            ),
          ),
        ],
      ),
    );
  }
}

class LiveChatMessagesList extends StatelessWidget {
  final ScrollController controller;
  final List<ChatMessageModel> messages;
  final bool isSending;
  final bool isDark;

  const LiveChatMessagesList({
    super.key,
    required this.controller,
    required this.messages,
    required this.isSending,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: controller,
      padding: EdgeInsets.all(16.w),
      itemCount: messages.length + (isSending ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == messages.length && isSending) {
          return LiveChatTypingIndicator(isDark: isDark);
        }

        return LiveChatMessageBubble(message: messages[index], isDark: isDark);
      },
    );
  }
}

class LiveChatMessageBubble extends StatelessWidget {
  final ChatMessageModel message;
  final bool isDark;

  const LiveChatMessageBubble({
    super.key,
    required this.message,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.isFromVisitor;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          bottom: 12.h,
          left: isUser ? 50.w : 0,
          right: isUser ? 0 : 50.w,
        ),
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: isUser
              ? AppColors.primary
              : (isDark ? AppColors.cardDark : AppColors.backgroundLight),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.r),
            topRight: Radius.circular(16.r),
            bottomLeft: Radius.circular(isUser ? 16.r : 4.r),
            bottomRight: Radius.circular(isUser ? 4.r : 16.r),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isUser && message.senderName != null) ...[
              Text(
                message.senderName!,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
              SizedBox(height: 4.h),
            ],
            Text(
              message.content,
              style: TextStyle(
                fontSize: 14.sp,
                color: isUser
                    ? Colors.white
                    : (isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight),
              ),
            ),
            SizedBox(height: 4.h),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatTime(message.createdAt),
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: isUser
                        ? Colors.white.withValues(alpha: 0.7)
                        : (isDark
                              ? AppColors.textTertiaryDark
                              : AppColors.textTertiaryLight),
                  ),
                ),
                if (isUser) ...[
                  SizedBox(width: 4.w),
                  Icon(
                    message.isRead ? Iconsax.tick_circle : Iconsax.tick_square,
                    size: 12.sp,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  }
}

class LiveChatTypingIndicator extends StatelessWidget {
  final bool isDark;

  const LiveChatTypingIndicator({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h, right: 50.w),
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.backgroundLight,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.r),
            topRight: Radius.circular(16.r),
            bottomLeft: Radius.circular(4.r),
            bottomRight: Radius.circular(16.r),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            return Container(
              margin: EdgeInsets.symmetric(horizontal: 2.w),
              width: 8.w,
              height: 8.w,
              decoration: const BoxDecoration(
                color: AppColors.textTertiaryLight,
                shape: BoxShape.circle,
              ),
            );
          }),
        ),
      ),
    );
  }
}

class LiveChatQuickReplies extends StatelessWidget {
  final bool isDark;
  final List<String> quickReplies;
  final ValueChanged<String> onReplyTap;

  const LiveChatQuickReplies({
    super.key,
    required this.isDark,
    required this.quickReplies,
    required this.onReplyTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Wrap(
        spacing: 8.w,
        runSpacing: 8.h,
        children: quickReplies.map((reply) {
          return ActionChip(
            label: Text(reply),
            onPressed: () => onReplyTap(reply),
            backgroundColor: isDark
                ? AppColors.cardDark
                : AppColors.backgroundLight,
          );
        }).toList(),
      ),
    );
  }
}

class LiveChatMessageInput extends StatelessWidget {
  final TextEditingController controller;
  final bool isDark;
  final bool canSend;
  final bool isSending;
  final VoidCallback onSend;

  const LiveChatMessageInput({
    super.key,
    required this.controller,
    required this.isDark,
    required this.canSend,
    required this.isSending,
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
              onPressed: canSend ? () {} : null,
              icon: Icon(
                Iconsax.attach_circle,
                color: canSend
                    ? AppColors.textSecondaryLight
                    : AppColors.textTertiaryLight,
              ),
            ),
            Expanded(
              child: TextField(
                controller: controller,
                enabled: canSend,
                decoration: InputDecoration(
                  hintText: canSend
                      ? 'اكتب رسالتك...'
                      : 'لا يمكن إرسال الرسائل الآن',
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
                onSubmitted: canSend ? (_) => onSend() : null,
              ),
            ),
            SizedBox(width: 8.w),
            CircleAvatar(
              radius: 22.r,
              backgroundColor: canSend
                  ? AppColors.primary
                  : AppColors.textTertiaryLight,
              child: IconButton(
                onPressed: canSend && !isSending ? onSend : null,
                icon: isSending
                    ? SizedBox(
                        width: 18.w,
                        height: 18.w,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Icon(Iconsax.send_1, color: Colors.white, size: 20.sp),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LiveChatOptionsSheet extends StatelessWidget {
  final VoidCallback onConvertToTicket;
  final VoidCallback onRateChat;
  final VoidCallback onEndChat;

  const LiveChatOptionsSheet({
    super.key,
    required this.onConvertToTicket,
    required this.onRateChat,
    required this.onEndChat,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Iconsax.ticket),
            title: const Text('تحويل إلى تذكرة'),
            onTap: onConvertToTicket,
          ),
          ListTile(
            leading: const Icon(Iconsax.star),
            title: const Text('تقييم المحادثة'),
            onTap: onRateChat,
          ),
          ListTile(
            leading: const Icon(Iconsax.close_circle),
            title: const Text('إنهاء المحادثة'),
            onTap: onEndChat,
          ),
        ],
      ),
    );
  }
}
