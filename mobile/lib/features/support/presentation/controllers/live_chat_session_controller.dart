import 'dart:developer' as developer;

import 'package:flutter/material.dart';

import '../../../../core/services/socket_service.dart';
import '../../data/models/support_model.dart';
import '../cubit/live_chat_cubit.dart';

class LiveChatSessionController {
  final SocketService _socketService;

  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  Function? _unsubChatMessage;
  Function? _unsubSessionUpdated;
  Function? _unsubSessionAccepted;
  Function? _unsubSessionWaiting;
  String? _joinedSessionId;
  int _lastMessageCount = 0;

  LiveChatSessionController({SocketService? socketService})
    : _socketService = socketService ?? SocketService();

  List<String> get quickReplies => const [
    'استفسار عن طلب',
    'مشكلة في منتج',
    'طلب استرجاع',
    'استفسار عام',
  ];

  void initialize(LiveChatCubit cubit) {
    cubit.initChat();
    _setupWebSocketListeners(cubit);
  }

  void syncState(LiveChatCubit cubit, LiveChatState state) {
    _ensureJoinedChat(state.session);
    if (state.messages.length != _lastMessageCount) {
      _lastMessageCount = state.messages.length;
      _scrollToBottom();
    }
  }

  void sendQuickReply(LiveChatCubit cubit, String message) {
    cubit.sendMessage(message);
  }

  void sendCurrentMessage(LiveChatCubit cubit) {
    final message = messageController.text.trim();
    if (message.isEmpty) return;

    messageController.clear();
    cubit.sendMessage(message);
  }

  void dispose() {
    _leaveChatRoom(_joinedSessionId);
    _disposeListeners();
    messageController.dispose();
    scrollController.dispose();
  }

  void _setupWebSocketListeners(LiveChatCubit cubit) {
    _unsubChatMessage = _socketService.on(
      'chat:message',
      (data) => _onChatMessage(cubit, data),
    );
    _unsubSessionUpdated = _socketService.on(
      'chat:session:updated',
      (data) => _onSessionUpdated(cubit, data),
    );
    _unsubSessionAccepted = _socketService.on(
      'chat:session:accepted',
      (data) => _onSessionUpdated(cubit, data),
    );
    _unsubSessionWaiting = _socketService.on(
      'chat:session:waiting',
      (_) => cubit.updateSessionStatus(ChatSessionStatus.waiting),
    );
  }

  void _onChatMessage(LiveChatCubit cubit, dynamic data) {
    try {
      final map = Map<String, dynamic>.from(data as Map);
      final message = ChatMessageModel.fromJson(map);
      cubit.addMessage(message);
    } catch (error) {
      developer.log(
        'Failed to parse chat:message: $error',
        name: 'LiveChatSessionController',
      );
    }
  }

  void _onSessionUpdated(LiveChatCubit cubit, dynamic data) {
    try {
      final map = Map<String, dynamic>.from(data as Map);
      final statusStr = map['status'] as String? ?? 'active';
      final status = ChatSessionStatus.fromString(statusStr);
      cubit.updateSessionStatus(status);
    } catch (error) {
      developer.log(
        'Failed to parse session update: $error',
        name: 'LiveChatSessionController',
      );
    }
  }

  void _joinChatRoom(String? sessionId) {
    if (sessionId == null || sessionId.isEmpty) return;
    _socketService.joinChat(sessionId);
  }

  void _leaveChatRoom(String? sessionId) {
    if (sessionId != null && sessionId.isNotEmpty) {
      _socketService.leaveChat(sessionId);
      _joinedSessionId = null;
    }
  }

  void _disposeListeners() {
    _unsubChatMessage?.call();
    _unsubSessionUpdated?.call();
    _unsubSessionAccepted?.call();
    _unsubSessionWaiting?.call();
  }

  void _ensureJoinedChat(ChatSessionModel? session) {
    if (session == null || session.id == _joinedSessionId) return;
    _leaveChatRoom(_joinedSessionId);
    _joinChatRoom(session.id);
    _joinedSessionId = session.id;
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (!scrollController.hasClients) return;

      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }
}
