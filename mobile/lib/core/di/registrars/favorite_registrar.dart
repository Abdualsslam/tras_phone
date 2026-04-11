library;

import 'package:get_it/get_it.dart';

import '../../../features/favorite/data/datasources/favorite_remote_datasource.dart';
import '../../../features/favorite/data/repositories/favorite_repository_impl.dart';
import '../../../features/favorite/data/services/favorite_cache_service.dart';
import '../../../features/favorite/domain/repositories/favorite_repository.dart';
import '../../network/api_client.dart';

void registerFavoriteDependencies(GetIt getIt) {
  getIt.registerLazySingleton<FavoriteRemoteDataSource>(
    () => FavoriteRemoteDataSourceImpl(
      apiClient: getIt<ApiClient>(),
      cacheService: getIt<FavoriteCacheService>(),
    ),
  );

  getIt.registerLazySingleton<FavoriteRepository>(
    () => FavoriteRepositoryImpl(
      remoteDataSource: getIt<FavoriteRemoteDataSource>(),
    ),
  );
}
