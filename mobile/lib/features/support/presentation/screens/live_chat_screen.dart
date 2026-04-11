library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/config/theme/app_colors.dart';
import '../../../../routes/app_route_paths.dart';
import '../controllers/live_chat_session_controller.dart';
import '../cubit/live_chat_cubit.dart';
import '../widgets/live_chat_sections.dart';
import '../widgets/rating_dialog.dart';

class LiveChatScreen extends StatefulWidget {
  const LiveChatScreen({super.key});

  @override
  State<LiveChatScreen> createState() => _LiveChatScreenState();
}

class _LiveChatScreenState extends State<LiveChatScreen> {
  late final LiveChatSessionController _controller;

  @override
  void initState() {
    super.initState();
    _controller = LiveChatSessionController()
      ..initialize(context.read<LiveChatCubit>());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _startChat() async {
    await context.read<LiveChatCubit>().startChat();
  }

  Future<void> _showRatingDialog() async {
    final result = await RatingDialog.show(
      context,
      title: 'قيم المحادثة',
      message: 'كيف كانت تجربتك مع فريق الدعم؟',
    );

    if (!mounted || result == null) return;

    await _endChat(
      rating: result['rating'] as int?,
      feedback: result['feedback'] as String?,
    );
  }

  Future<void> _endChat({int? rating, String? feedback}) async {
    await context.read<LiveChatCubit>().endChat(
      rating: rating,
      feedback: feedback,
    );
  }

  void _showOptions() {
    showModalBottomSheet<void>(
      context: context,
      builder: (bottomSheetContext) {
        return LiveChatOptionsSheet(
          onConvertToTicket: () {
            Navigator.of(bottomSheetContext).pop();
            context.push(AppRoutePaths.supportCreate);
          },
          onRateChat: () {
            Navigator.of(bottomSheetContext).pop();
            _showRatingDialog();
          },
          onEndChat: () {
            Navigator.of(bottomSheetContext).pop();
            _endChat();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocConsumer<LiveChatCubit, LiveChatState>(
      listener: (context, state) {
        _controller.syncState(context.read<LiveChatCubit>(), state);

        if (state.error case final error?) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: LiveChatTitle(state: state),
            actions: [
              if (state.status != LiveChatStatus.initial &&
                  state.status != LiveChatStatus.loading)
                IconButton(
                  onPressed: _showOptions,
                  icon: const Icon(Iconsax.more),
                  tooltip: 'المزيد',
                ),
            ],
          ),
          body: _buildBody(context, state, isDark),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, LiveChatState state, bool isDark) {
    if (state.status == LiveChatStatus.loading && state.session == null) {
      return const LiveChatLoadingView();
    }

    if (state.status == LiveChatStatus.initial) {
      return LiveChatStartView(onStartChat: _startChat);
    }

    if (state.status == LiveChatStatus.ended) {
      return Column(
        children: [
          Expanded(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(32.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Iconsax.message_remove,
                      size: 72.sp,
                      color: AppColors.textTertiaryLight,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'تم إنهاء المحادثة',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'يمكنك بدء محادثة جديدة في أي وقت إذا احتجت إلى دعم إضافي.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                    SizedBox(height: 24.h),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _startChat,
                        icon: const Icon(Iconsax.message_add),
                        label: const Text('ابدأ محادثة جديدة'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        if (state.isWaiting)
          LiveChatWaitingBanner(queuePosition: state.queuePosition),
        Expanded(
          child: state.messages.isEmpty
              ? _buildEmptyConversation(context, state, isDark)
              : LiveChatMessagesList(
                  controller: _controller.scrollController,
                  messages: state.messages,
                  isSending: state.isSending,
                  isDark: isDark,
                ),
        ),
        if (state.isActive && state.messages.length <= 1)
          LiveChatQuickReplies(
            isDark: isDark,
            quickReplies: _controller.quickReplies,
            onReplyTap: (message) {
              _controller.sendQuickReply(
                context.read<LiveChatCubit>(),
                message,
              );
            },
          ),
        LiveChatMessageInput(
          controller: _controller.messageController,
          isDark: isDark,
          canSend: state.isActive,
          isSending: state.isSending,
          onSend: () {
            _controller.sendCurrentMessage(context.read<LiveChatCubit>());
          },
        ),
      ],
    );
  }

  Widget _buildEmptyConversation(
    BuildContext context,
    LiveChatState state,
    bool isDark,
  ) {
    final message = state.isWaiting
        ? 'تم إنشاء الجلسة بنجاح. سنوصلك بأحد ممثلي الدعم حالما يصبح متاحاً.'
        : 'اكتب رسالتك الأولى وسيرد عليك فريق الدعم مباشرة.';

    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Iconsax.messages_3,
              size: 72.sp,
              color: isDark
                  ? AppColors.textTertiaryDark
                  : AppColors.textTertiaryLight,
            ),
            SizedBox(height: 16.h),
            Text(
              state.isWaiting ? 'بانتظار انضمام الدعم' : 'ابدأ المحادثة',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 8.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
