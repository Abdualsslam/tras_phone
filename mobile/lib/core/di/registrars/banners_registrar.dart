library;

import 'package:get_it/get_it.dart';

import '../../../features/banners/data/datasources/banners_remote_datasource.dart';
import '../../../features/banners/data/repositories/banners_repository_impl.dart';
import '../../../features/banners/data/services/banners_cache_service.dart';
import '../../../features/banners/domain/repositories/banners_repository.dart';
import '../../../features/banners/presentation/cubit/banners_cubit.dart';
import '../../cache/hive_cache_service.dart';
import '../../errors/repository_guard.dart';
import '../../network/api_client.dart';

void registerBannersDependencies(GetIt getIt) {
  getIt.registerLazySingleton<BannersCacheService>(
    () => BannersCacheService(getIt<HiveCacheService>()),
  );
  getIt.registerLazySingleton<BannersRemoteDataSource>(
    () => BannersRemoteDataSourceImpl(
      apiClient: getIt<ApiClient>(),
      cacheService: getIt<BannersCacheService>(),
    ),
  );
  getIt.registerLazySingleton<BannersRepository>(
    () => BannersRepositoryImpl(
      remoteDataSource: getIt<BannersRemoteDataSource>(),
      repositoryGuard: getIt<RepositoryGuard>(),
    ),
  );
  getIt.registerFactory<BannersCubit>(
    () => BannersCubit(repository: getIt<BannersRepository>()),
  );
}
