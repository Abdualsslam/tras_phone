/// Create Return Cubit - State management for creating return requests
library;

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/returns_repository.dart';
import '../../data/models/return_model.dart';
import 'create_return_state.dart';

class CreateReturnCubit extends Cubit<CreateReturnState> {
  final ReturnsRepository _repository;

  CreateReturnCubit({required ReturnsRepository repository})
      : _repository = repository,
        super(const CreateReturnInitial());

  /// Load return reasons
  Future<void> loadReasons() async {
    final result = await _repository.getReturnReasons();

    result.fold(
      (failure) => emit(CreateReturnError(failure.message)),
      (reasons) => emit(CreateReturnReasonsLoaded(reasons)),
    );
  }

  /// Upload images
  Future<List<String>> uploadImages(List<String> imagePaths) async {
    if (imagePaths.isEmpty) return [];

    emit(const CreateReturnImagesUploading(uploaded: 0, total: 0));

    final result = await _repository.uploadReturnImages(imagePaths);

    return result.fold(
      (failure) {
        emit(CreateReturnError(failure.message));
        return [];
      },
      (urls) {
        emit(const CreateReturnInitial());
        return urls;
      },
    );
  }

  /// Create return request
  Future<void> createReturn(CreateReturnRequest request) async {
    emit(const CreateReturnLoading());

    final result = await _repository.createReturn(request);

    result.fold(
      (failure) => emit(CreateReturnError(failure.message)),
      (returnRequest) => emit(CreateReturnSuccess(returnRequest)),
    );
  }

  /// Reset state
  void reset() {
    emit(const CreateReturnInitial());
  }
}
