library;

import 'package:get_it/get_it.dart';

import '../../../features/profile/data/datasources/profile_remote_datasource.dart';
import '../../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../../features/profile/domain/repositories/profile_repository.dart';
import '../../../features/profile/presentation/cubit/profile_cubit.dart';
import '../../network/api_client.dart';

void registerProfileDependencies(GetIt getIt) {
  getIt.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(apiClient: getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(dataSource: getIt<ProfileRemoteDataSource>()),
  );
  getIt.registerLazySingleton<ProfileCubit>(
    () => ProfileCubit(repository: getIt<ProfileRepository>()),
  );
  getIt.registerLazySingleton<AddressesCubit>(
    () => AddressesCubit(repository: getIt<ProfileRepository>()),
  );
}
