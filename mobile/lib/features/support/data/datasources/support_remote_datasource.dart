/// Support Remote DataSource - Real API implementation
library;

import 'dart:developer' as developer;
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../models/support_model.dart';

/// Abstract interface for support data source
abstract class SupportRemoteDataSource {
  // ═══════════════════════════════════════════════════════════════════════════
  // TICKET CATEGORIES
  // ═══════════════════════════════════════════════════════════════════════════

  /// جلب فئات التذاكر (Public)
  Future<List<TicketCategoryModel>> getCategories();

  // ═══════════════════════════════════════════════════════════════════════════
  // MY TICKETS
  // ═══════════════════════════════════════════════════════════════════════════

  /// جلب تذاكري
  Future<List<TicketModel>> getMyTickets({
    TicketStatus? status,
    int page = 1,
    int limit = 10,
  });

  /// جلب تفاصيل تذكرتي
  Future<TicketModel> getMyTicketById(String ticketId);

  /// إنشاء تذكرة جديدة
  Future<TicketModel> createTicket(CreateTicketRequest request);

  /// إضافة رسالة لتذكرتي
  Future<TicketMessageModel> addMessageToTicket({
    required String ticketId,
    required String content,
    List<String>? attachments,
  });

  /// تقييم التذكرة
  Future<void> rateTicket({
    required String ticketId,
    required int rating,
    String? feedback,
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // LIVE CHAT
  // ═══════════════════════════════════════════════════════════════════════════

  /// بدء محادثة جديدة
  Future<ChatSessionModel> startChat({
    String? initialMessage,
    String? department,
    String? categoryId,
  });

  /// جلب جلستي النشطة
  Future<ChatSessionModel?> getMySession();

  /// إرسال رسالة في المحادثة
  Future<ChatMessageModel> sendChatMessage({
    required String content,
    ChatMessageType messageType = ChatMessageType.text,
  });

  /// إنهاء المحادثة
  Future<void> endChat({int? rating, String? feedback});

  // ═══════════════════════════════════════════════════════════════════════════
  // ATTACHMENTS
  // ═══════════════════════════════════════════════════════════════════════════

  /// رفع المرفقات
  Future<List<String>> uploadAttachments(List<String> filePaths);
}

/// Implementation of SupportRemoteDataSource using API client
class SupportRemoteDataSourceImpl implements SupportRemoteDataSource {
  final ApiClient _apiClient;

  SupportRemoteDataSourceImpl({required ApiClient apiClient})
      : _apiClient = apiClient;

  // ═══════════════════════════════════════════════════════════════════════════
  // TICKET CATEGORIES
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  Future<List<TicketCategoryModel>> getCategories() async {
    developer.log('Fetching ticket categories', name: 'SupportDataSource');

    final response = await _apiClient.get(ApiEndpoints.ticketCategories);

    final data = response.data['data'] ?? response.data;
    final List<dynamic> list = data is List ? data : [];

    return list.map((json) => TicketCategoryModel.fromJson(json)).toList();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // MY TICKETS
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  Future<List<TicketModel>> getMyTickets({
    TicketStatus? status,
    int page = 1,
    int limit = 10,
  }) async {
    developer.log('Fetching my tickets (page: $page)', name: 'SupportDataSource');

    final response = await _apiClient.get(
      ApiEndpoints.myTickets,
      queryParameters: {
        'page': page,
        'limit': limit,
        if (status != null) 'status': status.apiValue,
      },
    );

    final data = response.data['data'] ?? response.data;
    final List<dynamic> list = data is List ? data : [];

    return list.map((json) => TicketModel.fromJson(json)).toList();
  }

  @override
  Future<TicketModel> getMyTicketById(String ticketId) async {
    developer.log('Fetching my ticket: $ticketId', name: 'SupportDataSource');

    final response = await _apiClient.get('${ApiEndpoints.myTickets}/$ticketId');
    final data = response.data['data'] ?? response.data;

    return TicketModel.fromJson(data);
  }

  @override
  Future<TicketModel> createTicket(CreateTicketRequest request) async {
    developer.log('Creating ticket', name: 'SupportDataSource');

    final response = await _apiClient.post(
      ApiEndpoints.tickets,
      data: request.toJson(),
    );

    final data = response.data['data'] ?? response.data;
    return TicketModel.fromJson(data);
  }

  @override
  Future<TicketMessageModel> addMessageToTicket({
    required String ticketId,
    required String content,
    List<String>? attachments,
  }) async {
    developer.log(
      'Adding message to ticket: $ticketId',
      name: 'SupportDataSource',
    );

    final response = await _apiClient.post(
      '${ApiEndpoints.myTickets}/$ticketId/messages',
      data: {
        'content': content,
        if (attachments != null) 'attachments': attachments,
      },
    );

    final data = response.data['data'] ?? response.data;
    return TicketMessageModel.fromJson(data);
  }

  @override
  Future<void> rateTicket({
    required String ticketId,
    required int rating,
    String? feedback,
  }) async {
    developer.log('Rating ticket: $ticketId', name: 'SupportDataSource');

    final response = await _apiClient.post(
      '${ApiEndpoints.myTickets}/$ticketId/rate',
      data: {
        'rating': rating,
        if (feedback != null) 'feedback': feedback,
      },
    );

    if (response.data['success'] != true) {
      throw Exception(response.data['messageAr'] ?? 'Failed to rate ticket');
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // LIVE CHAT
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  Future<ChatSessionModel> startChat({
    String? initialMessage,
    String? department,
    String? categoryId,
  }) async {
    developer.log('Starting chat session', name: 'SupportDataSource');

    final response = await _apiClient.post(
      ApiEndpoints.chatStart,
      data: {
        if (initialMessage != null) 'initialMessage': initialMessage,
        if (department != null) 'department': department,
        if (categoryId != null) 'categoryId': categoryId,
      },
    );

    final data = response.data['data'] ?? response.data;
    return ChatSessionModel.fromJson(data);
  }

  @override
  Future<ChatSessionModel?> getMySession() async {
    developer.log('Fetching my chat session', name: 'SupportDataSource');

    final response = await _apiClient.get(ApiEndpoints.chatMySession);

    if (response.data['success'] == true) {
      if (response.data['data'] == null) return null;
      return ChatSessionModel.fromJson(response.data['data']);
    }
    return null;
  }

  @override
  Future<ChatMessageModel> sendChatMessage({
    required String content,
    ChatMessageType messageType = ChatMessageType.text,
  }) async {
    developer.log('Sending chat message', name: 'SupportDataSource');

    final response = await _apiClient.post(
      '${ApiEndpoints.chatMySession}/messages',
      data: {
        'content': content,
        'messageType': messageType.apiValue,
      },
    );

    final data = response.data['data'] ?? response.data;
    return ChatMessageModel.fromJson(data);
  }

  @override
  Future<void> endChat({int? rating, String? feedback}) async {
    developer.log('Ending chat session', name: 'SupportDataSource');

    final response = await _apiClient.post(
      '${ApiEndpoints.chatMySession}/end',
      data: {
        if (rating != null) 'rating': rating,
        if (feedback != null) 'feedback': feedback,
      },
    );

    if (response.data['success'] != true) {
      throw Exception(response.data['messageAr'] ?? 'Failed to end chat');
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ATTACHMENTS
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  Future<List<String>> uploadAttachments(List<String> filePaths) async {
    developer.log('Uploading attachments', name: 'SupportDataSource');

    final uploadedUrls = <String>[];
    for (final path in filePaths) {
      final response = await _apiClient.uploadFile(
        '${ApiEndpoints.tickets}/upload',
        filePath: path,
        fieldName: 'file',
      );

      final url = response.data['data']?['url'] ?? response.data['url'];
      if (url != null) uploadedUrls.add(url);
    }

    return uploadedUrls;
  }
}
