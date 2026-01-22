/// Notifications Remote DataSource - Real API implementation
library;

import 'dart:developer' as developer;
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../domain/enums/notification_enums.dart';
import '../models/notification_model.dart';
import '../models/push_token_model.dart';

/// Abstract interface for notifications data source
abstract class NotificationsRemoteDataSource {
  /// Get my notifications with pagination
  Future<NotificationsResponse> getMyNotifications({
    int page = 1,
    int limit = 20,
    NotificationCategory? category,
    bool? isRead,
  });

  /// Get notification by ID
  Future<NotificationModel> getNotificationById(String id);

  /// Mark notification as read
  Future<bool> markAsRead(String id);

  /// Mark all notifications as read
  Future<bool> markAllAsRead();

  /// Delete notification
  Future<bool> deleteNotification(String id);

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

  /// Register push token
  Future<PushTokenModel> registerPushToken(PushTokenRequest request);

  /// Unregister push token
  Future<bool> unregisterPushToken(String token);
}

/// Implementation of NotificationsRemoteDataSource using API client
class NotificationsRemoteDataSourceImpl
    implements NotificationsRemoteDataSource {
  final ApiClient _apiClient;

  NotificationsRemoteDataSourceImpl({required ApiClient apiClient})
    : _apiClient = apiClient;

  @override
  Future<NotificationsResponse> getMyNotifications({
    int page = 1,
    int limit = 20,
    NotificationCategory? category,
    bool? isRead,
  }) async {
    developer.log(
      'Fetching notifications (page: $page)',
      name: 'NotificationsDataSource',
    );

    final response = await _apiClient.get(
      ApiEndpoints.notificationsMy,
      queryParameters: {
        'page': page,
        'limit': limit,
        if (category != null) 'category': category.name,
        if (isRead != null) 'isRead': isRead,
      },
    );

    return NotificationsResponse.fromJson(response.data);
  }

  @override
  Future<NotificationModel> getNotificationById(String id) async {
    developer.log(
      'Fetching notification: $id',
      name: 'NotificationsDataSource',
    );

    final response = await _apiClient.get('${ApiEndpoints.notifications}/$id');
    final data = response.data['data'] ?? response.data;

    return NotificationModel.fromJson(data);
  }

  @override
  Future<bool> markAsRead(String id) async {
    developer.log('Marking as read: $id', name: 'NotificationsDataSource');

    final response = await _apiClient.put(
      '${ApiEndpoints.notifications}/$id/read',
    );

    return response.statusCode == 200;
  }

  @override
  Future<bool> markAllAsRead() async {
    developer.log('Marking all as read', name: 'NotificationsDataSource');

    final response = await _apiClient.put(ApiEndpoints.notificationsReadAll);

    return response.statusCode == 200;
  }

  @override
  Future<bool> deleteNotification(String id) async {
    developer.log(
      'Deleting notification: $id',
      name: 'NotificationsDataSource',
    );

    final response = await _apiClient.delete(
      '${ApiEndpoints.notifications}/$id',
    );

    return response.statusCode == 200 || response.statusCode == 204;
  }

  @override
  Future<bool> deleteAllNotifications() async {
    developer.log(
      'Deleting all notifications',
      name: 'NotificationsDataSource',
    );

    final response = await _apiClient.delete(ApiEndpoints.notifications);
    return response.statusCode == 200 || response.statusCode == 204;
  }

  @override
  Future<int> getUnreadCount() async {
    developer.log('Getting unread count', name: 'NotificationsDataSource');

    try {
      // Try dedicated endpoint first if available
      try {
        final response = await _apiClient.get(
          ApiEndpoints.notificationsUnreadCount,
        );
        final data = response.data['data'] ?? response.data;
        return data['count'] ?? data['unreadCount'] ?? 0;
      } catch (e) {
        // If dedicated endpoint doesn't exist, get from notifications list meta
        developer.log(
          'Unread count endpoint not available, using notifications list meta',
          name: 'NotificationsDataSource',
        );
        final response = await getMyNotifications(page: 1, limit: 1);
        return response.unreadCount;
      }
    } catch (e) {
      developer.log(
        'Failed to get unread count: $e',
        name: 'NotificationsDataSource',
      );
      return 0;
    }
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
  Future<PushTokenModel> registerPushToken(PushTokenRequest request) async {
    developer.log('Registering push token', name: 'NotificationsDataSource');

    final response = await _apiClient.post(
      ApiEndpoints.notificationsToken,
      data: request.toJson(),
    );

    final data = response.data['data'] ?? response.data;
    return PushTokenModel.fromJson(data);
  }

  @override
  Future<bool> unregisterPushToken(String token) async {
    developer.log('Unregistering push token', name: 'NotificationsDataSource');

    final response = await _apiClient.delete(
      ApiEndpoints.notificationsToken,
      data: {'token': token},
    );

    return response.statusCode == 200 || response.statusCode == 204;
  }
}
