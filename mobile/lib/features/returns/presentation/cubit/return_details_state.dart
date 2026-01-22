/// Return Details Cubit State - State classes for ReturnDetailsCubit
library;

import 'package:equatable/equatable.dart';
import '../../domain/entities/return_entity.dart';

abstract class ReturnDetailsState extends Equatable {
  const ReturnDetailsState();

  @override
  List<Object?> get props => [];
}

class ReturnDetailsInitial extends ReturnDetailsState {
  const ReturnDetailsInitial();
}

class ReturnDetailsLoading extends ReturnDetailsState {
  const ReturnDetailsLoading();
}

class ReturnDetailsLoaded extends ReturnDetailsState {
  final ReturnEntity returnRequest;

  const ReturnDetailsLoaded(this.returnRequest);

  @override
  List<Object?> get props => [returnRequest];
}

class ReturnDetailsError extends ReturnDetailsState {
  final String message;

  const ReturnDetailsError(this.message);

  @override
  List<Object?> get props => [message];
}

class ReturnDetailsCancelling extends ReturnDetailsState {
  const ReturnDetailsCancelling();
}

class ReturnDetailsCancelled extends ReturnDetailsState {
  const ReturnDetailsCancelled();
}
