/// Support Remote DataSource - Real API implementation
library;

import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../helpers/file_upload_helper.dart';
import '../models/support_model.dart';

part 'support_remote_datasource_support.dart';
part 'support_remote_datasource_tickets.dart';
part 'support_remote_datasource_chat.dart';
part 'support_remote_datasource_uploads.dart';

abstract class SupportRemoteDataSource {
  Future<List<TicketCategoryModel>> getCategories({bool activeOnly = true});

  Future<List<TicketModel>> getMyTickets();

  Future<Map<String, dynamic>> getMyTicketById(String ticketId);

  Future<TicketModel> createTicket(CreateTicketRequest request);

  Future<TicketMessageModel> addMessageToTicket({
    required String ticketId,
    required String content,
    List<String>? attachments,
  });

  Future<TicketModel> rateTicket({
    required String ticketId,
    required int rating,
    String? feedback,
  });

  Future<ChatSessionModel> startChat({
    String? initialMessage,
    String? department,
    String? categoryId,
  });

  Future<ChatSessionModel?> getMySession();

  Future<ChatMessageModel> sendChatMessage({
    required String content,
    ChatMessageType messageType = ChatMessageType.text,
  });

  Future<void> endChat({int? rating, String? feedback});

  Future<List<String>> uploadAttachments(List<String> filePaths);
}

class SupportRemoteDataSourceImpl implements SupportRemoteDataSource {
  final ApiClient _apiClient;
  late final _SupportRemoteSupport _support = _SupportRemoteSupport(
    apiClient: _apiClient,
  );
  late final _SupportRemoteTicketsDelegate _tickets =
      _SupportRemoteTicketsDelegate(support: _support);
  late final _SupportRemoteChatDelegate _chat = _SupportRemoteChatDelegate(
    support: _support,
  );
  late final _SupportRemoteUploadsDelegate _uploads =
      _SupportRemoteUploadsDelegate(support: _support);

  SupportRemoteDataSourceImpl({required ApiClient apiClient})
    : _apiClient = apiClient;

  @override
  Future<List<TicketCategoryModel>> getCategories({bool activeOnly = true}) =>
      _tickets.getCategories(activeOnly: activeOnly);

  @override
  Future<List<TicketModel>> getMyTickets() => _tickets.getMyTickets();

  @override
  Future<Map<String, dynamic>> getMyTicketById(String ticketId) =>
      _tickets.getMyTicketById(ticketId);

  @override
  Future<TicketModel> createTicket(CreateTicketRequest request) =>
      _tickets.createTicket(request);

  @override
  Future<TicketMessageModel> addMessageToTicket({
    required String ticketId,
    required String content,
    List<String>? attachments,
  }) => _tickets.addMessageToTicket(
    ticketId: ticketId,
    content: content,
    attachments: attachments,
  );

  @override
  Future<TicketModel> rateTicket({
    required String ticketId,
    required int rating,
    String? feedback,
  }) => _tickets.rateTicket(
    ticketId: ticketId,
    rating: rating,
    feedback: feedback,
  );

  @override
  Future<ChatSessionModel> startChat({
    String? initialMessage,
    String? department,
    String? categoryId,
  }) => _chat.startChat(
    initialMessage: initialMessage,
    department: department,
    categoryId: categoryId,
  );

  @override
  Future<ChatSessionModel?> getMySession() => _chat.getMySession();

  @override
  Future<ChatMessageModel> sendChatMessage({
    required String content,
    ChatMessageType messageType = ChatMessageType.text,
  }) => _chat.sendChatMessage(content: content, messageType: messageType);

  @override
  Future<void> endChat({int? rating, String? feedback}) =>
      _chat.endChat(rating: rating, feedback: feedback);

  @override
  Future<List<String>> uploadAttachments(List<String> filePaths) =>
      _uploads.uploadAttachments(filePaths);
}
