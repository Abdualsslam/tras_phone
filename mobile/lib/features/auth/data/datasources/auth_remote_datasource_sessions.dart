part of 'auth_remote_datasource.dart';

class _AuthRemoteSessionsDelegate {
  final _AuthRemoteSupport _support;

  const _AuthRemoteSessionsDelegate({required _AuthRemoteSupport support})
    : _support = support;

  Future<void> updateFcmToken({
    required String fcmToken,
    Map<String, dynamic>? deviceInfo,
  }) async {
    _support.log('Updating FCM token');

    final response = await _support.apiClient.post(
      ApiEndpoints.fcmToken,
      data: {
        'fcmToken': fcmToken,
        if (deviceInfo != null) 'deviceInfo': deviceInfo,
      },
    );

    _support.ensureSuccess(
      _support.extractMap(response.data),
      fallbackMessage: 'فشل تحديث رمز الإشعارات',
    );
  }

  Future<List<SessionModel>> getSessions() async {
    _support.log('Fetching active sessions');

    final response = await _support.apiClient.get(ApiEndpoints.sessions);
    return _support
        .extractList(_support.extractPayload(response.data))
        .map((item) => SessionModel.fromJson(_support.extractMap(item)))
        .toList();
  }

  Future<void> deleteSession(String sessionId) async {
    _support.log('Deleting session: $sessionId');

    final response = await _support.apiClient.delete(
      ApiEndpoints.deleteSession(sessionId),
    );

    _support.ensureSuccess(
      _support.extractMap(response.data),
      fallbackMessage: 'فشل حذف الجلسة',
    );
  }
}
