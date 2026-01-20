/// Education Categories Cubit
library;

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/education_repository.dart';
import 'education_categories_state.dart';

class EducationCategoriesCubit extends Cubit<EducationCategoriesState> {
  final EducationRepository _repository;

  EducationCategoriesCubit({required EducationRepository repository})
      : _repository = repository,
        super(const EducationCategoriesInitial());

  Future<void> loadCategories({bool? activeOnly}) async {
    emit(const EducationCategoriesLoading());

    try {
      final categories = await _repository.getCategories(activeOnly: activeOnly);
      emit(EducationCategoriesLoaded(categories));
    } catch (e) {
      emit(EducationCategoriesError(e.toString()));
    }
  }

  Future<void> refreshCategories({bool? activeOnly}) async {
    try {
      final categories = await _repository.getCategories(activeOnly: activeOnly);
      emit(EducationCategoriesLoaded(categories));
    } catch (e) {
      emit(EducationCategoriesError(e.toString()));
    }
  }
}
