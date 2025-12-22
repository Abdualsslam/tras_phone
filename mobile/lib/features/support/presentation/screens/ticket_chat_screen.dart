/// Ticket Chat Screen - Chat interface for support ticket
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/config/theme/app_colors.dart';

class TicketChatScreen extends StatefulWidget {
  final int ticketId;
  final String subject;

  const TicketChatScreen({
    super.key,
    required this.ticketId,
    required this.subject,
  });

  @override
  State<TicketChatScreen> createState() => _TicketChatScreenState();
}

class _TicketChatScreenState extends State<TicketChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  final List<_Message> _messages = [
    _Message(
      id: 1,
      text: 'مرحباً، كيف يمكنني مساعدتك؟',
      isFromSupport: true,
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    _Message(
      id: 2,
      text: 'مرحباً، لدي مشكلة في طلبي رقم ORD-2024-001',
      isFromSupport: false,
      timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 50)),
    ),
    _Message(
      id: 3,
      text: 'أعتذر عن الإزعاج. دعني أتحقق من الطلب وأرد عليك قريباً.',
      isFromSupport: true,
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
    ),
  ];

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(widget.subject, style: TextStyle(fontSize: 14.sp)),
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_right_3),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          // Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.all(16.w),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageBubble(theme, isDark, message);
              },
            ),
          ),

          // Input
          _buildMessageInput(theme, isDark),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ThemeData theme, bool isDark, _Message message) {
    final isMe = !message.isFromSupport;

    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 16.r,
              backgroundColor: AppColors.primary,
              child: Icon(Iconsax.headphone, size: 16.sp, color: Colors.white),
            ),
            SizedBox(width: 8.w),
          ],
          Container(
            constraints: BoxConstraints(maxWidth: 280.w),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: isMe
                  ? AppColors.primary
                  : (isDark ? AppColors.cardDark : AppColors.cardLight),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.r),
                topRight: Radius.circular(16.r),
                bottomLeft: Radius.circular(isMe ? 16.r : 4.r),
                bottomRight: Radius.circular(isMe ? 4.r : 16.r),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.text,
                  style: TextStyle(
                    color: isMe
                        ? Colors.white
                        : theme.textTheme.bodyMedium?.color,
                    fontSize: 14.sp,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  _formatTime(message.timestamp),
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: isMe
                        ? Colors.white.withValues(alpha: 0.7)
                        : AppColors.textTertiaryLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput(ThemeData theme, bool isDark) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Iconsax.attach_circle),
              onPressed: () {},
              color: AppColors.textSecondaryLight,
            ),
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'اكتب رسالتك...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24.r),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: isDark
                      ? AppColors.cardDark
                      : AppColors.backgroundLight,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 12.h,
                  ),
                ),
              ),
            ),
            SizedBox(width: 8.w),
            Container(
              width: 48.w,
              height: 48.w,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Iconsax.send_1, color: Colors.white),
                onPressed: _sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      _messages.add(
        _Message(
          id: _messages.length + 1,
          text: _messageController.text.trim(),
          isFromSupport: false,
          timestamp: DateTime.now(),
        ),
      );
    });

    _messageController.clear();
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent + 100,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  }
}

class _Message {
  final int id;
  final String text;
  final bool isFromSupport;
  final DateTime timestamp;

  _Message({
    required this.id,
    required this.text,
    required this.isFromSupport,
    required this.timestamp,
  });
}
