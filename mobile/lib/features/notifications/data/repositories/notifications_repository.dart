/// Notifications Repository - Data layer repository with error handling
library;

import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/enums/notification_enums.dart';
import '../datasources/notifications_remote_datasource.dart';
import '../models/notification_model.dart';
import '../models/push_token_model.dart';

/// Abstract repository interface
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

/// Implementation of NotificationsRepository
class NotificationsRepositoryImpl implements NotificationsRepository {
  final NotificationsRemoteDataSource _remoteDataSource;

  NotificationsRepositoryImpl({
    required NotificationsRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<Either<Failure, NotificationsResponse>> getMyNotifications({
    int page = 1,
    int limit = 20,
    NotificationCategory? category,
    bool? isRead,
  }) async {
    try {
      final result = await _remoteDataSource.getMyNotifications(
        page: page,
        limit: limit,
        category: category,
        isRead: isRead,
      );
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, NotificationModel>> getNotificationById(
    String id,
  ) async {
    try {
      final result = await _remoteDataSource.getNotificationById(id);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> markAsRead(String id) async {
    try {
      final result = await _remoteDataSource.markAsRead(id);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> markAllAsRead() async {
    try {
      final result = await _remoteDataSource.markAllAsRead();
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteNotification(String id) async {
    try {
      final result = await _remoteDataSource.deleteNotification(id);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteAllNotifications() async {
    try {
      final result = await _remoteDataSource.deleteAllNotifications();
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> getUnreadCount() async {
    try {
      final result = await _remoteDataSource.getUnreadCount();
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, NotificationSettingsModel>> getSettings() async {
    try {
      final result = await _remoteDataSource.getSettings();
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, NotificationSettingsModel>> updateSettings(
    NotificationSettingsModel settings,
  ) async {
    try {
      final result = await _remoteDataSource.updateSettings(settings);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, PushTokenModel>> registerPushToken(
    PushTokenRequest request,
  ) async {
    try {
      final result = await _remoteDataSource.registerPushToken(request);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> unregisterPushToken(String token) async {
    try {
      final result = await _remoteDataSource.unregisterPushToken(token);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
