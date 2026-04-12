part of 'notifications_remote_datasource.dart';

class _NotificationsSettingsDelegate {
  final _NotificationsRemoteSupport _support;

  const _NotificationsSettingsDelegate({
    required _NotificationsRemoteSupport support,
  }) : _support = support;

  Future<NotificationSettingsModel> getSettings() async {
    _support.log('Fetching notification settings');
    final response = await _support.apiClient.get(
      '${ApiEndpoints.notifications}/settings',
    );
    return NotificationSettingsModel.fromJson(
      _support.extractMap(_support.extractPayload(response.data)),
    );
  }

  Future<NotificationSettingsModel> updateSettings(
    NotificationSettingsModel settings,
  ) async {
    _support.log('Updating notification settings');
    final response = await _support.apiClient.put(
      '${ApiEndpoints.notifications}/settings',
      data: settings.toJson(),
    );
    return NotificationSettingsModel.fromJson(
      _support.extractMap(_support.extractPayload(response.data)),
    );
  }

  Future<PushTokenModel> registerPushToken(PushTokenRequest request) async {
    _support.log('Registering push token');
    final response = await _support.apiClient.post(
      ApiEndpoints.notificationsToken,
      data: request.toJson(),
    );
    return PushTokenModel.fromJson(
      _support.extractMap(_support.extractPayload(response.data)),
    );
  }

  Future<bool> unregisterPushToken(String token) async {
    _support.log('Unregistering push token');
    final response = await _support.apiClient.delete(
      ApiEndpoints.notificationsToken,
      data: {'token': token},
    );
    return response.statusCode == 200 || response.statusCode == 204;
  }
}
