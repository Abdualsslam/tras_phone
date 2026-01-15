import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../data/datasources/support_remote_datasource.dart';
import '../../data/models/support_model.dart';

part 'support_state.dart';

@injectable
class SupportCubit extends Cubit<SupportState> {
  final SupportRemoteDataSource _dataSource;

  SupportCubit(this._dataSource) : super(const SupportState());

  /// تحميل فئات التذاكر
  Future<void> loadCategories() async {
    try {
      emit(state.copyWith(status: SupportStatus.loading));
      final categories = await _dataSource.getCategories();
      emit(state.copyWith(
        status: SupportStatus.loaded,
        categories: categories,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: SupportStatus.error,
        error: e.toString(),
      ));
    }
  }

  /// تحميل تذاكري
  Future<void> loadMyTickets({
    TicketStatus? status,
    bool refresh = false,
  }) async {
    try {
      if (refresh) {
        emit(state.copyWith(
          status: SupportStatus.loading,
          tickets: [],
          currentPage: 1,
          hasMoreTickets: true,
        ));
      } else {
        emit(state.copyWith(status: SupportStatus.loading));
      }

      final page = refresh ? 1 : state.currentPage;
      final tickets = await _dataSource.getMyTickets(
        status: status,
        page: page,
      );

      emit(state.copyWith(
        status: SupportStatus.loaded,
        tickets: refresh ? tickets : [...state.tickets, ...tickets],
        currentPage: page + 1,
        hasMoreTickets: tickets.length >= 10,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: SupportStatus.error,
        error: e.toString(),
      ));
    }
  }

  /// تحميل المزيد من التذاكر
  Future<void> loadMoreTickets({TicketStatus? status}) async {
    if (!state.hasMoreTickets || state.status == SupportStatus.loading) return;
    await loadMyTickets(status: status);
  }

  /// تحميل تفاصيل تذكرة
  Future<void> loadTicketDetails(String ticketId) async {
    try {
      emit(state.copyWith(status: SupportStatus.loading));
      final ticket = await _dataSource.getMyTicketById(ticketId);
      emit(state.copyWith(
        status: SupportStatus.loaded,
        selectedTicket: ticket,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: SupportStatus.error,
        error: e.toString(),
      ));
    }
  }

  /// إنشاء تذكرة جديدة
  Future<TicketModel?> createTicket({
    required String categoryId,
    required String subject,
    required String description,
    TicketPriority? priority,
    String? orderId,
    String? productId,
    List<String>? attachments,
  }) async {
    try {
      emit(state.copyWith(status: SupportStatus.loading));
      final ticket = await _dataSource.createTicket(
        CreateTicketRequest(
          categoryId: categoryId,
          subject: subject,
          description: description,
          priority: priority?.name,
          orderId: orderId,
          productId: productId,
          attachments: attachments,
        ),
      );
      emit(state.copyWith(
        status: SupportStatus.loaded,
        tickets: [ticket, ...state.tickets],
      ));
      return ticket;
    } catch (e) {
      emit(state.copyWith(
        status: SupportStatus.error,
        error: e.toString(),
      ));
      return null;
    }
  }

  /// إضافة رسالة للتذكرة
  Future<TicketMessageModel?> addMessage({
    required String ticketId,
    required String content,
    List<String>? attachments,
  }) async {
    try {
      final message = await _dataSource.addMessageToTicket(
        ticketId: ticketId,
        content: content,
        attachments: attachments,
      );
      emit(state.copyWith(
        messages: [...state.messages, message],
      ));
      return message;
    } catch (e) {
      emit(state.copyWith(
        status: SupportStatus.error,
        error: e.toString(),
      ));
      return null;
    }
  }

  /// تقييم التذكرة
  Future<bool> rateTicket({
    required String ticketId,
    required int rating,
    String? feedback,
  }) async {
    try {
      await _dataSource.rateTicket(
        ticketId: ticketId,
        rating: rating,
        feedback: feedback,
      );
      return true;
    } catch (e) {
      emit(state.copyWith(
        status: SupportStatus.error,
        error: e.toString(),
      ));
      return false;
    }
  }

  /// رفع المرفقات
  Future<List<String>> uploadAttachments(List<String> filePaths) async {
    try {
      return await _dataSource.uploadAttachments(filePaths);
    } catch (e) {
      emit(state.copyWith(
        status: SupportStatus.error,
        error: e.toString(),
      ));
      return [];
    }
  }

  /// مسح التذكرة المحددة
  void clearSelectedTicket() {
    emit(state.copyWith(selectedTicket: null, messages: []));
  }
}
