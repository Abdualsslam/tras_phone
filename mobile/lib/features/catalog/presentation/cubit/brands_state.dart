/// Brands State - State classes for BrandsCubit
library;

import 'package:equatable/equatable.dart';
import '../../domain/entities/brand_entity.dart';

/// Base state for brands
sealed class BrandsState extends Equatable {
  const BrandsState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class BrandsInitial extends BrandsState {
  const BrandsInitial();
}

/// Loading state
class BrandsLoading extends BrandsState {
  const BrandsLoading();
}

/// Loaded state with brands list
class BrandsLoaded extends BrandsState {
  final List<BrandEntity> brands;

  const BrandsLoaded(this.brands);

  @override
  List<Object?> get props => [brands];
}

/// Error state
class BrandsError extends BrandsState {
  final String message;

  const BrandsError(this.message);

  @override
  List<Object?> get props => [message];
}

/// State for single brand details
sealed class BrandDetailsState extends Equatable {
  const BrandDetailsState();

  @override
  List<Object?> get props => [];
}

class BrandDetailsInitial extends BrandDetailsState {
  const BrandDetailsInitial();
}

class BrandDetailsLoading extends BrandDetailsState {
  const BrandDetailsLoading();
}

class BrandDetailsLoaded extends BrandDetailsState {
  final BrandEntity brand;

  const BrandDetailsLoaded(this.brand);

  @override
  List<Object?> get props => [brand];
}

class BrandDetailsError extends BrandDetailsState {
  final String message;

  const BrandDetailsError(this.message);

  @override
  List<Object?> get props => [message];
}
