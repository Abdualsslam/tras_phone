/// Return Details Cubit - State management for return request details
library;

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/returns_repository.dart';
import 'return_details_state.dart';

class ReturnDetailsCubit extends Cubit<ReturnDetailsState> {
  final ReturnsRepository _repository;
  String? _currentReturnId;

  ReturnDetailsCubit({required ReturnsRepository repository})
      : _repository = repository,
        super(const ReturnDetailsInitial());

  String? get returnId => _currentReturnId;

  /// Load return by ID
  Future<void> loadReturn(String id) async {
    _currentReturnId = id;
    emit(const ReturnDetailsLoading());

    final result = await _repository.getReturnById(id);

    result.fold(
      (failure) => emit(ReturnDetailsError(failure.message)),
      (returnRequest) => emit(ReturnDetailsLoaded(returnRequest)),
    );
  }

  /// Cancel return request
  Future<void> cancelReturn(String id) async {
    emit(const ReturnDetailsCancelling());

    final result = await _repository.cancelReturn(id);

    result.fold(
      (failure) => emit(ReturnDetailsError(failure.message)),
      (_) {
        emit(const ReturnDetailsCancelled());
        // Reload return to get updated status
        loadReturn(id);
      },
    );
  }

  /// Refresh return details
  Future<void> refresh(String id) async {
    await loadReturn(id);
  }
}
