library;

import 'package:get_it/get_it.dart';

import '../../../features/address/data/datasources/locations_remote_datasource.dart';
import '../../../features/address/data/repositories/locations_repository_impl.dart';
import '../../../features/address/domain/repositories/locations_repository.dart';
import '../../../features/address/presentation/cubit/locations_cubit.dart';
import '../../errors/repository_guard.dart';
import '../../network/api_client.dart';

void registerLocationsDependencies(GetIt getIt) {
  getIt.registerLazySingleton<LocationsRemoteDataSource>(
    () => LocationsRemoteDataSourceImpl(apiClient: getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<LocationsRepository>(
    () => LocationsRepositoryImpl(
      dataSource: getIt<LocationsRemoteDataSource>(),
      repositoryGuard: getIt<RepositoryGuard>(),
    ),
  );
  getIt.registerFactory<LocationsCubit>(
    () => LocationsCubit(repository: getIt<LocationsRepository>()),
  );
}
