part of 'live_chat_cubit.dart';

enum LiveChatStatus { initial, loading, waiting, active, ended, error }

class LiveChatState extends Equatable {
  final LiveChatStatus status;
  final ChatSessionModel? session;
  final List<ChatMessageModel> messages;
  final String? error;
  final bool isSending;

  const LiveChatState({
    this.status = LiveChatStatus.initial,
    this.session,
    this.messages = const [],
    this.error,
    this.isSending = false,
  });

  LiveChatState copyWith({
    LiveChatStatus? status,
    ChatSessionModel? session,
    List<ChatMessageModel>? messages,
    String? error,
    bool? isSending,
  }) {
    return LiveChatState(
      status: status ?? this.status,
      session: session ?? this.session,
      messages: messages ?? this.messages,
      error: error,
      isSending: isSending ?? this.isSending,
    );
  }

  bool get isActive => status == LiveChatStatus.active;
  bool get isWaiting => status == LiveChatStatus.waiting;
  bool get canRate => session?.canRate ?? false;
  int get queuePosition => session?.queuePosition ?? 0;

  @override
  List<Object?> get props => [status, session, messages, error, isSending];
}
