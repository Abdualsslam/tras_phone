library;

import 'package:get_it/get_it.dart';

import '../../../features/promotions/data/datasources/promotions_remote_datasource.dart';
import '../../../features/promotions/presentation/cubit/promotions_cubit.dart';
import '../../network/api_client.dart';

void registerPromotionsDependencies(GetIt getIt) {
  getIt.registerLazySingleton<PromotionsRemoteDataSource>(
    () => PromotionsRemoteDataSourceImpl(getIt<ApiClient>()),
  );
  getIt.registerFactory<PromotionsCubit>(
    () => PromotionsCubit(getIt<PromotionsRemoteDataSource>()),
  );
}
