/// Notifications Repository - Data layer repository with error handling
library;

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/errors/repository_guard.dart';
import '../../domain/enums/notification_enums.dart';
import '../../domain/repositories/notifications_repository.dart';
import '../datasources/notifications_remote_datasource.dart';
import '../models/notification_model.dart';
import '../models/push_token_model.dart';

part 'notifications_repository_support.dart';
part 'notifications_repository_notifications.dart';
part 'notifications_repository_settings.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  final NotificationsRemoteDataSource _remoteDataSource;
  final RepositoryGuard _repositoryGuard;
  late final _NotificationsRepositorySupport _support =
      _NotificationsRepositorySupport(repositoryGuard: _repositoryGuard);
  late final _NotificationsRepositoryCrudDelegate _notifications =
      _NotificationsRepositoryCrudDelegate(
        remoteDataSource: _remoteDataSource,
        support: _support,
      );
  late final _NotificationsRepositorySettingsDelegate _settings =
      _NotificationsRepositorySettingsDelegate(
        remoteDataSource: _remoteDataSource,
        support: _support,
      );

  NotificationsRepositoryImpl({
    required NotificationsRemoteDataSource remoteDataSource,
    required RepositoryGuard repositoryGuard,
  }) : _remoteDataSource = remoteDataSource,
       _repositoryGuard = repositoryGuard;

  @override
  Future<Either<Failure, NotificationsResponse>> getMyNotifications({
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
  Future<Either<Failure, NotificationModel>> getNotificationById(String id) =>
      _notifications.getNotificationById(id);

  @override
  Future<Either<Failure, bool>> markAsRead(String id) =>
      _notifications.markAsRead(id);

  @override
  Future<Either<Failure, bool>> markAllAsRead() =>
      _notifications.markAllAsRead();

  @override
  Future<Either<Failure, bool>> deleteNotification(String id) =>
      _notifications.deleteNotification(id);

  @override
  Future<Either<Failure, bool>> deleteAllNotifications() =>
      _notifications.deleteAllNotifications();

  @override
  Future<Either<Failure, int>> getUnreadCount() =>
      _notifications.getUnreadCount();

  @override
  Future<Either<Failure, NotificationSettingsModel>> getSettings() =>
      _settings.getSettings();

  @override
  Future<Either<Failure, NotificationSettingsModel>> updateSettings(
    NotificationSettingsModel settings,
  ) => _settings.updateSettings(settings);

  @override
  Future<Either<Failure, PushTokenModel>> registerPushToken(
    PushTokenRequest request,
  ) => _settings.registerPushToken(request);

  @override
  Future<Either<Failure, bool>> unregisterPushToken(String token) =>
      _settings.unregisterPushToken(token);
}
