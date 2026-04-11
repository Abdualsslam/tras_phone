library;

import 'package:get_it/get_it.dart';

import '../../../features/support/data/datasources/support_remote_datasource.dart';
import '../../../features/support/presentation/cubit/live_chat_cubit.dart';
import '../../../features/support/presentation/cubit/support_cubit.dart';
import '../../network/api_client.dart';

void registerSupportDependencies(GetIt getIt) {
  getIt.registerLazySingleton<SupportRemoteDataSource>(
    () => SupportRemoteDataSourceImpl(apiClient: getIt<ApiClient>()),
  );
  getIt.registerFactory<SupportCubit>(
    () => SupportCubit(getIt<SupportRemoteDataSource>()),
  );
  getIt.registerFactory<LiveChatCubit>(
    () => LiveChatCubit(getIt<SupportRemoteDataSource>()),
  );
}
