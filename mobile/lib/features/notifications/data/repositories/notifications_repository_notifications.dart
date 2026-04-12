part of 'notifications_repository.dart';

class _NotificationsRepositoryCrudDelegate {
  final NotificationsRemoteDataSource remoteDataSource;
  final _NotificationsRepositorySupport support;

  const _NotificationsRepositoryCrudDelegate({
    required this.remoteDataSource,
    required this.support,
  });

  Future<Either<Failure, NotificationsResponse>> getMyNotifications({
    int page = 1,
    int limit = 20,
    NotificationCategory? category,
    bool? isRead,
  }) async {
    try {
      final result = await remoteDataSource.getMyNotifications(
        page: page,
        limit: limit,
        category: category,
        isRead: isRead,
      );
      return Right(result);
    } catch (error) {
      return Left(support.failure(error));
    }
  }

  Future<Either<Failure, NotificationModel>> getNotificationById(
    String id,
  ) async {
    try {
      return Right(await remoteDataSource.getNotificationById(id));
    } catch (error) {
      return Left(support.failure(error));
    }
  }

  Future<Either<Failure, bool>> markAsRead(String id) async {
    try {
      return Right(await remoteDataSource.markAsRead(id));
    } catch (error) {
      return Left(support.failure(error));
    }
  }

  Future<Either<Failure, bool>> markAllAsRead() async {
    try {
      return Right(await remoteDataSource.markAllAsRead());
    } catch (error) {
      return Left(support.failure(error));
    }
  }

  Future<Either<Failure, bool>> deleteNotification(String id) async {
    try {
      return Right(await remoteDataSource.deleteNotification(id));
    } catch (error) {
      return Left(support.failure(error));
    }
  }

  Future<Either<Failure, bool>> deleteAllNotifications() async {
    try {
      return Right(await remoteDataSource.deleteAllNotifications());
    } catch (error) {
      return Left(support.failure(error));
    }
  }

  Future<Either<Failure, int>> getUnreadCount() async {
    try {
      return Right(await remoteDataSource.getUnreadCount());
    } catch (error) {
      return Left(support.failure(error));
    }
  }
}
