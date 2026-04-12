part of 'notifications_repository.dart';

class _NotificationsRepositorySettingsDelegate {
  final NotificationsRemoteDataSource remoteDataSource;
  final _NotificationsRepositorySupport support;

  const _NotificationsRepositorySettingsDelegate({
    required this.remoteDataSource,
    required this.support,
  });

  Future<Either<Failure, NotificationSettingsModel>> getSettings() async {
    try {
      return Right(await remoteDataSource.getSettings());
    } catch (error) {
      return Left(support.failure(error));
    }
  }

  Future<Either<Failure, NotificationSettingsModel>> updateSettings(
    NotificationSettingsModel settings,
  ) async {
    try {
      return Right(await remoteDataSource.updateSettings(settings));
    } catch (error) {
      return Left(support.failure(error));
    }
  }

  Future<Either<Failure, PushTokenModel>> registerPushToken(
    PushTokenRequest request,
  ) async {
    try {
      return Right(await remoteDataSource.registerPushToken(request));
    } catch (error) {
      return Left(support.failure(error));
    }
  }

  Future<Either<Failure, bool>> unregisterPushToken(String token) async {
    try {
      return Right(await remoteDataSource.unregisterPushToken(token));
    } catch (error) {
      return Left(support.failure(error));
    }
  }
}
