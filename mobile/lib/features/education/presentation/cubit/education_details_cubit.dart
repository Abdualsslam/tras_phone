/// Education Details Cubit
library;

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/education_repository.dart';
import 'education_details_state.dart';

class EducationDetailsCubit extends Cubit<EducationDetailsState> {
  final EducationRepository _repository;

  EducationDetailsCubit({required EducationRepository repository})
    : _repository = repository,
      super(const EducationDetailsInitial());

  Future<void> loadContent(String slug) async {
    emit(const EducationDetailsLoading());

    try {
      final content = await _repository.getContentBySlug(slug);

      if (content != null) {
        emit(EducationDetailsLoaded(content));
      } else {
        emit(const EducationDetailsError('Content not found'));
      }
    } catch (e) {
      emit(EducationDetailsError(e.toString()));
    }
  }

  Future<bool> likeContent(String id) async {
    try {
      await _repository.likeContent(id);

      // Reload content to get updated like count
      final currentState = state;
      if (currentState is EducationDetailsLoaded) {
        await loadContent(currentState.content.slug);
      }
      return true;
    } catch (e) {
      // Silently fail - like action is not critical
      return false;
    }
  }

  Future<bool> shareContent(String id) async {
    try {
      await _repository.shareContent(id);

      // Reload content to get updated share count
      final currentState = state;
      if (currentState is EducationDetailsLoaded) {
        await loadContent(currentState.content.slug);
      }
      return true;
    } catch (e) {
      // Silently fail - share tracking is not critical
      return false;
    }
  }
}
