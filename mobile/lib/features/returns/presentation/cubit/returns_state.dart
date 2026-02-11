/// Returns Cubit State - State classes for ReturnsCubit
library;

import 'package:equatable/equatable.dart';
import '../../domain/entities/return_entity.dart';

abstract class ReturnsState extends Equatable {
  const ReturnsState();

  @override
  List<Object?> get props => [];
}

class ReturnsInitial extends ReturnsState {
  const ReturnsInitial();
}

class ReturnsLoading extends ReturnsState {
  const ReturnsLoading();
}

class ReturnsLoaded extends ReturnsState {
  final List<ReturnEntity> returns;
  final int total;
  final ReturnStatus? filterStatus;
  final int currentPage;
  final bool hasMore;

  const ReturnsLoaded(
    this.returns, {
    this.total = 0,
    this.filterStatus,
    this.currentPage = 1,
    this.hasMore = false,
  });

  @override
  List<Object?> get props => [
    returns,
    total,
    filterStatus,
    currentPage,
    hasMore,
  ];
}

class ReturnsError extends ReturnsState {
  final String message;

  const ReturnsError(this.message);

  @override
  List<Object?> get props => [message];
}
