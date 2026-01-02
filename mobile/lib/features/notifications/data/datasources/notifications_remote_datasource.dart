/// Notifications Remote DataSource - Real API implementation
library;

import 'dart:developer' as developer;
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../models/notification_model.dart';

/// Abstract interface for notifications data source
abstract class NotificationsRemoteDataSource {
  /// Get all notifications with pagination
  Future<List<NotificationModel>> getNotifications({
    int page = 1,
    int limit = 20,
    String? type,
    bool? unreadOnly,
  });

  /// Get notification by ID
  Future<NotificationModel> getNotificationById(int id);

  /// Mark notification as read
  Future<bool> markAsRead(int id);

  /// Mark all notifications as read
  Future<bool> markAllAsRead();

  /// Delete notification
  Future<bool> deleteNotification(int id);

  /// Delete all notifications
  Future<bool> deleteAllNotifications();

  /// Get unread count
  Future<int> getUnreadCount();

  /// Get notification settings
  Future<NotificationSettingsModel> getSettings();

  /// Update notification settings
  Future<NotificationSettingsModel> updateSettings(
    NotificationSettingsModel settings,
  );

  /// Register FCM token
  Future<bool> registerFcmToken(String token);

  /// Unregister FCM token
  Future<bool> unregisterFcmToken(String token);
}

/// Implementation of NotificationsRemoteDataSource using API client
class NotificationsRemoteDataSourceImpl
    implements NotificationsRemoteDataSource {
  final ApiClient _apiClient;

  NotificationsRemoteDataSourceImpl({required ApiClient apiClient})
    : _apiClient = apiClient;

  @override
  Future<List<NotificationModel>> getNotifications({
    int page = 1,
    int limit = 20,
    String? type,
    bool? unreadOnly,
  }) async {
    developer.log(
      'Fetching notifications (page: $page)',
      name: 'NotificationsDataSource',
    );

    final response = await _apiClient.get(
      ApiEndpoints.notifications,
      queryParameters: {
        'page': page,
        'limit': limit,
        if (type != null) 'type': type,
        if (unreadOnly != null) 'unread_only': unreadOnly,
      },
    );

    final data = response.data['data'] ?? response.data;
    final List<dynamic> list = data is List ? data : [];

    return list.map((json) => NotificationModel.fromJson(json)).toList();
  }

  @override
  Future<NotificationModel> getNotificationById(int id) async {
    developer.log(
      'Fetching notification: $id',
      name: 'NotificationsDataSource',
    );

    final response = await _apiClient.get('${ApiEndpoints.notifications}/$id');
    final data = response.data['data'] ?? response.data;

    return NotificationModel.fromJson(data);
  }

  @override
  Future<bool> markAsRead(int id) async {
    developer.log('Marking as read: $id', name: 'NotificationsDataSource');

    final response = await _apiClient.post(
      '${ApiEndpoints.notifications}/$id/read',
    );

    return response.statusCode == 200;
  }

  @override
  Future<bool> markAllAsRead() async {
    developer.log('Marking all as read', name: 'NotificationsDataSource');

    final response = await _apiClient.post(
      '${ApiEndpoints.notifications}/read-all',
    );

    return response.statusCode == 200;
  }

  @override
  Future<bool> deleteNotification(int id) async {
    developer.log(
      'Deleting notification: $id',
      name: 'NotificationsDataSource',
    );

    final response = await _apiClient.delete(
      '${ApiEndpoints.notifications}/$id',
    );

    return response.statusCode == 200;
  }

  @override
  Future<bool> deleteAllNotifications() async {
    developer.log(
      'Deleting all notifications',
      name: 'NotificationsDataSource',
    );

    final response = await _apiClient.delete(ApiEndpoints.notifications);
    return response.statusCode == 200;
  }

  @override
  Future<int> getUnreadCount() async {
    developer.log('Getting unread count', name: 'NotificationsDataSource');

    final response = await _apiClient.get(
      ApiEndpoints.notificationsUnreadCount,
    );
    final data = response.data['data'] ?? response.data;

    return data['count'] ?? 0;
  }

  @override
  Future<NotificationSettingsModel> getSettings() async {
    developer.log(
      'Fetching notification settings',
      name: 'NotificationsDataSource',
    );

    final response = await _apiClient.get(
      '${ApiEndpoints.notifications}/settings',
    );
    final data = response.data['data'] ?? response.data;

    return NotificationSettingsModel.fromJson(data);
  }

  @override
  Future<NotificationSettingsModel> updateSettings(
    NotificationSettingsModel settings,
  ) async {
    developer.log(
      'Updating notification settings',
      name: 'NotificationsDataSource',
    );

    final response = await _apiClient.put(
      '${ApiEndpoints.notifications}/settings',
      data: settings.toJson(),
    );

    final data = response.data['data'] ?? response.data;
    return NotificationSettingsModel.fromJson(data);
  }

  @override
  Future<bool> registerFcmToken(String token) async {
    developer.log('Registering FCM token', name: 'NotificationsDataSource');

    final response = await _apiClient.post(
      ApiEndpoints.fcmToken,
      data: {'token': token},
    );

    return response.statusCode == 200;
  }

  @override
  Future<bool> unregisterFcmToken(String token) async {
    developer.log('Unregistering FCM token', name: 'NotificationsDataSource');

    final response = await _apiClient.delete(
      ApiEndpoints.fcmToken,
      data: {'token': token},
    );

    return response.statusCode == 200;
  }
}
