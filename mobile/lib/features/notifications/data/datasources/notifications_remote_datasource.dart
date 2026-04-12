/// Notifications Remote DataSource - Real API implementation
library;

import 'dart:developer' as developer;

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/enums/notification_enums.dart';
import '../models/notification_model.dart';
import '../models/push_token_model.dart';

part 'notifications_remote_datasource_support.dart';
part 'notifications_remote_datasource_notifications.dart';
part 'notifications_remote_datasource_settings.dart';

abstract class NotificationsRemoteDataSource {
  Future<NotificationsResponse> getMyNotifications({
    int page = 1,
    int limit = 20,
    NotificationCategory? category,
    bool? isRead,
  });

  Future<NotificationModel> getNotificationById(String id);

  Future<bool> markAsRead(String id);

  Future<bool> markAllAsRead();

  Future<bool> deleteNotification(String id);

  Future<bool> deleteAllNotifications();

  Future<int> getUnreadCount();

  Future<NotificationSettingsModel> getSettings();

  Future<NotificationSettingsModel> updateSettings(
    NotificationSettingsModel settings,
  );

  Future<PushTokenModel> registerPushToken(PushTokenRequest request);

  Future<bool> unregisterPushToken(String token);
}

class NotificationsRemoteDataSourceImpl
    implements NotificationsRemoteDataSource {
  final ApiClient _apiClient;
  late final _NotificationsRemoteSupport _support = _NotificationsRemoteSupport(
    apiClient: _apiClient,
  );
  late final _NotificationsCrudDelegate _notifications =
      _NotificationsCrudDelegate(support: _support);
  late final _NotificationsSettingsDelegate _settings =
      _NotificationsSettingsDelegate(support: _support);

  NotificationsRemoteDataSourceImpl({required ApiClient apiClient})
    : _apiClient = apiClient;

  @override
  Future<NotificationsResponse> getMyNotifications({
    int page = 1,
    int limit = 20,
    NotificationCategory? category,
    bool? isRead,
  }) => _notifications.getMyNotifications(
    page: page,
    limit: limit,
    category: category,
    isRead: isRead,
  );

  @override
  Future<NotificationModel> getNotificationById(String id) =>
      _notifications.getNotificationById(id);

  @override
  Future<bool> markAsRead(String id) => _notifications.markAsRead(id);

  @override
  Future<bool> markAllAsRead() => _notifications.markAllAsRead();

  @override
  Future<bool> deleteNotification(String id) =>
      _notifications.deleteNotification(id);

  @override
  Future<bool> deleteAllNotifications() =>
      _notifications.deleteAllNotifications();

  @override
  Future<int> getUnreadCount() => _notifications.getUnreadCount();

  @override
  Future<NotificationSettingsModel> getSettings() => _settings.getSettings();

  @override
  Future<NotificationSettingsModel> updateSettings(
    NotificationSettingsModel settings,
  ) => _settings.updateSettings(settings);

  @override
  Future<PushTokenModel> registerPushToken(PushTokenRequest request) =>
      _settings.registerPushToken(request);

  @override
  Future<bool> unregisterPushToken(String token) =>
      _settings.unregisterPushToken(token);
}
