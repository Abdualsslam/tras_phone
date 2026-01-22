/// Ticket Chat Screen - Chat interface for support ticket
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../cubit/support_cubit.dart';
import '../widgets/ticket_message_bubble.dart';

class TicketChatScreen extends StatefulWidget {
  final String ticketId;
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
  final List<String> _selectedAttachments = [];
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    context.read<SupportCubit>().loadTicketDetails(widget.ticketId);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty && _selectedAttachments.isEmpty) {
      return;
    }

    setState(() => _isSending = true);

    try {
      List<String> attachmentUrls = [];
      
      // Upload attachments if any
      if (_selectedAttachments.isNotEmpty) {
        final cubit = context.read<SupportCubit>();
        attachmentUrls = await cubit.uploadAttachments(_selectedAttachments);
      }

      // Send message
      final message = await context.read<SupportCubit>().addMessage(
            ticketId: widget.ticketId,
            content: _messageController.text.trim(),
            attachments: attachmentUrls.isNotEmpty ? attachmentUrls : null,
          );

      if (message != null) {
        _messageController.clear();
        setState(() => _selectedAttachments.clear());
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل إرسال الرسالة: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(widget.subject, style: TextStyle(fontSize: 14.sp)),
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_right_3),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocBuilder<SupportCubit, SupportState>(
        builder: (context, state) {
          if (state.status == SupportStatus.loading &&
              state.messages.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == SupportStatus.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    state.error ?? 'حدث خطأ',
                    style: TextStyle(color: AppColors.error),
                  ),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: () {
                      context.read<SupportCubit>().loadTicketDetails(widget.ticketId);
                    },
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Messages
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    await context.read<SupportCubit>().loadTicketDetails(widget.ticketId);
                  },
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.all(16.w),
                    itemCount: state.messages.length,
                    itemBuilder: (context, index) {
                      return TicketMessageBubble(
                        message: state.messages[index],
                        isDark: isDark,
                      );
                    },
                  ),
                ),
              ),

              // Attachments Preview
              if (_selectedAttachments.isNotEmpty)
                Container(
                  height: 100.h,
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.cardDark : AppColors.backgroundLight,
                    border: Border(
                      top: BorderSide(
                        color: isDark
                            ? AppColors.dividerDark
                            : AppColors.dividerLight,
                      ),
                    ),
                  ),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _selectedAttachments.length,
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
                                  _selectedAttachments[index],
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
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
                                  onPressed: () {
                                    setState(() {
                                      _selectedAttachments.removeAt(index);
                                    });
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

              // Message Input
              _buildMessageInput(isDark),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMessageInput(bool isDark) {
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
              onPressed: () async {
                final ImagePicker picker = ImagePicker();
                final XFile? image = await picker.pickImage(
                  source: ImageSource.gallery,
                  imageQuality: 85,
                );
                if (image != null && mounted) {
                  setState(() {
                    if (_selectedAttachments.length < 5) {
                      _selectedAttachments.add(image.path);
                    }
                  });
                }
              },
              icon: Icon(
                Iconsax.attach_circle,
                color: AppColors.textSecondaryLight,
              ),
            ),
            Expanded(
              child: TextField(
                controller: _messageController,
                enabled: !_isSending,
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
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            SizedBox(width: 8.w),
            CircleAvatar(
              radius: 22.r,
              backgroundColor: AppColors.primary,
              child: _isSending
                  ? SizedBox(
                      width: 20.w,
                      height: 20.h,
                      child: const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : IconButton(
                      onPressed: _sendMessage,
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
