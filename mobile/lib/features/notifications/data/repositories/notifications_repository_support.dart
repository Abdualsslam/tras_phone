part of 'notifications_repository.dart';

class _NotificationsRepositorySupport {
  Failure failure(Object error) => ServerFailure(message: error.toString());
}
