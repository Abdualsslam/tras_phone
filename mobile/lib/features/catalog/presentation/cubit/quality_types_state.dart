/// Quality Types State - State classes for QualityTypesCubit
library;

import 'package:equatable/equatable.dart';
import '../../domain/entities/quality_type_entity.dart';

/// Base state for quality types
sealed class QualityTypesState extends Equatable {
  const QualityTypesState();

  @override
  List<Object?> get props => [];
}

class QualityTypesInitial extends QualityTypesState {
  const QualityTypesInitial();
}

class QualityTypesLoading extends QualityTypesState {
  const QualityTypesLoading();
}

class QualityTypesLoaded extends QualityTypesState {
  final List<QualityTypeEntity> qualityTypes;

  const QualityTypesLoaded(this.qualityTypes);

  @override
  List<Object?> get props => [qualityTypes];
}

class QualityTypesError extends QualityTypesState {
  final String message;

  const QualityTypesError(this.message);

  @override
  List<Object?> get props => [message];
}
