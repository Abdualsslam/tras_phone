/// Create Return Cubit State - State classes for CreateReturnCubit
library;

import 'package:equatable/equatable.dart';
import '../../domain/entities/return_entity.dart';

abstract class CreateReturnState extends Equatable {
  const CreateReturnState();

  @override
  List<Object?> get props => [];
}

class CreateReturnInitial extends CreateReturnState {
  const CreateReturnInitial();
}

class CreateReturnLoading extends CreateReturnState {
  const CreateReturnLoading();
}

class CreateReturnReasonsLoaded extends CreateReturnState {
  final List<ReturnReasonEntity> reasons;

  const CreateReturnReasonsLoaded(this.reasons);

  @override
  List<Object?> get props => [reasons];
}

class CreateReturnSuccess extends CreateReturnState {
  final ReturnEntity returnRequest;

  const CreateReturnSuccess(this.returnRequest);

  @override
  List<Object?> get props => [returnRequest];
}

class CreateReturnError extends CreateReturnState {
  final String message;

  const CreateReturnError(this.message);

  @override
  List<Object?> get props => [message];
}

class CreateReturnImagesUploading extends CreateReturnState {
  final int uploaded;
  final int total;

  const CreateReturnImagesUploading({
    required this.uploaded,
    required this.total,
  });

  @override
  List<Object?> get props => [uploaded, total];
}
