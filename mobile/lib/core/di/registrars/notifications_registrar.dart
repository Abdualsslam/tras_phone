library;

import 'package:get_it/get_it.dart';

import '../../../features/notifications/data/datasources/notifications_remote_datasource.dart';
import '../../../features/notifications/data/repositories/notifications_repository.dart';
import '../../../features/notifications/domain/repositories/notifications_repository.dart';
import '../../../features/notifications/presentation/cubit/notifications_cubit.dart';
import '../../errors/repository_guard.dart';
import '../../../features/notifications/services/push_notification_manager.dart';
import '../../network/api_client.dart';

void registerNotificationsDependencies(GetIt getIt) {
  getIt.registerLazySingleton<NotificationsRemoteDataSource>(
    () => NotificationsRemoteDataSourceImpl(apiClient: getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<NotificationsRepository>(
    () => NotificationsRepositoryImpl(
      remoteDataSource: getIt<NotificationsRemoteDataSource>(),
      repositoryGuard: getIt<RepositoryGuard>(),
    ),
  );
  getIt.registerFactory<NotificationsCubit>(
    () => NotificationsCubit(repository: getIt<NotificationsRepository>()),
  );
  getIt.registerLazySingleton<PushNotificationManager>(
    () => PushNotificationManager(repository: getIt<NotificationsRepository>()),
  );
}
