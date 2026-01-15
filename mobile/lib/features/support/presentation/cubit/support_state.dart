part of 'support_cubit.dart';

enum SupportStatus { initial, loading, loaded, error }

class SupportState extends Equatable {
  final SupportStatus status;
  final List<TicketCategoryModel> categories;
  final List<TicketModel> tickets;
  final TicketModel? selectedTicket;
  final List<TicketMessageModel> messages;
  final String? error;
  final bool hasMoreTickets;
  final int currentPage;

  const SupportState({
    this.status = SupportStatus.initial,
    this.categories = const [],
    this.tickets = const [],
    this.selectedTicket,
    this.messages = const [],
    this.error,
    this.hasMoreTickets = true,
    this.currentPage = 1,
  });

  SupportState copyWith({
    SupportStatus? status,
    List<TicketCategoryModel>? categories,
    List<TicketModel>? tickets,
    TicketModel? selectedTicket,
    List<TicketMessageModel>? messages,
    String? error,
    bool? hasMoreTickets,
    int? currentPage,
  }) {
    return SupportState(
      status: status ?? this.status,
      categories: categories ?? this.categories,
      tickets: tickets ?? this.tickets,
      selectedTicket: selectedTicket ?? this.selectedTicket,
      messages: messages ?? this.messages,
      error: error,
      hasMoreTickets: hasMoreTickets ?? this.hasMoreTickets,
      currentPage: currentPage ?? this.currentPage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        categories,
        tickets,
        selectedTicket,
        messages,
        error,
        hasMoreTickets,
        currentPage,
      ];
}
