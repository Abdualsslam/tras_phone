/// Support Remote DataSource - Real API implementation
library;

import 'dart:developer' as developer;
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../models/support_model.dart';

/// Abstract interface for support data source
abstract class SupportRemoteDataSource {
  // Tickets
  Future<List<SupportTicketModel>> getTickets({
    TicketStatus? status,
    int page = 1,
    int limit = 20,
  });
  Future<SupportTicketModel> getTicketById(int id);
  Future<SupportTicketModel> createTicket(CreateTicketRequest request);
  Future<bool> closeTicket(int id);
  Future<bool> reopenTicket(int id);

  // Messages
  Future<List<TicketMessageModel>> getTicketMessages(int ticketId);
  Future<TicketMessageModel> sendMessage(
    int ticketId,
    String message, {
    List<String>? attachments,
  });

  // Categories
  Future<List<SupportCategoryModel>> getCategories();

  // FAQs
  Future<List<Map<String, dynamic>>> getFaqs({int? categoryId});
  Future<Map<String, dynamic>> searchFaqs(String query);

  // Attachments
  Future<List<String>> uploadAttachments(List<String> filePaths);

  // Contact
  Future<Map<String, dynamic>> getContactInfo();
}

/// Implementation of SupportRemoteDataSource using API client
class SupportRemoteDataSourceImpl implements SupportRemoteDataSource {
  final ApiClient _apiClient;

  SupportRemoteDataSourceImpl({required ApiClient apiClient})
    : _apiClient = apiClient;

  // ═══════════════════════════════════════════════════════════════════════════
  // TICKETS
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  Future<List<SupportTicketModel>> getTickets({
    TicketStatus? status,
    int page = 1,
    int limit = 20,
  }) async {
    developer.log('Fetching tickets (page: $page)', name: 'SupportDataSource');

    final response = await _apiClient.get(
      ApiEndpoints.tickets,
      queryParameters: {
        'page': page,
        'limit': limit,
        if (status != null) 'status': status.name,
      },
    );

    final data = response.data['data'] ?? response.data;
    final List<dynamic> list = data is List ? data : [];

    return list.map((json) => SupportTicketModel.fromJson(json)).toList();
  }

  @override
  Future<SupportTicketModel> getTicketById(int id) async {
    developer.log('Fetching ticket: $id', name: 'SupportDataSource');

    final response = await _apiClient.get('${ApiEndpoints.tickets}/$id');
    final data = response.data['data'] ?? response.data;

    return SupportTicketModel.fromJson(data);
  }

  @override
  Future<SupportTicketModel> createTicket(CreateTicketRequest request) async {
    developer.log('Creating ticket', name: 'SupportDataSource');

    final response = await _apiClient.post(
      ApiEndpoints.tickets,
      data: request.toJson(),
    );

    final data = response.data['data'] ?? response.data;
    return SupportTicketModel.fromJson(data);
  }

  @override
  Future<bool> closeTicket(int id) async {
    developer.log('Closing ticket: $id', name: 'SupportDataSource');

    final response = await _apiClient.post('${ApiEndpoints.tickets}/$id/close');

    return response.statusCode == 200;
  }

  @override
  Future<bool> reopenTicket(int id) async {
    developer.log('Reopening ticket: $id', name: 'SupportDataSource');

    final response = await _apiClient.post(
      '${ApiEndpoints.tickets}/$id/reopen',
    );

    return response.statusCode == 200;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // MESSAGES
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  Future<List<TicketMessageModel>> getTicketMessages(int ticketId) async {
    developer.log(
      'Fetching messages for ticket: $ticketId',
      name: 'SupportDataSource',
    );

    final response = await _apiClient.get(
      '${ApiEndpoints.tickets}/$ticketId/messages',
    );

    final data = response.data['data'] ?? response.data;
    final List<dynamic> list = data is List ? data : [];

    return list.map((json) => TicketMessageModel.fromJson(json)).toList();
  }

  @override
  Future<TicketMessageModel> sendMessage(
    int ticketId,
    String message, {
    List<String>? attachments,
  }) async {
    developer.log(
      'Sending message to ticket: $ticketId',
      name: 'SupportDataSource',
    );

    final response = await _apiClient.post(
      '${ApiEndpoints.tickets}/$ticketId/messages',
      data: {
        'message': message,
        if (attachments != null) 'attachments': attachments,
      },
    );

    final data = response.data['data'] ?? response.data;
    return TicketMessageModel.fromJson(data);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CATEGORIES & FAQs
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  Future<List<SupportCategoryModel>> getCategories() async {
    developer.log('Fetching support categories', name: 'SupportDataSource');

    final response = await _apiClient.get(ApiEndpoints.supportCategories);
    final data = response.data['data'] ?? response.data;
    final List<dynamic> list = data is List ? data : [];

    return list.map((json) => SupportCategoryModel.fromJson(json)).toList();
  }

  @override
  Future<List<Map<String, dynamic>>> getFaqs({int? categoryId}) async {
    developer.log('Fetching FAQs', name: 'SupportDataSource');

    final response = await _apiClient.get(
      ApiEndpoints.faqs,
      queryParameters: {if (categoryId != null) 'category_id': categoryId},
    );

    final data = response.data['data'] ?? response.data;
    if (data is List) {
      return data.cast<Map<String, dynamic>>();
    }
    return [];
  }

  @override
  Future<Map<String, dynamic>> searchFaqs(String query) async {
    developer.log('Searching FAQs: $query', name: 'SupportDataSource');

    final response = await _apiClient.get(
      '${ApiEndpoints.faqs}/search',
      queryParameters: {'q': query},
    );

    return response.data['data'] ?? response.data;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ATTACHMENTS & CONTACT
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

  @override
  Future<Map<String, dynamic>> getContactInfo() async {
    developer.log('Fetching contact info', name: 'SupportDataSource');

    final response = await _apiClient.get(
      '${ApiEndpoints.supportCategories}/contact',
    );
    return response.data['data'] ?? response.data;
  }
}
