library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/config/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../controllers/ticket_conversation_controller.dart';
import '../cubit/support_cubit.dart';
import '../widgets/rating_dialog.dart';
import '../widgets/ticket_details_sections.dart';

class TicketDetailsScreen extends StatefulWidget {
  final String ticketId;

  const TicketDetailsScreen({super.key, required this.ticketId});

  @override
  State<TicketDetailsScreen> createState() => _TicketDetailsScreenState();
}

class _TicketDetailsScreenState extends State<TicketDetailsScreen> {
  late final TicketConversationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TicketConversationController()
      ..initialize(context.read<SupportCubit>(), widget.ticketId);
  }

  @override
  void dispose() {
    _controller.disposeForTicket(widget.ticketId);
    super.dispose();
  }

  Future<void> _reloadTicket() {
    return context.read<SupportCubit>().loadTicketDetails(widget.ticketId);
  }

  Future<void> _sendMessage() async {
    final error = await _controller.sendMessage(
      context.read<SupportCubit>(),
      widget.ticketId,
    );

    if (!mounted || error == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error), backgroundColor: AppColors.error),
    );
  }

  Future<void> _showRatingDialog() async {
    final result = await RatingDialog.show(
      context,
      title: 'قيم خدمة الدعم',
      message: 'كيف تقيم خدمة الدعم التي تلقيتها؟',
    );

    if (!mounted || result == null) return;

    final success = await context.read<SupportCubit>().rateTicket(
      ticketId: widget.ticketId,
      rating: result['rating'] as int,
      feedback: result['feedback'] as String?,
    );

    if (!mounted || !success) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('شكراً لتقييمك!'),
        backgroundColor: AppColors.success,
      ),
    );
    await _reloadTicket();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return BlocConsumer<SupportCubit, SupportState>(
          listener: (context, state) {
            _controller.syncMessages(state.messages);
          },
          builder: (context, state) {
            return Scaffold(
              appBar: AppBar(
                title: Text(AppLocalizations.of(context)!.ticketDetails),
                actions: [
                  if (state.selectedTicket?.canRate == true)
                    IconButton(
                      icon: const Icon(Iconsax.star),
                      onPressed: _showRatingDialog,
                      tooltip: 'قيم التذكرة',
                    ),
                ],
              ),
              body: _buildBody(context, state, isDark),
            );
          },
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, SupportState state, bool isDark) {
    if (state.status == SupportStatus.loading && state.selectedTicket == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.status == SupportStatus.error) {
      return TicketDetailsErrorState(
        message: state.error ?? 'حدث خطأ',
        onRetry: _reloadTicket,
      );
    }

    final ticket = state.selectedTicket;
    if (ticket == null) {
      return Center(child: Text(AppLocalizations.of(context)!.noResults));
    }

    return Column(
      children: [
        TicketConversationHeader(ticket: ticket, isDark: isDark),
        Expanded(
          child: TicketConversationList(
            controller: _controller.scrollController,
            messages: state.messages,
            isDark: isDark,
            onRefresh: _reloadTicket,
          ),
        ),
        TicketAttachmentsPreview(
          attachments: _controller.selectedAttachments,
          isDark: isDark,
          onRemove: _controller.removeAttachmentAt,
        ),
        TicketMessageInputBar(
          controller: _controller.messageController,
          isDark: isDark,
          isSending: _controller.isSending,
          onPickAttachment: _controller.pickAttachment,
          onSend: _sendMessage,
        ),
      ],
    );
  }
}
