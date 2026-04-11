library;

import 'package:get_it/get_it.dart';

import '../../../features/catalog/data/datasources/catalog_remote_datasource.dart';
import '../../../features/catalog/data/repositories/catalog_repository_impl.dart';
import '../../../features/catalog/data/services/product_cache_service.dart';
import '../../../features/catalog/domain/repositories/catalog_repository.dart';
import '../../../features/catalog/presentation/cubit/brands_cubit.dart';
import '../../../features/catalog/presentation/cubit/categories_cubit.dart';
import '../../../features/catalog/presentation/cubit/devices_cubit.dart';
import '../../../features/catalog/presentation/cubit/quality_types_cubit.dart';
import '../../network/api_client.dart';

void registerCatalogDependencies(GetIt getIt) {
  getIt.registerLazySingleton<CatalogRemoteDataSource>(
    () => CatalogRemoteDataSourceImpl(apiClient: getIt<ApiClient>()),
  );

  getIt.registerLazySingleton<CatalogRepository>(
    () => CatalogRepositoryImpl(
      remoteDataSource: getIt<CatalogRemoteDataSource>(),
      cacheService: getIt<ProductCacheService>(),
    ),
  );

  getIt.registerFactory<BrandsCubit>(
    () => BrandsCubit(repository: getIt<CatalogRepository>()),
  );
  getIt.registerFactory<BrandDetailsCubit>(
    () => BrandDetailsCubit(repository: getIt<CatalogRepository>()),
  );
  getIt.registerFactory<CategoriesCubit>(
    () => CategoriesCubit(repository: getIt<CatalogRepository>()),
  );
  getIt.registerFactory<CategoryTreeCubit>(
    () => CategoryTreeCubit(repository: getIt<CatalogRepository>()),
  );
  getIt.registerFactory<CategoryDetailsCubit>(
    () => CategoryDetailsCubit(repository: getIt<CatalogRepository>()),
  );
  getIt.registerFactory<CategoryChildrenCubit>(
    () => CategoryChildrenCubit(repository: getIt<CatalogRepository>()),
  );
  getIt.registerFactory<DevicesCubit>(
    () => DevicesCubit(repository: getIt<CatalogRepository>()),
  );
  getIt.registerFactory<DeviceDetailsCubit>(
    () => DeviceDetailsCubit(repository: getIt<CatalogRepository>()),
  );
  getIt.registerFactory<QualityTypesCubit>(
    () => QualityTypesCubit(repository: getIt<CatalogRepository>()),
  );
}
