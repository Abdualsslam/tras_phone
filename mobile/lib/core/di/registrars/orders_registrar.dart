library;

import 'package:get_it/get_it.dart';

import '../../../features/orders/data/datasources/orders_remote_datasource.dart';
import '../../../features/orders/presentation/cubit/orders_cubit.dart';
import '../../../features/orders/presentation/cubit/payment_methods_cubit.dart';
import '../../network/api_client.dart';

void registerOrdersDependencies(GetIt getIt) {
  getIt.registerLazySingleton<OrdersRemoteDataSource>(
    () => OrdersRemoteDataSourceImpl(apiClient: getIt<ApiClient>()),
  );

  getIt.registerFactory<OrdersCubit>(
    () => OrdersCubit(dataSource: getIt<OrdersRemoteDataSource>()),
  );
  getIt.registerFactory<PaymentMethodsCubit>(
    () => PaymentMethodsCubit(dataSource: getIt<OrdersRemoteDataSource>()),
  );
}
