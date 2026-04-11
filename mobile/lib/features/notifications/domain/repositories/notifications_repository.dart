library;

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../data/models/notification_model.dart';
import '../../data/models/push_token_model.dart';
import '../enums/notification_enums.dart';

abstract class NotificationsRepository {
  Future<Either<Failure, NotificationsResponse>> getMyNotifications({
    int page = 1,
    int limit = 20,
    NotificationCategory? category,
    bool? isRead,
  });

  Future<Either<Failure, NotificationModel>> getNotificationById(String id);
  Future<Either<Failure, bool>> markAsRead(String id);
  Future<Either<Failure, bool>> markAllAsRead();
  Future<Either<Failure, bool>> deleteNotification(String id);
  Future<Either<Failure, bool>> deleteAllNotifications();
  Future<Either<Failure, int>> getUnreadCount();
  Future<Either<Failure, NotificationSettingsModel>> getSettings();
  Future<Either<Failure, NotificationSettingsModel>> updateSettings(
    NotificationSettingsModel settings,
  );
  Future<Either<Failure, PushTokenModel>> registerPushToken(
    PushTokenRequest request,
  );
  Future<Either<Failure, bool>> unregisterPushToken(String token);
}
