import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/services/socket_service.dart';
import '../../data/models/support_model.dart';
import '../../utils/support_error_helper.dart';
import '../cubit/support_cubit.dart';

class TicketConversationController extends ChangeNotifier {
  final SocketService _socketService;
  final ImagePicker _imagePicker;

  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  final List<String> _selectedAttachments = [];
  Function? _unsubTicketMessage;
  bool _isSending = false;
  int _lastMessageCount = 0;

  TicketConversationController({
    SocketService? socketService,
    ImagePicker? imagePicker,
  }) : _socketService = socketService ?? SocketService(),
       _imagePicker = imagePicker ?? ImagePicker();

  List<String> get selectedAttachments =>
      List<String>.unmodifiable(_selectedAttachments);
  bool get isSending => _isSending;

  void initialize(SupportCubit supportCubit, String ticketId) {
    supportCubit.loadTicketDetails(ticketId);
    _socketService.joinTicket(ticketId);
    _unsubTicketMessage = _socketService.on(
      'ticket:message',
      (data) => _onTicketMessage(supportCubit, ticketId, data),
    );
  }

  void syncMessages(List<TicketMessageModel> messages) {
    if (messages.length != _lastMessageCount) {
      _lastMessageCount = messages.length;
      _scrollToBottom();
    }
  }

  Future<void> pickAttachment() async {
    final image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (image == null || _selectedAttachments.length >= 5) return;

    _selectedAttachments.add(image.path);
    notifyListeners();
  }

  void removeAttachmentAt(int index) {
    if (index < 0 || index >= _selectedAttachments.length) return;
    _selectedAttachments.removeAt(index);
    notifyListeners();
  }

  Future<String?> sendMessage(
    SupportCubit supportCubit,
    String ticketId,
  ) async {
    if (messageController.text.trim().isEmpty && _selectedAttachments.isEmpty) {
      return null;
    }

    _isSending = true;
    notifyListeners();

    try {
      List<String> attachmentUrls = const [];
      if (_selectedAttachments.isNotEmpty) {
        attachmentUrls = await supportCubit.uploadAttachments(
          _selectedAttachments,
        );
      }

      final message = await supportCubit.addMessage(
        ticketId: ticketId,
        content: messageController.text.trim(),
        attachments: attachmentUrls.isNotEmpty ? attachmentUrls : null,
      );

      if (message != null) {
        messageController.clear();
        _selectedAttachments.clear();
        _scrollToBottom();
      }

      return null;
    } catch (error) {
      return getSupportErrorMessage(error);
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }

  void disposeForTicket(String ticketId) {
    _socketService.leaveTicket(ticketId);
    _unsubTicketMessage?.call();
    messageController.dispose();
    scrollController.dispose();
  }

  void _onTicketMessage(
    SupportCubit supportCubit,
    String ticketId,
    dynamic data,
  ) {
    try {
      final map = Map<String, dynamic>.from(data as Map);
      final message = TicketMessageModel.fromJson(map);
      if (message.ticketId == ticketId) {
        supportCubit.addMessageFromSocket(message);
        _scrollToBottom();
      }
    } catch (error) {
      developer.log(
        'Failed to parse ticket:message: $error',
        name: 'TicketConversationController',
      );
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!scrollController.hasClients) return;

      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }
}
