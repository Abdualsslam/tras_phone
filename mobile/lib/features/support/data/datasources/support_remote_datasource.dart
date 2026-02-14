/// Support Remote DataSource - Real API implementation
library;

import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../models/support_model.dart';
import '../helpers/file_upload_helper.dart';

/// Abstract interface for support data source
abstract class SupportRemoteDataSource {
  // ═══════════════════════════════════════════════════════════════════════════
  // TICKET CATEGORIES
  // ═══════════════════════════════════════════════════════════════════════════

  /// جلب فئات التذاكر (Public)
  /// [activeOnly] جلب الفئات النشطة فقط (default: true حسب التوثيق)
  Future<List<TicketCategoryModel>> getCategories({bool activeOnly = true});

  // ═══════════════════════════════════════════════════════════════════════════
  // MY TICKETS
  // ═══════════════════════════════════════════════════════════════════════════

  /// جلب تذاكري (جميع تذاكر العميل - لا query params حسب التوثيق)
  Future<List<TicketModel>> getMyTickets();

  /// جلب تفاصيل تذكرتي مع الرسائل
  Future<Map<String, dynamic>> getMyTicketById(String ticketId);

  /// إنشاء تذكرة جديدة
  Future<TicketModel> createTicket(CreateTicketRequest request);

  /// إضافة رسالة لتذكرتي
  Future<TicketMessageModel> addMessageToTicket({
    required String ticketId,
    required String content,
    List<String>? attachments,
  });

  /// تقييم التذكرة - يرجع التذكرة المحدثة
  Future<TicketModel> rateTicket({
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
  Future<List<TicketCategoryModel>> getCategories(
      {bool activeOnly = true}) async {
    developer.log('Fetching ticket categories', name: 'SupportDataSource');

    final response = await _apiClient.get(
      ApiEndpoints.ticketCategories,
      queryParameters: {'activeOnly': activeOnly.toString()},
    );

    final payload = _unwrapSupportResponse(response.data);

    if (payload['success'] != true) {
      throw Exception(
        payload['messageAr'] ??
            payload['message'] ??
            response.data['messageAr'] ??
            response.data['message'] ??
            'Failed to load categories',
      );
    }

    final data = payload['data'];
    final List<dynamic> list = data is List ? data : const [];

    return list.map((json) => TicketCategoryModel.fromJson(json)).toList();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // MY TICKETS
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  Future<List<TicketModel>> getMyTickets() async {
    developer.log('Fetching my tickets', name: 'SupportDataSource');

    final response = await _apiClient.get(ApiEndpoints.myTickets);
    final payload = _unwrapSupportResponse(response.data);

    if (payload['success'] != true) {
      throw Exception(
        payload['messageAr'] ??
            payload['message'] ??
            response.data['messageAr'] ??
            response.data['message'] ??
            'Failed to load tickets',
      );
    }

    final data = payload['data'];
    final List<dynamic> list = data is List ? data : const [];

    return list.map((json) => TicketModel.fromJson(json)).toList();
  }

  @override
  Future<Map<String, dynamic>> getMyTicketById(String ticketId) async {
    developer.log('Fetching my ticket: $ticketId', name: 'SupportDataSource');

    final response = await _apiClient.get(ApiEndpoints.ticketDetails(ticketId));
    final payload = _unwrapSupportResponse(response.data);

    if (payload['success'] != true) {
      throw Exception(
        payload['messageAr'] ??
            payload['message'] ??
            response.data['messageAr'] ??
            response.data['message'] ??
            'Failed to load ticket',
      );
    }

    final data = payload['data'] ?? response.data['data'] ?? response.data;
    final ticketData = data is Map ? data['ticket'] ?? data : null;
    final messagesJson = data is Map ? data['messages'] as List<dynamic>? : null;

    if (ticketData is! Map) {
      throw Exception(
        payload['messageAr'] ??
            payload['message'] ??
            'Invalid ticket response',
      );
    }

    final ticket =
        TicketModel.fromJson(Map<String, dynamic>.from(ticketData));
    final messages = messagesJson != null
        ? messagesJson
            .whereType<Map>()
            .map((m) =>
                TicketMessageModel.fromJson(Map<String, dynamic>.from(m)))
            .toList()
        : <TicketMessageModel>[];

    return {
      'ticket': ticket,
      'messages': messages,
    };
  }

  @override
  Future<TicketModel> createTicket(CreateTicketRequest request) async {
    developer.log('Creating ticket', name: 'SupportDataSource');

    final body = request.toJson();
    body['source'] = request.source ?? 'mobile_app';

    if (request.customerName != null && request.customerEmail != null) {
      body['customer'] = {
        'name': request.customerName,
        'email': request.customerEmail,
      };
    }

    final response = await _apiClient.post(
      ApiEndpoints.tickets,
      data: body,
    );

    final payload = _unwrapSupportResponse(response.data);

    if (payload['success'] != true) {
      throw Exception(
        payload['messageAr'] ??
            payload['message'] ??
            response.data['messageAr'] ??
            response.data['message'] ??
            'Failed to create ticket',
      );
    }

    final data = payload['data'];
    if (data is! Map) {
      throw Exception(
        payload['messageAr'] ??
            payload['message'] ??
            'Invalid ticket response',
      );
    }
    return TicketModel.fromJson(Map<String, dynamic>.from(data));
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
      ApiEndpoints.ticketMessages(ticketId),
      data: {
        'content': content,
        if (attachments != null) 'attachments': attachments,
      },
    );

    if (response.data['success'] != true) {
      throw Exception(
        response.data['messageAr'] ??
            response.data['message'] ??
            'Failed to send message',
      );
    }

    final data = response.data['data'] ?? response.data;
    return TicketMessageModel.fromJson(data);
  }

  @override
  Future<TicketModel> rateTicket({
    required String ticketId,
    required int rating,
    String? feedback,
  }) async {
    developer.log('Rating ticket: $ticketId', name: 'SupportDataSource');

    final response = await _apiClient.post(
      ApiEndpoints.ticketRate(ticketId),
      data: {
        'rating': rating,
        if (feedback != null) 'feedback': feedback,
      },
    );

    if (response.data['success'] != true) {
      throw Exception(
        response.data['messageAr'] ??
            response.data['message'] ??
            'Failed to rate ticket',
      );
    }

    final data = response.data['data'] ?? response.data;
    return TicketModel.fromJson(data);
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

    if (response.data['success'] != true) {
      throw Exception(
        response.data['messageAr'] ??
            response.data['message'] ??
            'Failed to start chat',
      );
    }

    final data = response.data['data'] ?? response.data;
    return ChatSessionModel.fromJson(data);
  }

  @override
  Future<ChatSessionModel?> getMySession() async {
    developer.log('Fetching my chat session', name: 'SupportDataSource');

    final response = await _apiClient.get(ApiEndpoints.chatMySession);

    if (response.data['success'] != true) {
      throw Exception(
        response.data['messageAr'] ??
            response.data['message'] ??
            'Failed to load session',
      );
    }
    if (response.data['data'] == null) return null;
    return ChatSessionModel.fromJson(response.data['data']);
  }

  @override
  Future<ChatMessageModel> sendChatMessage({
    required String content,
    ChatMessageType messageType = ChatMessageType.text,
  }) async {
    developer.log('Sending chat message', name: 'SupportDataSource');

    final response = await _apiClient.post(
      ApiEndpoints.chatMessages,
      data: {
        'content': content,
        'messageType': messageType.apiValue,
      },
    );

    if (response.data['success'] != true) {
      throw Exception(
        response.data['messageAr'] ??
            response.data['message'] ??
            'Failed to send message',
      );
    }

    final data = response.data['data'] ?? response.data;
    return ChatMessageModel.fromJson(data);
  }

  @override
  Future<void> endChat({int? rating, String? feedback}) async {
    developer.log('Ending chat session', name: 'SupportDataSource');

    final response = await _apiClient.post(
      ApiEndpoints.chatEnd,
      data: {
        if (rating != null) 'rating': rating,
        if (feedback != null) 'feedback': feedback,
      },
    );

    if (response.data['success'] != true) {
      throw Exception(
        response.data['messageAr'] ??
            response.data['message'] ??
            'Failed to end chat',
      );
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ATTACHMENTS
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  Future<List<String>> uploadAttachments(List<String> filePaths) async {
    developer.log('Uploading attachments', name: 'SupportDataSource');

    // Import helper
    final helper = await _convertFilesToBase64(filePaths);

    final response = await _apiClient.post(
      ApiEndpoints.ticketUpload,
      data: {
        'files': helper.map((f) => f.toJson()).toList(),
      },
    );

    final data = response.data['data'] ?? response.data;
    final urls = data['urls'] as List<dynamic>?;

    if (urls != null) {
      return urls.map((url) => url.toString()).toList();
    }

    throw Exception(
      response.data['messageAr'] ??
          response.data['message'] ??
          'Failed to upload files',
    );
  }

  /// Convert file paths to base64 format
  Future<List<FileUploadData>> _convertFilesToBase64(
    List<String> filePaths,
  ) async {
    final results = <FileUploadData>[];
    for (final path in filePaths) {
      final file = File(path);
      if (!await file.exists()) {
        throw Exception('File does not exist: $path');
      }

      final bytes = await file.readAsBytes();
      final base64String = base64Encode(bytes);
      final extension = path.split('.').last;
      final mimeType = _getMimeTypeFromExtension(extension);
      final filename = path.split('/').last;

      results.add(FileUploadData(
        base64: base64String,
        filename: filename,
        mimeType: mimeType,
      ));
    }
    return results;
  }

  /// Unwrap nested API response: { status, data: { success, data: [...] } }
  Map<String, dynamic> _unwrapSupportResponse(dynamic raw) {
    if (raw is! Map<String, dynamic>) return {};
    final inner = raw['data'];
    if (inner is Map<String, dynamic> && inner.containsKey('success')) {
      return inner;
    }
    return raw;
  }

  /// Get MIME type from file extension
  String _getMimeTypeFromExtension(String extension) {
    final ext = extension.toLowerCase();
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'pdf':
        return 'application/pdf';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'txt':
        return 'text/plain';
      default:
        return 'application/octet-stream';
    }
  }
}
