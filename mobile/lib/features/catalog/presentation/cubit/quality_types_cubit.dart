/// Quality Types Cubit - Manages quality types state
library;

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/catalog_repository.dart';
import 'quality_types_state.dart';

/// Cubit for managing quality types
class QualityTypesCubit extends Cubit<QualityTypesState> {
  final CatalogRepository _repository;

  QualityTypesCubit({required CatalogRepository repository})
      : _repository = repository,
        super(const QualityTypesInitial());

  /// Load all quality types
  Future<void> loadQualityTypes() async {
    emit(const QualityTypesLoading());

    final result = await _repository.getQualityTypes();

    result.fold(
      (failure) => emit(QualityTypesError(failure.message)),
      (qualityTypes) => emit(QualityTypesLoaded(qualityTypes)),
    );
  }
}
