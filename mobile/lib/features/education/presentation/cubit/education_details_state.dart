/// Education Details State
library;

import 'package:equatable/equatable.dart';
import '../../domain/entities/educational_content_entity.dart';

abstract class EducationDetailsState extends Equatable {
  const EducationDetailsState();

  @override
  List<Object?> get props => [];
}

class EducationDetailsInitial extends EducationDetailsState {
  const EducationDetailsInitial();
}

class EducationDetailsLoading extends EducationDetailsState {
  const EducationDetailsLoading();
}

class EducationDetailsLoaded extends EducationDetailsState {
  final EducationalContentEntity content;

  const EducationDetailsLoaded(this.content);

  @override
  List<Object?> get props => [content];
}

class EducationDetailsError extends EducationDetailsState {
  final String message;

  const EducationDetailsError(this.message);

  @override
  List<Object?> get props => [message];
}
