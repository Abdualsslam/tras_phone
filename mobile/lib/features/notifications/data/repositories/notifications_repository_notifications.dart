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
  }) {
    return support.guard(
      () => remoteDataSource.getMyNotifications(
        page: page,
        limit: limit,
        category: category,
        isRead: isRead,
      ),
      source: 'NotificationsRepository.getMyNotifications',
    );
  }

  Future<Either<Failure, NotificationModel>> getNotificationById(String id) =>
      support.guard(
        () => remoteDataSource.getNotificationById(id),
        source: 'NotificationsRepository.getNotificationById',
      );

  Future<Either<Failure, bool>> markAsRead(String id) => support.guard(
    () => remoteDataSource.markAsRead(id),
    source: 'NotificationsRepository.markAsRead',
  );

  Future<Either<Failure, bool>> markAllAsRead() => support.guard(
    remoteDataSource.markAllAsRead,
    source: 'NotificationsRepository.markAllAsRead',
  );

  Future<Either<Failure, bool>> deleteNotification(String id) => support.guard(
    () => remoteDataSource.deleteNotification(id),
    source: 'NotificationsRepository.deleteNotification',
  );

  Future<Either<Failure, bool>> deleteAllNotifications() => support.guard(
    remoteDataSource.deleteAllNotifications,
    source: 'NotificationsRepository.deleteAllNotifications',
  );

  Future<Either<Failure, int>> getUnreadCount() => support.guard(
    remoteDataSource.getUnreadCount,
    source: 'NotificationsRepository.getUnreadCount',
  );
}
