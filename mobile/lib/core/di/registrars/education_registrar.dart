library;

import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../features/education/data/datasources/education_remote_datasource.dart';
import '../../../features/education/data/repositories/education_repository_impl.dart';
import '../../../features/education/data/services/favorites_service.dart';
import '../../../features/education/domain/repositories/education_repository.dart';
import '../../../features/education/presentation/cubit/education_categories_cubit.dart';
import '../../../features/education/presentation/cubit/education_content_cubit.dart';
import '../../../features/education/presentation/cubit/education_details_cubit.dart';
import '../../network/api_client.dart';

Future<void> registerEducationDependencies(GetIt getIt) async {
  getIt.registerLazySingleton<EducationRemoteDataSource>(
    () => EducationRemoteDataSourceImpl(apiClient: getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<EducationRepository>(
    () => EducationRepositoryImpl(
      remoteDataSource: getIt<EducationRemoteDataSource>(),
    ),
  );

  final prefs = await SharedPreferences.getInstance();
  getIt.registerLazySingleton<FavoritesService>(
    () => FavoritesService(prefs: prefs),
  );

  getIt.registerFactory<EducationCategoriesCubit>(
    () => EducationCategoriesCubit(repository: getIt<EducationRepository>()),
  );
  getIt.registerFactory<EducationContentCubit>(
    () => EducationContentCubit(repository: getIt<EducationRepository>()),
  );
  getIt.registerFactory<EducationDetailsCubit>(
    () => EducationDetailsCubit(repository: getIt<EducationRepository>()),
  );
}
