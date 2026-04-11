library;

import 'package:get_it/get_it.dart';

import '../../../features/cart/data/datasources/cart_local_datasource.dart';
import '../../../features/cart/data/datasources/cart_remote_datasource.dart';
import '../../../features/cart/presentation/cubit/cart_cubit.dart';
import '../../../features/cart/presentation/cubit/checkout_session_cubit.dart';
import '../../network/api_client.dart';
import '../../storage/local_storage.dart';

void registerCartDependencies(GetIt getIt) {
  getIt.registerLazySingleton<CartRemoteDataSource>(
    () => CartRemoteDataSourceImpl(apiClient: getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<CartLocalDataSource>(
    () => CartLocalDataSourceImpl(storage: getIt<LocalStorage>()),
  );

  getIt.registerLazySingleton<CartCubit>(
    () => CartCubit(
      remoteDataSource: getIt<CartRemoteDataSource>(),
      localDataSource: getIt<CartLocalDataSource>(),
    ),
  );
  getIt.registerFactory<CheckoutSessionCubit>(
    () => CheckoutSessionCubit(
      remoteDataSource: getIt<CartRemoteDataSource>(),
    ),
  );
}
