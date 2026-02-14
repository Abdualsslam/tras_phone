/// Live Chat Screen - Real-time chat with support
library;

import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../../../../core/services/socket_service.dart';
import '../../data/models/support_model.dart';
import '../cubit/live_chat_cubit.dart';
import '../widgets/rating_dialog.dart';

class LiveChatScreen extends StatefulWidget {
  const LiveChatScreen({super.key});

  @override
  State<LiveChatScreen> createState() => _LiveChatScreenState();
}

class _LiveChatScreenState extends State<LiveChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  Function? _unsubChatMessage;
  Function? _unsubSessionUpdated;
  Function? _unsubSessionAccepted;
  Function? _unsubSessionWaiting;
  String? _joinedSessionId;

  final _quickReplies = [
    'استفسار عن طلب',
    'مشكلة في منتج',
    'طلب استرجاع',
    'استفسار عام',
  ];

  @override
  void initState() {
    super.initState();
    context.read<LiveChatCubit>().initChat();
    _setupWebSocketListeners();
  }

  void _setupWebSocketListeners() {
    final socket = SocketService();
    _unsubChatMessage = socket.on('chat:message', _onChatMessage);
    _unsubSessionUpdated = socket.on('chat:session:updated', _onSessionUpdated);
    _unsubSessionAccepted = socket.on('chat:session:accepted', _onSessionUpdated);
    _unsubSessionWaiting = socket.on('chat:session:waiting', _onSessionWaiting);
  }

  void _onChatMessage(dynamic data) {
    if (!mounted) return;
    try {
      final map = Map<String, dynamic>.from(data as Map);
      final message = ChatMessageModel.fromJson(map);
      context.read<LiveChatCubit>().addMessage(message);
    } catch (e) {
      developer.log('Failed to parse chat:message: $e', name: 'LiveChatScreen');
    }
  }

  void _onSessionUpdated(dynamic data) {
    if (!mounted) return;
    try {
      final map = Map<String, dynamic>.from(data as Map);
      final statusStr = map['status'] as String? ?? 'active';
      final status = ChatSessionStatus.fromString(statusStr);
      context.read<LiveChatCubit>().updateSessionStatus(status);
    } catch (e) {
      developer.log('Failed to parse session update: $e', name: 'LiveChatScreen');
    }
  }

  void _onSessionWaiting(dynamic data) {
    if (!mounted) return;
    context.read<LiveChatCubit>().updateSessionStatus(ChatSessionStatus.waiting);
  }

  void _joinChatRoom(String? sessionId) {
    if (sessionId != null && sessionId.isNotEmpty) {
      SocketService().joinChat(sessionId);
    }
  }

  void _leaveChatRoom(String? sessionId) {
    if (sessionId != null && sessionId.isNotEmpty) {
      SocketService().leaveChat(sessionId);
      _joinedSessionId = null;
    }
    _unsubChatMessage?.call();
    _unsubSessionUpdated?.call();
    _unsubSessionAccepted?.call();
    _unsubSessionWaiting?.call();
  }

  void _ensureJoinedChat(ChatSessionModel? session) {
    if (session != null && session.id != _joinedSessionId) {
      _leaveChatRoom(_joinedSessionId);
      _joinChatRoom(session.id);
      _joinedSessionId = session.id;
    }
  }

  @override
  void dispose() {
    _leaveChatRoom(_joinedSessionId);
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: BlocBuilder<LiveChatCubit, LiveChatState>(
          builder: (context, state) {
            return Row(
              children: [
                CircleAvatar(
                  radius: 18.r,
                  backgroundColor: state.isActive
                      ? AppColors.success
                      : state.isWaiting
                          ? AppColors.warning
                          : AppColors.textTertiaryLight,
                  child: Icon(
                    Iconsax.headphone,
                    size: 18.sp,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 12.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'الدعم المباشر',
                      style: TextStyle(fontSize: 16.sp),
                    ),
                    Row(
                      children: [
                        Container(
                          width: 8.w,
                          height: 8.w,
                          decoration: BoxDecoration(
                            color: state.isActive
                                ? AppColors.success
                                : state.isWaiting
                                    ? AppColors.warning
                                    : AppColors.textTertiaryLight,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          state.isActive
                              ? 'متصل الآن'
                              : state.isWaiting
                                  ? 'في الانتظار (${state.queuePosition})'
                                  : 'غير متصل',
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
          },
        ),
        actions: [
          IconButton(
            onPressed: () => _showOptions(context),
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
      body: BlocConsumer<LiveChatCubit, LiveChatState>(
        listener: (context, state) {
          _ensureJoinedChat(state.session);
          if (state.status == LiveChatStatus.error && state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error!),
                backgroundColor: AppColors.error,
              ),
            );
          }
          // Scroll to bottom when new messages arrive
          if (state.messages.isNotEmpty) {
            _scrollToBottom();
          }
        },
        builder: (context, state) {
          if (state.status == LiveChatStatus.loading &&
              state.session == null) {
            return const Center(child: CircularProgressIndicator());
          }

          // Show start chat UI if no session
          if (state.status == LiveChatStatus.initial) {
            return _buildStartChatUI(isDark);
          }

          return Column(
            children: [
              // Waiting indicator
              if (state.isWaiting)
                Container(
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
                          'جاري توصيلك بأحد ممثلي الدعم...\nموقعك في الانتظار: ${state.queuePosition}',
                          style: TextStyle(
                            color: AppColors.warning,
                            fontSize: 13.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Messages
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.all(16.w),
                  itemCount:
                      state.messages.length + (state.isSending ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == state.messages.length && state.isSending) {
                      return _buildTypingIndicator(isDark);
                    }
                    final msg = state.messages[index];
                    return _buildMessageBubble(msg, isDark);
                  },
                ),
              ),

              // Quick Replies
              if (state.messages.length <= 2 && state.session != null)
                _buildQuickReplies(isDark, state),

              // Message Input
              _buildMessageInput(isDark, state),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStartChatUI(bool isDark) {
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
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
              ),
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
                onPressed: () {
                  context.read<LiveChatCubit>().startChat();
                },
                icon: const Icon(Iconsax.message_add),
                label: const Text('بدء المحادثة'),
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

  Widget _buildMessageBubble(ChatMessageModel msg, bool isDark) {
    final isUser = msg.isFromVisitor;

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
            if (!isUser && msg.senderName != null) ...[
              Text(
                msg.senderName!,
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
              msg.content,
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
                  _formatTime(msg.createdAt),
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
                    msg.isRead ? Iconsax.tick_circle : Iconsax.tick_square,
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

  Widget _buildTypingIndicator(bool isDark) {
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
              decoration: BoxDecoration(
                color: AppColors.textTertiaryLight,
                shape: BoxShape.circle,
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildQuickReplies(bool isDark, LiveChatState state) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Wrap(
        spacing: 8.w,
        runSpacing: 8.h,
        children: _quickReplies.map((reply) {
          return ActionChip(
            label: Text(reply),
            onPressed: () {
              context.read<LiveChatCubit>().sendMessage(reply);
            },
            backgroundColor:
                isDark ? AppColors.cardDark : AppColors.backgroundLight,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMessageInput(bool isDark, LiveChatState state) {
    final canSend = state.isActive || state.isWaiting;

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
                controller: _messageController,
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
                  fillColor:
                      isDark ? AppColors.cardDark : AppColors.backgroundLight,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 10.h,
                  ),
                ),
                onSubmitted: canSend ? (_) => _sendMessage() : null,
              ),
            ),
            SizedBox(width: 8.w),
            CircleAvatar(
              radius: 22.r,
              backgroundColor:
                  canSend ? AppColors.primary : AppColors.textTertiaryLight,
              child: IconButton(
                onPressed: canSend && !state.isSending ? _sendMessage : null,
                icon: state.isSending
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

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;
    final message = _messageController.text.trim();
    _messageController.clear();
    context.read<LiveChatCubit>().sendMessage(message);
  }

  String _formatTime(DateTime time) {
    return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Iconsax.ticket),
              title: const Text('تحويل إلى تذكرة'),
              onTap: () {
                Navigator.pop(ctx);
                context.push('/support/create-ticket');
              },
            ),
            ListTile(
              leading: const Icon(Iconsax.star),
              title: const Text('تقييم المحادثة'),
              onTap: () {
                Navigator.pop(ctx);
                _showRatingDialog();
              },
            ),
            ListTile(
              leading: const Icon(Iconsax.close_circle),
              title: const Text('إنهاء المحادثة'),
              onTap: () {
                Navigator.pop(ctx);
                _endChat();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showRatingDialog() async {
    final result = await RatingDialog.show(
      context,
      title: 'قيم المحادثة',
      message: 'كيف تقيم خدمة الدعم التي تلقيتها؟',
      allowFeedback: true,
    );

    if (result != null && mounted) {
      await context.read<LiveChatCubit>().endChat(
            rating: result['rating'] as int,
            feedback: result['feedback'] as String?,
          );
      if (mounted) {
        context.pop();
      }
    }
  }

  Future<void> _endChat() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إنهاء المحادثة'),
        content: const Text('هل تريد إنهاء المحادثة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('إنهاء'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _showRatingDialog();
    }
  }
}
