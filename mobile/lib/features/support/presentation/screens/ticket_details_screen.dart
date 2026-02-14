/// Ticket Details Screen - Support ticket details and chat
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../../data/models/support_model.dart';
import '../../utils/support_error_helper.dart';
import '../cubit/support_cubit.dart';
import '../widgets/ticket_status_badge.dart';
import '../widgets/ticket_priority_badge.dart';
import '../widgets/ticket_message_bubble.dart';
import '../widgets/rating_dialog.dart';

class TicketDetailsScreen extends StatefulWidget {
  final String ticketId;

  const TicketDetailsScreen({super.key, required this.ticketId});

  @override
  State<TicketDetailsScreen> createState() => _TicketDetailsScreenState();
}

class _TicketDetailsScreenState extends State<TicketDetailsScreen> {
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
            content: Text(getSupportErrorMessage(e)),
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

  Future<void> _showRatingDialog() async {
    final result = await RatingDialog.show(
      context,
      title: 'قيم خدمة الدعم',
      message: 'كيف تقيم خدمة الدعم التي تلقيتها؟',
    );

    if (result != null && mounted) {
      final success = await context.read<SupportCubit>().rateTicket(
            ticketId: widget.ticketId,
            rating: result['rating'] as int,
            feedback: result['feedback'] as String?,
          );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('شكراً لتقييمك!'),
            backgroundColor: AppColors.success,
          ),
        );
        // Reload ticket details
        context.read<SupportCubit>().loadTicketDetails(widget.ticketId);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل التذكرة'),
        actions: [
          BlocBuilder<SupportCubit, SupportState>(
            builder: (context, state) {
              if (state.selectedTicket?.canRate == true) {
                return IconButton(
                  icon: const Icon(Iconsax.star),
                  onPressed: _showRatingDialog,
                  tooltip: 'قيم التذكرة',
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocBuilder<SupportCubit, SupportState>(
        builder: (context, state) {
          if (state.status == SupportStatus.loading &&
              state.selectedTicket == null) {
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

          final ticket = state.selectedTicket;
          if (ticket == null) {
            return const Center(child: Text('التذكرة غير موجودة'));
          }

          return Column(
            children: [
              // Ticket Info Header
              _buildTicketHeader(ticket, isDark),

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

  Widget _buildTicketHeader(TicketModel ticket, bool isDark) {
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
              if (ticket.category != null)
                Chip(
                  label: Text(ticket.category!.getName('ar')),
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
