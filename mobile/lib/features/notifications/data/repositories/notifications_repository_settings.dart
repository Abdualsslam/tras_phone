part of 'notifications_repository.dart';

class _NotificationsRepositorySettingsDelegate {
  final NotificationsRemoteDataSource remoteDataSource;
  final _NotificationsRepositorySupport support;

  const _NotificationsRepositorySettingsDelegate({
    required this.remoteDataSource,
    required this.support,
  });

  Future<Either<Failure, NotificationSettingsModel>> getSettings() =>
      support.guard(
        remoteDataSource.getSettings,
        source: 'NotificationsRepository.getSettings',
      );

  Future<Either<Failure, NotificationSettingsModel>> updateSettings(
    NotificationSettingsModel settings,
  ) => support.guard(
    () => remoteDataSource.updateSettings(settings),
    source: 'NotificationsRepository.updateSettings',
  );

  Future<Either<Failure, PushTokenModel>> registerPushToken(
    PushTokenRequest request,
  ) => support.guard(
    () => remoteDataSource.registerPushToken(request),
    source: 'NotificationsRepository.registerPushToken',
  );

  Future<Either<Failure, bool>> unregisterPushToken(String token) =>
      support.guard(
        () => remoteDataSource.unregisterPushToken(token),
        source: 'NotificationsRepository.unregisterPushToken',
      );
}
