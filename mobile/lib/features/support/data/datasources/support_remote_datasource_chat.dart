part of 'support_remote_datasource.dart';

class _SupportRemoteChatDelegate {
  final _SupportRemoteSupport _support;

  const _SupportRemoteChatDelegate({required _SupportRemoteSupport support})
    : _support = support;

  Future<ChatSessionModel> startChat({
    String? initialMessage,
    String? department,
    String? categoryId,
  }) async {
    _support.log('Starting chat session');

    final response = await _support.apiClient.post(
      ApiEndpoints.chatStart,
      data: {
        if (initialMessage != null) 'initialMessage': initialMessage,
        if (department != null) 'department': department,
        if (categoryId != null) 'categoryId': categoryId,
      },
    );

    final payload = _support.requireSuccess(
      response.data,
      fallbackMessage: 'Failed to start chat',
    );
    return ChatSessionModel.fromJson(
      _support.extractMap(payload['data'] ?? response.data),
    );
  }

  Future<ChatSessionModel?> getMySession() async {
    _support.log('Fetching my chat session');

    final response = await _support.apiClient.get(ApiEndpoints.chatMySession);
    final payload = _support.requireSuccess(
      response.data,
      fallbackMessage: 'Failed to load session',
    );
    if (payload['data'] == null) return null;
    return ChatSessionModel.fromJson(_support.extractMap(payload['data']));
  }

  Future<ChatMessageModel> sendChatMessage({
    required String content,
    ChatMessageType messageType = ChatMessageType.text,
  }) async {
    _support.log('Sending chat message');

    final response = await _support.apiClient.post(
      ApiEndpoints.chatMessages,
      data: {'content': content, 'messageType': messageType.apiValue},
    );

    final payload = _support.requireSuccess(
      response.data,
      fallbackMessage: 'Failed to send message',
    );
    return ChatMessageModel.fromJson(
      _support.extractMap(payload['data'] ?? response.data),
    );
  }

  Future<void> endChat({int? rating, String? feedback}) async {
    _support.log('Ending chat session');

    final response = await _support.apiClient.post(
      ApiEndpoints.chatEnd,
      data: {
        if (rating != null) 'rating': rating,
        if (feedback != null) 'feedback': feedback,
      },
    );

    _support.requireSuccess(
      response.data,
      fallbackMessage: 'Failed to end chat',
    );
  }
}
