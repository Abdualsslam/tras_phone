import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../data/datasources/support_remote_datasource.dart';
import '../../data/models/support_model.dart';

part 'live_chat_state.dart';

@injectable
class LiveChatCubit extends Cubit<LiveChatState> {
  final SupportRemoteDataSource _dataSource;

  LiveChatCubit(this._dataSource) : super(const LiveChatState());

  /// تهيئة المحادثة (تحقق من وجود جلسة نشطة)
  Future<void> initChat() async {
    try {
      emit(state.copyWith(status: LiveChatStatus.loading));

      // تحقق من وجود جلسة نشطة
      final session = await _dataSource.getMySession();

      if (session != null) {
        final chatStatus = session.isActive
            ? LiveChatStatus.active
            : session.isWaiting
                ? LiveChatStatus.waiting
                : LiveChatStatus.ended;

        emit(state.copyWith(
          status: chatStatus,
          session: session,
          messages: session.messages,
        ));
      } else {
        emit(state.copyWith(status: LiveChatStatus.initial));
      }
    } catch (e) {
      emit(state.copyWith(
        status: LiveChatStatus.error,
        error: e.toString(),
      ));
    }
  }

  /// بدء محادثة جديدة
  Future<void> startChat({
    String? initialMessage,
    String? department,
    String? categoryId,
  }) async {
    try {
      emit(state.copyWith(status: LiveChatStatus.loading));

      final session = await _dataSource.startChat(
        initialMessage: initialMessage,
        department: department,
        categoryId: categoryId,
      );

      emit(state.copyWith(
        status: session.isWaiting
            ? LiveChatStatus.waiting
            : LiveChatStatus.active,
        session: session,
        messages: session.messages,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: LiveChatStatus.error,
        error: e.toString(),
      ));
    }
  }

  /// إرسال رسالة
  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;

    try {
      emit(state.copyWith(isSending: true));

      final message = await _dataSource.sendChatMessage(content: content);

      emit(state.copyWith(
        isSending: false,
        messages: [...state.messages, message],
      ));
    } catch (e) {
      emit(state.copyWith(
        isSending: false,
        status: LiveChatStatus.error,
        error: e.toString(),
      ));
    }
  }

  /// إنهاء المحادثة
  Future<void> endChat({int? rating, String? feedback}) async {
    try {
      emit(state.copyWith(status: LiveChatStatus.loading));

      await _dataSource.endChat(rating: rating, feedback: feedback);

      emit(state.copyWith(
        status: LiveChatStatus.ended,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: LiveChatStatus.error,
        error: e.toString(),
      ));
    }
  }

  /// إضافة رسالة محلياً (للـ WebSocket)
  void addMessage(ChatMessageModel message) {
    emit(state.copyWith(
      messages: [...state.messages, message],
    ));
  }

  /// تحديث حالة الجلسة (للـ WebSocket)
  void updateSessionStatus(ChatSessionStatus status) {
    if (state.session == null) return;

    final chatStatus = status == ChatSessionStatus.active
        ? LiveChatStatus.active
        : status == ChatSessionStatus.waiting
            ? LiveChatStatus.waiting
            : LiveChatStatus.ended;

    emit(state.copyWith(status: chatStatus));
  }

  /// إعادة تعيين المحادثة
  void resetChat() {
    emit(const LiveChatState());
  }
}
