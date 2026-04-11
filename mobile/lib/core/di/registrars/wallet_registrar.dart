library;

import 'package:get_it/get_it.dart';

import '../../../features/wallet/data/datasources/wallet_remote_datasource.dart';
import '../../../features/wallet/data/repositories/wallet_repository.dart';
import '../../../features/wallet/domain/repositories/wallet_repository.dart';
import '../../../features/wallet/presentation/cubit/wallet_cubit.dart';
import '../../network/api_client.dart';

void registerWalletDependencies(GetIt getIt) {
  getIt.registerLazySingleton<WalletRemoteDataSource>(
    () => WalletRemoteDataSourceImpl(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<WalletRepository>(
    () => WalletRepositoryImpl(getIt<WalletRemoteDataSource>()),
  );
  getIt.registerFactory<WalletCubit>(
    () => WalletCubit(getIt<WalletRepository>()),
  );
}
