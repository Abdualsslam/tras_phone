library;

import 'package:get_it/get_it.dart';

import '../../../features/returns/data/datasources/returns_remote_datasource.dart';
import '../../../features/returns/data/repositories/returns_repository_impl.dart';
import '../../../features/returns/domain/repositories/returns_repository.dart';
import '../../../features/returns/presentation/cubit/create_return_cubit.dart';
import '../../../features/returns/presentation/cubit/return_details_cubit.dart';
import '../../../features/returns/presentation/cubit/returns_cubit.dart';
import '../../network/api_client.dart';

void registerReturnsDependencies(GetIt getIt) {
  getIt.registerLazySingleton<ReturnsRemoteDataSource>(
    () => ReturnsRemoteDataSourceImpl(apiClient: getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<ReturnsRepository>(
    () => ReturnsRepositoryImpl(
      remoteDataSource: getIt<ReturnsRemoteDataSource>(),
    ),
  );
  getIt.registerFactory<ReturnsCubit>(
    () => ReturnsCubit(repository: getIt<ReturnsRepository>()),
  );
  getIt.registerFactory<CreateReturnCubit>(
    () => CreateReturnCubit(repository: getIt<ReturnsRepository>()),
  );
  getIt.registerFactory<ReturnDetailsCubit>(
    () => ReturnDetailsCubit(repository: getIt<ReturnsRepository>()),
  );
}
