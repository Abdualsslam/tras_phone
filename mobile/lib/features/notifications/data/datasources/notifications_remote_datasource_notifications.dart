part of 'notifications_remote_datasource.dart';

class _NotificationsCrudDelegate {
  final _NotificationsRemoteSupport _support;

  const _NotificationsCrudDelegate({
    required _NotificationsRemoteSupport support,
  }) : _support = support;

  Future<NotificationsResponse> getMyNotifications({
    int page = 1,
    int limit = 20,
    NotificationCategory? category,
    bool? isRead,
  }) async {
    _support.log('Fetching notifications (page: $page)');

    final response = await _support.apiClient.get(
      ApiEndpoints.notificationsMy,
      queryParameters: {
        'page': page,
        'limit': limit,
        if (category != null) 'category': category.name,
        if (isRead != null) 'isRead': isRead,
      },
    );

    return NotificationsResponse.fromJson(_support.extractMap(response.data));
  }

  Future<NotificationModel> getNotificationById(String id) async {
    _support.log('Fetching notification: $id');
    final response = await _support.apiClient.get(
      '${ApiEndpoints.notifications}/$id',
    );
    return NotificationModel.fromJson(
      _support.extractMap(_support.extractPayload(response.data)),
    );
  }

  Future<bool> markAsRead(String id) async {
    _support.log('Marking as read: $id');
    final response = await _support.apiClient.put(
      '${ApiEndpoints.notifications}/$id/read',
    );
    return response.statusCode == 200;
  }

  Future<bool> markAllAsRead() async {
    _support.log('Marking all as read');
    final response = await _support.apiClient.put(
      ApiEndpoints.notificationsReadAll,
    );
    return response.statusCode == 200;
  }

  Future<bool> deleteNotification(String id) async {
    _support.log('Deleting notification: $id');
    final response = await _support.apiClient.delete(
      '${ApiEndpoints.notifications}/$id',
    );
    return response.statusCode == 200 || response.statusCode == 204;
  }

  Future<bool> deleteAllNotifications() async {
    _support.log('Deleting all notifications');
    final response = await _support.apiClient.delete(
      ApiEndpoints.notifications,
    );
    return response.statusCode == 200 || response.statusCode == 204;
  }

  Future<int> getUnreadCount() async {
    _support.log('Getting unread count');

    try {
      try {
        final response = await _support.apiClient.get(
          ApiEndpoints.notificationsUnreadCount,
        );
        final data = _support.extractMap(
          _support.extractPayload(response.data),
        );
        return (data['count'] ?? data['unreadCount'] ?? 0) as int;
      } catch (_) {
        _support.log(
          'Unread count endpoint not available, using notifications list meta',
        );
        final response = await getMyNotifications(page: 1, limit: 1);
        return response.unreadCount;
      }
    } catch (error) {
      _support.log('Failed to get unread count: $error');
      return 0;
    }
  }
}
