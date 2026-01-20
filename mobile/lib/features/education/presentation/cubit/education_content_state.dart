/// Education Content State
library;

import 'package:equatable/equatable.dart';
import '../../domain/entities/educational_content_entity.dart';

abstract class EducationContentState extends Equatable {
  const EducationContentState();

  @override
  List<Object?> get props => [];
}

class EducationContentInitial extends EducationContentState {
  const EducationContentInitial();
}

class EducationContentLoading extends EducationContentState {
  const EducationContentLoading();
}

class EducationContentLoaded extends EducationContentState {
  final List<EducationalContentEntity> content;
  final bool hasMore;
  final int currentPage;
  final int total;

  const EducationContentLoaded({
    required this.content,
    required this.hasMore,
    required this.currentPage,
    required this.total,
  });

  @override
  List<Object?> get props => [content, hasMore, currentPage, total];
}

class EducationContentError extends EducationContentState {
  final String message;

  const EducationContentError(this.message);

  @override
  List<Object?> get props => [message];
}
