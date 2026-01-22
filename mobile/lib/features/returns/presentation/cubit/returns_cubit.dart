/// Returns Cubit - State management for returns list
library;

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/returns_repository.dart';
import '../../domain/enums/return_enums.dart';
import 'returns_state.dart';

class ReturnsCubit extends Cubit<ReturnsState> {
  final ReturnsRepository _repository;

  ReturnsCubit({required ReturnsRepository repository})
      : _repository = repository,
        super(const ReturnsInitial());

  /// Load my returns
  Future<void> loadReturns({
    ReturnStatus? status,
    int page = 1,
    int limit = 20,
  }) async {
    emit(const ReturnsLoading());

    final result = await _repository.getMyReturns(
      status: status,
      page: page,
      limit: limit,
    );

    result.fold(
      (failure) => emit(ReturnsError(failure.message)),
      (returns) {
        final hasMore = returns.length >= limit;
        emit(ReturnsLoaded(
          returns,
          total: returns.length,
          filterStatus: status,
          currentPage: page,
          hasMore: hasMore,
        ));
      },
    );
  }

  /// Filter returns by status
  Future<void> filterByStatus(ReturnStatus? status) async {
    await loadReturns(status: status, page: 1);
  }

  /// Load more returns (pagination)
  Future<void> loadMore() async {
    final currentState = state;
    if (currentState is ReturnsLoaded && currentState.hasMore) {
      final result = await _repository.getMyReturns(
        status: currentState.filterStatus,
        page: currentState.currentPage + 1,
        limit: 20,
      );

      result.fold(
        (failure) => emit(ReturnsError(failure.message)),
        (newReturns) {
          if (newReturns.isEmpty) {
            // No more items
            emit(ReturnsLoaded(
              currentState.returns,
              total: currentState.total,
              filterStatus: currentState.filterStatus,
              currentPage: currentState.currentPage,
              hasMore: false,
            ));
          } else {
            // Append new items
            emit(ReturnsLoaded(
              [...currentState.returns, ...newReturns],
              total: currentState.total + newReturns.length,
              filterStatus: currentState.filterStatus,
              currentPage: currentState.currentPage + 1,
              hasMore: newReturns.length >= 20,
            ));
          }
        },
      );
    }
  }

  /// Refresh returns
  Future<void> refresh() async {
    final currentState = state;
    if (currentState is ReturnsLoaded) {
      await loadReturns(
        status: currentState.filterStatus,
        page: 1,
      );
    } else {
      await loadReturns();
    }
  }
}
