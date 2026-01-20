/// Education Categories State
library;

import 'package:equatable/equatable.dart';
import '../../domain/entities/educational_category_entity.dart';

abstract class EducationCategoriesState extends Equatable {
  const EducationCategoriesState();

  @override
  List<Object?> get props => [];
}

class EducationCategoriesInitial extends EducationCategoriesState {
  const EducationCategoriesInitial();
}

class EducationCategoriesLoading extends EducationCategoriesState {
  const EducationCategoriesLoading();
}

class EducationCategoriesLoaded extends EducationCategoriesState {
  final List<EducationalCategoryEntity> categories;

  const EducationCategoriesLoaded(this.categories);

  @override
  List<Object?> get props => [categories];
}

class EducationCategoriesError extends EducationCategoriesState {
  final String message;

  const EducationCategoriesError(this.message);

  @override
  List<Object?> get props => [message];
}
