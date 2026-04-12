part of 'support_remote_datasource.dart';

class _SupportRemoteTicketsDelegate {
  final _SupportRemoteSupport _support;

  const _SupportRemoteTicketsDelegate({required _SupportRemoteSupport support})
    : _support = support;

  Future<List<TicketCategoryModel>> getCategories({
    bool activeOnly = true,
  }) async {
    _support.log('Fetching ticket categories');

    final response = await _support.apiClient.get(
      ApiEndpoints.ticketCategories,
      queryParameters: {'activeOnly': activeOnly.toString()},
    );

    final payload = _support.requireSuccess(
      response.data,
      fallbackMessage: 'Failed to load categories',
    );

    return _support
        .extractList(payload['data'])
        .map((json) => TicketCategoryModel.fromJson(_support.extractMap(json)))
        .toList();
  }

  Future<List<TicketModel>> getMyTickets() async {
    _support.log('Fetching my tickets');

    final response = await _support.apiClient.get(ApiEndpoints.myTickets);
    final payload = _support.requireSuccess(
      response.data,
      fallbackMessage: 'Failed to load tickets',
    );

    return _support
        .extractList(payload['data'])
        .map((json) => TicketModel.fromJson(_support.extractMap(json)))
        .toList();
  }

  Future<Map<String, dynamic>> getMyTicketById(String ticketId) async {
    _support.log('Fetching my ticket: $ticketId');

    final response = await _support.apiClient.get(
      ApiEndpoints.ticketDetails(ticketId),
    );
    final payload = _support.requireSuccess(
      response.data,
      fallbackMessage: 'Failed to load ticket',
    );

    final data =
        payload['data'] ??
        _support.extractMap(response.data)['data'] ??
        response.data;
    final dataMap = _support.extractMap(data);
    final ticketData = dataMap['ticket'] ?? dataMap;
    final messagesJson = dataMap['messages'];

    if (ticketData is! Map) {
      throw Exception(
        payload['messageAr'] ?? payload['message'] ?? 'Invalid ticket response',
      );
    }

    return {
      'ticket': TicketModel.fromJson(Map<String, dynamic>.from(ticketData)),
      'messages': _support
          .extractList(messagesJson)
          .whereType<Map>()
          .map(
            (message) =>
                TicketMessageModel.fromJson(Map<String, dynamic>.from(message)),
          )
          .toList(),
    };
  }

  Future<TicketModel> createTicket(CreateTicketRequest request) async {
    _support.log('Creating ticket');

    final body = request.toJson()..['source'] = request.source ?? 'mobile_app';
    if (request.customerName != null && request.customerEmail != null) {
      body['customer'] = {
        'name': request.customerName,
        'email': request.customerEmail,
      };
    }

    final response = await _support.apiClient.post(
      ApiEndpoints.tickets,
      data: body,
    );

    final payload = _support.requireSuccess(
      response.data,
      fallbackMessage: 'Failed to create ticket',
    );
    final data = payload['data'];
    if (data is! Map) {
      throw Exception(
        payload['messageAr'] ?? payload['message'] ?? 'Invalid ticket response',
      );
    }

    return TicketModel.fromJson(Map<String, dynamic>.from(data));
  }

  Future<TicketMessageModel> addMessageToTicket({
    required String ticketId,
    required String content,
    List<String>? attachments,
  }) async {
    _support.log('Adding message to ticket: $ticketId');

    final response = await _support.apiClient.post(
      ApiEndpoints.ticketMessages(ticketId),
      data: {
        'content': content,
        if (attachments != null) 'attachments': attachments,
      },
    );

    final payload = _support.requireSuccess(
      response.data,
      fallbackMessage: 'Failed to send message',
    );
    final data = payload['data'];
    if (data is! Map) {
      throw Exception(
        payload['messageAr'] ??
            payload['message'] ??
            'Invalid message response',
      );
    }

    return TicketMessageModel.fromJson(Map<String, dynamic>.from(data));
  }

  Future<TicketModel> rateTicket({
    required String ticketId,
    required int rating,
    String? feedback,
  }) async {
    _support.log('Rating ticket: $ticketId');

    final response = await _support.apiClient.post(
      ApiEndpoints.ticketRate(ticketId),
      data: {'rating': rating, if (feedback != null) 'feedback': feedback},
    );

    final payload = _support.requireSuccess(
      response.data,
      fallbackMessage: 'Failed to rate ticket',
    );

    return TicketModel.fromJson(
      _support.extractMap(payload['data'] ?? response.data),
    );
  }
}
